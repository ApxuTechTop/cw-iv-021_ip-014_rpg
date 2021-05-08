local widget = require("widget")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

display.setDefault("background", 245 / 255, 245 / 255, 220 / 255)

local Gui = {}
Gui.settings = {
    catalogs = {interface = "interface/", masks = "masks/"},
    colors = {
        iconFrame = {
            path = {127 / 255, 247 / 255, 103 / 255},
            entity = {247 / 255, 184 / 255, 103 / 255},
            battle = {247 / 255, 103 / 255, 103 / 255},
            stroke = {117 / 255, 59 / 255, 2 / 255},
            none = {0.5, 0.5, 0.5}
        },
        battleBackground = {display.getDefault("background")}
    },
    sizes = {
        battle = {barWidth = gw / 6, barHeight = gh / 20, actionSize = gh / 10},
        itemInfoFontSize = gw / 50,
        slotListIndent = gh / 80,
        slotListWidth = gw / 3,
        slotButtonCornerRadius = gh / 70,
        equipmentListIndent = gh / 100,
        equipmentButtonSize = gh / 6.5,
        inGameMenuButtonWidth = gh / 5.5,
        inGameMenuButtonHeight = gh / 5.5
    },
    masks = {}
}
Gui.settings.catalogs.battleActionsImages = Gui.settings.catalogs.interface .. "battleActions/"
Gui.settings.catalogs.equipment = Gui.settings.catalogs.interface .. "equipment/"
do
    local edir = Gui.settings.catalogs.equipment
    Gui.settings.images = {
        equipment = {
            head = edir .. "helmet.png",
            chest = edir .. "chestplate.png",
            legs = edir .. "pants.png",
            foots = edir .. "boots.png"
        }
    }
end

Gui.settings.sizes.icon = gh / 13
Gui.settings.sizes.iconFrameWidth = Gui.settings.sizes.icon * 1.15
Gui.settings.sizes.iconFrameStrokeWidth = Gui.settings.sizes.icon / 20

Gui.settings.masks.cirlce = {
    mask = graphics.newMask(Gui.settings.catalogs.masks .. "circle_mask.png", system.ResourceDirectory),
    width = 512,
    height = 512
}

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
            local ignore
            if event.time - (self.time or 0) < system.tapDelay then
                if self.onDoubleTap then
                    ignore = self:onDoubleTap(event.x, event.y)
                end
            else
                if self.onTap then
                    ignore = self:onTap(event)
                end
            end
            self.background.fill = self.defaultColor or self.background.fill
            self.time = event.time
            return ignore
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
        options.cornerRadius = options.cornerRadius or 0
        button.background = display.newRoundedRect(button, 0, 0, options.width, options.height, options.cornerRadius)
        button.defaultColor = options.defaultColor or Gui.color.buttonBackground.none
        button.overColor = options.overColor or button.defaultColor
        button.background.fill = button.defaultColor
        if options.stroke then
            button.background.stroke = options.stroke.color
            button.background.strokeWidth = options.stroke.width
        end
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
        button.image = display.newImageRect(button, options.image, system.ResourceDirectory,
                                            options.imageWidth or options.width, options.imageHeight or options.height)
    end
    button.onPress = options.onPress
    button.onTouch = options.onTouch
    button.onRelease = options.onRelease
    button.onTap = options.onTap
    button.onDoubleTap = options.onDoubleTap
    button.onEvent = options.onEvent

    for key, value in pairs(buttonMeta.__index) do
        button[key] = value
    end
    if not options.noListeners then
        if not options.disableTouch then
            button:addEventListener("touch", button)
        end
        if not options.disableTap then
            button:addEventListener("tap", button)
        end
    end

    return button
end

Gui.default = {
    iconImage = { -- make images
        path = "Icon.png",
        entity = "Icon.png",
        battle = "Icon.png",
        none = "Icon.png"
    }
}

