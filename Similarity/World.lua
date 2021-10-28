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
local World = {settings = {minDistItemMerge = 0.05}}
local Entity = require(dir .. "Entity")

local function isPlayer(entity)
    return entity == entity.position.loc.world.players[1]
end

local lootMeta = {
    __index = {
        setObscurity = function(self, obscurity)
            self.obscurity = obscurity
        end
    }
}

local battleMeta = {
    __index = {
        getEntitySide = function(self, entity)
            for _, key in pairs({"left", "right"}) do
                for i, e in pairs(self[key]) do
                    if e == entity then
                        return key, i
                    end
                end
            end
        end,
        addEntity = function(self, entity, key)
            if key ~= "right" and key ~= "left" then
                assert(false, "Expected 'right' or 'left' key")
            end
            self[key][#self[key] + 1] = entity
            entity.battle = self
            if isPlayer(entity) then
                self.position.loc.graphics.displayBattle(self)
            else
                entity:think()
                entity.battleBuffer:run()
                if self.graphics and self.graphics.scene then
                    entity.graphics.displayhpbar(entity, key)
                    entity.graphics.hpbar:setProgress(entity.health / entity.healthmax)
                    self.graphics.scene[self.graphics.scene[key]]:add(entity.graphics.hpbar)
                end
            end
            entity:think()
            entity.battleBuffer:run()
        end,
        removeEntity = function(self, entity, key)
            if key and key ~= "right" and key ~= "left" then
                assert(false, "Expected 'right' or 'left' key")
            end
            for _, key in pairs(key and {key} or {"left", "right"}) do
                local num
                if type(entity) == "number" then
                    num = entity
                else
                    for i = 1, #self[key] do
                        if self[key][i] == entity then
                            num = i
                            break
                        end
                    end
                end
                if num then
                    self[key][num].battle = nil
                    table.remove(self[key], num)
                    if #self[key] == 0 then
                        local enemySide = (key == "left") and "right" or "left"
                        for i = #self[enemySide], 1, -1 do
                            self:removeEntity(i, enemySide)
                        end
                        if self.graphics then
                            self.graphics.scene:removeSelf()
                            self.graphics.icon:removeSelf()
                        end
                        self.position.loc:removeBattle(self)
                    end
                    return true
                end
            end
        end,
        run = function(self)
            local isPlayerThere
            for _, key in pairs({"left", "right"}) do
                for _, entity in pairs(self[key]) do
                    entity:think()
                    entity.battleBuffer:run()
                    if isPlayer(entity) then
                        isPlayerThere = true
                    end
                end
            end
            if isPlayerThere and not (self.graphics.scene and self.graphics.scene.removeSelf) then
                self.position.loc.graphics.displayBattle(self)
            end
        end
    }
}

local spotMeta = {
    __index = {
        addMob = function(self, options)
            local length = #self.mobs + 1
            self.mobs[length] = {}
            self.mobs[length].entity = options.entity
            self.mobs[length].max = options.max
            self.mobs[length].count = 0
            self.mobs[length].weight = options.weight
            self.mobs[length].time = options.time
            self.mobs[length].id = options.id
        end,
        run = function(self)
            if self.count < self.max and not self.spawned then
                self.spawned = true
                local weight = 0
                for _, v in pairs(self.mobs) do
                    if v.count < v.max then
                        weight = weight + v.weight
                    end
                end
                if weight > 0 then
                    weight = math.random(weight)
                    for _, v in ipairs(self.mobs) do
                        if v.count < v.max then
                            weight = weight - v.weight
                            if weight <= 0 then

                                timer.performWithDelay(v.time, function()
                                    self:createMob(v)
                                    self.spawned = nil
                                    self:run()
                                end)
                                return true
                            end
                        end
                    end
                end
            end
        end,
        createMob = function(self, mob)
            local posx = math.random(math.floor(self.position.x - self.radiusX),
                                     math.ceil(self.position.x + self.radiusX))
            local posy = math.random(math.floor(self.position.y - self.radiusY),
                                     math.ceil(self.position.y + self.radiusY))
            local e = (type(mob.entity) == "function") and mob.entity() or mob.entity
            local entity = Entity.new(e)
            entity.spot = self
            self.position.loc:addEntity(entity, {x = posx, y = posy})
            entity.timers = entity.timers or {}
            entity.timers.think = timer.performWithDelay(2000, function()
                entity:think()
            end, -1);

            self.count = self.count + 1
            mob.count = mob.count + 1
        end,
        removeMob = function(self, mob)
            for k, v in pairs(self.mobs) do
                local entity = type(v.entity) == "function" and v.entity() or v.entity
                if entity.name == mob.name and entity.surname == mob.surname then
                    v.count = v.count - 1
                    self.count = self.count - 1
                end
            end
            self:run()
        end
    }
}

local locationMeta = {
    __index = {
        addEntity = function(self, entity, position)
            local position = position or {loc = self, x = 0, y = 0}
            self.entities = self.entities or {}
            entity.position.x = position.x
            entity.position.y = position.y
            entity.position.loc = self
            self.entities[#self.entities + 1] = entity
            if self.graphics and self.graphics.group and self.graphics.group.insert then

                self.graphics.group:insert(self.graphics.displayEntity(entity))
            end
            -- ивент на отображение
        end,
        removeEntity = function(self, entity)
            if type(entity) == "table" then
                for i = 1, #self.entities do
                    if self.entities[i] == entity then
                        table.remove(self.entities, i)
                        if entity.graphics and entity.graphics.icon and entity.graphics.icon.removeSelf then
                            entity.graphics.icon:removeSelf()
                        end
                        return true
                    end
                end
            else
                assert(false, "Expected table")
            end
            if entity.graphics and entity.graphics.icon and entity.graphics.icon.removeSelf then
                entity.graphics.icon:removeSelf()
            end
        end,
        addBattle = function(self, battle)
            self.battles[#self.battles + 1] = battle
            battle.position.loc = self
            if self == self.world.players[1].position.loc then
                self.graphics = self.graphics or {}
                self.graphics.group:insert(battle.graphics.displayBattleIcon(battle))
            end
        end,
        removeBattle = function(self, battle)
            if type(battle) == "table" then
                for i = 1, #self.battles do
                    if self.battles[i] == battle then
                        table.remove(self.battles, i)
                    end
                end
            elseif type(battle) == "number" then
                table.remove(self.battles, i)
            else
                assert(false, "Expected table")
            end
        end,
        addLoot = function(self, loot)
            self.loot[#self.loot + 1] = loot
        end,
        addLootItem = function(self, item, pos)
            if #self.loot == 0 then
                return self:newLoot({pos = pos, items = Storage.new(20):createSlot(item, 1, true)})
            end
            local min = math.distance(self.loot[1].pos, pos)
            local minI = 1
            for i = 2, #self.loot do
                if math.distance(self.loot[i].pos, pos) < min then
                    min = math.distance(self.loot[i].pos, pos)
                    minI = i
                end
            end
            if min <= 0.05 then
                self.loot[minI].items:addItem(item, 1)
                return self.loot[minI]
            else
                return self:newLoot({pos = pos, items = Storage.new(20):createSlot(item, 1, true)})
            end
        end,
        removeLoot = function(self, loot)
            if type(loot) == "table" then
                for i = 1, #self.loot do
                    if self.loot[i] == loot then
                        table.remove(self.loot, i)
                    end
                end
            elseif type(loot) == "number" then
                table.remove(self.loot, i)
            else
                assert(false, "Expected number or table")
            end
        end,
        newLoot = function(self, options)
            local loot = {items = options.items, obscurity = options.obscurity or 0}
            loot.position = {x = options.position.x, y = options.position.y, loc = self}
            loot.items.parent = loot
            self:addLoot(loot)
            setmetatable(loot, lootMeta);
            return loot
        end,
        newBattle = function(self, options)
            local battle = {
                position = options.position or {loc = self, x = 50, y = 50},
                left = options.left or {},
                right = options.right or {},
                graphics = {
                    displayBattleIcon = self.graphics.displayBattleIcon,
                    displayBattle = self.graphics.displayBattle
                }
            }
            battle.position.loc = battle.position.loc or self
            setmetatable(battle, battleMeta)
            self:addBattle(battle)
            for _, entity in pairs(battle.left) do
                battle:addEntity(entity, "left")
            end
            for _, entity in pairs(battle.right) do
                battle:addEntity(entity, "right")
            end
            return battle
        end,
        newSpot = function(self, options)
            local pos = options.position
            pos.loc = pos.loc or self
            pos.x, pos.y = pos.x or 0, pos.y or 0
            local spot = {
                position = {x = pos.x, y = pos.y, loc = pos.loc},
                radiusX = options.radiusX or 500,
                radiusY = options.radiusY or 500,
                mobs = options.mobs or {},
                max = options.max,
                count = options.count or 0
            }

            setmetatable(spot, spotMeta)
            self.spots[#self.spots + 1] = spot
            return spot
        end,
        removeSpot = function(self, spot)
            for k, v in pairs(self.spots) do
                if v == spot then
                    tabale.remove(self.spots, k)
                end
            end
        end
    }
}

local worldMeta = {
    __index = {
        clear = function(self, entity)
            local location = entity.position.loc
            if not location:removeEntity(entity) then
                print("Didn't find entity" .. entity.name)
            end
            for k, v in pairs(location.battles) do
                if v:removeEntity(entity) then
                    break
                end
            end
            for k, battleAction in pairs(entity.battleBuffer) do
                if battleAction.timer then
                    timer.cancel(battleAction.timer)
                end
                if battleAction.another.timer then
                    timer.cancel(battleAction.another.timer)
                end
            end
            return true
        end,
        newLocation = function(self, options)
            local location = {
                id = options.id,
                name = options.name,
                desc = options.desc,
                texture = options.texture,
                path = options.path or {},
                loot = options.loot or {},
                entities = options.entities or {},
                battles = options.battles or {},
                world = self,
                spots = options.spots or {},
                width = options.width or 2000,
                height = options.height or 1000
            }
            setmetatable(location, locationMeta)
            self.locations[location.id] = location
            for _, path in pairs(location.path) do
                path.position.loc = location
            end
            return location
        end,
        run = function(self)
            for k, location in pairs(self.locations) do
                for _, entity in pairs(location.entities) do
                    entity.timers = entity.timers or {}
                    entity.timers.think = timer.performWithDelay(2000, function()
                        entity:think()
                    end, -1)
                end
                for _, battle in pairs(location.battles) do
                    battle:run()
                end
                for _, spot in pairs(location.spots) do
                    spot:run()
                end
            end
        end
    }
}

World.new = function()
    local world = {locations = {}}
    setmetatable(world, worldMeta)
    return world
end

World.reload = function(world)
    setmetatable(world, worldMeta)
    for k, location in pairs(world.locations) do
        setmetatable(location, locationMeta)
        for _, entity in pairs(location.entities) do
            Entity.reload(entity)
        end
        for _, battle in pairs(location.battles) do
            setmetatable(battle, battleMeta)
        end
        for _, spot in pairs(location.spots) do
            setmetatable(spot, spotMeta)
        end
        for _, loot in pairs(location.loot) do
            setmetatable(loot, lootMeta)
        end
    end
end

return World
--[=[

location = {
    id = "string",
    height=100,
    width=100,
    name = "string",
    desc = function(world)
        return "Description"
    end,
    texture = function()
    end,
    path = {{id = "string", pos = {1, 0.5}, image = "string", graphics = gui.icon}},
    entities = {entity},
    loot = {{items = st, pos = {0.2, 0.2}, obscurity = -1}},
    battles = {battle},
    world = world,
    spots={spot},
    graphics = {
        texture = display.object,
        info = {
            name = display.text, 
            desc = display.text, 
            minimap = display.container, 
            loot = display.object
        }
    }
}

world = {
    time = {
        y = 1000, 
        m = 1, 
        d = 1, 
        h = 1
    }, 
    weather = {}, 
    locations = {location}, 
    graphics = widget.scrollView
}

battle = {
    left = {entity},
    right = {entity},
    pos = {
        loc = location,
        x = 300,
        y = 350
    }, 
    graphics = gui.icon
}

spot ={
    position={loc=location,x=50,y=50},
    radiusX=25,
    radiusY=25,
    mobs={{entity=entity,max=10,count=2,weight=5,time=10000}},
    max=10,
    count=2
}
function findItems()
    local l = world.locations[self.position[1]]
    for key, loot in pairs(l.loot) do
        if (obscurity == -1) then

        end
        local posx, posy = loot.pos[1], loot.pos[2]
        local x, y = self.position[2], self.position[3]
        local dist = math.sqrt((posx - x) ^ 2 + (posy - y) ^ 2)
        local r = math.random()
        if (r * obscurity ^ (0.5) * dist < 1) then

        end
    end
end
-- ]=]
