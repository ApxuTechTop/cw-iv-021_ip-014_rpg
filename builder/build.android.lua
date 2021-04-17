local getenv = function(name)
    os.execute("echo %" .. name .. "% > tmp.txt")
    local f = io.open("tmp.txt", "r")
    local value = f:read("*l")
    io.close(f)
    os.remove("tmp.txt")
    return string.match(value, ".+[^ ]")
end
local cwd = getenv("CD")
local sdk = getenv("ANDROID_SDK_ROOT")
local params = {
    platform = 'Android',
    appName = 'Similarity',
    appVersion = '1.0',
    dstPath = cwd .. '/bin',
    sdkPath = sdk,
    projectPath = cwd .. '/Similarity',
    androidAppPackage = 'com.coronalabs.Similarity'

    -- Following are optional:
    --[[
	certificatePath='/path/to/cert.keystore',
	keystorePassword='',
	keystoreAlias='',
	keystoreAliasPassword='',
	androidVersionCode=1,
	--]]
}
return params
