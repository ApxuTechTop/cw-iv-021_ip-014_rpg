local Gui = require("Gui")
local json = require("json")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

display.setDefault("background", 245 / 255, 245 / 255, 220 / 255);

local game = {settings = {music = true, sounds = true}}

local menu = display.newGroup()
menu.x = cx
menu.y = cy
for key, val in pairs({"Продолжить игру", "Новая игра", "Настройки", "Звуки", "Музыка"}) do
    menu[key] = Gui.createMenuButton(val, 0, (key - 2) * gh / 3, gw / 4, gh / 4, menu)
    menu[key]._view._label.size = gw / 40
end
menu[2]._view._onEvent = function(event)
    if event.phase == "ended" then
        menu.isVisible = false
    end
end
menu[4]:setFillColor(0.1,0.9,0.1)
menu[5]:setFillColor(0.1,0.9,0.1)
menu[3]._view._onEvent = function(event)
    if event.phase == "ended" then
        if not event.target.isPressed then
            event.target.isPressed = true
            transition.moveBy(menu, {y = -gh / 1.5, time = 500, transition = easing.inOutCubic})
        else
            event.target.isPressed = false
            transition.moveBy(menu, {y = gh / 1.5, time = 500, transition = easing.inOutCubic})
        end
    end
end
menu[4]._view._onEvent = function(event)
    if event.phase == "ended" then
        if game.settings.music then
            game.settings.music = false
            menu[4]:setFillColor(0.8,0.1,0.1)
        else
            game.settings.music = true
            menu[4]:setFillColor(0.1,0.9,0.1)
        end
    end
end
menu[5]._view._onEvent = function(event)
    if event.phase == "ended" then
        if game.settings.sounds then
            game.settings.sounds = false
            menu[5]:setFillColor(0.8,0.1,0.1)
        else
            game.settings.sounds = true
            menu[5]:setFillColor(0.1,0.9,0.1)
        end
    end
end
