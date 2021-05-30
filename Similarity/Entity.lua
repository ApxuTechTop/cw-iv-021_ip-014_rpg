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
local Storage = require(dir .. "Storage")
local Item = Storage.Item
local ItemDataBase = require(dir .. "ItemDataBase")

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
            if me.position and me.position.loc and me == me.position.loc.world.players[1] then
                me.graphics.displayBattleAction(self[last]) -- todo
            else
                self:run()
            end

            return self[last]
        end, -- TODO interface
        remove = function(self, battleAction)
            if battleAction.timer then
                timer.cancel(battleAction.timer)
            end
            if battleAction.graphics and battleAction.graphics.removeSelf then
                battleAction.graphics:removeSelf()
            end
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
        moveSpeed = 500,

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
            if self.graphics and self.graphics.hpbar then
                self.graphics.hpbar:setProgress((health > 0 and health or 0) / self.healthmax)
            end
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

        move = function(self, position, foo)
            local distance = math.distance(self.position, position)
            local steps = math.ceil(distance / 100)
            local moveSpeedX = (position.x - self.position.x) / steps
            local moveSpeedY = (position.y - self.position.y) / steps
            self.transitions = self.transitions or {}
            if self.transitions.move then
                transition.cancel(self.transitions.move)
            end
            self.timers = self.timers or {}
            if self.timers.move then
                timer.cancel(self.timers.move)
            end
            self.transitions.move = transition.to(self.graphics.icon, {
                x = position.x,
                y = position.y,
                time = distance / self.moveSpeed * 1000
            })
            self.timers.move = timer.performWithDelay(distance / self.moveSpeed * 1000 / steps, function(event)
                self.position.x = self.position.x + moveSpeedX
                self.position.y = self.position.y + moveSpeedY
                if event.count == steps and foo then
                    foo()
                end
            end, steps)
        end,

        getDamage = function(self, damage) -- TODO interface
            local armor = 0
            for k, v in pairs(self.equipment) do
                if k ~= "hands" then
                    armor = armor + v.armor
                end
            end
            local totalDamage = (damage - armor) / (self.vitality or 1)
            self:setHealth(self.health - ((totalDamage > 0.5) and totalDamage or 0.5))
            for k, v in pairs(self.equipment) do
                if k ~= "hands" then
                    if v:getHarm(damage * v.armor / armor) then
                        self.equipment[k] = nil
                    end
                end
            end
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
            if self.graphics then
                if self.graphics.hpbar then
                    self.graphics.hpbar:removeSelf()
                end
                if self.graphics.icon then
                    self.graphics.icon:removeSelf()
                end
            end
            if self.position and self.position.loc and self.position.loc.world:clear(self) then
                return true
            else
                -- assert(false, "Didn't find entity to clear")
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
                if #self.battle[enemySide] > 0 then
                    local enemyNum = math.random(#self.battle[enemySide])
                    for key, weapon in pairs(self.equipment.hands) do
                        if weapon.tags:find("Broken") then
                            self:unequip(key) -- todo
                        else
                            weapon:tryAttack(self, self.battle[enemySide][enemyNum])
                        end
                    end
                end
            end
        end,
        equip = function(self, item, tag)
            if item.tags:find(
                ({head = "Head", chest = "Chest", legs = "Legs", foots = "Foots", bracers = "Bracers"})[tag] or "Weapon") then
                self:unequip(tag)
                if type(tag) == "number" then
                    self.equipment.hands[tag] = item
                else
                    self.equipment[tag] = item
                end
                return true
            end
            return false
        end,
        unequip = function(self, tag)
            if type(tag) == "number" then
                if not self.equipment.hands[tag] then
                    return true
                end
                if self.equipment.hands[tag].id == "hand" then
                    self.equipment.hands[1] = nil
                    self.equipment.hands[2] = nil
                    return true
                end
                self.inventory:addItem(self.equipment.hands[tag])
                self.equipment.hands[tag] = nil
                if not (self.equipment.hands[1] or self.equipment.hands[2]) then
                    self.equipment.hands[1] = Item.new({id = "hand"})
                    self.equipment.hands[2] = Item.new({id = "hand"})
                end
                return true
            else
                if not self.equipment[tag] or self.equipment[tag].tags:find("Broken") then
                    self.equipment[tag] = nil
                    return true
                end
                self.inventory:addItem(self.equipment[tag])
                self.equipment[tag] = nil
                return true
            end
            return false
        end
    }
}

Entity.new = function(options)
    local entity = {
        name = options.name, --
        surname = options.surname, --
        icon = options.icon,
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
        position = options.position or {}, --
        battleBuffer = options.battleBuffer or {}
    }
    setmetatable(entity.battleBuffer, battleBufferMeta)
    setmetatable(entity, entityMeta)
    entity.equipment.hands[1] = Item.new({id = "hand"})
    entity.equipment.hands[2] = Item.new({id = "hand"})
    for k, v in pairs(options.equipment or {}) do
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
    local location = entity.position.loc
    if location and location.graphics and location.graphics.group then
        location.graphics.group:insert(location.graphics.displayEntity(entity)) -- todo
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
                displayBattleAction=function() end,
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