local swiperMeta = {
    __index = {
        add = function(self, object)
            self:insert(object)
            self.main:toFront()
            if self.isOpened then
                object.isVisible = true
            else
                object.isVisible = false
                object.x, object.y = 0, 0
            end
        end,
        open = function(self, time)
            self.isOpened = true
            local dirX = self.direction == "right" and 1 or (self.direction == "left" and -1 or 0)
            local dirY = self.direction == "down" and 1 or (self.direction == "up" and -1 or 0)
            local x = self[1].x
            local y = self[1].y
            x = self.main.x + math.abs(dirX) * self.main.width * ((1 + dirX) / 2 - self.main.anchorX)
            y = self.main.y + math.abs(dirY) * self.main.height * ((1 + dirY) / 2 - self.main.anchorY)
            for i = 1, self.numChildren - 1 do
                x = x + dirX * self.indent
                y = y + dirY * self.indent
                x = x - dirX * self[i].width * ((1 - dirX) / 2 - self[i].anchorX)
                y = y - dirY * self[i].height * ((1 - dirY) / 2 - self[i].anchorY)
                self[i].isVisible = true
                transition.to(self[i], {time = time or self.time, x = x, y = y, transition = easing.outSine})
                x = x + math.abs(dirX) * self[i].width * ((1 + dirX) / 2 - self[i].anchorX)
                y = y + math.abs(dirY) * self[i].height * ((1 + dirY) / 2 - self[i].anchorY)
            end
        end,
        close = function(self, time)
            self.isOpened = false
            for i = 1, self.numChildren - 1 do
                transition.to(self[i], {
                    time = time or self.time,
                    x = 0,
                    y = 0,
                    transition = easing.outSine,
                    onComplete = function()
                        self[i].isVisible = false
                    end
                })
            end
        end,
        activate = function(self, time)
            if self.isOpened then
                self:close(time)
            else
                self:open(time)
            end
        end
    }
}

Gui.createSwiper = function(options)
    local swiper = display.newGroup()
    swiper.main = options.main
    swiper.indent = options.indent or 0
    swiper.time = options.time or 500
    swiper.direction = options.direction or "down"
    for key, val in pairs(swiperMeta.__index) do
        swiper[key] = val
    end
    return swiper
end

