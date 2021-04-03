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
                error("Expected number or table", 1)
            end
        end
    }
}

local battleMeta = {
    addEntity = function(self, entity, key)
        if key ~= "right" and key ~= "left" then
            error("Expected 'right' or 'left' key")
        end
        self[key][#self[key] + 1] = entity
        -- ивент на отображение
    end,
    removeEntity = function(self, entity, key)
        if key and key ~= "right" and key ~= "left" then
            error("Expected 'right' or 'left' key")
        end
        if key then
            if type(entity) == "table" then
                for i = 1, #self[key] do
                    if self[key][i] == entity then
                        table.remove(self[key], i)
                    end
                end
            elseif type(entity) == "number" then
                table.remove(self[key], i)
            else
                error("Expected number or table", 1)
            end
        else
            for _, key in pairs({"left", "right"}) do
                if type(entity) == "table" then
                    for i = 1, #self[key] do
                        if self[key][i] == entity then
                            table.remove(self[key], i)
                        end
                    end
                elseif type(entity) == "number" then
                    table.remove(self[key], i)
                else
                    error("Expected number or table", 1)
                end
            end
        end
    end
}

local locationMeta = {
    __index = {
        addEntity = function(self, entity)
            self.entities[#self.entities + 1] = entity
            -- ивент на отображение
        end,
        removeEntity = function(self, entity)
            if type(entity) == "table" then
                for i = 1, #self.entities do
                    if self.entities[i] == entity then
                        table.remove(self.entities, i)
                    end
                end
            elseif type(entity) == "number" then
                table.remove(self.entities, i)
            else
                error("Expected number or table", 1)
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
                error("Expected number or table", 1)
            end
        end,
        addLoot = function(self, loot)
            self.loot[#self.loot + 1] = loot
        end,
        addLootItem = function(self, item, pos)
            -- TODO добавить item в loot ближайший к pos
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
                error("Expected number or table", 1)
            end
        end,
        newLoot = function(options)
            local loot = {}
            setmetatable(loot, lootMeta);
            return loot
        end,
        newBattle = function(options)
            local battle = {pos = options.pos or {0.5, 0.5}, left = options.left, right = options.right}
            setmetatable(battle, battleMeta)
            return battle
        end
    }
}

World.newLocation = function(options)
    local location = {
        id = options.id,
        name = options.name,
        desc = options.desc,
        texture = options.texture,
        path = options.path,
        loot = options.loot,
        entities = options.entities,
        battles = options.battles
    }
    setmetatable(location, locationMeta);

    return location
end

World.new = function()
    local world = {}

    return world
end

--[=[

    location = {
        id = "string",
        name = "string",
        desc = function(world)
            return "Description"
        end,
        texture = function()  end,
        path = {{id = "string", pos = {1, 0.5}, image = "string"}},
        entities = {},
        loot = {{items = {item}, pos = {0.2, 0.2}, obscurity = -1}},
        battles = {battle}
    }

    world = {
        time = {
            y = 1000, 
            m = 1, 
            d = 1, 
            h = 1
        }
        weather = {},
        locations = {location}
    }

    battle = {
        left = {entity.id},
        right = {entity.id},
        pos = {0.3, 0.3}
    }

    function findItems()
        local l = world.locations[self.position[1]]
        for key, loot in pairs(l.loot) do
            if (obscurity == -1) then

            end
            local posx, posy = loot.pos[1], loot.pos[2]
            local x, y = self.position[2], self.position[3]
            local dist = math.sqrt((posx - x)^2 + (posy - y)^2)
            local r = math.random()
            if (r * obscurity^(0.5) * dist < 1) then

            end
        end
    end
-- ]=]
