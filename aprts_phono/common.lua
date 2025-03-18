function GetRandomPreset()
    local presets = {}
    for preset, _ in pairs(Config.Presets) do
        table.insert(presets, preset)
    end
    if #presets > 0 then
        return presets[math.random(#presets)]
    else
        return ''
    end
end

function GetHandleFromCoords(coords)
    return GetHashKey(string.format('%d_%d_%d',
            math.floor(coords.x * 10),
            math.floor(coords.y * 10),
            math.floor(coords.z * 10))
    )
end

function Clamp(val, min, max, def)
    if not val then
        return def
    elseif val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end