local listMeta = {
    __index = {
        add = function(self, object, index)
            self:insert(object)
            local index = index or (#self.objects + 1)
            for i = #self.objects, index, -1 do
                transition.to(self.objects[i], {
                    time = self.time,
                    y = self.objects[i].y + object.height + self.indent,
                    transition = easing.outSine
                })
                self.objects[i + 1] = self.objects[i]
            end
            self.objects[index] = object
            local prev = self.objects[index - 1]
            object.y = (prev and (prev.y + prev.height * (1 - prev.anchorY)) or 0) + self.indent + object.height *
                           object.anchorY
        end,
        find = function(self, object)
            local num = object
            if type(object) ~= "number" then
                for i = 1, #self.objects do
                    if self.objects[i] == object then
                        num = i
                        break
                    end
                end
            end
            return num
        end,
        remove = function(self, object)
            local num = self:find(object)
            local height = self.objects[num].height + self.indent
            display.getCurrentStage():insert(self.objects[num])
            table.remove(self.objects, num)
            for i = num, #self.objects do
                transition.to(self.objects[i],
                              {time = self.time, y = self.objects[i].y - height, transition = easing.outSine})
            end
            return num
        end,
        hide = function(self, object)
            local num = self:find(object)
            self.objects[num].isVisible = false
            local height = self.objects[num].height + self.indent
            for i = num + 1, #self.objects do
                transition.to(self.objects[i],
                              {time = self.time, y = self.objects[i].y - height, transition = easing.outSine})
            end
            return num
        end,
        show = function(self, object)
            local num = self:find(object)
            self.objects[num].isVisible = true
            local height = self.objects[num].height + self.indent
            for i = num + 1, #self.objects do
                transition.to(self.objects[i],
                              {time = self.time, y = self.objects[i].y + height, transition = easing.outSine})
            end
            return num
        end
    }
}

Gui.createList = function(options)
    local list = display.newGroup()
    list.x, list.y = options.x or 0, options.y or 0
    if options.background then
        list.background = display.newRect(0, 0, options.width, options.height)
        if options.fill then
            list.background:setFillColor(unpack(options.fill))
        end
    end
    list.indent = options.indent or gw / 50
    list.time = options.time or 0
    list.objects = {}
    for key, value in pairs(listMeta.__index) do
        list[key] = value
    end
    return list
end

Gui.createItemDescription = function()

end

local scrollViewMeta = {
    __index = {
        add = function(self, object)
            self.objectsGroup:insert(object)
        end
    },
    backgroundTouch = function(self, event)
        if event.phase == "moved" or event.phase == "began" then
            display.getCurrentStage():setFocus(self)
            self.isFocus = true
            local scroll = self.parent
            local objectsGroup = scroll.objectsGroup
            local bounds = objectsGroup.contentBounds
            if not scroll.horizontalScrollDisabled then
                self.xStart = self.xStart or objectsGroup.x
                local posX = self.xStart + event.x - event.xStart
                local dxr = objectsGroup.x - bounds.xMax + scroll.scrollWidth + scroll.xMaxOffset
                local dxl = objectsGroup.x - bounds.xMin + scroll.xMinOffset
                posX = math.max(dxr, posX)
                posX = math.min(dxl, posX)
                objectsGroup.x = posX
            end
            if not scroll.verticalScrollDisabled then
                self.yStart = self.yStart or objectsGroup.y
                local posY = self.yStart + event.y - event.yStart
                local dyr = objectsGroup.y - bounds.yMax + scroll.scrollHeight + scroll.yMaxOffset
                local dyl = objectsGroup.y - bounds.yMin + scroll.yMinOffset
                posY = math.max(dyr, posY)
                posY = math.min(dyl, posY)
                objectsGroup.y = posY
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            self.isFocus = false
            self.xStart, self.yStart = nil
        end
        return true
    end
}

Gui.createScrollView = function(options)
    local scroll
    if options.isMasked then
        scroll = display.newContainer(options.width, options.height)
    else
        scroll = display.newGroup()
    end
    scroll.x = options.x or 0
    scroll.y = options.y or 0
    scroll.scrollWidth = options.scrollWidth or options.width
    scroll.scrollHeight = options.scrollHeight or options.height
    scroll.horizontalScrollDisabled = options.horizontalScrollDisabled
    scroll.verticalScrollDisabled = options.verticalScrollDisabled
    scroll.xMaxOffset = options.xMaxOffset or 0
    scroll.xMinOffset = options.xMinOffset or 0
    scroll.yMaxOffset = options.yMaxOffset or 0
    scroll.yMinOffset = options.yMinOffset or 0
    scroll.background = display.newRect(scroll, 0, 0, options.width, options.height)
    scroll.background.fill = options.backgroundColor or {display.getDefault("background")}
    scroll.background.anchorX, scroll.background.anchorY = 0, 0
    scroll.background.alpha = options.alpha or 1
    scroll.background.touch = scrollViewMeta.backgroundTouch
    scroll.background:addEventListener("touch", scroll.background)
    scroll.objectsGroup = display.newGroup()
    for key, val in pairs(scrollViewMeta.__index) do
        scroll[key] = val
    end
    scroll:insert(scroll.objectsGroup)

    return scroll
end

local progressViewMeta = {
    __index = {
        setProgress = function(self, percent)
            if percent == 0 then
                self.bar.isVisible = false
                return
            end
            self.bar.isVisible = true
            self.bar.xScale = percent
        end,
        getProgress = function(self)
            return self.bar.xScale
        end
    }
}
Gui.createProgressView = function(options)
    local progressView = display.newGroup()
    progressView.x = options.x or 0
    progressView.y = options.y or 0
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
    progressBackground.fill = options.bgFill or {1, 1, 1}
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

Gui.createIcon = function(what, name)
    local what = what or "none"
    local name = name or Gui.default.iconImage[what]
    local icon = display.newGroup()
    local size = Gui.settings.sizes.icon
    icon.frame = display.newCircle(icon, 0, 0, Gui.settings.sizes.iconFrameWidth)
    icon.frame:setFillColor(unpack(Gui.settings.colors.iconFrame[what]))
    icon.frame.strokeWidth = Gui.settings.sizes.iconFrameStrokeWidth
    icon.frame.stroke = Gui.settings.colors.iconFrame.stroke
    icon.image = display.newImageRect(icon, name, system.ResourceDirectory, 2 * size, 2 * size)
    local circlemask = Gui.settings.masks.cirlce
    icon.image:setMask(circlemask.mask)
    icon.image.maskScaleX = size * 2 / circlemask.width
    icon.image.maskScaleY = size * 2 / circlemask.height
    return icon
end

Gui.displayBattle = function(battle)
    local scene = display.newGroup()
    battle.graphics = battle.graphics or {}
    battle.graphics.scene = scene
    local background = display.newRect(scene, 0, 0, gw, gh)
    local bActionsGroup = display.newGroup()
    battle.graphics.battleActions = bActionsGroup
    scene:insert(bActionsGroup)
    background.anchorX, background.anchorY = 0, 0
    background:setFillColor(unpack(Gui.settings.colors.battleBackground))
    background:addEventListener("tap", function()
        return true
    end)
    background:addEventListener("touch", function()
        return true
    end)
    local leftBars = Gui.createList {indent = gh / 100}
    local indent = gw / 100
    leftBars.x = indent
    local rightBars = Gui.createList {indent = gh / 100}
    rightBars.x = gw - indent
    scene.leftBars = leftBars
    scene.rightBars = rightBars
    scene:insert(leftBars)
    scene:insert(rightBars)
    local playerSide
    for _, k in pairs {"left", "right"} do
        for _, entity in pairs(battle[k]) do
            if entity == battle.position.loc.world.players[1] then
                playerSide = k
                break
            end
        end
    end
    scene[playerSide] = "leftBars"
    scene[playerSide == "left" and "right" or "left"] = "rightBars"
    local barWidth = Gui.settings.sizes.battle.barWidth
    local barHeight = Gui.settings.sizes.battle.barHeight
    for _, entity in pairs(battle[playerSide]) do
        entity.graphics = entity.graphics or {}
        entity.graphics.hpbar = Gui.createProgressView {
            bgShape = "roundedRect",
            barShape = "roundedRect",
            fill = {1, 0, 0},
            width = barWidth,
            height = barHeight
        }
        entity.graphics.hpbar:setProgress(entity.health / entity.healthmax)
        leftBars:add(entity.graphics.hpbar)
    end
    for _, entity in pairs(battle[playerSide == "left" and "right" or "left"]) do
        entity.graphics = entity.graphics or {}
        entity.graphics.hpbar = Gui.createProgressView {
            parent = rightBars,
            bgShape = "roundedRect",
            barShape = "roundedRect",
            width = barWidth,
            height = barHeight,
            fill = {1, 0, 0},
            isRight = true,
            x = 0
        }
        entity.graphics.hpbar:setProgress(entity.health / entity.healthmax)
        rightBars:add(entity.graphics.hpbar)
    end
end

Gui.displayBattleAction = function(battleAction)
    local battleActionSize = Gui.settings.sizes.battle.actionSize
    local image = display.newImageRect(battleAction.me.battle.graphics.battleActions,
                                       Gui.settings.catalogs.battleActionsImages .. battleAction.type .. ".png",
                                       system.ResourceDirectory, battleActionSize, battleActionSize)
    battleAction.graphics = image
    image.x = math.random(gw)
    image.y = math.random(gh)
    image:addEventListener("touch", function(event)
        if event.phase == "began" then
            battleAction:event()
            image:removeSelf()
            battleAction.me.battleBuffer:remove(battleAction)
        end
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

Gui.displayBattleIcon = function(battle)
    battle.graphics = {icon = Gui.createIcon("battle")}
    battle.graphics.icon:translate(battle.position.x, battle.position.y)
    return battle.graphics.icon
end

Gui.displayEntity = function(entity)
    local icon = Gui.createIcon("entity")
    entity.graphics = {icon = icon}
    icon:translate(entity.position.x, entity.position.y)
    icon.text = display.newText {
        parent = icon,
        y = -icon.frame.path.radius * 1.05,
        text = (entity.surname and (entity.surname .. " ") or "") .. entity.name,
        align = "center",
        font = native.systemFont,
        fontSize = icon.frame.path.radius / 2
    }
    icon.text.anchorY = 1
    icon:addEventListener("tap", function(event)
        if event.time - (event.target.time or 0) < system.tapDelay then
            local player = entity.position.loc.world.players[1]
            player:move({x = event.target.x, y = event.target.y}, function()
                local battle = entity.position.loc:newBattle{
                    left = {},
                    right = {},
                    position = {loc = entity.position.loc, x = entity.position.x, y = entity.position.y}
                }
                battle:addEntity(player, "left")
                battle:addEntity(entity, "right")
                
                battle:run()
            end)
        end
        event.target.time = event.time
        return true
    end)
    return icon
end

Gui.displayLocation = function(location)
    local location = location
    location.graphics = {}
    local lgraphics = location.graphics
    local group = display.newGroup()
    lgraphics.group = group
    local texture
    if location.texture then
        texture = location:texture()
    else
        texture = display.newRect(0, 0, location.width, location.height)
        texture:setFillColor(0.6, 0.5, 0.3)
        texture.anchorX, texture.anchorY = 0, 0
    end
    texture:addEventListener("tap", function(event)
        local posX, posY = event.target:contentToLocal(event.x, event.y)
        posX, posY = posX + event.target.width / 2, posY + event.target.height / 2
        location.world.players[1]:move{x = posX, y = posY}
    end)
    group:insert(texture)
    lgraphics.texture = texture

    for key, path in ipairs(location.path) do
        path.graphics = {icon = Gui.createIcon("path")}
        path.graphics.icon:translate(path.position.x, path.position.y)
        group:insert(path.graphics.icon)
    end
    for key, battle in ipairs(location.battles) do

        group:insert(Gui.displayBattleIcon(battle))
    end
    for key, entity in ipairs(location.entities) do
        group:insert(Gui.displayEntity(entity))
    end
    return lgraphics
end

Gui.displayWorld = function(world)
    world.graphics = {}
    local offset = gw / 10
    world.graphics.scroll = Gui.createScrollView({
        x = 0,
        y = 0,
        width = gw,
        height = gh,
        xMaxOffset = -offset,
        xMinOffset = offset,
        yMaxOffset = -offset,
        yMinOffset = offset,
        scrollWidth = gw,
        scrollHeight = gh
    })
    local player = world.players[1]
    local location = player.position.loc
    world.graphics.scroll:add(Gui.displayLocation(location).group)
    --[[
    for key, path in pairs(location.path) do
        world.graphics.scroll:insert(Gui.displayLocation(val.loc).group)
    end
    ]]
end

Gui.openInventory = function()
    Gui.inventory.isVisible = true
end
Gui.closeInventory = function()
    Gui.inventory.isVisible = false
end

Gui.updateItemInfo = function(item)
    local info = Gui.inventory.info
    info.name.text = item.name
    info.desc.text = item.desc
    local num = info.list:remove(info.rarity)
    info.rarity:removeSelf()
    local fontSize = Gui.settings.sizes.itemInfoFontSize
    local x = -info.background.width + gw / 200
    info.rarity = display.newColorText {
        parent = info.list,
        text = "Качество: <#(0, ff, 0), [48], (0, 0, ff)>" .. item.tags[1],
        font = native.systemFont,
        fontSize = fontSize,
        x = x,
        y = y
    }
    info.rarity.anchorX = 0
    info.rarity.anchorY = 0
    info.list:add(info.rarity, num)
    --info.list:hide(info.desc)
    --info.list:show(info.desc)
    info.durability.text = "Прочность: " .. item.durability ..
                               (rawget(item, "durabilitymax") and "/" .. item.durabilitymax or "")
end

Gui.createInventory = function(world)
    local inventory = display.newGroup()
    do
        local background = display.newRect(inventory, 0, 0, gw, gh)
        inventory.background = background
        background.alpha = 0.6
        background:setFillColor(0.2, 0.2, 0.2)
        background.anchorX = 0
        background.anchorY = 0
        background:addEventListener("tap", function()
            return true
        end)
    end
    do
        local equipment = Gui.createList {indent = Gui.settings.sizes.equipmentListIndent}
        inventory:insert(equipment)
        inventory.equipment = equipment
        local x = Gui.settings.sizes.equipmentButtonSize / 2 + Gui.settings.sizes.equipmentListIndent
        equipment.foots = Gui.createButton {
            image = Gui.settings.images.equipment.foots,
            x = x,
            width = Gui.settings.sizes.equipmentButtonSize,
            height = Gui.settings.sizes.equipmentButtonSize
        }
        equipment:add(equipment.foots)
    end

    local indent = gh / 20
    inventory.scroll = Gui.createScrollView {
        width = Gui.settings.sizes.slotListWidth,
        height = gh,
        x = gw / 3,
        yMinOffset = gh / 20,
        yMaxOffset = -gh / 20,
        horizontalScrollDisabled = true,
        backgroundColor = {0.3, 0.3, 0.3, 0.5}
    }
    inventory:insert(inventory.scroll)
    inventory.scroll.list = Gui.createList {
        x = Gui.settings.sizes.slotListWidth / 2,
        indent = Gui.settings.sizes.slotListIndent
    }
    inventory.scroll:add(inventory.scroll.list)
    world.players[1].inventory.graphics = world.players[1].inventory.graphics or {}
    world.players[1].inventory.graphics.list = inventory.scroll.list

    do
        local info = display.newGroup()
        info.isVisible = false
        inventory.info = info
        info.x = gw
        inventory:insert(info)
        local background = display.newRect(info, 0, 0, gw / 3, gh)
        info.background = background
        background:setFillColor(0.3, 0.3, 0.3)
        background.anchorX = 1
        background.anchorY = 0

        local fontSize = Gui.settings.sizes.itemInfoFontSize
        local indent = gw / 200
        ---[=[
        local list = Gui.createList {indent = indent}
        info:insert(list)
        info.list = list
        info.name = display.newText {
            parent = info,
            text = "Name",
            font = native.systemFont,
            fontSize = fontSize * 1.2,
            x = -background.width / 2,
            y = fontSize * 1.5
        }
        local x = -background.width + indent
        local y = gh / 10 + indent
        list.y = y
        info.desc = display.newText {
            parent = info,
            text = ("Desc"):rep(10),
            font = native.systemFont,
            fontSize = fontSize,
            x = x,
            y = y,
            align = "left",
            width = background.width - 2 * indent
        }
        info.desc.anchorX = 0
        info.desc.anchorY = 0
        list:add(info.desc)
        info.count = display.newText {
            parent = info,
            x = x,
            y = y,
            text = "1",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.count.anchorX = 0
        info.count.anchorY = 0
        list:add(info.count)
        info.rarity = display.newColorText {
            parent = info,
            text = "Качество: <#(0, ff, 0), [48], (0, 0, ff)>Эпическое",
            font = native.systemFont,
            fontSize = fontSize,
            x = x,
            y = y
        }
        info.rarity.anchorX = 0
        info.rarity.anchorY = 0
        list:add(info.rarity)
        info.durability = display.newText {
            parent = info,
            x = x,
            y = y,
            text = "Прочность: 80/80",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.durability.anchorX = 0
        info.durability.anchorY = 0
        list:add(info.durability)
        info.critChance = display.newText {
            parent = info,
            x = x,
            y = y,
            text = "Шанс критической атаки: 11%",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.critChance.anchorX = 0
        info.critChance.anchorY = 0
        list:add(info.critChance)
        info.critDamage = display.newText {
            parent = info,
            text = "Критический урон: x1.5",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.accuracy = display.newText {
            parent = info,
            text = "Точность оружия: 1.1",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.attackSpeed = display.newText {
            parent = info,
            text = "Скорость атаки: 2",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.damage = display.newText {
            parent = info,
            text = "Урон: 5",
            font = native.systemFont,
            fontSize = fontSize
        }
        info.armor = display.newText {
            parent = info,
            text = "Защита: 3",
            font = native.systemFont,
            fontSize = fontSize
        }
        -- ]=]
    end
    local buttonSize = gh / 10
    inventory.closeButton = Gui.createButton {
        parent = inventory,
        x = gw - buttonSize / 2,
        y = buttonSize / 2,
        width = buttonSize,
        height = buttonSize,
        defaultColor = {0.7, 0.1, 0.1},
        onTap = function(self)
            Gui.closeInventory()
            return true
        end
    }
    inventory.isVisible = false
    Gui.inventory = inventory
    return inventory
end

Gui.createInterface = function(world)
    local player = world.players[1]
    local location = player.position.loc
    local interface = {}
    interface.group = display.newGroup()
    local indent = gh / 60
    local swiper = Gui.createSwiper {indent = 5} --
    interface.swiper = swiper
    interface.group:insert(swiper)
    local size = Gui.settings.sizes.inGameMenuButtonWidth
    swiper.x, swiper.y = gw - size / 2, size / 2
    swiper.main = Gui.createButton {
        parent = swiper,
        width = size,
        height = size,
        defaultColor = {142 / 255, 196 / 255, 223 / 255},
        stroke = {color = {0, 0, 0}, width = size / 20},
        image = Gui.interfaceCatalog .. "triangle.png",
        imageWidth = size / 2,
        imageHeight = size / 2,
        disableTouch = true,
        onTap = function(self, event)
            transition.to(self.image, {time = 500, yScale = self.isOpened and 1 or -1})
            self.isOpened = not self.isOpened
            swiper:activate()
            return true
        end
    }
    swiper.main:rotate(180)
    local buttons = {}
    interface.buttons = buttons

    buttons.inventory = Gui.createButton {
        width = size,
        height = size,
        defaultColor = {142 / 255, 196 / 255, 223 / 255},
        stroke = {color = {0, 0, 0}, width = size / 20},
        disableTouch = true,
        image = Gui.settings.catalogs.interface .. "inventory_button.png",
        onTap = function(self)
            Gui.openInventory()
            return true
        end
    } --
    swiper:add(buttons.inventory)
    buttons.quests = Gui.createButton {
        width = size,
        height = size,
        defaultColor = {142 / 255, 196 / 255, 223 / 255},
        stroke = {color = {0, 0, 0}, width = size / 20},
        image = Gui.settings.catalogs.interface .. "quests_button.png"
    } --
    swiper:add(buttons.quests)

    buttons.reputation = Gui.createButton {
        width = size,
        height = size,
        defaultColor = {142 / 255, 196 / 255, 223 / 255},
        stroke = {color = {0, 0, 0}, width = size / 20},
        image = Gui.settings.catalogs.interface .. "reputation_button.png"
    } --
    swiper:add(buttons.reputation)

    buttons.settings = Gui.createButton {
        width = size,
        height = size,
        defaultColor = {142 / 255, 196 / 255, 223 / 255},
        stroke = {color = {0, 0, 0}, width = size / 20},
        image = Gui.settings.catalogs.interface .. "settings_button.png"
    } --
    swiper:add(buttons.settings)

    local locationInfo = display.newGroup()
    interface.group:insert(locationInfo)
    locationInfo.x, locationInfo.y = -gw / 2, 0
    locationInfo.background = display.newRect(locationInfo, 0, 0, gw / 2, gh)
    locationInfo.background:setFillColor(0.5, 0.5, 0.5)
    locationInfo.background.alpha = 0.5
    locationInfo.background.anchorX, locationInfo.background.anchorY = 0, 0
    local fontSize = gh / 11
    locationInfo.name = display.newText {
        parent = locationInfo,
        x = size + indent * 2,
        y = indent + fontSize / 2,
        text = location.name,
        fontSize = fontSize
    }
    locationInfo.name.anchorX = 0
    locationInfo.desc = display.newText {
        parent = locationInfo,
        x = indent,
        y = size + indent,
        width = locationInfo.background.width - 2 * indent,
        text = location:desc(),
        fontSize = fontSize / 2,
        align = "left"
    }
    locationInfo.desc.anchorX = 0
    locationInfo.desc.anchorY = 0
    local minimapSize = locationInfo.background.width / 3
    local minimap = display.newContainer(minimapSize, minimapSize)
    locationInfo.minimap = minimap
    minimap:translate(minimap.width / 2, locationInfo.height - minimap.height / 2)
    locationInfo:insert(locationInfo.minimap)
    local minimapBackground = display.newRect(0, 0, minimap.width, minimap.height)
    minimap:insert(minimapBackground)
    minimapBackground:setFillColor(0, 0.5, 0.5)

    interface.buttons.location = Gui.createButton {
        x = size / 2,
        y = size / 2,
        parent = interface.group,
        width = size,
        height = size,
        image = Gui.settings.catalogs.interface .. "triangle.png",
        imageWidth = size / 2,
        imageHeight = size / 2,
        disableTouch = true,
        stroke = {color = {0, 0, 0}, width = size / 20},
        defaultColor = {142 / 255, 196 / 255, 223 / 255}
    } --
    interface.buttons.location:rotate(90)
    interface.buttons.location.onTap = function(self, event)
        transition.to(locationInfo, {time = 500, x = self.tapped and -gw / 2 or 0})
        transition.to(self.image, {time = 500, yScale = self.tapped and 1 or -1})
        self.tapped = not self.tapped
        return true
    end
    return interface
end

return Gui
