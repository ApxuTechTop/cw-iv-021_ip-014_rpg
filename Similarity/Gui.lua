local widget = require("widget")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

local Gui = {}
Gui.interfaceCatalog = "interface/"
Gui.battleActionsCatalog = Gui.interfaceCatalog .. "battleActions/"
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
    buttonBackground = {none = {0.5, 0.5, 0.5}},
    progressBar = {none = {0.5, 0.5, 0.5}}
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

local swiperMeta = {
    __index = {
        add = function(self, object)
            self:insert(object)
            if self.isOpened then
                object.isVisible = true
            else
                object.isVisible = false
                object.x, object.y = 0, 0
            end
        end,
        open = function(self)
            self.isOpened = true
            local dirX = self.direction == "right" and 1 or (self.direction == "left" and -1 or 0)
            local dirY = self.direction == "down" and 1 or (self.direction == "up" and -1 or 0)
            local x = self[1].x
            local y = self[1].y
            x = self.main.x + math.abs(dirX) * self.width * ((1 + dirX) / 2 - self.main.anchorX)
            y = self.main.y + math.abs(dirY) * self.height * ((1 + dirY) / 2 - self.main.anchorY)
            for i = 2, self.numChildren do
                x = x + math.abs(dirX) * self[i - 1].width * ((1 + dirX) / 2 - self.main.anchorX) - dirX *
                        self[i - 1].width * ((1 - dirX) / 2 - self[i].anchorX)
                y = y + math.abs(dirY) * self[i - 1].height * ((1 + dirY) / 2 - self.main.anchorY) - dirY *
                        self[i].height * ((1 - dirY) / 2 - self[i].anchorY)
                x = x + dirX * self.indent
                y = y + dirY * self.indent
                self[i].isVisible = true
                transition.to(self[i], {time = self.time, x = x, y = y, transition = easing.outSine})
            end
        end,
        close = function(self)
            self.isOpened = false
            for i = 2, self.numChildren do
                transition.to(self[i], {
                    time = self.time,
                    x = 0,
                    y = 0,
                    transition = easing.outSine,
                    onComplete = function()
                        self[i].isVisible = false
                    end
                })
            end
        end
    }
}

Gui.createSwiper = function()
    local swiper = display.newGroup()
    for key, val in pairs(swiperMeta.__index) do
        swiper[key] = val
    end
    return swiper
end

