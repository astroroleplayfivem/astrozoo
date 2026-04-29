
local spawnedAnimals, boardObjects, penState, behaviorState = {}, {}, {}, {}
local uiOpen = false
local lastFeedAction, lastObserveAction = {}, {}
local zooPeds = {}
local ambientMusicActive = false
local callbackId = 0
local pendingCallbacks = {}

local Framework = { type = nil, object = nil }

local function detectFramework()
    local configured = Config.Framework and Config.Framework.Type or 'auto'
    if configured ~= 'auto' then
        Framework.type = configured
    elseif GetResourceState((Config.Framework and Config.Framework.Resource and Config.Framework.Resource.qb) or 'qb-core') == 'started' then
        Framework.type = 'qb'
    elseif GetResourceState((Config.Framework and Config.Framework.Resource and Config.Framework.Resource.esx) or 'es_extended') == 'started' then
        Framework.type = 'esx'
    else
        Framework.type = 'standalone'
    end

    if Framework.type == 'qb' then
        local resource = (Config.Framework and Config.Framework.Resource and Config.Framework.Resource.qb) or 'qb-core'
        Framework.object = exports[resource]:GetCoreObject()
    elseif Framework.type == 'esx' then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            Framework.object = obj
        else
            TriggerEvent('esx:getSharedObject', function(obj2) Framework.object = obj2 end)
        end
    end
end

local function notify(msg, typ)
    typ = typ or 'inform'
    if GetResourceState('ox_lib') == 'started' and lib and lib.notify then
        lib.notify({ description = msg, type = typ == 'error' and 'error' or (typ == 'success' and 'success' or 'inform') })
        return
    end

    if Framework.type == 'qb' and Framework.object and Framework.object.Functions and Framework.object.Functions.Notify then
        local qbType = typ == 'inform' and 'primary' or typ
        Framework.object.Functions.Notify(msg, qbType)
        return
    end

    if Framework.type == 'esx' and Framework.object and Framework.object.ShowNotification then
        Framework.object.ShowNotification(msg)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent('astro-zoo:client:notify', function(msg, typ)
    notify(msg, typ)
end)

local function triggerServerCallback(name, cb, ...)
    callbackId = callbackId + 1
    pendingCallbacks[callbackId] = cb
    TriggerServerEvent('astro-zoo:server:triggerCallback', callbackId, name, ...)
end

RegisterNetEvent('astro-zoo:client:callbackResponse', function(id, ...)
    local cb = pendingCallbacks[id]
    if not cb then return end
    pendingCallbacks[id] = nil
    cb(...)
end)

local function sendAmbientMusic(action)
    if not Config.AmbientMusic or not Config.AmbientMusic.Enabled then return end
    SendNUIMessage({
        action = action,
        music = {
            sourceType = Config.AmbientMusic.SourceType or 'youtube',
            youtubeId = Config.AmbientMusic.YouTubeId,
            directUrl = Config.AmbientMusic.DirectUrl,
            volume = Config.AmbientMusic.Volume or 10,
            fadeMs = Config.AmbientMusic.FadeMs or 2500
        }
    })
end

local function loadModel(model)
    if not model or model == '' then return false end
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print(('[astro-zoo] Invalid model: %s'):format(tostring(model)))
        return false
    end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(0)
        if GetGameTimer() > timeout then
            print(('[astro-zoo] Timed out loading model: %s'):format(tostring(model)))
            return false
        end
    end
    return hash
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local activeActionProp = nil
local function clearActionProp()
    if activeActionProp and DoesEntityExist(activeActionProp) then
        DeleteObject(activeActionProp)
    end
    activeActionProp = nil
end

local function attachActionProp(model, bone, offset, rotation)
    clearActionProp()
    local hash = loadModel(model)
    if not hash then return end
    local ped = PlayerPedId()
    local obj = CreateObject(hash, 0.0, 0.0, 0.0, true, true, false)
    if not DoesEntityExist(obj) then return end
    local boneIndex = GetPedBoneIndex(ped, bone or 57005)
    AttachEntityToEntity(obj, ped, boneIndex, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, true, true, false, true, 1, true)
    activeActionProp = obj
    SetModelAsNoLongerNeeded(hash)
end

