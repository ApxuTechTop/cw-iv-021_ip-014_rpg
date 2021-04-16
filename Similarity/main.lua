local Gui = require("Gui")
local json = require("json")
local widget = require("widget")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

system.tapDelay = 350

display.setDefault("background", 245 / 255, 245 / 255, 220 / 255);

local game = {settings = {music = true, sounds = true}}

local menu = display.newGroup()
menu.x = cx
menu.y = cy
for key, val in pairs({
    "Продолжить игру", "Новая игра", "Настройки", "Звуки", "Музыка"
}) do
    menu[key] = Gui.createButton {
        parent = menu,
        x = 0,
        y = (key - 2) * gh / 3,
        width = gw / 4,
        height = gh / 4,
        text = val,
        defaultColor = {219 / 255, 124 / 255, 29 / 255},
        overColor = {219 / 255, 124 / 255, 29 / 255, 0.6},
        cornerRadius = gw / 40
    }
end

local function startGame(self)
    self.isVisible = false
    --

end
menu[2].onRelease = startGame

menu[4]:setDefaultColor{0.1, 0.9, 0.1}
menu[5]:setDefaultColor{0.1, 0.9, 0.1}
menu[3].onRelease = function(self)
    if not self.isPressed then
        self.isPressed = true
        transition.to(menu, {y = cy - gh / 1.5, time = 500, transition = easing.inOutCubic})
    else
        self.isPressed = false
        transition.to(menu, {y = cy, time = 500, transition = easing.inOutCubic})
    end
end

menu[4].onRelease = function(self)
    if game.settings.music then
        game.settings.music = false
        self.defaultColor = {0.8, 0.1, 0.1}
    else
        game.settings.music = true
        self.defaultColor = {0.1, 0.9, 0.1}
    end
end
menu[5].onRelease = function(self)
    if game.settings.sounds then
        game.settings.sounds = false
        self.defaultColor = {0.8, 0.1, 0.1}
    else
        game.settings.sounds = true
        self.defaultColor = {0.1, 0.9, 0.1}
    end
end
