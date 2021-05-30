table.equal = function(tab1, tab2, stack) -- TODO
    local b = true
    local stack = stack or {}
    stack[tab1] = stack[tab1] or {}
    stack[tab2] = stack[tab2] or {}

    stack[tab1][tab2] = true
    for k, v in pairs(tab1) do
        if not (tab2[k] == v) then
            if type(tab2[k]) == "table" and type(v) == "table" then
                if stack[v] and not stack[v][tab2[k]] then
                    b = table.equal(v, tab2[k], stack)
                    if not b then
                        return b
                    end
                end
            else
                return false
            end
        end
    end
    if not stack[tab2][tab1] then
        b = table.equal(tab2, tab1, stack)
    end
    if b then
        return true
    end
end

table.fullCopy = function(tab, stack)
    local stack = stack or {}
    local tabCopy = {}
    stack[tab] = tabCopy
    for k, v in pairs(tab) do
        if type(v) == "table" then
            if not stack[v] then
                tabCopy[k] = table.fullCopy(v, stack)
                setmetatable(tabCopy[k], getmetatable(v))
            else
                tabCopy[k] = stack[v]
            end
        else
            tabCopy[k] = v
        end
    end
    return tabCopy
end

math.distance = function(pos1, pos2)
    return math.sqrt((pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2)
end

math.critChance = function(entity, item)
    return (entity.dexterity ^ item.accuracy + entity.luck / 2) * 4
end

math.evasionChance = function(me, enemy)
    return (me.agility / enemy.agility) * (me.agility - enemy.agility) * 5
end
