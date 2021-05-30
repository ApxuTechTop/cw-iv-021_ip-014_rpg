local World = require("World")
local world = World.new()
--[=[local testLocation = world:newLocation({
    id = "test_location",
    name = "Test location",
    desc = "Small location",
    height = 200,
    width = 200
})--]=]
local town = world:newLocation({
    id = "main_town",
    name = "Town",
    desc = function(self)
        if self.world.time.h < 12 then
            return "Какой чудесный день"
        else
            return "Какой хороший день"
        end
    end,
    width = 5000,
    height = 3000,
    patg = {
        {id = "forest", pos = {5000, 800}}, {id = "rabbit_meadow", pos = {5000, 2500}},
        {id = "tavern", pos = {2500, 2000}}
    }
})

local rabbit_meadow = world:newLocation({
    id = "rabbit_meadow",
    name = "rabbit_meadow",
    desc = function(self)
        if self.world.time.h < 12 then
            return "Какой чудесный день"
        else
            return "Какой хороший день"
        end
    end,
    height = 720 * 3,
    width = 1520 * 3,
    patg = {{id = "mait_town", pos = {0, 700}}, {id = "forest", pos = {2000, 0}}},
    texture = function(self)
        local group = display.newGroup()
        local bg = display.newRect(0, 0, self.width, self.height)
        bg.anchorX, bg.anchorY = 0, 0
        bg:setFillColor(0.1, 0.6, 0.1)
        group:insert(bg)
        for i = 0, self.width - 500, 500 do
            for j = 0, self.height - 500, 500 do
                local circle = display.newCircle(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 15))
                local rect = display.newRect(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 50),
                                             math.random(1, 10))
                rect.anchorX, rect.anchorY = 0, 0
                rect:setFillColor(0, math.random(3, 5) / 10, 0)
                circle:setFillColor(0, math.random(3, 5) / 10, 0)
                group:insert(circle)
            end
        end
        return group
    end
})

local forest = world:newLocation({
    id = "forest",
    name = "forest",
    desc = function(self)
        if self.world.time.h < 12 then
            return "Какой чудесный день"
        else
            return "Какой хороший день"
        end
    end,
    width = 7500,
    height = 5500,
    path = {{id = "mait_town", pos = {0, 4500}}, {id = "rabbit_meadow", pos = {2000, 5500}}},
    texture = function(self)
        local group = display.newGroup()
        local bg = display.newRect(0, 0, self.width, self.height)
        bg.anchorX, bg.anchorY = 0, 0
        bg:setFillColor(0, 0.4, 0)
        group:insert(bg)
        for i = 0, self.width - 500, 500 do
            for j = 0, self.height - 500, 500 do
                local circle = display.newCircle(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 15))
                local rect = display.newRect(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 50),
                                             math.random(1, 10))
                rect.anchorX, rect.anchorY = 0, 0
                rect:setFillColor(0.5, 0.5, 0.5)
                circle:setFillColor(0.5, 0.5, 0.5)
                group:insert(circle)
            end
        end
        return group
    end
})
local tavern = world:newLocation({
    id = "tavern",
    name = "tavern",
    desc = function(self)
        if self.world.time.h < 12 then
            return "Какой чудесный день"
        else
            return "Какой хороший день"
        end
    end,
    width = 3000,
    height = 2500,
    patg = {{id = "mait_town", pos = {0, 1250}}}
})
