local widget = require("widget")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

local Gui = {}
Gui.interfaceCatalog = "interface\\"

local options = {
    frames = {
        {x = 0, y = 0, width = 23, height = 23}, {x = 23, y = 0, width = 210, height = 23},
        {x = 233, y = 0, width = 23, height = 23}, {x = 0, y = 23, width = 23, height = 82},
        {x = 23, y = 23, width = 210, height = 82}, {x = 233, y = 23, width = 23, height = 82},
        {x = 0, y = 105, width = 23, height = 23}, {x = 23, y = 105, width = 210, height = 23},
        {x = 233, y = 105, width = 23, height = 23}, {x = 256, y = 0, width = 23, height = 23},
        {x = 279, y = 0, width = 210, height = 23}, {x = 489, y = 0, width = 23, height = 23},
        {x = 256, y = 23, width = 23, height = 82}, {x = 279, y = 23, width = 210, height = 82},
        {x = 489, y = 23, width = 23, height = 82}, {x = 256, y = 105, width = 23, height = 23},
        {x = 279, y = 105, width = 210, height = 23}, {x = 489, y = 105, width = 23, height = 23}
    },
    sheetContentWidth = 512,
    sheetContentHeight = 128
}
local menu_button_sheet = graphics.newImageSheet(Gui.interfaceCatalog .. "menu-button-9slice.png", options)

Gui.createMenuButton = function(name, x, y, width, height, parent, listener)
    local button = widget.newButton({
        x = x,
        y = y,
        label = name,
        onEvent = listener,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = width,
        height = height,
        cornerRadius = width / 15,
        fillColor = {default = {219 / 255, 124 / 255, 29 / 255, 1}, over = {219 / 255, 124 / 255, 29 / 255, 0.5}},
        strokeColor = {default = {0.2, 0.2, 0, 1}, over = {0.2, 0.2, 0, 1}},
        strokeWidth = width / 40,
        labelColor = {default = {0, 0, 0}, over = {0, 0, 0}}
    })
    if parent then
        parent:insert(button)
    end
    return button
end

return Gui
