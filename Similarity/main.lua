require("supplement")
local saver = require("saver")
local systemFonts = native.getFontNames()

local Gui = require("Gui")
local json = require("json")
local widget = require("widget")
local World = require("World")
local Entity = require("Entity")
local Storage = require("Storage")
local Item = Storage.Item
local ItemDataBase = require("ItemDataBase")
local Locations = require("Locations")
local Entities = require("Entities")

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

system.tapDelay = 350

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

local saveFile = "save_file.txt"
local function loadGame(filename)
    local game = saver.load(filename)
    local world = game.world
    World.reload(world)

    for key, location in pairs(world.locations) do
        location.desc = Locations[key].desc
        location.texture = Locations[key].texture
    end
    for k, location in pairs(world.locations) do
        for _, spot in pairs(location.spots) do
            for _, mob in pairs(spot.mobs) do
                if not mob.entity then
                    mob.entity = Entities[mob.id]
                end
            end
        end
    end
    Gui.displayWorld(world)
    Gui.createInterface(world)
    Gui.createInventory(world)
    world:run()
    return game
end

local function saveGame(game, filename, dir)
    local world = game.world
    world.graphics = nil
    for _, location in pairs(world.locations) do
        location.graphics = nil
        for _, entity in pairs(location.entities) do
            if entity.timers then
                for key, t in pairs(entity.timers) do
                    timer.cancel(t)
                    entity.timers[key] = nil
                end
            end
            if entity.transitions then
                for key, t in pairs(entity.transitions) do
                    transition.cancel(t)
                    entity.transitions[key] = nil
                end
            end
            entity.graphics = nil
            entity.inventory.graphics = nil
            for _, slot in pairs(entity.inventory.slots) do
                slot.graphics = nil
                slot.item.graphics = nil
            end
        end
        for _, battle in pairs(location.battles) do
            battle.graphics = nil
        end
        for _, path in pairs(location.path) do
            path.graphics = nil
        end
    end
    saver.save(game, filename, dir)
end

local function onSystemEvent(event)
    local eventType = event.type

    if (eventType == "applicationStart") then
        -- Occurs when the application is launched and all code in "main.lua" is executed
    elseif (eventType == "applicationExit") then
        saveGame(game, saveFile, system.DocumentsDirectory)
    elseif (eventType == "applicationSuspend") then
        -- Perform all necessary actions for when the device suspends the application, i.e. during a phone call
    elseif (eventType == "applicationResume") then
        -- Perform all necessary actions for when the app resumes from a suspended state
    elseif (eventType == "applicationOpen") then
        -- Occurs when the application is asked to open a URL resource (Android and iOS only)
    end
end

Runtime:addEventListener("system", onSystemEvent)

menu[1].onRelease = function(self)
    game = loadGame(saveFile)
end

