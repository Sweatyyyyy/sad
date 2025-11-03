function toggleWeather(boolean)
    if boolean then
        TriggerEvent('qb-weathersync:client:EnableSync') -- for qb-weathersync enable weather & time sync
    else
        TriggerEvent('qb-weathersync:client:DisableSync') -- for qb-weathersync disable weather & time sync
    end
end