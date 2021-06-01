local saver = {}
local old_json = require("old_json")

saver._defaultDir = system.DocumentsDirectory

saver.save = function(tab, filename, dir)
    local dir = dir or saver._defaultDir
    local path = system.pathForFile(filename, dir)
    local file, errorString = io.open(path, "w")

    if not file then
        print("File error: " .. errorString)
        return false
    end

    file:write(old_json.encode_ref(tab))
    io.close(file)
    return true

end

saver.load = function(filename, dir)

    local dir = dir or saver._defaultDir
    local path = system.pathForFile(filename, dir)
    local file, errorString = io.open(path, "r")

    if not file then
        print("File error: " .. errorString)
        return false
    end
    local contents = file:read("*a")
    local tab = old_json.decode_ref(contents)
    io.close(file)
    return tab

end

return saver
