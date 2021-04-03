--[=[
    local ItemDataBase = {
        iron_sword = {name = "Iron Sword", tags = {}, armor = 1, damage = 1, attackIcon = "string"},
        small_hp_potion = {
            name = "Маленькое зелье здоровья",
            desc = "Лечит на 10 здоровья",
            use = function(self, me)
                if self.capacity > 0 then
                    me:changeHealth(10)
                end
            end,
            time = 150
        }
    }

    defaultItem = {
        attack = function(self, me, enemy)
        end,
        crash = function(self, count)
        end
    }

    local foo = function(self, key)
        if defaultItem[key] then
            return defaultItem[key]
        else
            return ItemDataBase[self.id][key]
        end
    end

    ItemMetaTable = {__index = foo}

    Item = {
        id = "iron_sword",
        name = "string",
        desc = "description",
        tags = {"tag1", "tag2"},
        countmax = 64,
        rarity = "epic",
        armor = 1,
        damage = 2,
        stats = {
            strength = {1.5, 1},
            agility = 1,
            dexterity = 1,
            luck = 1,
            vitality = 1,
            attentiveness = 1 -- vigilance если что
        },
        count = 1
    }
-- ]=]
