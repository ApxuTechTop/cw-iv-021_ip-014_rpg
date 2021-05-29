local test = require("thirdparty.u-test")
require("Similarity.ItemDataBase")
local Storage = require("Similarity.Storage")
local Item = Storage.Item
local Entity = require("Similarity.Entity")
require("Similarity.supplement")
timer = {timers = {}, time = 0}

local testEntity1 = {
    name = "testEntity1",
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
    equipment = {
        hands = {
            {
                name = "testSword",
                desc = "testSword",
                tags = {"Common", "Equipment", "Weapon", "Sword"},
                damage = 10,
                critDamage = 5,
                accuracy = 1,
                cooldown = 2000,
                durability = 100
            }
        }
    }
}

local testEntity2 = {
    name = "testEntity2",
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
    equipment = {
        head = {
            name = "Железный шлем",
            tags = {"Common", "Equipment", "Armor", "Head"},
            armor = 0.5,
            durability = 15
        },
        chest = {
            name = "Латные доспехи",
            tags = {"Common", "Equipment", "Armor", "Chest"},
            armor = 1,
            durability = 25
        }
    }
}

timer.cancel = function(nowtimer)
    for i = #timer.timers, 1, -1 do
        if nowtimer == timer.timers[i] then
            table.remove(timer.timers, i)
            break
        end
    end
end

timer.run = function()
    local timer = timer
    local timers = timer.timers
    local length = #timers
    local lastTimer = timers[length]
    timer.time = math.max(timer.time, lastTimer.fireTime)
    lastTimer.listener()
    lastTimer.iterations = lastTimer.iterations - 1
    if lastTimer.iterations == 0 then
        for i = #timers, 1, -1 do
            if lastTimer == timers[i] then
                table.remove(timers, i)
                break
            end
        end
    else
        lastTimer.fireTime = timer.time + lastTimer.delay
        for i = length, 2, -1 do
            local left = timers[i - 1]
            local rigth = timers[i]
            if rigth.fireTime > left.fireTime then
                rigth, left = left, rigth
            end
        end
    end
end

timer.autorun = function()
    while #timer.timers > 0 do
        timer.run()
    end
end

timer.performWithDelay = function(delay, listener, iterations)
    local iterations = iterations or 1
    local nowtimer = {delay = delay, listener = listener, iterations = iterations, fireTime = timer.time + delay}
    table.insert(timer.timers, nowtimer);
    for i = #timer.timers, 2, -1 do
        if timer.timers[i].fireTime >= timer.timers[i - 1].fireTime then
            timer.timers[i], timer.timers[i - 1] = timer.timers[i - 1], timer.timers[i]
        end
    end
    return nowtimer
end

local oldRand = math.random

local function setrandom(...)
    local arg = {...}
    local i = 0
    return function()
        i = i + 1
        return arg[i]
    end
end

test.setrandom = function()
    math.random = setrandom(1, 2, 3, 4, 5)
    local result = math.random(10, 20)
    test.equal(1, result)
    result = math.random(20, 30)
    test.equal(2, result)
    result = math.random(20, 30)
    test.equal(3, result)
    result = math.random(20, 30)
    test.equal(4, result)
    result = math.random(20, 30)
    test.equal(5, result)
end

test.supplement.table_equal_simple_g = function()
    local t = {a = 1, b = true, c = "abc", d = {a = 2, c = 3}}
    local t2 = {}
    t2.a = 1
    t2.b = true
    t2.c = "abc"
    t2.d = {a = 2, c = 3}
    local result = table.equal(t, t2)
    test.equal(true, result)
end

test.supplement.table_equal_simple_b = function()
    local t = {a = 1, b = true, c = "asbssc", d = {a = 2, c = 3}}
    local t2 = {}
    t2.a = 1
    t2.b = true
    t2.c = "abc"
    t2.d = {}
    t2.d.a = 2
    t2.d.c = 3
    local result = table.equal(t, t2)
    test.equal(false, result)
end

test.supplement.table_equal_1_g = function()
    local t = {}
    local c = {t = t, d = 1}
    local b = {c = c}
    t.b = b
    local t2 = {b = {c = {d = 1}}}
    t2.b.c.t = t2
    local result = table.equal(t, t2)
    test.equal(true, result)
end

test.supplement.table_fullCopy_simple = function()
    local t = {a = 1, b = "abc", c = true}
    local t2 = table.fullCopy(t)
    local result = table.equal(t, t2)
    test.not_equal(t, t2)
    test.equal(true, result)
end

test.supplement.table_fullCopy_normal = function()
    local t = {a = 1, b = {c = "abc", d = false}}
    local t2 = table.fullCopy(t)
    local result = table.equal(t, t2)
    test.not_equal(t, t2)
    test.equal(true, result)
