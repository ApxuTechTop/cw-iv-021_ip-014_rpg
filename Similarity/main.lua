require("supplement")
local Gui = require("Gui")
local json = require("json")
local World = require("World")
local Entity = require("Entity")
local Storage = require("Storage")
local Item = Storage.Item

local cx, cy = display.contentCenterX, display.contentCenterY
local gw, gh = display.contentWidth, display.contentHeight

display.setDefault("background", 245 / 255, 245 / 255, 220 / 255);

local game = {settings = {music = true, sounds = true}}

local menu = display.newGroup()
menu.x = cx
menu.y = cy
for key, val in pairs({
    "Продолжить игру", "Новая игра", "Настройки", "Звуки", "Музыка"
}) do
    menu[key] = Gui.createMenuButton(val, 0, (key - 2) * gh / 3, gw / 4, gh / 4, menu)
    menu[key]._view._label.size = gw / 40
end
menu[2]._view._onEvent = function(event)
    if event.phase == "ended" then
        menu.isVisible = false
    end
end
menu[4]:setFillColor(0.1, 0.9, 0.1)
menu[5]:setFillColor(0.1, 0.9, 0.1)
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
            menu[4]:setFillColor(0.8, 0.1, 0.1)
        else
            game.settings.music = true
            menu[4]:setFillColor(0.1, 0.9, 0.1)
        end
    end
end
menu[5]._view._onEvent = function(event)
    if event.phase == "ended" then
        if game.settings.sounds then
            game.settings.sounds = false
            menu[5]:setFillColor(0.8, 0.1, 0.1)
        else
            game.settings.sounds = true
            menu[5]:setFillColor(0.1, 0.9, 0.1)
        end
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

-- -- local ApxuTechTopHelper = Entity.new({
-- --     name = "ApxuTechTopHelper",
-- --     level = 5,
-- --     exp = 0,
-- --     expmax = 100,
-- --     reaction=350,
-- --     energy = 10,
-- --     energymax = 10,
-- --     health = 100,
-- --     healthmax = 100,
-- --     strength = 1,
-- --     agility = 3,
-- --     dexterity = 3,
-- --     luck = 3,
-- --     equipment = {hands = {stick}}
-- -- }

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
    hralthmax = 15,
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
    hralthmax = 15,
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

local world = World.new()
local testLocation = world:newLocation({
    id = "test_location",
    name = "Test location",
    desc = "Small location",
    height = 720 * 3,
    width = 1520 * 3,

})

local goblinSpot = testLocation:newSpot({position = {x = 50, y = 50}, radiusX = 20, radiusY = 20, max = 5})

local goblinSpearmanSpotOptions = {entityOptions = goblinSpearmanOptions, max = 2, weigth = 10, time = 1500}

local goblinRogueSpotOptions = {entityOptions = goblinRogueOptions, max = 10, weigth = 4, time = 1000}

goblinSpot:addMob(goblinRogueSpotOptions)
goblinSpot:addMob(goblinSpearmanSpotOptions)
goblinSpot:run()
timer.performWithDelay(3000, function()
    for k, v in pairs(testLocation.entities) do
        if v.name == "Гоблин-разбойник" then
            print(json.prettify(v.equipment.hands))
            break
        end
    end
end, 19)