local function doProgress(label, duration, animDict, animName, propModel, propBone, propOffset, propRotation)
    if GetResourceState('ox_lib') == 'started' and lib and lib.progressCircle then
        if animDict then loadAnimDict(animDict) end
        return lib.progressCircle({
            duration = duration,
            label = label,
            canCancel = true,
            disable = { move = false, car = true, mouse = false, combat = true },
            anim = animDict and { dict = animDict, clip = animName or 'base', flag = 49 } or nil,
            prop = propModel and {
                model = propModel,
                bone = propBone or 57005,
                pos = propOffset or vector3(0.0, 0.0, 0.0),
                rot = propRotation or vector3(0.0, 0.0, 0.0)
            } or nil
        })
    end

    if Framework.type == 'qb' and Framework.object and Framework.object.Functions and Framework.object.Functions.Progressbar then
        local done, ok = false, false
        if animDict then loadAnimDict(animDict) end
        if propModel then attachActionProp(propModel, propBone, propOffset or vector3(0.0, 0.0, 0.0), propRotation or vector3(0.0, 0.0, 0.0)) end
        Framework.object.Functions.Progressbar('astro_zoo_action', label, duration, false, true,
            { disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = true },
            animDict and { animDict = animDict, anim = animName or 'base', flags = 49 } or {}, {}, {},
            function() ok = true done = true clearActionProp() end,
            function() done = true clearActionProp() end
        )
        while not done do Wait(0) end
        return ok
    end

    if animDict then
        loadAnimDict(animDict)
        TaskPlayAnim(PlayerPedId(), animDict, animName or 'base', 3.0, 3.0, duration, 49, 0.0, false, false, false)
    end
    if propModel then attachActionProp(propModel, propBone, propOffset or vector3(0.0, 0.0, 0.0), propRotation or vector3(0.0, 0.0, 0.0)) end
    Wait(duration)
    ClearPedTasks(PlayerPedId())
    clearActionProp()
    return true
end

local function createBlip()
    if not Config.EnableBlip then return end
    local b = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
    SetBlipSprite(b, Config.Blip.sprite)
    SetBlipDisplay(b, 4)
    SetBlipScale(b, Config.Blip.scale)
    SetBlipColour(b, Config.Blip.color)
    SetBlipAsShortRange(b, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(b)
end

local function cleanupAnimals()
    for _, peds in pairs(spawnedAnimals) do
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) then DeletePed(ped) end
        end
    end
    for _, obj in pairs(boardObjects) do
        if DoesEntityExist(obj) then DeleteObject(obj) end
    end
    for _, ped in ipairs(zooPeds) do
        if DoesEntityExist(ped) then DeletePed(ped) end
    end
end

local function applyBehavior(penKey, ped)
    if not DoesEntityExist(ped) then return end
    local pen = Config.AnimalPens[penKey]
    local profile = pen and Config.BehaviorProfiles[pen.type]
    if not pen or not profile then return end

    local state = penState[penKey] or {}
    if state.isEscaped and state.escapeIndex and pen.escapePoints[state.escapeIndex] then
        local ep = pen.escapePoints[state.escapeIndex]
        TaskGoStraightToCoord(ped, ep.x, ep.y, ep.z, profile.movement or 1.0, -1, ep.w or 0.0, 0.0)
        return
    end

    local now = GetGameTimer()
    local unixNow = (GetCloudTimeAsInt and GetCloudTimeAsInt()) or 0
    behaviorState[ped] = behaviorState[ped] or { nextAt = 0 }
    if now < behaviorState[ped].nextAt then return end

    if state.reactionUntil and unixNow > 0 and state.reactionUntil > unixNow then
        if state.reaction == 'feeding' then
            local offx = (math.random() * 1.2 - 0.6)
            local offy = (math.random() * 1.2 - 0.6)
            TaskGoStraightToCoord(ped, pen.center.x + offx, pen.center.y + offy, pen.center.z, (profile.movement or 1.0) + 0.1, -1, 0.0, 0.0)
            behaviorState[ped].nextAt = now + 5000
            return
        elseif state.reaction == 'cleaning' then
            TaskStandStill(ped, 6000)
            behaviorState[ped].nextAt = now + 6000
            return
        elseif state.reaction == 'observing' then
            TaskTurnPedToFaceCoord(ped, pen.board.coords.x, pen.board.coords.y, pen.board.coords.z, 4000)
            behaviorState[ped].nextAt = now + 4000
            return
        end
    end

    local mood = (state.mood or Config.DefaultMood)
    if mood < 45 and math.random(1, 100) <= 60 then
        local offx = (math.random() * 2 - 1) * pen.radius
        local offy = (math.random() * 2 - 1) * pen.radius
        TaskGoStraightToCoord(ped, pen.center.x + offx, pen.center.y + offy, pen.center.z, (profile.movement or 1.0) + 0.15, -1, 0.0, 0.0)
        behaviorState[ped].nextAt = now + math.random(profile.wanderMin, profile.wanderMax) * 1000
    elseif math.random(1, 100) <= 65 then
        local offx = (math.random() * 2 - 1) * pen.radius
        local offy = (math.random() * 2 - 1) * pen.radius
        TaskGoStraightToCoord(ped, pen.center.x + offx, pen.center.y + offy, pen.center.z, profile.movement or 1.0, -1, 0.0, 0.0)
        behaviorState[ped].nextAt = now + math.random(profile.wanderMin, profile.wanderMax) * 1000
    else
        TaskStandStill(ped, math.random(profile.restMin, profile.restMax) * 1000)
        behaviorState[ped].nextAt = now + math.random(profile.restMin, profile.restMax) * 1000
    end