end

test.supplement.table_fullCopy_self_rec = function()
    local t = {a = 1, b = {c = "abc", d = false}}
    t.t = t
    local t2 = table.fullCopy(t)
    local result = table.equal(t, t2)
    test.not_equal(t, t2)
    test.equal(true, result)
end

test.supplement.table_fullCopy_out_rec = function()
    local t = {a = 1, b = {c = "abc", d = false, e = {a = 2}}}
    t.b.e.t = t
    local t2 = table.fullCopy(t)
    local result = table.equal(t, t2)
    test.not_equal(t, t2)
    test.equal(true, result)
end

test.fight.getHarm = function()
    local testSword = Item.new({
        name = "testSword",
        desc = "testSword",
        tags = {"Common", "Equipment", "Weapon", "Sword"},
        damage = 10,
        critDamage = 1,
        accuracy = 1,
        cooldown = 1000,
        durability = 100
    })
    testSword:getHarm(23.5)
    test.equal(76.5, testSword.durability)
end

test.fight.getDamage_without_armor = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        luck = 3
    }
    testEntity:getDamage(20)
    test.equal(80, testEntity.health)
end

test.fight.getDamage_with_armor = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        equipment = {
            head = {
                name = "Железный шлем",
                tags = {"Common", "Equipment", "Armor", "Head"},
                armor = 0.5,
                durability = 15
            }
        }
    }
    testEntity:getDamage(10)
    test.equal(90.5, testEntity.health)
    test.equal(5, testEntity.equipment.head.durability)
end

test.fight.getDamage_with_armors = function()
    local testEntity = Entity.new(testEntity2)
    testEntity:getDamage(10)
    test.equal(91.5, testEntity.health)
    test.equal(15 - 10 * 0.5 / 1.5, testEntity.equipment.head.durability)
    test.equal(25 - 10 * 1 / 1.5, testEntity.equipment.chest.durability)
end

