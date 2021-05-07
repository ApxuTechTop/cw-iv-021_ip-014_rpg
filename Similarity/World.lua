local Gui = require("Gui")

local World = {settings = {minDistItemMerge = 0.05}}

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
            if entity == self.position.loc.world.players[1] then
                Gui.displayBattle(self)
            else
                entity:think()
                entity.battleBuffer:run()
                if self.graphics and self.graphics.scene then
                    local barWidth = Gui.settings.sizes.battle.barWidth
                    local barHeight = Gui.settings.sizes.battle.barHeight
                    entity.graphics = entity.graphics or {}
                    entity.graphics.hpbar = Gui.createProgressView {
                        bgShape = "roundedRect",
                        barShape = "roundedRect",
                        width = barWidth,
                        height = barHeight,
                        fill = {1, 0, 0},
                        isRight = self.graphics.scene[key] == "rightBars" and true
                    }
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
                    print(key, num)
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
    }
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
                width = options.width or 2000,
                height = options.height or 1000
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
