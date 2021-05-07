--[=[
    Unrare | Trash | Common | Uncommon | Rare | Epic | Legendagy | Mythical
    Equipment: {
        Weapon: {
            Sword | Axe | Spear | Staff | Shield | Hammer,
            Onehanded | Twohanded,
        } | Armor: {
            Head | Chest | Legs | Foots | Bracers
        } | Jewelry: {
            Ring | Bracelet | Necklace
        }
    } | Loot: {
        Resource: {
            [Wood: {[Fuel]} | Stone | Fuel | Gem]
        } | Mob | Money   
    } | Product: {
        Food | Drink
    } | Usable: {
        Potion | Pearl | Scroll
    }, [Quest]
--]=] --
local ItemDataBase = {
    -- Money
    copper_coin = {
        name = "Медная монета",
        tags = {"Unrare", "Loot", "Money"},
        desc = "Самая дешевая валюта",
        countmax = 100
    },
    silver_coin = {
        name = "Серебреная монета",
        tags = {"Unrare", "Loot", "Money"},
        desc = "Красиво переливающаеся на солнце монета",
        countmax = 100
    },
    gold_coin = {
        name = "Золотая монета",
        tags = {"Unrare", "Loot", "Money"},
        desc = "Ярко сияющая монета",
        countmax = 100
    },
    -- Weapon
    iron_sword = {
        name = "Железный меч",
        tags = {"Common", "Equipment", "Weapon", "Sword", "Onehanded"},
        damage = 3,
        block = 0.4,
        critDamage = 1.5,
        accuracy = 1.2,
        cooldown = 1500,
        durability = 15
    },
    wood_sword = {
        name = "Деревянный меч",
        tags = {"Trash", "Equipment", "Weapon", "Sword", "Onehanded"},
        damage = 1,
        block = 0.3,
        critDamage = 1.5,
        accuracy = 1.2,
        cooldown = 1500,
        durability = 10
    },
    spear = {
        name = "Обычное копье",
        tags = {"Common", "Equipment", "Weapon", "Spear", "Twohanded"},
        damage = 5.5,
        block = 0.2,
        critDamage = 1.3,
        accuracy = 0.9,
        cooldown = 1900,
        durability = 12
    },
    iron_axe = {
        name = "Обычный топор",
        tags = {"Common", "Equipment", "Weapon", "Axe", "Onehanded"},
        damage = 3,
        block = 0.25,
        critDamage = 1.5,
        accuracy = 1,
        cooldown = 1300,
        durability = 15
    },
    hand = {
        id = "hand",
        name = "Рука",
        tags = {"Unrare", "Equipment", "Weapon", "Hammer", "Onehanded"},
        damage = 0.5,
        critDamage = 1.2,
        accuracy = 1,
        cooldown = 750
    },
    claws = {
        name = "Коготь",
        tags = {"Unrare", "Equipment", "Weapon", "Sword", "Onehanded"},
        damage = 2,
        critDamage = 1.2,
        accuracy = 1,
        cooldown = 800
    },
    shield = {
        name = "Обычный щит",
        tags = {"Common", "Equipment", "Weapon", "Shield", "Onehanded"},
        block = 0.7,
        damage = 1.5,
        critDamage = 1.5,
        accuracy = 1,
        cooldown = 1800,
        durability = 25
    },
    -- Armor
    iron_helmet = {
        name = "Железный шлем",
        tags = {"Common", "Equipment", "Armor", "Head"},
        armor = 0.5,
        durability = 15

    },
    chain_mail = {
        name = "Кольчуга",
        tags = {"Common", "Equipment", "Armor", "Chest"},
        armor = 0.5,
        durability = 15
    },
    iron_chestplate = {
        name = "Латные доспехи",
        tags = {"Common", "Equipment", "Armor", "Chest"},
        armor = 1,
        durability = 25
    },
    chain_mail_greaves = {
        name = "Кольчужные поножи",
        tags = {"Common", "Equipment", "Armor", "Legs"},
        armor = 0,
        5,
        durability = 15
    },
    iron_greaves = {
        name = "Латные Поножи",
        tags = {"Common", "Equipment", "Armor", "Legs"},
        armor = 1,
        durability = 25
    },
    leather_boots = {
        name = "Кожаные ботинки",
        tags = {"Common", "Equipment", "Armor", "Foots"},
        armor = 0.2,
        durability = 10
    },
    iron_boots = {
        name = "Латные ботинки",
        tags = {"Common", "Equipment", "Armor", "Foots"},
        armor = 0.5,
        durability = 15
    },
    iron_gloves = {
        name = "Латные перчатки",
        tags = {"Common", "Equipment", "Armor", "Bracers"},
        armor = 0.5,
        durability = 15
    },
    leather_gloves = {
        name = "Кожаные перчатки",
        tags = {"Common", "Equipment", "Armor", "Bracers"},
        armor = 0.2,
        durability = 10
    },
    -- MOB
    rabbit_fur = {name = "Кроличий мех", tags = {"Unrare", "Loot", "Mob"}, countmax = 5},
    rabbit_ear = {name = "кроличье  ухо", tags = {"Unrare", "Loot", "Mob"}, countmax = 5},
    rabbit_meat = {name = "кроличье  мясо", tags = {"Unrare", "Product", "Food"}, countmax = 5}
}
return ItemDataBase
