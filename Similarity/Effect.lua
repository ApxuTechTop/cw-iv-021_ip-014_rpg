--[=[
local standartEffects = {
    poison = function(entity, damage) return function() entity.health = entity.health - damage end end
}
local standartTime = {
    log_time = function(base) return function(iteration) return math.log(iteration, base) end end
}

effect = {
    time = function() end,
    count = function() end,
    foo = function() end,
    iteration = 1,
    params = {time = {"time_id", params}, count = {"count_id", params}, foo = {"foo_id", params}}
}
Effect.update(effect)
entity[n].effects[#entity[n].effects] = Effect.new{foo = {"poison", 10}, count = 9, time = {"log_time", 2}}
--]=] 
