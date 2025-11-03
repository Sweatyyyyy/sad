local QBCore = exports['qb-core']:GetCoreObject()
local inSpawnMenu = false
local camera = nil
local scene = nil
local duiObj = nil
local locations = {}
local isNewPlayer = false

---=============== [[ FUNCTIONS ]] ===============---

local function fadeScreen(bool)
    if bool then
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(0)
        end
    else
        if IsScreenFadedOut() then
            DoScreenFadeIn(500)
            while not IsScreenFadedIn() do
                Wait(0)
            end
        end
    end
end

local sfHandle = lib.requestScaleformMovie('generic_texture_renderer')
if not sfHandle or not HasScaleformMovieLoaded(sfHandle) then
    print("Error: Скалиформата не можа да се зареди!")
    return
end

local sfHandle = lib.requestScaleformMovie('generic_texture_renderer')
if not sfHandle or not HasScaleformMovieLoaded(sfHandle) then
    print("Error: Скалиформата не можа да се зареди!")
    return
end



local function toggleWeatherClosed(boolean)
    toggleWeather(boolean)
    if not boolean then
        Wait(500)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist('EXTRASUNNY')
        SetWeatherTypeNow('EXTRASUNNY')
        SetWeatherTypeNowPersist('EXTRASUNNY')
        NetworkOverrideClockTime(11, 0, 0)
    end
end

local function cursorLoop(bool)
    CreateThread(function()
        local nX = 0
        local nY = 0
        local w, h = math.floor(1920* 0.75), math.floor(1080* 0.75) 
        local minX, maxX = ((w - (w / 2)) / 2), (w - (w / 4))
        local totalX = minX - maxX
        local minY, maxY = 120, 800 ---((h - (h / 2)) / 2), (h - (h / 4))
        local totalY = minY - maxY
        lib.requestStreamedTextureDict('fib_pc')
        while inSpawnMenu do
            nX = GetControlNormal(0, 239) * w
            nY = GetControlNormal(0, 240) * h
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 106, true)
            if nX ~= mX or nY ~= mY then
                mX = nX; mY = nY
                local duiX = -w * ((mX - minX) / totalX) 
                local duiY = -h * ((mY - minY) / totalY)
                SendDuiMouseMove(duiObj, math.floor(duiX), math.floor(duiY))
            end
            DrawSprite('fib_pc', 'arrow', mX / w, mY / h, 0.005, 0.01, 0.0, 255, 255, 255, 255)
            if IsControlPressed(2, 15) then  -- scroll up
                SendDuiMouseWheel(duiObj, 20, 0)
            end
            if IsControlPressed(2, 14) then -- scroll down
                SendDuiMouseWheel(duiObj, -20, 0)
            end
            if IsDisabledControlJustPressed(0, 24) then
                SendDuiMouseDown(duiObj, 'left')
            elseif IsDisabledControlJustReleased(0, 24) then
                SendDuiMouseUp(duiObj, 'left')
            end
            Wait(0)
        end
    end)
end