local listMeta = {
    __index = {
        add = function(self, object, index)
            local index = index or (#self.objects + 1)
            for i = index, #self.objects do
                transition.to(self.objects[i], {
                    time = self.addTime,
                    y = self.objects[i].y + object.height + self.indent,
                    transition = easing.outSine
                })
            end
            timer.performWithDelay(self.addTime, function()
                object.y =
                    (self.objects[index - 1] and (self.objects[index - 1].y + self.objects[index - 1].height / 2) or 0) +
                        self.indent + object.height / 2
            end)
        end,
        remove = function(self, object)
            local num = object
            if type(object) ~= "number" then
                for i = 1, #self.objects do
                    if self.objects[i] == object then
                        num = i
                        break
                    end
                end
            end
        end
    }
}

Gui.createList = function(options)
    local list = display.newGroup()
    list.x, list.y = options.x or 0, options.y or 0
    if options.background then

    end
    list.indent = options.indent or gw / 50
    list.objects = {}
    for key, value in pairs(listMeta) do
        list[key] = value
    end
    return list
end

Gui.createItemDescription = function()

end

local progressViewMeta = {
    __index = {
        setProgress = function(self, percent)
            self.bar.scaleX = percent
        end,
        getProgress = function(self)
            return self.bar.scaleX
        end
    }
}
Gui.createProgressView = function(options)
    local progressView = display.newGroup()
    if options.parent then
        options.parent:insert(progressView)
    end
    local progressBackground
    if options.bgShape == "rect" then
        progressBackground = display.newRect(progressView, 0, 0, options.width, options.height)
    elseif options.bgShape == "roundedRect" then
        progressBackground = display.newRoundedRect(progressView, 0, 0, options.width, options.height,
                                                    options.bgCornerRadius or options.height / 10)
    end
    progressBackground.anchorX, progressBackground.anchorY = options.isRight and 1 or 0, 0
    local progressBar
    options.barWidth = options.barWidth or options.width
    options.barHeight = options.barHeight or options.height
    if options.barShape == "rect" then
        progressBar = display.newRect(progressView, 0, 0, options.width, options.height)
    elseif options.barShape == "roundedRect" then
        progressBar = display.newRoundedRect(progressView, 0, 0, options.barWidth, options.barHeight,
                                             options.barCornerRadius or options.height / 10)
    end
    progressBar.fill = options.fill or Gui.color.progressBar
    progressBar.anchorX, progressBar.anchorY = options.isRight and 1 or 0, 0.5
    progressBar.x = (options.width - options.barWidth) / 2 * (options.isRight and -1 or 1)
    progressBar.y = options.height / 2

    progressView.bar = progressBar
    progressView.bg = progressBackground
    for key, value in pairs(progressViewMeta.__index) do
        progressView[key] = value
    end
    return progressView
end

Gui.displayBattle = function(battle)
    battle.graphics.scene = display.newGroup()
    battle.graphics.battleActions = display.newGroup()
    battle.graphics.scene:insert(battle.graphics.battleActions)
    local background = display.newRect(battle.graphics.scene, 0, 0, gw, gh)
    background.anchorX, background.anchorY = 0, 0
    local leftBars = Gui.createList()
    local rightBars = Gui.createList()
    local playerSide
    for _, k in pairs("left", "right") do
        for _, entity in pairs(battle[k]) do
            if entity == battle.position.loc.world.players[1] then
                playerSide = k
                break
            end
        end
    end
    local barWidth = gw / 4
    local barHeight = gh / 10
    for _, entity in pairs(battle[playerSide]) do
        entity.graphics.hpbar = Gui.createProgressView {
            parent = leftBars,
            bgShape = "roundedRect",
            barShape = "roundedRect",
            width = barWidth,
            height = barHeight
        }
    end
    for _, entity in pairs(battle[playerSide == "left" and "right" or "left"]) do
        entity.graphics.hpbar = Gui.createProgressView {
            parent = rightBars,
            bgShape = "roundedRect",
            barShape = "roundedRect",
            width = barWidth,
            height = barHeight,
            isRight = true
        }
    end
end
local battleActionSize = gh / 10
Gui.displayBattleAction = function(battleAction)
    local image = display.newImageRect(battleAction.me.battle.graphics.battleActions,
                                       Gui.battleActionsCatalog .. battleAction.type .. ".png",
                                       system.ResourceDirectory, battleActionSize, battleActionSize)
    battleAction.graphics = image
    image:addEventListener("tap", function()
        battleAction:event()
        image:removeEventListener("tap")
        image:removeSelf()
        battleAction.me.battleBuffer:remove(battleAction)
    end)
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

Gui.createInventory = function()
    local inventory = display.newGroup()
    inventory.background = display.newRect(inventory, 0, 0, gw, gh)
    inventory.background.alpha = 0.6
    inventory.background:setFillColor(0.2, 0.2, 0.2)
    inventory.list = widget.newScrollView()
    inventory.info = display.newGroup()
    inventory.info.background = display.newRect(inventory.info, 0, 0, gw / 3, gh)
    local fontSize = gw / 100
    inventory.info.name = display.newText {
        parent = inventory.info,
        text = "Name",
        font = native.systemFont,
        fontSize = fontSize * 1.2
    }
    inventory.info.desc = display.newText {
        parent = inventory.info,
        text = "Desc",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.count = display.newText {
        parent = inventory.info,
        text = "1",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.rarity = display.newText {
        parent = inventory.info,
        text = "Epic",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.durability = display.newText {
        parent = inventory.info,
        text = "Прочность: 80/80",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.critChance = display.newText {
        parent = inventory.info,
        text = "Шанс критической атаки: 11%",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.critDamage = display.newText {
        parent = inventory.info,
        text = "Критический урон: x1.5",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.accuracy = display.newText {
        parent = inventory.info,
        text = "Точность оружия: 1.1",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.attackSpeed = display.newText {
        parent = inventory.info,
        text = "Скорость атаки: 2",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.damage = display.newText {
        parent = inventory.info,
        text = "Урон: 5",
        font = native.systemFont,
        fontSize = fontSize
    }
    inventory.info.armor = display.newText {
        parent = inventory.info,
        text = "Защита: 3",
        font = native.systemFont,
        fontSize = fontSize
    }

    return inventory
end

Gui.createInterface = function(world)
    local player = world.players[1]
    local location = player.position.loc
    local interface = {}
    interface.group = display.newGroup()
    local indent = gh / 60
    interface.swiper = Gui.createSwiper() --
    local size = gh / 5
    interface.buttons = {}
    interface.buttons.inventory = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "inventory_button.png"
    } --
    interface.buttons.inventory.onRelease = Gui.openInventory() --
    interface.swiper:add(interface.buttons.inventory)
    interface.buttons.quests = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "quests_button.png"
    } --
    interface.swiper:add(interface.buttons.quests)

    interface.buttons.reputation = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "reputation_button.png"
    } --
    interface.swiper:add(interface.buttons.reputation)

    interface.buttons.settings = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "settings_button.png"
    } --
    interface.swiper:add(interface.buttons.settings)

    local locationGraphics = display.newGroup()
    locationGraphics = display.newGroup()
    locationGraphics.x, locationGraphics.y = -gw / 2, 0
    locationGraphics.background = display.newRect(locationGraphics, 0, 0, gw / 2, gh)
    locationGraphics.background.anchorX, locationGraphics.background.anchorY = 0, 0

    locationGraphics.name = display.newText {
        parent = locationGraphics,
        x = size + indent * 2,
        y = indent,
        text = location.name
    }
    locationGraphics.desc = display.newText {
        parent = locationGraphics,
        x = indent,
        y = size + 2 * indent,
        text = location:desc()
    }
    locationGraphics.minimap = display.newContainer(locationGraphics, locationGraphics.background.width / 2,
                                                    locationGraphics.background.width / 2)
    local minimapBackground = display.newRect(locationGraphics.minimap, 0, 0, locationGraphics.background.width / 2,
                                              locationGraphics.background.width / 2)
    minimapBackground:setFillColor(0.5, 0.5, 0.5)
    minimapBackground.anchorX, minimapBackground.anchorY = 0, 0

    interface.buttons.location = Gui.createButton {
        width = size,
        height = size,
        image = Gui.interfaceCatalog .. "triangle.png"
    } --
    interface.buttons.location:rotate(-90)
    interface.buttons.location.onRelease = function()

    end
    return interface
end

return Gui
