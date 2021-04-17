local widget = require("widget")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

local Gui = {}
Gui.interfaceCatalog = "interface/"
Gui.masksCatalog = "masks/"

--[=[
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
--]=]

Gui.color = {
    iconFrame = {
        path = {127 / 255, 247 / 255, 103 / 255},
        entity = {247 / 255, 184 / 255, 103 / 255},
        battle = {247 / 255, 103 / 255, 103 / 255},
        stroke = {117 / 255, 59 / 255, 2 / 255},
        none = {}
    },
    buttonBackground = {none = {}}
}

local buttonMeta = {
    __index = {
        tap = function(self, event)
            if event.time - (self.time or 0) < system.tapDelay then
                if self.onDoubleTap then
                    self:onDoubleTap(event.x, event.y)
                end
            end
            self.background.fill = self.defaultColor or self.background.fill
            self.time = event.time
        end,
        touch = function(self, event)
            local ignore
            if self.onEvent then
                return self:onEvent(event)
            end
            if event.phase == "moved" then
                if self.isTouched and self.overColor then
                    local x, y = self:localToContent(0, 0)
                    if math.abs(event.x - x) < self.width / 2 and math.abs(event.y - y) < self.height / 2 then
                        self.background.fill = self.overColor
                    else
                        self.background.fill = self.defaultColor
                    end
                end
                if self.onTouch then
                    ignore = self:onTouch()
                end
            elseif event.phase == "began" then
                self.isTouched = true
                display.getCurrentStage():setFocus(self)
                self.background.fill = self.overColor or self.background.fill
                if self.onPress then
                    ignore = self:onPress()
                end
            elseif event.phase == "ended" then
                if self.onRelease and self.isTouched then
                    local x, y = self:localToContent(0, 0)
                    if math.abs(event.x - x) < self.width / 2 and math.abs(event.y - y) < self.height / 2 then
                        ignore = self:onRelease()
                    end
                end
                self.isTouched = nil
                self.background.fill = self.defaultColor
                display.getCurrentStage():setFocus(nil)
                -- elseif event.phase == "cancelled" then
            end
            return ignore
        end,
        setDefaultColor = function(self, color)
            self.defaultColor = color
            if not self.isTouched then
                self.background.fill = color
            end
        end,
        setOverColor = function(self, color)
            self.overColor = color
            if self.isTouched then
                self.background.fill = color
            end
        end,
        setBackgroundSize = function(self, width, height)
            self.background.width, self.background.height = width, height
        end,
        setImage = function(self, imageName, width, height)
            self.image = display.newImageRect(self, imageName, system.ResourceDirectory, width, height)
        end

    }
}
Gui.createButton = function(options)
    local button = display.newGroup()
    if options.parent then
        options.parent:insert(button)
    end
    button.x, button.y = options.x, options.y
    if not options.noBackground then
        button.background = display.newRoundedRect(button, 0, 0, options.width, options.height,
                                                   options.cornerRadius or options.width * 0.05)
        button.defaultColor = options.defaultColor or Gui.color.buttonBackground.none
        button.overColor = options.overColor
        button.background.fill = button.defaultColor
    end

    if options.text then
        button.text = display.newText {
            parent = button,
            text = options.text,
            x = 0,
            y = 0,
            width = options.width * 0.9,
            font = options.font or native.systemFont,
            fontSize = options.width * 0.1,
            align = options.align or "center"
        }
    end
    if options.image then
        button.image = display.newImageRect(button, options.image, system.ResourceDirectory, options.width,
                                            options.height)
    end
    button.onPress = options.onPress
    button.onTouch = options.onTouch
    button.onRelease = options.onRelease
    button.onDoubleTap = options.onDoubleTap
    button.onEvent = options.onEvent

    for key, value in pairs(buttonMeta.__index) do
        button[key] = value
    end
    if not options.noListeners then
        button:addEventListener("touch", button)
        button:addEventListener("tap", button)
    end
    
    return button
end

Gui.circlemask = graphics.newMask("circle_mask.png", system.ResourceDirectory)

Gui.default = {
    iconImage = { -- make images
        path = "",
        entity = "",
        battle = "",
        none = ""
    }
}

Gui.createIcon = function(what, name)
    local what = what or "none"
    local name = name or Gui.default.iconImage[what]
    local icon = display.newGroup()
    local size = gh / 5.5
    icon.frame = display.newCircle(icon, 0, 0, size * 1.15)
    icon.frame.fill = Gui.color.iconFrame[what]
    icon.strokeWidth = icon.frame.width / 125
    icon.strokeColor = Gui.color.iconFrame.stroke
    icon.image = display.newImageRect(icon, name, system.ResourceDirectory, size, size)
    icon.image:setMask(Gui.circlemask)
    return icon
end

local swiperMeta = {__index = {}}
Gui.createSwiper = function()

end

Gui.createItemDescription = function()

end

local locationMeta = {__index = {}}

local iconMeta = {
    __index = {
        translate = function(self, options)
            local key = options.key
            options.key = nil
            if key == "instant" then
                self.group.x, self.group.y = options.x, options.y
            end
            transition[key](self.group, options)
        end
    }
}

Gui.displayLocation = function(location)
    local location = location
    location.graphics = {}
    local lgraphics = location.graphics
    setmetatable(lgraphics, locationMeta)
    lgraphics.group = display.newGroup()
    if location.texture then
        lgraphics.texture = location.texture()
    else
        lgraphics.texture = display.newRect(0, 0, location.width, location.height)
    end
    lgraphics.group:insert(lgraphics.texture)
    for key, path in ipairs(location.path) do
        path.graphics = {icon = Gui.createIcon("path")}
        lgraphics.group:insert(path.graphics.icon)
    end
    for key, battle in ipairs(location.battles) do
        battle.graphics = {icon = Gui.createIcon("battle")}
        lgraphics.group:insert(battle.graphics.icon)
    end
    for key, entity in ipairs(location.entities) do
        entity.graphics = {icon = Gui.createIcon("entity")}
        lgraphics.group:insert(battle.graphics.icon)
    end
    return lgraphics
end

Gui.displayWorld = function(world)
    world.graphics = {}
    world.graphics.scroll = widget.newScrollView({top = 0, left = 0, width = gw, height = gh, isBounceEnabled = false})
    local player = world.players[1]
    local location = player.position.loc
    world.graphics.scroll:insert(Gui.displayLocation(location).group)
    for key, path in pairs(location.path) do
        world.graphics.scroll:insert(Gui.displayLocation(val.loc).group)
    end
end

Gui.openInventory = function()

end
Gui.closeInventory = function()

end

Gui.createInterface = function()
    local interface = {}
    interface.group = display.newGroup()
    interface.swiper = Gui.createSwiper() --
    local size = gh / 5
    local inventoryButton = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "inventory_button.png"
    } --
    inventoryButton.onRelease = Gui.openInventory() --
    local questsButton = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "quests_button.png"
    } --

    local reputationButton = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "reputation_button.png"
    } --

    local settingsButton = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "settings_button.png"
    } --

    local locationMenu = display.newGroup()

    local locationButton = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "triangle.png"
    } --
    locationButton:rotate(-90)
    locationButton.onRelease = function()

    end
    return interface
end

return Gui