local function drawScaleForm()
    inSpawnMenu = true
    local sfHandle = lib.requestScaleformMovie('generic_texture_renderer')
    local txd = CreateRuntimeTxd('snspawn_b_dict')
    duiObj = CreateDui('https://cfx-nui-sn_spawn/build/index.html', 1280, 720) --https://cfx-nui-sn_spawn/build/index.html -- http://localhost:3000
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'snspawn_b_txd', dui)
    Wait(10)
    PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
    PushScaleformMovieMethodParameterString('snspawn_b_dict')
    PushScaleformMovieMethodParameterString('snspawn_b_txd')
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(1280)
    PushScaleformMovieFunctionParameterInt(720)
    PopScaleformMovieFunctionVoid()
    local prop = GetClosestObjectOfType(785.19, -1369.46, 25.55, 5.0, `prop_busstop_05`, false, false, false)
    while prop == 0 do Wait(100) end
    cursorLoop(true)
    CreateThread(function()
        while inSpawnMenu and duiObj do
            if (prop and sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
                local offset = GetOffsetFromEntityInWorldCoords(prop, -1.8665, -0.537, 2.02)
                DrawScaleformMovie_3dSolid(sfHandle, offset, 1.0, 0.0, 180.0, 2.0, 2.0, 2.0, 0.0435, 0.0645, 2)
            end
            SetUseHiDof()

            Wait(0)
        end
    end)
    Wait(1000)
    SendDuiMessage(duiObj, json.encode({
        action = 'setup',
        data = {
            spawns = locations,
            style = Config.style,
        }
    }))
    fadeScreen(false)
end

local function cleanup()
    local ped = PlayerPedId()
	SetCamActive(camera, false)
    DestroyCam(camera, true)
    RenderScriptCams(false, false, 1, true, true)
    SetEntityVisible(ped, true, 0)
    FreezeEntityPosition(ped, false)
    toggleWeatherClosed(true)
end

---=============== [[ EVENTS ]] ===============---

RegisterNetEvent('qb-houses:client:setHouseConfig', function(newHouses)
    allHouses = newHouses
end)

RegisterNetEvent('qb-spawn:client:setupSpawns', function(playerData, newPlayer, appartements)
    TriggerServerEvent('sn_spawn:server:setBucket')
    isNewPlayer = newPlayer
    TriggerServerEvent('qb-clothes:loadPlayerSkin')
    TriggerEvent('sn_appearance:client:loadPlayerClothing')
    Wait(1000)
    locations = {}
    local ped = PlayerPedId()
    local location = vector4(785.75, -1369.27, 26.85, 163.47)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, 784.84, -1370.41, 25.63)
    SetEntityHeading(ped, 263.92)
    local animDict = 'amb@world_human_leaning@female@wall@back@holding_elbow@idle_a'
    local start = GetGameTimer()
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        if (GetGameTimer() - start) > 5000 then return end
        Wait(1)
    end
    Wait(1000)
    TaskPlayAnim(PlayerPedId(), animDict, 'idle_a', 8.0, 8.0, -1, 1, 0, true, true, true)
    local nearPeds = lib.getNearbyPeds(location.xyz, 10.0)
    for i, npc in pairs(nearPeds) do DeleteEntity(npc.ped) end
    toggleWeatherClosed(false)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", location.x, location.y, location.z, 0.0, 0.0, location.w, 60.00, false, 0)
    SetCamUseShallowDofMode(camera, true)
    SetCamNearDof(camera, 0)
    SetCamDofStrength(camera, 0.9)
    SetCamFarDof(camera, 1.0)
    SetCamActive(camera, true)
    RenderScriptCams(1, 0, 0, 1, 1)
    if isNewPlayer then
        for i, data in pairs(appartements) do
            if Config.housingSystem == 'qb' then
                data.type = 'appartments'
                data.coords = data.coords.enter
                locations[#locations+1] = data
            elseif Config.housingSystem == 'ps-housing' then
                data.type = 'appartments'
                data.coords = vector3(data.door.x,data.door.y,data.door.z)
                locations[#locations+1] = data
            end
        end
        drawScaleForm()
        return
    end
    QBCore.Functions.TriggerCallback('sn_spawn:callback:getHouses', function(myHouses)
        if playerData.position then
            local streetname1, streetname2 = GetStreetNameAtCoord(playerData.position.x, playerData.position.y, playerData.position.z)
            locations[#locations+1] = {
                label = Config.lastLocationStreet and GetStreetNameFromHashKey(streetname1) or 'Last Location',
                coords = vector3(playerData.position.x, playerData.position.y, playerData.position.z),
            }
        end
        if appartements ~= nil then -- only qb
            for i, data in pairs(appartements) do
                data.type = 'appartments'
                data.coords = Config.housingSystem == 'qb' and data.coords.enter or vector4(data.door.x, data.door.y, data.door.z, data.door.h)
                locations[#locations+1] = data
            end
        end
        if myHouses ~= nil then
            for i = 1, (#myHouses), 1 do
                local houseData = myHouses[i]
                if Config.housingSystem == 'qb' then
                    locations[#locations+1] = {
                        label = allHouses[houseData.house].adress,
                        coords = allHouses[houseData.house].coords.enter,
                        house = houseData.house,
                    }
                elseif Config.housingSystem == 'ps-housing' then
                    if houseData.street then
                        local label = houseData.apartment or houseData.street
                        local coords = json.decode(houseData.door_data)
                        locations[#locations+1] = {
                            label = label,
                            coords = vector4(coords.x, coords.y, coords.z, coords.h),
                            property_id = houseData.property_id,
                        }
                    end
                end
            end
        end
        for i, data in ipairs(Config.locations) do
            if data.job or data.gang then
                if data.job == playerData.job.name then
                    locations[#locations+1] = data
                end
                if data.gang == playerData.gang.name then
                    locations[#locations+1] = data
                end
            else
                locations[#locations+1] = data
            end
        end
        Wait(500)
        drawScaleForm()
    end, playerData.citizenid)
end)

---=============== [[ NUI ]] ===============---

RegisterNUICallback('spawnAt', function(data, cb)
    fadeScreen(true)
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local insideMeta = playerData.metadata["inside"]
    inSpawnMenu = false
    SetCamActive(camera, false)
    DestroyCam(camera, true)
    RenderScriptCams(false, false, 1, true, true)
    camera = nil
    DestroyDui(duiObj)
    SetEntityVisible(ped, false, 0)
    if Config.housingSystem == 'ps-housing' then
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end
    if data.type == 'appartments' then
        if isNewPlayer then
            if Config.housingSystem == 'qb' then
                TriggerServerEvent("apartments:server:CreateApartment", data.name, data.label, true)
                TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
                TriggerEvent('QBCore:Client:OnPlayerLoaded')
            elseif Config.housingSystem == 'ps-housing' then
                TriggerServerEvent("ps-housing:server:createNewApartment", data.label, true)
            end
        else
            if Config.housingSystem == 'qb' then
                SetEntityCoords(ped, data.coords.x+0.0, data.coords.y+0.0, data.coords.z+0.0)
                TriggerEvent('qb-apartments:client:LastLocationHouse', data.name, data.label)
            elseif Config.housingSystem == 'ps-housing' then
                TriggerServerEvent('ps-housing:server:enterProperty', tostring(data.property_id))
            end
        end
    elseif data.type == 'house' then
        SetEntityCoords(ped, data.coords.x+0.0, data.coords.y+0.0, data.coords.z+0.0)
        if Config.housingSystem == 'qb' then
            TriggerEvent('qb-houses:client:enterOwnedHouse', data.house)
        elseif Config.housingSystem == 'ps-housing' then
            TriggerServerEvent('ps-housing:server:enterProperty', tostring(data.property_id))
        end
    elseif data.type == 'lastLocation' then
        SetEntityCoords(ped, data.coords.x+0.0, data.coords.y+0.0, data.coords.z+0.0)
        if data.coords.w then SetEntityHeading(ped, data.coords.w+0.0) end
        PlaceObjectOnGroundProperly(ped)
        if insideMeta.house ~= nil then
            local houseId = insideMeta.house
            TriggerEvent('qb-houses:client:LastLocationHouse', houseId)
        elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
            local apartmentType = insideMeta.apartment.apartmentType
            local apartmentId = insideMeta.apartment.apartmentId
            TriggerEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
        elseif insideMeta.property_id ~= nil then
            local property_id = insideMeta.property_id
            TriggerServerEvent('ps-housing:server:enterProperty', tostring(property_id))
        else
            TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
            TriggerServerEvent('ps-housing:server:resetMetaData')
        end
    else
        SetEntityCoords(ped, data.coords.x+0.0, data.coords.y+0.0, data.coords.z+0.0)
        if data.coords.w then SetEntityHeading(ped, data.coords.w+0.0) end
        PlaceObjectOnGroundProperly(ped)
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        TriggerServerEvent('ps-housing:server:resetMetaData')
    end
    if Config.housingSystem == 'qb' and not isNewPlayer then
        Wait(500)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end
    Wait(500)
    SetEntityVisible(PlayerPedId(), true)
    TriggerServerEvent('sn_spawn:server:setBucket', 0)
    local ped = PlayerPedId()
    if not isNewPlayer then
        PlaceObjectOnGroundProperly(ped)
        local pedCoords = GetEntityCoords(ped)
        local pedRot = GetEntityRotation(ped)
        scene = NetworkCreateSynchronisedScene(data.coords.x, data.coords.y, data.coords.z-1.0, pedRot.x, pedRot.y, pedRot.z, 2, true, false, -1, 0.1, 1.0)
        lib.requestAnimDict('anim@scripted@heist@ig25_beach@male@')
        NetworkAddPedToSynchronisedScene(ped, scene, 'anim@scripted@heist@ig25_beach@male@', 'action', 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddPedToSynchronisedSceneWithIk(ped, scene, 'anim@scripted@heist@ig25_beach@male@', 'action_facial', 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddSynchronisedSceneCamera(scene, 'anim@scripted@heist@ig25_beach@male@', 'action_camera')
        NetworkStartSynchronisedScene(scene)
        Wait(1000)
        DoScreenFadeIn(500)
        RemoveAnimDict('anim@scripted@heist@ig25_beach@male@')
        Wait(13000)
        NetworkStopSynchronisedScene(scene)
        PlaceObjectOnGroundProperly(ped)
    else
        DoScreenFadeIn(500)
    end
    FreezeEntityPosition(ped, false)
    cb(1)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= 'sn_spawn' then return end
    if not inSpawnMenu then return end
	cleanup()
    fadeScreen(false)
end)