local Storage = require("Storage")
local Item = Storage.Item
local ItemDataBase = require("ItemDataBase")
local Entity = {}
local battleBufferMeta

local battleActionMeta = {
    __index = {
        event = function(self) -- TODO
            if self.type == "attack" then
                self.item:attack(self.me, self.enemy)
            elseif self.type == "defense" then -- mbmb miss
                local maxBlockItem
                for k, item in pairs(self.me.equipment.hands) do
                    if item.tags:find("Shield") then
                        maxBlockItem = maxBlockItem and ((item.block < maxBlockItem.block) and maxBlockItem) or item
                    else
                        maxBlockItem = maxBlockItem and (((item.block) < maxBlockItem.block) and maxBlockItem) or item

                    end
                end
                local harm = self.item:attack(self.enemy, self.me, maxBlockItem and maxBlockItem.block or 0.1)
                if maxBlockItem then
                    maxBlockItem:getHarm(harm)
                end
            else -- TODO

            end
            if self.another.timer then
                print("timer работает")
                timer.cancel(self.another.timer)
            end
            self.enemy.battleBuffer:remove(self.another)
            self.me.battleBuffer:remove(self)

        end
    }
}

battleBufferMeta = {

    __index = {
        add = function(self, type, me, enemy, item, event)
            local last = #self + 1
            self[last] = {}
            self[last].type = type
            self[last].me = me
            self[last].enemy = enemy
            self[last].item = item
            self[last].event = event
            setmetatable(self[last], battleActionMeta)
            self:run()
            return self[last]
        end, -- TODO interface
        remove = function(self, battleAction)
            for k, v in pairs(self) do
                if v == battleAction then
                    return table.remove(self, k)
                end
            end
        end, -- TODO interface
        run = function(self)
            if #self > 0 and not self[1].me.battleActionCooldown then
                local battleAction = self[math.random(#self)]
                battleAction.me.battleActionCooldown = true
                local reaction = battleAction.me.reaction * math.random(900, 1100) / 1000
                timer.performWithDelay(reaction, function()
                    battleAction.me.battleActionCooldown = nil
                end)
                battleAction.timer = timer.performWithDelay(reaction, function()
                    battleAction:event()
                    self:run()
                end)
            end
        end
    }
}

local entityMeta = {
    __index = {
        moveSpeed = 50,

        setLevel = function(self, level)
            self.level = level
            if self.graphics then
            end -- update ui
        end,

        setExp = function(self, exp)
            self.exp = exp
            if self.graphics then
            end -- update ui
        end,

        addExp = function(self, exp)
            self.exp = self.exp + exp
            while self.exp > self.expmax do
                entityMeta.__index.setlevel(self, self.level + 1)
                entityMeta.__index.setExpmax(self, self.level, self.curve)
            end
        end,

        setExpmax = function(self, level, curve)
            local expmax = curve(level)
            return expmax
        end,

        setEnergy = function(self, energy)
            self.energy = energy
        end,

        setEnergymax = function(self, energymax)
            self.energymax = energymax
        end,

        setMana = function(self, mana)
            self.mana = mana
        end,

        setManamax = function(self, manamax)
            self.manamax = manamax
        end,

        setHealth = function(self, health)
            self.health = health
        end,

        setHealthmax = function(self, healthmax)
            self.healthmax = healthmax
        end,

        setHunger = function(self, hunger)
            self.hunger = hunger
        end,

        setThirst = function(self, thirst)
            self.thirst = thirst
        end,

        setFatigue = function(self, fatigue)
            self.fatigue = fatigue
        end,

        setStrench = function(self, strength)
            self.strength = strength
        end,

        setAgility = function(self, agility)
            self.agility = agility
        end,

        setDexterity = function(self, dexterity)
            self.dexterity = dexterity
        end,

        setLuck = function(self, luck)
            self.luck = luck
        end,

        setVitality = function(self, vitality)
            self.vitality = vitality
        end,

        setAttentiveness = function(self, attentiveness)
            self.attentiveness = attentiveness
        end,

        move = function(self, position)
            local distance = math.distance(self.position, position)
            local steps = distance / self.moveSpeed
            local moveSpeedX = (position.x - self.position.x) / steps
            local moveSpeedY = (position.y - self.position.y) / steps
            timer.performWithDelay(500, function()
                self.position.x = self.position.x + moveSpeedX
                self.position.y = self.position.y + moveSpeedY
            end, steps)
            timer.performWithDelay(500 * steps, function()
                self.position.x = position.x
                self.position.y = position.y
            end)
        end,

        getDamage = function(self, damage) -- TODO interface
            local armor = 0
            for k, v in pairs(self.equipment) do
                if k ~= "hands" then
                    armor = armor + v.armor
                end
            end
            local totalDamage = (damage - armor) / (self.vitality or 1)
            self.health = self.health - ((totalDamage > 0.5) and totalDamage or 0.5) -- balance
            for k, v in pairs(self.equipment) do
                if k ~= "hands" then
                    if v:getHarm(damage * v.armor / armor) then
                        self.equipment[k] = nil
                    end
                end
            end
            print(self.name .. " - Получил урон " .. damage)
            if self.health <= 0 then
                self:death()
            end
            return damage -- TODO
        end,

        death = function(self)
            -- drop
            if self.spot then
                self.spot:removeMob(self)
            end
            if self.position.loc.world:clear(self) then
                return true
            else
                assert(false, "Didn't find entity to clear")
            end
        end,
        think = function(self)
            local enemySide
            if self.battle then
                for k, v in pairs(self.battle.left) do
                    if v == self then
                        enemySide = "right"
                        break
                    end
                end
                enemySide = enemySide or "left"

                local enemyNum = math.random(#self.battle[enemySide])
                for key, weapon in pairs(self.equipment.hands) do
                    if weapon.tags:find("Broken") then
                        self.equipment.hands[key] = nil
                    else
                        weapon:tryAttack(self, self.battle[enemySide][enemyNum])
                    end
                end
            end
        end,
        equip = function(self, item, tag)
            self:unequip(tag)
            if type(tag) == number then
                if self.equipment.hands[1].id == "hand" then
                    self.equipment.hands[1] = nil
                end
                self.equipment.hands[tag] = item
            else
                self.equipment[tag] = item
            end
        end,
        unequip = function(self, tag)
            if type(tag) == "number" then
                if not self.equipment.hands[tag] then
                    return
                end
                if self.equipment.hands[tag].id == "hand" then
                    return
                end
                -- self.inventory:addItem(self.equipment.hands[tag])
                self.equipment.hands[tag] = nil
                if #self.equipment.hands == 0 then
                    self.equipment.hands[1] = Item.new({id = "hand"})
                end
            else
                if not self.equipment[tag] then
                    return
                end
                -- self.inventory:addItem(self.equipment[tag])
                self.equipment[tag] = nil
            end
        end
    }
}

Entity.new = function(options)
    local entity = {
        name = options.name, --
        surname = options.surname, --
        level = options.level,
        exp = options.exp,
        expmax = options.expmax,
        energy = options.energy,
        energymax = options.energymax,
        mana = options.mana,
        manamax = options.manamax,
        health = options.health,
        healthmax = options.healthmax,
        hunger = options.hunger,
        thirst = options.thirst,
        fatigue = options.fatigue,
        strength = options.strength or 1,
        agility = options.agility or 1,
        dexterity = options.dexterity or 1,
        luck = options.luck or 1,
        vitality = options.vitality or 1,
        attentiveness = options.attentiveness,
        reaction = options.reaction or 350, --
        relationship = options.relationship, --
        inventory = Storage.new(), --
        equipment = {hands = {}}, --
        position = options.position, --
        battleBuffer = options.battleBuffer or {}
    }
    setmetatable(entity.battleBuffer, battleBufferMeta)
    setmetatable(entity, entityMeta)
    entity.equipment.hands[1] = Item.new({id = "hand"})
    for k, v in pairs(options.equipment) do
        if k == "hands" then
            for key, value in pairs(v) do
                local weapon = Item.new(value)
                entity:equip(weapon, key)
            end
        else
            local item = Item.new(v)
            entity:equip(item, k)
        end
    end

    return entity
end

return Entity

--[=[
        Entity = {
            name = "name",
            surname = "surname",

            level = 1,
            exp = 0,
            expmax = 10,

            energy = 10,
            energymax = 10,
            mana = 10,
            manamax = 10,
            health = 10,
            healthmax = 10,

            hunger = 0,
            thirst = 0,
            fatigue = 0,
            strength = 1,
            agility = 1,
            dexterity = 1,
            luck = 1,
            vitality = 1,
            attentiveness = 1,

            reaction = 350,
            relationship = {},
            inventory = storage,
            equipment = {hands = {[1] = item, [2] = item}, bracers = item, head = item, chest = item, legs = item, foots = item},
            position = {loc = location, x = 500, y = 300},
            actions = {},

            battleBuffer = {battleAction},
            battleActionCooldown=false
            battle=battle,
            effects = {effect},
            graphics = {
                hpbar = display.object,
                icon = {image = display.object, hpdiagramm = display.object},
                image = display.object,
                equipment = {
                    hands = gui.swiper,
                    bracers = gui.button,
                    head = gui.button,
                    chest = gui.button,
                    legs = gui.button,
                    foots = gui.button
                }
            }
        }

        battleAction = {
            type = "attack" or "defense",
            enemy = entity,
            item = item,
            me = entity,
            event = function(self)
            end,
            another = battleAction,
            timer=timer or time
            time = os.time()
        }
-- ]=]
