local World = {settings = {minDistItemMerge = 0.05}}
local Entity = require("Entity")
local lootMeta = {
    __index = {
        setObscurity = function(self, obscurity)
            self.obscurity = obscurity
        end,
        addItem = function(self, item)
            self.items[#self.items + 1] = item
        end,
        removeItem = function(self, item)
            if type(item) == "table" then
                for i = 1, #self.items do
                    if self.items[i] == item then
                        table.remove(self.items, i)
                    end
                end
            elseif type(item) == "number" then
                table.remove(self.items, i)
            else
                assert(false, "Expected number or table")
            end
        end
    }
}

local battleMeta = {
    __index = {

        addEntity = function(self, entity, key)
            if key ~= "right" and key ~= "left" then
                assert(false, "Expected 'right' or 'left' key")
            end
            self[key][#self[key] + 1] = entity
            entity.battle = self
            -- ивент на отображение
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
                    print(key, num)
                    self[key][num].battle = nil
                    table.remove(self[key], num)
                    if #self[key] == 0 then
                        local enemySide = (key == "left") and "right" or "left"
                        for i = #self[enemySide], 1, -1 do
                            self:removeEntity(i, enemySide)
                        end
                    end
                    return true
                end
            end
        end,
        run = function(self)
            for _, entity in pairs(self.left) do
                entity:think()
                entity.battleBuffer:run()
            end
            for _, entity in pairs(self.right) do
                entity:think()
                entity.battleBuffer:run()
            end
        end
    }
}

local spotMeta = {
    __index = {
        addMob = function(self, options)
            local length = #self.mobs + 1
            self.mobs[length].entityOptions = options.entityOptions
            self.mobs[length].max = options.max
            self.mobs[length].count = 0
            self.mobs[length].weigth = options.weigth
            self.mobs[length].time = options.time
        end,
        run = function(self)
            if self.count < self.max and not self.spawned then
                self.spawned = true
                local weigth
                for _, v in pairs(self.mobs) do
                    if v.count < v.max then
                        weigth = weigth + v.weigth
                    end
                end
                weigth = math.random(weigth)
                for _, v in ipairs(self.mobs) do
                    if v.count < v.max then
                        weigth = weigth - v.weigth
                        if weigth <= 0 then
                            timer.performWithDelay(v.time, function()
                                createMob(v)
                                self.spawned = nil
                                self:run()
                            end)
                            return true
                        end
                    end
                end
            end
        end,
        createMob = function(self, mob)
            local posx = random(math.floor(self.position.x - self.radiusX), math.floor(self.position.x + self.radiusX))
            local posy = random(math.floor(self.position.y - self.radiusY), math.floor(self.position.y + self.radiusY))
            mob.entityOptions.position = {loc = self.loc, x = posx, y = posy}
            local entity = Entity.new(mob.entityOptions)
            entity.spot = self
            entity.position.loc:addEntity(entity)
        end,
        removeMob = function(self, mob)
            for k, v in pairs(self.mobs) do
                if v.entityOptions.name == mob.name and v.entityOptions.surname == mob.surname then
                    v.count = v.count - 1
                    self.count = self.count - 1
                end
            end
        end
    }
}

local locationMeta = {
    __index = {
        addEntity = function(self, entity, position)
            self.entities = self.entities or {}
            entity.position = position or {loc = self, x = 0, y = 0}
            self.entities[#self.entities + 1] = entity

            -- ивент на отображение
        end,
        removeEntity = function(self, entity)
            if type(entity) == "table" then
                for i = 1, #self.entities do
                    if self.entities[i] == entity then
                        table.remove(self.entities, i)
                        return true
                    end
                end
            else
                assert(false, "Expected table")
            end
        end,
        addBattle = function(self, battle)
            self.battles[#self.battles + 1] = battle
            -- ивент на отображение
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
                return locationMeta.__index.newLoot(self, {pos = pos, items = {item}})
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
                self.loot[minI].items[#self.loot[minI].items + 1] = item
                return self.loot[minI]
            else
                return locationMeta.__index.newLoot(self, {pos = pos, items = {item}})
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
            local loot = {}
            setmetatable(loot, lootMeta);
            return loot
        end,
        newBattle = function(self, options)
            local battle = {
                position = options.position or {loc = self, x = 50, y = 50},
                left = options.left,
                right = options.right
            }
            battle.position.loc = battle.position.loc or self
            setmetatable(battle, battleMeta)
            self.battles = self.battles or {}
            self.battles[#self.battles + 1] = battle
            for _, entity in pairs(battle.left) do
                entity.battle = battle
            end
            for _, entity in pairs(battle.right) do
                entity.battle = battle
            end
            return battle
        end
    },
    newSpot = function(self, options)
        local spot = {
            position = {loc = options.loc or self, x = options.x, y = options.y},
            radiusX = options.radiusX or 50,
            radiusY = options.radiusY or 50,
            mobs = options.mobs,
            max = options.max,
            count = options.count or 0
        }
        setmetatable(spot, spotMeta)
        self.spots[#self.spots + 1] = spot
    end,
    removeSpot = function(self, spot)
        for k, v in pairs(self.spots) do
            if v == spot then
                tabale.remove(self.spots, k)
            end
        end
    end
}

local worldMeta = {
    __index = {
        clear = function(self, entity)
            local location = entity.position.loc
            if not location:removeEntity(entity) then
                assert(false, "Didn't find entity")
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
                path = options.path,
                loot = options.loot,
                entities = options.entities,
                battles = options.battles,
                world = self,
                spots = options.spots or {}
            }
            setmetatable(location, locationMeta)
            self.locations[location.id] = location
            return location
        end
    }
}

World.new = function()
    local world = {locations = {}}
    setmetatable(world, worldMeta)
    return world
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
    loot = {{items = {item}, pos = {0.2, 0.2}, obscurity = -1}},
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
    mobs={{entity=entity,max=10,count=2,weigth=5,time=10000}},
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
