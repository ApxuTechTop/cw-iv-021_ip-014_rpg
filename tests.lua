local test = require("thirdparty.u-test")

local timer = {timers = {}, time = 0}

timer.run = function()
    local timer = timer
    local timers = timer.timers
    local length = #timers
    local lastTimer = timers[length]
    timer.time = lastTimer.fireTime
    lastTimer.listener()
    lastTimer.iterations = lastTimer.iterations - 1
    if lastTimer.iterations == 0 then
        table.remove(timers, length)
    else
        lastTimer.fireTime = timer.time + lastTimer.delay
        for i = length, 2, -1 do
            local left = timers[i - 1]
            local rigth = timers[i]
            if rigth.fireTime > left.fireTime then
                rigth, left = left, rigth
            end
        end
    end
end

timer.performWithDelay = function(delay, listener, iterations)
    local iterations = iterations or 1
    table.insert(timer.timers,
                 {delay = delay, listener = listener, iterations = iterations, fireTime = timer.time + delay});
    for i = #timer.timers, 2, -1 do
        if timer.timers[i].fireTime > timer.timers[i - 1].fireTime then
            timer.timers[i], timer.timers[i - 1] = timer.timers[i - 1], timer.timers[i]
        end
    end
end
timer.performWithDelay(1000, function()
end, 2)
timer.run()

local function setrandom(...)
    local i = 0
    return function()
        i = i + 1
        return arg[i]
    end
end
