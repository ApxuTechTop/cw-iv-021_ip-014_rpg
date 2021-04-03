local Entity = {}
Entity.new = function()

end
local function entityDeath(self)

end

local function entityAI(self)

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
        energymax = 10
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
        inventory = {count = 0, countmax = 10, backpack = {item}},
        equipment = {
            hands = {[1] = item, [2] = item},
            bracers = item,
            head = item,
            chest = item,
            legs = item,
            foots = item
        }
        position = {"id", 0.5, 0.5},
        actions = {},
        effects = {effect},
        graphics = {hpbar = display.object, icon = {image = display.object, hpdiagramm = display.object}, image = display.object}
}
--]=]