test.fight.attack_without_armor = function()
    math.random = setrandom(1)
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new {
        name = "testEntity2",
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
        luck = 3
    }
    testEntity1.equipment.hands[1]:attack(testEntity1, testEntity2)
    timer.autorun()
    test.equal(90, testEntity2.health)
    test.equal(90, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.fight.attack_with_armor = function()
    math.random = setrandom(1)
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new(testEntity2)
    testEntity1.equipment.hands[1]:attack(testEntity1, testEntity2)
    timer.autorun()
    test.equal(91.5, testEntity2.health)
    test.equal(15 - 10 * 0.5 / 1.5, testEntity2.equipment.head.durability)
    test.equal(25 - 10 * 1 / 1.5, testEntity2.equipment.chest.durability)
    test.equal(90, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.fight.attack_with_armor_and_block = function()
    math.random = setrandom(1)
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new(testEntity2)
    testEntity1.equipment.hands[1]:attack(testEntity1, testEntity2, 0.4)
    timer.autorun()
    test.equal(95.5, testEntity2.health)
    test.equal(15 - 0.6 * 10 * 0.5 / 1.5, testEntity2.equipment.head.durability)
    test.equal(25 - 0.6 * 10 * 1 / 1.5, testEntity2.equipment.chest.durability)
    test.equal(94, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.fight.attack_with_armor_and_block_and_crit = function()
    math.random = setrandom(0)
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new(testEntity2)
    testEntity1.equipment.hands[1]:attack(testEntity1, testEntity2, 0.4)
    timer.autorun()
    test.equal(71.5, testEntity2.health)
    test.equal(15 - 5 * 0.6 * 10 * 0.5 / 1.5, testEntity2.equipment.head.durability)
    test.equal(25 - 5 * 0.6 * 10 * 1 / 1.5, testEntity2.equipment.chest.durability)
    test.equal(70, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.fight.tryAttack_fastAtack = function()
    math.random = setrandom(1, 900, 1, 1000, 1)
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new(testEntity2)
    testEntity1.equipment.hands[1]:tryAttack(testEntity1, testEntity2)
    timer.autorun()
    test.equal(91.5, testEntity2.health)
    test.equal(15 - 10 * 0.5 / 1.5, testEntity2.equipment.head.durability)
    test.equal(25 - 10 * 1 / 1.5, testEntity2.equipment.chest.durability)
    test.equal(90, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.fight.tryAttack_slowAtack = function()
    math.random = setrandom(1, 1000, 1, 900, 1)
    timer.autorun()
    local testEntity1 = Entity.new(testEntity1)
    local testEntity2 = Entity.new(testEntity2)
    testEntity1.equipment.hands[1]:tryAttack(testEntity1, testEntity2)
    timer.autorun()
    test.equal(95.5, testEntity2.health)
    test.equal(15 - 0.6 * 10 * 0.5 / 1.5, testEntity2.equipment.head.durability)
    test.equal(25 - 0.6 * 10 * 1 / 1.5, testEntity2.equipment.chest.durability)
    test.equal(94, testEntity1.equipment.hands[1].durability)
    math.random = oldRand
end

test.storage.create_item_with_id = function()
    local spear = {
        id = "spear",
        name = "Обычное копье",
        tags = {"Common", "Equipment", "Weapon", "Spear", "Twohanded"},
        damage = 5.5,
        block = 0.2,
        critDamage = 1.3,
        accuracy = 0.9,
        cooldown = 1900,
        durability = 12
    }
    local testItem = Item.new({id = "spear"})
    local result = table.equal(testItem, spear)
    test.equal(true, result)
end

test.storage.create_item_without_id = function()
    local spear = {
        name = "Обычное копье",
        tags = {"Common", "Equipment", "Weapon", "Spear", "Twohanded"},
        damage = 5.5,
        block = 0.2,
        critDamage = 1.3,
        accuracy = 0.9,
        cooldown = 1900,
        durability = 12
    }
    local testItem = Item.new(spear)
    local result = table.equal(testItem, spear)
    test.equal(true, result)
end

test.storage.broke_item = function()
    local testEntity2 = Entity.new(testEntity2)
    testEntity2:getDamage(40)
    test.not_equal(testEntity2.equipment.head, nil)
    test.equal(testEntity2.equipment.chest, nil)
end

test.storage.create_slot_good_1 = function()
    local testStorage = Storage.new(1)
    local testItem = Item.new {id = "copper_coin"}
    local expectedTable = {count = 100, item = testItem, storage = testStorage}
    local result1 = testStorage:createSlot(testItem, 100)
    local result2 = table.equal(testStorage.slots[1], expectedTable)
    test.equal(result1, true)
    test.equal(result2, true)
end

test.storage.create_slot_good_2 = function()
    local testStorage = Storage.new(3)
    local testItem = Item.new {id = "copper_coin"}
    local expectedTable = {count = 100, item = testItem, storage = testStorage}
    local result1 = testStorage:createSlot(testItem, 200)
    test.equal(#testStorage.slots, 2)
    local result2 = table.equal(testStorage.slots[1], expectedTable)
    local result3 = table.equal(testStorage.slots[2], expectedTable)
    test.equal(result1, true)
    test.equal(result2, true)
    test.equal(result3, true)
end

test.storage.create_slot_bad_1 = function()
    local testStorage = Storage.new(1)
    local testItem1 = Item.new {id = "copper_coin"}
    local testItem2 = Item.new {id = "copper_coin"}
    local result1 = testStorage:createSlot(testItem1, 100)
    local result2 = testStorage:createSlot(testItem2, 100)
    test.equal(result1, true)
    test.equal(result2, false)
end

test.storage.create_slot_bad_2 = function()
    local testStorage = Storage.new(1)
    local testItem1 = Item.new {id = "copper_coin"}
    local testItem2 = Item.new {id = "copper_coin"}
    local result = testStorage:createSlot(testItem1, 200)
    test.equal(result, false)
end

test.storage.findItem = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    slot, num = testStorage:findItem(Item.new {id = "gold_coin"})
    result = table.equal(slot, testStorage.slots[2])
    test.equal(result, true)
    test.equal(2, num)
end

test.storage.removeItem_good_1 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    result1 = testStorage:removeItem(Item.new {id = "gold_coin"}, 50)
    result2 = table.equal({count = 50, item = Item.new {id = "gold_coin"}, storage = testStorage}, testStorage.slots[2])
    test.equal(result1, true)
    test.equal(result2, true)
end

test.storage.removeItem_good_2 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    result1 = testStorage:removeItem(Item.new {id = "copper_coin"}, 150)
    test.equal(#testStorage.slots, 2)
    result2 = table.equal({count = 50, item = Item.new {id = "gold_coin"}, storage = testStorage}, testStorage.slots[2])
    test.equal(result1, true)
    test.equal(result2, true)
end

test.storage.removeItem_bad_1 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    result, num = testStorage:removeItem(Item.new {id = "silver_coin"}, 50)
    test.equal(#testStorage.slots, 3)
    test.equal(result, false)
    test.equal(num, 50)
end

test.storage.removeItem_bad_2 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    result, num = testStorage:removeItem(Item.new {id = "gold_coin"}, 150)
    test.equal(#testStorage.slots, 2)
    test.equal(result, false)
    test.equal(num, 50)
end

test.storage.removeItem_bad_3 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    testStorage:createSlot(Item.new {id = "gold_coin"}, 100)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 100)
    result, num = testStorage:removeItem(Item.new {id = "copper_coin"}, 250)
    test.equal(#testStorage.slots, 1)
    test.equal(result, false)
    test.equal(num, 50)
end

test.storage.addItem_good_1 = function()
    local testStorage = Storage.new(1)
    result = testStorage:addItem(Item.new {id = "copper_coin"}, 30)
    test.equal(30, testStorage.slots[1].count)
    test.equal(result, true)
end

test.storage.addItem_good_2 = function()
    local testStorage = Storage.new(1)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 60)
    result = testStorage:addItem(Item.new {id = "copper_coin"}, 30)
    test.equal(90, testStorage.slots[1].count)
    test.equal(result, true)
end

test.storage.addItem_good_3 = function()
    local testStorage = Storage.new(3)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 60)
    result = testStorage:addItem(Item.new {id = "copper_coin"}, 150)
    test.equal(3, #testStorage.slots)
    test.equal(100, testStorage.slots[1].count)
    test.equal(100, testStorage.slots[2].count)
    test.equal(10, testStorage.slots[3].count)
    test.equal(result, true)
end

test.storage.addItem_bad_1 = function()
    local testStorage = Storage.new(1)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 60)
    result = testStorage:addItem(Item.new {id = "copper_coin"}, 50)
    test.equal(100, testStorage.slots[1].count)
    test.equal(result, false)
end

test.storage.addItem_bad_2 = function()
    local testStorage = Storage.new(1)
    result = testStorage:addItem(Item.new {id = "copper_coin"}, 150)
    test.equal(100, testStorage.slots[1].count)
    test.equal(result, false)
end

test.storage.addItem_bad_3 = function()
    local testStorage = Storage.new(4)
    testStorage:createSlot(Item.new {id = "copper_coin"}, 60)
    result = testStorage:addItem(Item.new {id = "silver_coin"}, 350)
    test.equal(60, testStorage.slots[1].count)
    test.equal(100, testStorage.slots[2].count)
    test.equal(100, testStorage.slots[3].count)
    test.equal(100, testStorage.slots[4].count)
    test.equal(result, false)
end

test.entity.unequip_1 = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        inventory = Storage.new(4),
        equipment = {chest = Item.new {id = "iron_chestplate"}}
    }
    test.equal(0, #testEntity.inventory.slots)
    local result = testEntity:unequip("chest")
    test.equal(true, result)
    test.equal(testEntity.equipment.chest, nil)
    test.equal(1, #testEntity.inventory.slots)
    test.equal(table.equal(testEntity.inventory.slots[1].item, Item.new {id = "iron_chestplate"}), true)
end

test.entity.unequip_2 = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        inventory = Storage.new(4),
        equipment = {chest = Item.new {id = "iron_chestplate"}}
    }
    test.equal(0, #testEntity.inventory.slots)
    test.equal(table.equal(testEntity.equipment.hands[1], Item.new {id = "hand"}), true)
    test.equal(table.equal(testEntity.equipment.hands[2], Item.new {id = "hand"}), true)
    local result = testEntity:unequip(1)
    test.equal(true, result)
    test.equal(testEntity.equipment.hands[1])
    test.equal(testEntity.equipment.hands[1])
    test.equal(0, #testEntity.inventory.slots)
end

test.entity.equip_1 = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        inventory = Storage.new(4)
    }
    local testItem = Item.new({id = "chain_mail"})
    local result = testEntity:equip(testItem, "chest")
    test.equal(true, result)
    test.equal(table.equal(testItem, testEntity.equipment.chest), true)
    test.equal(0, #testEntity.inventory.slots)
end

test.entity.equip_2 = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        inventory = Storage.new(4)
    }
    test.equal(table.equal(Item.new {id = "hand"}, testEntity.equipment.hands[1]), true)
    test.equal(table.equal(Item.new {id = "hand"}, testEntity.equipment.hands[2]), true)
    local testItem = Item.new({id = "iron_axe"})
    local result = testEntity:equip(testItem, 1)
    test.equal(true, result)
    test.equal(table.equal(testItem, testEntity.equipment.hands[1]), true)
    test.equal(nil, testEntity.equipment.hands[2])
    test.equal(0, #testEntity.inventory.slots)
end

test.entity.equip_3 = function()
    local testEntity = Entity.new {
        name = "testEntity",
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
        inventory = Storage.new(4),
        equipment = {chest = Item.new {id = "iron_chestplate"}}
    }
    local testItem = Item.new {id = "chain_mail"}
    local result = testEntity:equip(testItem, "chest")
    test.equal(true, result)
    test.equal(table.equal(testItem, testEntity.equipment.chest), true)
    test.equal(1, #testEntity.inventory.slots)
    test.equal(table.equal(testEntity.inventory.slots[1].item, Item.new {id = "iron_chestplate"}), true)
end

test.summary()