end

local function spawnZooPed(model, coords, scenario, freeze, setup)
    local hash = loadModel(model)
    if not hash then return end
    local ped = CreatePed(0, hash, coords.x, coords.y, coords.z - 1.0, coords.w or 0.0, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, freeze ~= false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if setup then setup(ped) end
    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
    zooPeds[#zooPeds + 1] = ped
    SetModelAsNoLongerNeeded(hash)
end

local function spawnBoards()
    local hash = loadModel(Config.BoardProp)
    if not hash then return end
    for penKey, pen in pairs(Config.AnimalPens) do
        local c = pen.board.coords
        local obj = CreateObject(hash, c.x, c.y, c.z - 1.0, false, false, false)
        SetEntityHeading(obj, c.w or 0.0)
        FreezeEntityPosition(obj, true)
        boardObjects[penKey] = obj
    end
    SetModelAsNoLongerNeeded(hash)
end

local function spawnAnimals()
    for penKey, pen in pairs(Config.AnimalPens) do
        spawnedAnimals[penKey] = spawnedAnimals[penKey] or {}
        local hash = loadModel(pen.model)
        if hash then
            for _, coords in ipairs(pen.pedCoords) do
                local ped = CreatePed(28, hash, coords.x, coords.y, coords.z, coords.w or 0.0, false, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, 0)
                SetPedCanRagdoll(ped, false)
                FreezeEntityPosition(ped, false)
                spawnedAnimals[penKey][#spawnedAnimals[penKey] + 1] = ped
            end
            SetModelAsNoLongerNeeded(hash)
        end
    end
end

local function requestBootData()
    triggerServerCallback('getBootData', function(data)
        penState = data and data.pens or {}
    end)
end

RegisterNetEvent('astro-zoo:client:syncState', function(data)
    penState = data or {}
end)

RegisterNetEvent('astro-zoo:client:penEscaped', function(penKey, idx)
    local s = penState[penKey] or {}
    s.isEscaped = true
    s.escapeIndex = idx
    penState[penKey] = s
    notify((Config.AnimalPens[penKey].label .. ' has an escape event. Enclosure temporarily closed.'), 'error')
end)

RegisterNetEvent('astro-zoo:client:returnEscaped', function(penKey)
    local s = penState[penKey] or {}
    s.isEscaped = false
    s.escapeIndex = nil
    penState[penKey] = s
    notify((Config.AnimalPens[penKey].label .. ' has been returned to the enclosure.'), 'success')
end)

local function closeUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb('ok')
end)

RegisterNUICallback('observe', function(data, cb)
    local penKey = data.penKey
    local now = GetGameTimer()
    if lastObserveAction[penKey] and now - lastObserveAction[penKey] < (Config.ObserveCooldownSeconds * 1000) then
        notify('You just observed this enclosure.', 'error')
        cb('ok')
        return
    end

    if doProgress('Observing animal behavior', 4500, 'amb@world_human_tourist_map@male@base', 'base') then
        lastObserveAction[penKey] = now
        TriggerServerEvent('astro-zoo:server:observePen', penKey)
        triggerServerCallback('getPenDetails', function(details)
            if details and not details.denied then
                SendNUIMessage({ action = 'update', details = details })
            end
        end, penKey)
    end

    cb('ok')
end)

RegisterNUICallback('feed', function(data, cb)
    local penKey = data.penKey
    local now = GetGameTimer()
    if lastFeedAction[penKey] and now - lastFeedAction[penKey] < (Config.FeedCooldownSeconds * 1000) then
        notify('This enclosure feeding point is on cooldown.', 'error')
        cb('ok')
        return
    end

    if doProgress('Feeding enclosure', 5500, 'amb@medic@standing@kneel@base', 'base', Config.FeedTrayProp, 57005, vector3(0.16, 0.02, -0.02), vector3(80.0, 160.0, 15.0)) then
        lastFeedAction[penKey] = now
        TriggerServerEvent('astro-zoo:server:feedPen', penKey)
        Wait(250)
        triggerServerCallback('getPenDetails', function(details)
            if details and not details.denied then
                SendNUIMessage({ action = 'update', details = details })
            end
        end, penKey)
    end

    cb('ok')
end)

RegisterNUICallback('clean', function(data, cb)
    local penKey = data.penKey
    if doProgress('Cleaning viewing area', 4000, 'amb@world_human_janitor@male@idle_a', 'idle_a', Config.BroomProp, 57005, vector3(0.12, 0.0, -0.02), vector3(-80.0, 0.0, 0.0)) then
        TriggerServerEvent('astro-zoo:server:cleanViewingArea', penKey)
        Wait(250)
        triggerServerCallback('getPenDetails', function(details)
            if details and not details.denied then
                SendNUIMessage({ action = 'update', details = details })
            end
        end, penKey)
    end
    cb('ok')
end)

local function openPenUI(penKey)
    triggerServerCallback('getPenDetails', function(details)
        if not details then
            notify('Could not load enclosure details.', 'error')
            return
        end
        if details.denied then
            notify('You do not have zoo access right now.', 'error')
            return
        end
        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open', details = details })
    end, penKey)
end

local function addBoxZone(name, coords, length, width, heading, minZ, maxZ, options, distance)
    local targetType = Config.Target and Config.Target.Type or 'auto'
    if targetType == 'auto' then
        if GetResourceState((Config.Target and Config.Target.Resource and Config.Target.Resource.ox) or 'ox_target') == 'started' then
            targetType = 'ox'
        else
            targetType = 'qb'
        end
    end

    if targetType == 'ox' then
        exports[(Config.Target and Config.Target.Resource and Config.Target.Resource.ox) or 'ox_target']:addBoxZone({
            name = name,
            coords = coords,
            size = vec3(length, width, math.max((maxZ - minZ), 2.0)),
            rotation = heading or 0.0,
            debug = Config.Debug,
            drawSprite = Config.Debug,
            options = options
        })
        return
    end

    exports[(Config.Target and Config.Target.Resource and Config.Target.Resource.qb) or 'qb-target']:AddBoxZone(name, coords, length, width, {
        name = name,
        heading = heading or 0.0,
        debugPoly = Config.Debug,
        minZ = minZ,
        maxZ = maxZ
    }, {
        options = options,
        distance = distance or 2.0
    })
end

local function registerBoardTargets()
    for penKey, pen in pairs(Config.AnimalPens) do
        local targetCoords = pen.board.coords or pen.board.zone
        local targetType = Config.Target and Config.Target.Type or 'auto'
        local options
        if targetType == 'ox' or (targetType == 'auto' and GetResourceState((Config.Target and Config.Target.Resource and Config.Target.Resource.ox) or 'ox_target') == 'started') then
            options = {{
                name = ('astro_zoo_board_%s'):format(penKey),
                icon = (Config.BoardIcon or 'fas fa-circle-info'),
                label = ('Open %s board'):format(pen.label),
                distance = (Config.TargetDistance or 2.0),
                onSelect = function() openPenUI(penKey) end
            }}
        else
            options = {{
                icon = (Config.BoardIcon or 'fas fa-circle-info'),
                label = ('Open %s board'):format(pen.label),
                action = function() openPenUI(penKey) end
            }}
        end
        addBoxZone(('astro_zoo_board_' .. penKey), vec3(targetCoords.x, targetCoords.y, targetCoords.z), pen.board.length, pen.board.width, (targetCoords.w or pen.board.heading or 0.0), pen.board.minZ, pen.board.maxZ, options, (Config.TargetDistance or 2.0))
    end
end

local function registerEntranceTargets()
    local targetType = Config.Target and Config.Target.Type or 'auto'
    local options
    if targetType == 'ox' or (targetType == 'auto' and GetResourceState((Config.Target and Config.Target.Resource and Config.Target.Resource.ox) or 'ox_target') == 'started') then
        options = {
            {
                name = 'astro_zoo_buy_ticket',
                icon = 'fas fa-ticket',
                label = ('Buy zoo ticket - $%s'):format(Config.TicketPrice),
                distance = 2.0,
                onSelect = function() TriggerServerEvent('astro-zoo:server:buyTicket') end
            },
            {
                name = 'astro_zoo_check_access',
                icon = 'fas fa-id-card',
                label = 'Check zoo access',
                distance = 2.0,
                onSelect = function()
                    triggerServerCallback('getBootData', function(data)
                        notify(('Zoo access: %s'):format(data.hasAccess and (data.accessType or 'active') or 'not active'), data.hasAccess and 'success' or 'error')
                    end)
                end
            }
        }
    else
        options = {
            { icon = 'fas fa-ticket', label = ('Buy zoo ticket - $%s'):format(Config.TicketPrice), action = function() TriggerServerEvent('astro-zoo:server:buyTicket') end },
            { icon = 'fas fa-id-card', label = 'Check zoo access', action = function() triggerServerCallback('getBootData', function(data) notify(('Zoo access: %s'):format(data.hasAccess and (data.accessType or 'active') or 'not active'), data.hasAccess and 'success' or 'error') end) end }
        }
    end
    addBoxZone('astro_zoo_ticketbooth', vec3(Config.TicketPedCoords.x, Config.TicketPedCoords.y, Config.TicketPedCoords.z), 1.0, 1.2, Config.TicketPedCoords.w, Config.TicketPedCoords.z - 1.0, Config.TicketPedCoords.z + 1.6, options, 2.0)
end

local function playConsumableAnim(isDrink)
    if isDrink then
        doProgress('Drinking', 2500, 'mp_player_intdrink', 'loop_bottle', nil)
    else
        doProgress('Eating', 2500, 'mp_player_inteat@burger', 'mp_player_int_eat_burger', nil)
    end
end

local function consumeClient(isDrink, label)
    playConsumableAnim(isDrink)
    TriggerServerEvent('astro-zoo:server:applyConsumableStatus', isDrink, label)
end

exports('useWater', function() consumeClient(true, 'Water') end)
exports('useSoda', function() consumeClient(true, 'Soda') end)
exports('useBurger', function() consumeClient(false, 'Burger') end)
exports('useHotdog', function() consumeClient(false, 'Hotdog') end)
exports('useCottonCandy', function() consumeClient(false, 'Cotton Candy') end)
exports('useAnimalCrackers', function() consumeClient(false, 'Animal Crackers') end)

CreateThread(function()
    detectFramework()
    Wait(1000)
    requestBootData()
    spawnAnimals()
    spawnBoards()
    spawnZooPed(Config.TicketPed, Config.TicketPedCoords, 'WORLD_HUMAN_CLIPBOARD', true)
    for _, guard in ipairs(Config.GuardPeds or {}) do
        spawnZooPed(guard.model, guard.coords, nil, true, function(ped)
            GiveWeaponToPed(ped, joaat('WEAPON_CARBINERIFLE'), 250, false, true)
            SetCurrentPedWeapon(ped, joaat('WEAPON_CARBINERIFLE'), true)
            SetPedCanSwitchWeapon(ped, false)
            SetPedCombatAttributes(ped, 46, false)
            SetPedCombatAttributes(ped, 5, false)
            SetPedSeeingRange(ped, 0.0)
            SetPedHearingRange(ped, 0.0)
            SetPedAlertness(ped, 0)
            ClearPedTasksImmediately(ped)
        end)
    end
    createBlip()
    registerBoardTargets()
    registerEntranceTargets()
end)

CreateThread(function()
    while true do
        for penKey, peds in pairs(spawnedAnimals) do
            for _, ped in ipairs(peds) do
                applyBehavior(penKey, ped)
            end
        end
        Wait(5000)
    end
end)

CreateThread(function()
    if not Config.EnableAmbientAnnouncements then return end
    local waitMs = ((Config.AnnouncementIntervalMinutes or 180) * 60000)
    while true do
        Wait(waitMs)
        local penKeys = {}
        for k, _ in pairs(Config.AnimalPens) do penKeys[#penKeys + 1] = k end
        if #penKeys > 0 then
            local pick = penKeys[math.random(1, #penKeys)]
            local s = penState[pick] or {}
            local status = s.isEscaped and 'temporarily closed due to animal return procedures' or ('currently ' .. (s.status or 'stable'))
            notify(('Astro Zoo Update: %s is %s.'):format(Config.AnimalPens[pick].label, status), 'inform')
        end
    end
end)

CreateThread(function()
    if not Config.AmbientMusic or not Config.AmbientMusic.Enabled then return end
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local center = Config.Blip.coords
        local dist = #(coords - center)
        local shouldPlay = dist <= (Config.AmbientMusic.Radius or 180.0)
        if shouldPlay and not ambientMusicActive then
            ambientMusicActive = true
            sendAmbientMusic('ambientMusicStart')
        elseif (not shouldPlay) and ambientMusicActive then
            ambientMusicActive = false
            sendAmbientMusic('ambientMusicStop')
        end
        Wait(2000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if ambientMusicActive then sendAmbientMusic('ambientMusicStop') end
    cleanupAnimals()
end)
