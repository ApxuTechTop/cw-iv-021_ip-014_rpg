require("supplement")
local systemFonts = native.getFontNames()

-- Set the string to query for (part of the font name to locate)
local searchString = "pt"

-- Display each font in the Terminal/console
for i, fontName in ipairs(systemFonts) do

    local j, k = string.find(string.lower(fontName), string.lower(searchString))

    if (j ~= nil) then
        print("Font Name = " .. tostring(fontName))
    end
end

local Gui = require("Gui")
local json = require("json")
local widget = require("widget")
local World = require("World")
local Entity = require("Entity")
local Storage = require("Storage")
local Item = Storage.Item

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

local function startGame(self)
    local swordOption = {
        name = "Iron sword",
        desc = "Обычный ржавый меч",
        tags = {"Common", "Equipment", "Weapon", "Sword"},
        damage = 3,
        critDamage = 1.5,
        accuracy = 1.2,
        cooldown = 1500,
        durability = 15
    }

    local goblinRogueOptions = {
        name = "Гоблин-разбойник",
        lvl = 3,
        exp = 0,
        expmax = 100,
        energy = 10,
        mana = 0,
        manamax = 0,
        health = 15,
        healthmax = 15,
        strength = 2,
        agility = 2,
        dexterity = 2,
        luck = 2,
        vitality = 2,
        reaction = 500,
        equipment = {hands = {swordOption}}
    }

    local spearOptions = {
        name = "short spear",
        desk = "Немного заурядное короткое копье",
        tags = {"Equipment", "Weapon", "Spear"},
        rarity = "Common",
        damage = 5,
        critDamage = 1,
        5,
        accuracy = 0.9,
        cooldown = 2500,
        durability = 15
    }
    local goblinSpearmanOptions = {
        name = "Гоблин-Копейщик",
        lvl = 3,
        exp = 0,
        expmax = 100,
        energy = 10,
        mana = 0,
        manamax = 0,
        health = 20,
        healthmax = 15,
        strength = 3,
        agility = 1,
        5,
        dexterity = 1,
        5,
        luck = 2,
        vitality = 2,
        reaction = 550,
        equipment = {hands = {spearOptions}}
    }
    self.isVisible = false
    local world = World.new()
    local testLocation = world:newLocation({
        id = "test_location",
        name = "Test location",
        desc = function(self)
            return ("Its test location "):rep(5)
        end,
        entities = {},
        path = {},
        battles = {},
        height = 720 * 5,
        width = 1520 * 10
    })
    testLocation.world = world

    local stick = {
        name = "stick",
        desc = "a fragile stick",
        tags = {"Common", "Equipment", "Weapon", "Sword"},
        damage = 1,
        critDamage = 4,
        accuracy = 1.2,
        cooldown = 1000,
        durability = 100
    }

    local ApxuTechTop = Entity.new({
        name = "ApxuTechTop",
        level = 5,
        exp = 0,
        expmax = 100,
        reaction = 350,
        energy = 10,
        energymax = 10,
        health = 100,
        healthmax = 100,
        strength = 3,
        agility = 3,
        dexterity = 3,
        luck = 3,
        equipment = {hands = {}},
        inventory = Storage.new(10),
        position = {loc = testLocation, x = 600, y = 350}
    })
    local ApxuTechTopHelper = Entity.new({
        name = "ApxuTechTopHelper",
        level = 5,
        exp = 0,
        expmax = 100,
        reaction = 350,
        energy = 10,
        energymax = 10,
        health = 100,
        healthmax = 100,
        strength = 1,
        agility = 3,
        dexterity = 3,
        luck = 3,
        position = {loc = testLocation, x = 600, y = 350},
        equipment = {hands = {stick}}
    })

    local Avili0 = Entity.new({
        name = "Avili0",
        level = 5,
        exp = 0,
        expmax = 100,
        reaction = 1200,
        energy = 10,
        energymax = 10,
        health = 20,
        healthmax = 100,
        strength = 3,
        agility = 3,
        dexterity = 3,
        luck = 3,
        equipment = {hands = {}},
        position = {loc = testLocation, x = 600, y = 350}
    })

    testLocation:addEntity(ApxuTechTop, ApxuTechTop.position)
    testLocation:addEntity(Avili0, Avili0.position)
    testLocation:addEntity(ApxuTechTopHelper, ApxuTechTopHelper.position)
    world.players = {ApxuTechTop}

    ApxuTechTop:equip(Item.new(stick), 1)
    Avili0:equip(Item.new(stick), 1)
    Gui.displayWorld(world)
    local beatingUp = testLocation:newBattle({right = {}, left = {}, position = {x = 50, y = 50}})
    -- for i=1,5 do
    -- testLocation:addEntity(eTabl[i])
    -- beatingUp:addEntity(eTabl[i],"right")
    -- end
    local goblinSpot = testLocation:newSpot({position = {x = 1000, y = 1000}, radiusX = 500, radiusY = 500, max = 5})

    local goblinSpearmanSpotOptions = {entityOptions = goblinSpearmanOptions, max = 2, weigth = 10, time = 1500}

    local goblinRogueSpotOptions = {entityOptions = goblinRogueOptions, max = 10, weigth = 4, time = 1000}

    goblinSpot:addMob(goblinRogueSpotOptions)
    goblinSpot:addMob(goblinSpearmanSpotOptions)
    goblinSpot:run()
    Gui.createInterface(world)
    beatingUp:addEntity(ApxuTechTop, "left")
    beatingUp:addEntity(ApxuTechTopHelper, "left")
    beatingUp:addEntity(Avili0, "right")
    beatingUp:run()
    Gui.createInventory(world)
    for i = 1, 13 do
        ApxuTechTop.inventory:createSlot(Item.new(stick), 1)
    end

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
