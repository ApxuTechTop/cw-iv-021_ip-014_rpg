--[=[local testLocation = world:newLocation({
    id = "test_location",
    name = "Test location",
    desc = "Small location",
    height = 200,
    width = 200
})--]=] --
local Locations = {
    main_town = {
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
        height = 3000
    },
    rabbit_meadow = {
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
        texture = function(self)
            local group = display.newGroup()
            local bg = display.newRect(0, 0, self.width, self.height)
            bg.anchorX, bg.anchorY = 0, 0
            bg:setFillColor(0.1, 0.6, 0.1)
            group:insert(bg)
            for i = 0, self.width - 500, 500 do
                for j = 0, self.height - 500, 500 do
                    local circle = display.newCircle(math.random(i, i + 500), math.random(j, j + 500),
                                                     math.random(5, 15))
                    local rect = display.newRect(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 50),
                                                 math.random(1, 10))
                    rect.anchorX, rect.anchorY = 0, 0
                    rect:setFillColor(0, math.random(3, 5) / 10, 0)
                    circle:setFillColor(0, math.random(3, 5) / 10, 0)
                    group:insert(circle)
                    group:insert(rect)
                end
            end
            return group
        end
    },
    forest = {
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
        texture = function(self)
            local group = display.newGroup()
            local bg = display.newRect(0, 0, self.width, self.height)
            bg.anchorX, bg.anchorY = 0, 0
            bg:setFillColor(0, 0.4, 0)
            group:insert(bg)
            for i = 0, self.width - 500, 500 do
                for j = 0, self.height - 500, 500 do
                    local circle = display.newCircle(math.random(i, i + 500), math.random(j, j + 500),
                                                     math.random(5, 15))
                    local rect = display.newRect(math.random(i, i + 500), math.random(j, j + 500), math.random(5, 50),
                                                 math.random(1, 10))
                    rect.anchorX, rect.anchorY = 0, 0
                    rect:setFillColor(0.5, 0.5, 0.5)
                    circle:setFillColor(0.5, 0.5, 0.5)
                    group:insert(circle)
                    group:insert(rect)
                end
            end
            return group
        end
    },
    tavern = {
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
        height = 2500
    }
}
do
    local main_town_to_forest = {id = "forest", position = {x = 5000, y = 800, loc = Locations.main_town}}
    local main_town_to_rabbit_meadow = {
        id = "rabbit_meadow",
        position = {x = 5000, y = 2500, loc = Locations.main_town}
    }
    local main_town_to_tavern = {id = "tavern", position = {x = 2500, y = 2000, loc = Locations.main_town}}

    local rabbit_meadow_to_main_town = {id = "main_town", position = {x = 0, y = 700, loc = Locations.rabbit_meadow}}
    local rabbit_meadow_to_forest = {id = "forest", position = {x = 2000, y = 0, loc = Locations.rabbit_meadow}}

    local forest_to_main_town = {id = "main_town", position = {x = 0, y = 4500, loc = Locations.forest}}
    local forest_to_rabbit_meadow = {id = "rabbit_meadow", position = {x = 2000, y = 5500, loc = Locations.forest}}

    local tavern_to_main_town = {id = "main_town", position = {x = 0, y = 1250, loc = Locations.tavern}}

    main_town_to_forest.another = forest_to_main_town
    main_town_to_rabbit_meadow.another = rabbit_meadow_to_main_town
    main_town_to_tavern.another = tavern_to_main_town

    rabbit_meadow_to_main_town.another = main_town_to_rabbit_meadow
    rabbit_meadow_to_forest.another = forest_to_rabbit_meadow

    forest_to_main_town.another = main_town_to_forest
    forest_to_rabbit_meadow.another = rabbit_meadow_to_forest

    tavern_to_main_town.another = main_town_to_tavern

    Locations.main_town.path = {main_town_to_forest, main_town_to_rabbit_meadow, main_town_to_tavern}
    Locations.rabbit_meadow.path = {rabbit_meadow_to_main_town, rabbit_meadow_to_forest}
    Locations.forest.path = {forest_to_main_town, forest_to_rabbit_meadow}
    Locations.tavern.path = {tavern_to_main_town}
end
return Locations
