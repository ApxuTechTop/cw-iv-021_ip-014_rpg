local dir = select(1, ...)
for i = #dir, 1, -1 do
    if dir:sub(i, i) == '.' then
        dir = dir:sub(1, i)
        break
    end
end
if dir == select(1, ...) then
    dir = ""
end

local ItemDataBase = require("ItemDataBase")
local Storage = require(dir .. "Storage")
local Item = Storage.Item
local Gui = require(dir .. "Gui")
local Names = {male = {}, female = {}}
local old_json = require(dir .. "old_json")

do
    local namesDb = io.open(system.pathForFile("Names.db", system.ResourceDirectory), "r");
    local gender = "male"
    local i = 1
    while namesDb:read(0) do
        local name = namesDb:read("*l")
        if name == "=" then
            gender = "female"
            i = 1
        else
            Names[gender][i] = name
            i = i + 1
        end
    end
    namesDb:close()
end

local Entities = {
    goblin_rogue = {
        name = "Гоблин-разбойник",
        icon = Gui.settings.icons.goblinIcon,
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
        equipment = {hands = {ItemDataBase.sword}},
        moveSpeed = 200
    },
    goblin_spearman = {
        name = "Гоблин-Копейщик",
        icon = Gui.settings.icons.goblinIcon,
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
        dexterity = 1,
        luck = 2,
        vitality = 2,
        reaction = 550,
        equipment = {hands = {ItemDataBase.spear}},
        moveSpeed = 200
    },
    create_knight = function()
        local gender = ({"male", "female"})[math.random(2)]
        local name
        if #Names[gender] > 0 then
            name = Names[gender][math.random(#Names[gender])]
        else
            name = "Рыцарь"
        end
        local lvl = math.random(5)
        local weapon1 = ({ItemDataBase.spear, ItemDataBase.sword, ItemDataBase.iron_axe, nil})[math.random(4)]
        local weapon2 = ({ItemDataBase.shield})[math.random(5)]
        local head = ({ItemDataBase.iron_helmet, nil})[math.random(2)]
        local chest = ({ItemDataBase.chain_mail, ItemDataBase.iron_chestplate})[math.random(2)]
        local legs = ({ItemDataBase.iron_greaves})[1]
        local foots = ({ItemDataBase.iron_boots, ItemDataBase.leather_boots})[2]
        local bracers = ({ItemDataBase.iron_gloves, ItemDataBase.leather_gloves})[5]
        local knight = {
            name = name,
            lvl = lvl,
            exp = math.random(0, lvl * 10 - 1),
            expmax = lvl * 10,
            energy = math.random(2, lvl * 10),
            energymax = lvl * 10,
            mana = 0,
            manamax = 0,
            health = math.random(lvl * 5, lvl * 10),
            healthmax = lvl * 10,
            strength = math.random(8, 15) / 10,
            agility = math.random(8, 15) / 10,
            dexterity = math.random(8, 15) / 10,
            luck = math.random(8, 15) / 10,
            vitality = math.random(8, 15) / 10,
            reaction = math.random(400, 1200),
            moveSpeed = math.random(150, 250),
            equipment = {
                hands = {weapon1, weapon2},
                head = head,
                chest = chest,
                legs = legs,
                foots = foots,
                bracers = bracers
            }
        }
        local inventory = Storage.new(15)
        knight.inventory = inventory
        inventory:createSlot(Item.new(ItemDataBase.copper_coin), math.random(0, 200))
        inventory:createSlot(Item.new(ItemDataBase.silver_coin), math.random(0, 2))
        inventory:createSlot(Item.new(ItemDataBase.gold_coin), math.floor(math.random(0, 501) / 500))
        return knight
    end,
    create_rabbit = function()
        local paw = {
            name = "Лапка",
            tags = {"Unrare", "Equipment", "Weapon", "Sword", "Onehanded"},
            damage = 0.1,
            critDamage = 1.2,
            accuracy = 1,
            cooldown = 800,
            cantDrop = true
        }
        local lvl = 1
        local rabbit = {
            name = "Безобидный кролик",
            lvl = lvl,
            exp = math.random(0, lvl * 10 - 1),
            expmax = lvl * 10,
            energy = math.random(2, lvl * 10),
            energymax = lvl * 10,
            mana = 0,
            manamax = 0,
            health = math.random(lvl * 5, lvl * 10),
            healthmax = lvl * 10,
            strength = math.random(3, 9) / 10,
            agility = math.random(3, 9) / 10,
            dexterity = math.random(3, 9) / 10,
            luck = math.random(3, 9) / 10,
            vitality = math.random(3, 9) / 10,
            reaction = math.random(1000, 1900),
            equipment = {hands = {paw, paw}},
            moveSpeed = math.random(70, 130)
        }
        rabbit.inventory = Storage.new(3)
        rabbit.inventory:createSlot(Item.new(ItemDataBase.rabbit_fur), math.random(0, 1))
        rabbit.inventory:createSlot(Item.new(ItemDataBase.rabbit_meat), math.random(0, 1))
        rabbit.inventory:createSlot(Item.new(ItemDataBase.rabbit_ear), math.random(0, 2))

        return rabbit
    end
}

return Entities