local function startGame(self)
    self.isVisible = false
    local world = World.new()
    game.world = world
    world.time = {h = 13, d = 13, m = 1, y = 2021}
    local town = world:newLocation(Locations.main_town)
    local rabbitMeadow = world:newLocation(Locations.rabbit_meadow)
    local forest = world:newLocation(Locations.forest)
    local tavern = world:newLocation(Locations.tavern)

    for i = 1, math.random(15, 30) do
        town:addEntity(Entity.new(Entities.create_knight()), {x = math.random(town.width), y = math.random(town.height)})
    end
    for i = 1, math.random(10) do
        forest:addEntity(Entity.new(Entities.create_knight()),
                         {x = math.random(forest.width), y = math.random(forest.height)})
    end
    if #town.entities > 0 then
        world.players = {town.entities[math.random(#town.entities)]}
    end
    local rabbitSpot = rabbitMeadow:newSpot{
        position = {x = rabbitMeadow.width / 2, y = rabbitMeadow.height / 2},
        radiusX = rabbitMeadow.width / 2,
        radiusY = rabbitMeadow.height / 2,
        max = 20
    }
    local rabbitSpotOptions = {
        entity = Entities.create_rabbit,
        max = 20,
        weight = 10,
        time = 1500,
        id = "create_rabbit"
    }
    rabbitSpot:addMob(rabbitSpotOptions)

    Gui.displayWorld(world)
    Gui.createInterface(world)
    Gui.createInventory(world)
    world:run()
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

-- local sword = Item.new({
--     name = "Iron sword",
--     desc = "+10 Убийца богов ,способный убить даже разраба",
--     tags = {"Equipment", "Weapon", "Sword"}, -- ?
--     rarity = "Common",
--     damage = 7,
--     critDamage = 2,
--     accuracy = 1.2,
--     cooldown = 5000,
--     durability = 15
-- })

-- local sword_1 = Item.new({
--     name = "Iron sword",
--     desc = "+10 Убийца богов ,способный убить даже разраба",
--     tags = {"Equipment", "Weapon", "Sword"}, -- ?
--     rarity = "Common",
--     damage = 7,
--     critDamage = 2,
--     accuracy = 1.2,
--     cooldown = 5000,
--     durability = 15
-- })

-- local stick = Item.new({
--     name = "stick",
--     desc = "a fragile stick",
--     tags = {"Equipment", "Weapon", "Sword"}, -- ?
--     rarity = "Common",
--     damage = 1,
--     critDamage = 4,
--     accuracy = 1.2,
--     cooldown = 1000,
--     durability = 10
-- })

-- local eTabl = {}

-- for i = 1, 5 do
--     eTabl[i] = Entity.new({
--         name = i,
--         level = 5,
--         exp = 0,
--         expmax = 100,
--         energy = 10,
--         energymax = 10,
--         health = 400,
--         healthmax = 100,
--         strength = 3,
--         agility = 3,
--         dexterity = 3,
--         luck = 3,
--         reaction = 350,
--         equipment = {
--             hands = {
--                 Item.new({
--                     name = "stick",
--                     desc = "a fragile stick",
--                     tags = {"Equipment", "Weapon", "Sword"}, -- ?
--                     rarity = "Common",
--                     damage = 1,
--                     critDamage = 4,
--                     accuracy = 1.2,
--                     cooldown = 1000,
--                     durability = 10
--                 })
--             }
--         }

--     })
-- end

-- local Avili0 = Entity.new({
--     name = "Avili0",
--     level = 5,
--     exp = 0,
--     expmax = 100,
--     energy = 10,
--     energymax = 10,
--     health = 4000,
--     healthmax = 100,
--     strength = 3,
--     agility = 3,
--     dexterity = 3,
--     luck = 3,
--     reaction = 350,
--     equipment = {hands = {sword}}

-- })
-- local ApxuTechTop = Entity.new({
--     name = "ApxuTechTop",
--     level = 5,
--     exp = 0,
--     expmax = 100,
--     reaction = 350,
--     energy = 10,
--     energymax = 10,
--     health = 100,
--     healthmax = 100,
--     strength = 3,
--     agility = 3,
--     dexterity = 3,
--     luck = 3,
--     equipment = {hands = {sword_1, stick}}
-- })

-- local world = World.new()
-- local testLocation = world:newLocation({
--     id = "test_location",
--     name = "Test location",
--     desc = "Small location",
--     entities = {},
--     height = 100,
--     width = 100
-- })
-- testLocation:addEntity(Avili0)
-- testLocation:addEntity(ApxuTechTop)
-- -- testLocation:addEntity(ApxuTechTopHelper)
-- local beatingUp = testLocation:newBattle({right = {Avili0}, left = {ApxuTechTop}, position = {x = 50, y = 50}})
-- -- for i=1,5 do
-- -- testLocation:addEntity(eTabl[i])
-- -- beatingUp:addEntity(eTabl[i],"right")
-- -- end
-- beatingUp:run()
