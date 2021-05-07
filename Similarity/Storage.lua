require("supplement")
local Gui = require("Gui")
local gw, gh = display.contentWidth, display.contentHeight
local Storage = {}
local Item = {}

local slotMeta = {
    __index = {
        setItem = function(self, item) -- TODO update interface
            self.item = item
        end,

        setCount = function(self, count) -- TODO update interface
            self.count = count
        end

    }
}

local storageMeta = {
    __index = {
        addSlot = function(self, slot)
            self.slots[#self.slots + 1] = slot
        end,

        addItem = function(self, item, count)
            local count = count or 1
            for k, slot in ipairs(self.slots) do
                if slot.count < slot.item.countmax then
                    if table.equal(slot.item, item) then
                        local dCount = slot.item.countmax - slot.count
                        if count >= dCount then
                            slot:setCount(slot.count + dCount)
                            count = count - dCount
                        else
                            slot:setCount(slot.count + count)
                            return true
                        end

                    end
                end
            end
            return self:createSlot(item, count)
        end,

        removeItem = function(self, item, count)
            for k, slot in pairs(self.slots) do
                if table.equal(slot.item, item) then
                    if count >= slot.count then
                        count = count - slot.count
                        self:removeSlot(slot)
                        if count == 0 then
                            return true
                        end
                    elseif count < slot.count then
                        slot:setCount(slot.count - count)
                        return true
                    end
                end
            end
            return false, count
        end,

        removeSlot = function(self, slot)
            if type(slot) == "number" then
                return table.remove(self.slots, slot)
            elseif type(slot) == "table" then
                for k, v in pairs(self.slots) do
                    if table.equal(v, slot) then
                        return table.remove(self.slots, k)
                    end
                end
            end
        end,

        findItem = function(self, item)
            for k, slot in pairs(self.slots) do
                if table.equal(slot.item, item) then
                    return slot, k
                end
            end
        end,

        setCountmax = function(self, countmax) -- TODO update interface
            while countmax < #self.slots do
                self:removeSlot(#self.slots)
            end
            self.countmax = countmax
        end,

        createSlot = function(self, item, count)
            local count = count or 1
            if #self.slots < self.countmax then
                local index = #self.slots + 1
                self.slots[index] = {count = count, item = item, graphics = {}} -- TODO update interface
                setmetatable(self.slots[index], slotMeta)
                if self.graphics then
                    local slotGraphics = self.slots[index].graphics
                    local indent = gw / 100
                    local width = gw / 3 - 2 * indent
                    slotGraphics.button = Gui.createButton {
                        width = width,
                        fill = {0.5, 0.3, 0.3},
                        height = gh / 10,
                        shape = "roundedRect",
                        cornerRadius = Gui.settings.sizes.slotButtonCornerRadius,
                        disableTouch = true,
                        onTap = function()
                            Gui.inventory.info.isVisible = true
                            Gui.updateItemInfo(item)
                        end
                    }
                    slotGraphics.name = display.newText {
                        parent = slotGraphics.button,
                        x = indent - width / 2,
                        text = item.name,
                        fontSize = gh / 15
                    }
                    slotGraphics.name.fill = {0, 0, 0}
                    slotGraphics.name.anchorX = 0
                    slotGraphics.count = display.newText {
                        parent = slotGraphics.button,
                        x = width / 2 - indent,
                        text = "x" .. count,
                        fontSize = gh / 15
                    }
                    slotGraphics.count.fill = {0, 0, 0}
                    slotGraphics.count.anchorX = 1
                    self.graphics.list:add(slotGraphics.button)
                end

                return true
            end
            return false
        end
    }
}

local defaultItemMethods = { -- TODO
    setName = function(self, name)
        self.name = name
    end,

    setDesk = function(self, desk)
        self.desk = desk
    end,

    setTags = function(self, tags)
        self.tags = tags
    end,

    addTag = function(self, tag)
        self.tags[#self.tags + 1] = tag
    end,

    setRarity = function(self, rarity)
        self.rarity = rarity
    end,

    setArmor = function(self, armor)
        self.armor = armor
    end,

    setDamage = function(self, damage)
        self.damage = damage
    end,

    setStats = function(self, stats)
        self.stats = stats
    end,

    attack = function(self, me, enemy, block)
        local block = block or 0
        self.timer = timer.performWithDelay(self.cooldown, function()
            self.attackCooldown = nil
            me:think()
        end)
        local damage
        if math.random() < (math.critChance(me, self) / 100) then
            damage = enemy:getDamage(self.damage * me.strength * self.critDamage * (1 - block))
        else
            damage = enemy:getDamage(self.damage * me.strength * (1 - block))
        end
        return damage
    end,

    tryAttack = function(self, me, enemy)
        if not self.attackCooldown then
            local myBattleAction = me.battleBuffer:add("attack", me, enemy, self)
            local enemyBattleAction = enemy.battleBuffer:add("defense", enemy, me, self)
            myBattleAction.another = enemyBattleAction
            enemyBattleAction.another = myBattleAction
            self.attackCooldown = true
        end
    end,

    getHarm = function(self, harm)
        self.durability = self.durability - harm
        if self.durability <= 0 then
            self.tags:add("Broken")
            return true
        end
        -- TODO interface
    end,
    attackCooldown = false,
    block = 0.4

}

local itemTagsMeta = {
    __index = {
        add = function(self, ...)
            local length = #self
            for i = 1, #arg do
                self[length + i] = arg[i]
            end
        end,
        remove = function(self, tag)
            if type(tag) == "number" then
                table.remove(self, tag)
                return true
            else
                for i = #self, 1, -1 do
                    if self[i] == tag then
                        table.remove(self, i)
                        return true
                    end
                end
            end
            assert(false, "Didn't find tag to remove")
            return false
        end,
        find = function(self, tag)
            for i = #self, 1, -1 do
                if self[i] == tag then
                    return i
                end
            end
            return false
        end
    }
}

local itemMeta = {
    __index = function(self, key)
        if rawget(self, "id") and itemDataBase[self.id] and itemDataBase[self.id][key] then
            return itemDataBase[self.id][key]
        elseif defaultItemMethods[key] ~= nil then
            return defaultItemMethods[key]
        end
        assert(false, "Didn't find value at index " .. key)
    end
}

Storage.new = function(capacity, slots)
    local storage = {countmax = capacity, slots = slots or {}}
    setmetatable(storage, storageMeta)
    return storage
end

Item.new = function(options)
    local item = {
        id = options.id,
        name = options.name,
        desc = options.desc,
        tags = options.tags,
        rarity = options.rarity,
        armor = options.armor,
        damage = options.damage,
        stats = options.stats,
        critDamage = options.critDamage,
        accuracy = options.accuracy,
        cooldown = options.cooldown,
        durability = options.durability,
        attackCooldown = options.attackCooldown
    }
    setmetatable(item.tags, itemTagsMeta)
    setmetatable(item, itemMeta)
    return item
end

Storage.Item = Item
return Storage

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
            name = "Железный меч",
            desc = "description",
            tags = {"tag1", "tag2"},
            rarity = "epic",
            armor = 1,
            damage = 2,
            cooldown = 1200,
            attackCooldown = false,
            durability = 15,
            critDamage = 1.3,
            accuracy = 1.2,
            timer=timer or timeLeft,
            cantDrop = false,
            stats = {
                strength = {1.5, 1},
                agility = 1,
                dexterity = 1,
                luck = 1,
                vitality = 1,
                attentiveness = 1 -- vigilance если что
            },
            graphics = {info = storage.info, button = gui.button},
            slot = slot
        }

        slot = {
            count = 1,
            item = item,
            graphics = {button = gui.button, name = display.text, count = display.text, icon = display.image},
            storage = storage

        }

        storage = {
            countmax = 10,
            slots = {slot},
            graphics = {
                list = {slot.graphics},
                info = {
                    name = display.text,
                    desc = display.text,
                    count = display.text,
                    rarity = display.text,
                    stats = {
                        strength = display.text,
                        agility = display.text,
                        dexterity = display.text,
                        luck = display.text,
                        vitality = display.text,
                        attentiveness = display.text
                    },
                    durability = display.text,
                    critChance = display.text,
                    critDamage = display.text,
                    accuracy = display.text,
                    attackSpeed = display.text,
                    damage = display.text,
                    armor = display.text
                }
            },
            parent = entity or chest
        }

        Storage.new = function()
            local storage = {}
            setmetatabele(storage, storageMeta)
            return storage
        end
        entity.inventory:addItem{id = "iron_sword"}

-- ]=]
