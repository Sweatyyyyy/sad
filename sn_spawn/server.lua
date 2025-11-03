QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('sn_spawn:server:setBucket', function(bucket)
    local src = source
    if not tonumber(bucket) then bucket = src end
    print(src, bucket)
    SetPlayerRoutingBucket(src, bucket)
end)

QBCore.Functions.CreateCallback('sn_spawn:callback:getHouses', function(_, cb, cid)
    if cid ~= nil then
        local houses = nil
        if Config.housingSystem == 'qb' then
            houses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {cid})
        elseif Config.housingSystem == 'ps-housing' then
            houses = MySQL.query.await('SELECT * FROM properties WHERE owner_citizenid = ?', {cid})
        end
        if houses[1] ~= nil then
            cb(houses)
        else
            cb({})
        end
    else
        cb({})
    end
end)