
local ZooState = { tickets = {}, pens = {}, lastDecay = os.time(), lastEscapeCheck = os.time() }
local Framework = { type = nil, object = nil }
local RegisteredCallbacks = {}

local function detectFramework()
    local configured = Config.Framework and Config.Framework.Type or 'auto'
    if configured ~= 'auto' then
        Framework.type = configured
    elseif GetResourceState((Config.Framework and Config.Framework.Resource and Config.Framework.Resource.qb) or 'qb-core') == 'started' then
        Framework.type = 'qb'
    elseif GetResourceState((Config.Framework and Config.Framework.Resource and Config.Framework.Resource.esx) or 'es_extended') == 'started' then
        Framework.type = 'esx'
    else
        error('[astro-zoo] No supported framework detected. Set Config.Framework.Type manually.')
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
            TriggerEvent('esx:getSharedObject', function(shared) Framework.object = shared end)
        end
    end
end

local function detectInventory()
    local configured = Config.Inventory and Config.Inventory.Type or 'auto'
    if configured ~= 'auto' then return configured end
    if GetResourceState((Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.ox) or 'ox_inventory') == 'started' then return 'ox' end
    if GetResourceState((Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.tgiann) or 'tgiann-inventory') == 'started' then return 'tgiann' end
    if Framework.type == 'qb' then return 'qb' end
    return 'esx'
end

local function clamp(v) return Config.Clamp(v) end

local function initPens()
    for penKey, _ in pairs(Config.AnimalPens) do
        ZooState.pens[penKey] = ZooState.pens[penKey] or {
            mood = Config.DefaultMood or 82,
            hunger = Config.DefaultHunger or 76,
            hydration = Config.DefaultHydration or 78,
            cleanliness = Config.DefaultCleanliness or 84,
            stimulation = Config.DefaultStimulation or 80,
            status = 'Settled',
            lastFeed = 0,
            lastObserve = 0,
            escapeRisk = 0,
            isEscaped = false,
            escapeIndex = nil,
            lastEscape = 0,
            closed = false
        }
    end
end

local function getPlayer(src)
    if Framework.type == 'qb' then
        return Framework.object.Functions.GetPlayer(src)
    end
    if Framework.object.GetPlayerFromId then
        return Framework.object.GetPlayerFromId(src)
    end
    return nil
end

local function getIdentifier(src, player)
    if Framework.type == 'qb' then
        return player and player.PlayerData and (player.PlayerData.citizenid or player.PlayerData.license) or tostring(src)
    end
    return player and player.identifier or tostring(src)
end

local function notify(src, msg, typ)
    TriggerClientEvent('astro-zoo:client:notify', src, msg, typ or 'inform')
end

local function removeMoney(player, amount)
    if Framework.type == 'qb' then
        return player.Functions.RemoveMoney(Config.RewardMoneyType, amount, 'astro-zoo-ticket')
    end

    if (Config.RewardMoneyType or 'cash') == 'bank' then
        if player.getAccount then
            local account = player.getAccount('bank')
            if account and (account.money or 0) >= amount then
                player.removeAccountMoney('bank', amount)
                return true
            end
        end
        return false
    end

    local cash = player.getMoney and player.getMoney() or 0
    if cash >= amount then
        player.removeMoney(amount)
        return true
    end
    return false
end

local function getItemLabel(itemName)
    return itemName
end

local function getItemCount(src, player, itemName)
    local invType = detectInventory()
    if invType == 'ox' then
        return exports[(Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.ox) or 'ox_inventory']:GetItemCount(src, itemName) or 0
    elseif invType == 'tgiann' then
        local resource = (Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.tgiann) or 'tgiann-inventory'
        local ok, count = pcall(function() return exports[resource]:GetItemCount(src, itemName) end)
        if ok and type(count) == 'number' then return count end
        ok, count = pcall(function() return exports[resource]:Search(src, 'count', itemName) end)
        if ok and type(count) == 'number' then return count end
    end

    if Framework.type == 'qb' then
        local item = player.Functions.GetItemByName(itemName)
        return item and item.amount or 0
    end

    local item = player.getInventoryItem and player.getInventoryItem(itemName)
    return item and (item.count or item.amount or 0) or 0
end

local function hasItem(src, player, itemName, amount)
    amount = amount or 1
    return getItemCount(src, player, itemName) >= amount
end

local function removeItem(src, player, itemName, amount, slot)
    amount = amount or 1
    local invType = detectInventory()
    if invType == 'ox' then
        return exports[(Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.ox) or 'ox_inventory']:RemoveItem(src, itemName, amount, nil, slot)
    elseif invType == 'tgiann' then
        local resource = (Config.Inventory and Config.Inventory.Resource and Config.Inventory.Resource.tgiann) or 'tgiann-inventory'
        local ok, result = pcall(function() return exports[resource]:RemoveItem(src, itemName, amount, slot) end)
        if ok and result ~= nil then return result end
    end

    if Framework.type == 'qb' then
        return player.Functions.RemoveItem(itemName, amount, slot)
    end

    if player.removeInventoryItem then
        player.removeInventoryItem(itemName, amount)
        return true
    end
    return false
end

local function hasAccess(src)
    if not (Config.AccessRequired == true) then return true, 'open' end
    local player = getPlayer(src)
    if not player then return false end
    if Config.MemberPassItem and Config.MemberPassItem ~= '' and hasItem(src, player, Config.MemberPassItem, 1) then
        return true, 'membership'
    end
    local identifier = getIdentifier(src, player)
    local expiry = ZooState.tickets[identifier]
    if expiry and expiry > os.time() then
        return true, 'ticket'
    end
    return false, nil
end

local function syncState(target)
    TriggerClientEvent('astro-zoo:client:syncState', target or -1, ZooState.pens)
end

local function recalcState(penKey)
    local s = ZooState.pens[penKey]
    if not s then return end
    s.escapeRisk = clamp(math.floor(((100 - s.mood) + (100 - s.cleanliness) + (100 - s.hydration) + (100 - s.hunger) + (100 - s.stimulation)) / 9))
    if s.isEscaped then
        s.status = 'Escaped'
        s.closed = true
        return
    end
    if s.reaction and s.reactionUntil and s.reactionUntil > os.time() then
        if s.reaction == 'feeding' then s.status = 'Reacting to feed'
        elseif s.reaction == 'cleaning' then s.status = 'Settling after cleaning'
        elseif s.reaction == 'observing' then s.status = 'Watching visitors'
        end
        s.closed = false
        return
    end
    if s.mood >= 85 then s.status = 'Active'
    elseif s.mood >= 65 then s.status = 'Stable'
    elseif s.mood >= 45 then s.status = 'Restless'
    else s.status = 'Agitated'
    end
    s.closed = false
end

local function setReaction(s, reaction, seconds)
    s.reaction = reaction
    s.reactionUntil = os.time() + (seconds or 45)
end

local function applyDecay()
    local now = os.time()
    if now - ZooState.lastDecay < (Config.DecayMinutes * 60) then return end
    ZooState.lastDecay = now
    for penKey, s in pairs(ZooState.pens) do
        if not s.isEscaped then
            s.hunger = clamp(s.hunger - 4)
            s.hydration = clamp(s.hydration - 4)
            s.cleanliness = clamp(s.cleanliness - 3)
            s.stimulation = clamp(s.stimulation - 3)
            local avg = math.floor((s.hunger + s.hydration + s.cleanliness + s.stimulation) / 4)
            s.mood = clamp(math.floor((s.mood + avg) / 2) - 1)
        end
        recalcState(penKey)
    end
    syncState()
end

local function chooseEscapablePen()
    local opts = {}
    for penKey, pen in pairs(Config.AnimalPens) do
        local profile = Config.BehaviorProfiles[pen.type]
        local s = ZooState.pens[penKey]
        if s and profile and profile.escapeEnabled and not s.isEscaped and #pen.escapePoints > 0 and s.escapeRisk >= 28 then
            opts[#opts + 1] = { penKey = penKey, score = s.escapeRisk }
        end
    end
    table.sort(opts, function(a, b) return a.score > b.score end)
    return opts[1] and opts[1].penKey or nil
end

local function triggerEscape(penKey)
    local pen = Config.AnimalPens[penKey]
    local s = ZooState.pens[penKey]
    if not pen or not s or s.isEscaped or #pen.escapePoints == 0 then return end
    local idx = math.random(1, #pen.escapePoints)
    s.isEscaped = true
    s.escapeIndex = idx
    s.lastEscape = os.time()
    s.status = 'Escaped'
    s.closed = true
    TriggerClientEvent('astro-zoo:client:penEscaped', -1, penKey, idx)
    syncState()
    SetTimeout(Config.EscapeReturnSeconds * 1000, function()
        local st = ZooState.pens[penKey]
        if not st or not st.isEscaped then return end
        st.isEscaped = false
        st.escapeIndex = nil
        st.mood = clamp(st.mood - 4)
        st.stimulation = clamp(st.stimulation + 6)
        st.cleanliness = clamp(st.cleanliness - 2)
        recalcState(penKey)
        TriggerClientEvent('astro-zoo:client:returnEscaped', -1, penKey)
        syncState()
    end)
end

local function maybeEscape()
    if not Config.EnableEscapes then return end
    local now = os.time()
    if now - ZooState.lastEscapeCheck < (Config.EscapeCheckMinutes * 60) then return end
    ZooState.lastEscapeCheck = now
    if math.random(1, 100) > 40 then return end
    local penKey = chooseEscapablePen()
    if penKey then triggerEscape(penKey) end
end

local function registerCallback(name, fn)
    RegisteredCallbacks[name] = fn
end

RegisterNetEvent('astro-zoo:server:triggerCallback', function(requestId, name, ...)
    local src = source
    local handler = RegisteredCallbacks[name]
    if not handler then
        TriggerClientEvent('astro-zoo:client:callbackResponse', src, requestId, nil)
        return
    end
    handler(src, function(...)
        TriggerClientEvent('astro-zoo:client:callbackResponse', src, requestId, ...)
    end, ...)
end)

CreateThread(function()
    detectFramework()
    initPens()
    while true do
        Wait(60000)
        applyDecay()
        maybeEscape()
    end
end)

AddEventHandler('playerDropped', function()
    syncState()
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(playerSource)
    if Framework.type == 'qb' then
        initPens()
        syncState(playerSource)
    end
end)

RegisterNetEvent('esx:playerLoaded', function(playerSource)
    if Framework.type == 'esx' then
        initPens()
        syncState(playerSource)
    end
end)

registerCallback('getBootData', function(source, cb)
    initPens()
    local allowed, accessType = hasAccess(source)
    cb({ pens = ZooState.pens, hasAccess = allowed, accessType = accessType })
end)

registerCallback('getPenDetails', function(source, cb, penKey)
    local pen = Config.AnimalPens[penKey]
    local state = ZooState.pens[penKey]
    if not pen or not state then return cb(nil) end
    local allowed = hasAccess(source)
    if not allowed then return cb({ denied = true }) end
    cb({
        key = penKey,
        label = pen.label,
        species = pen.species,
        habitat = pen.habitat,
        diet = pen.diet,
        temperament = pen.temperament,
        danger = pen.danger,
        summary = pen.summary,
        facts = pen.facts,
        stats = state
    })
end)

RegisterNetEvent('astro-zoo:server:buyTicket', function()
    local src = source
    local player = getPlayer(src)
    if not player or not Config.AccessRequired then return end
    local allowed, why = hasAccess(src)
    if allowed then
        notify(src, ('Zoo access already active (%s).'):format(why or 'open'), 'inform')
        return
    end
    if removeMoney(player, Config.TicketPrice) then
        local expireAt = os.time() + (Config.TicketDurationMinutes * 60)
        ZooState.tickets[getIdentifier(src, player)] = expireAt
        notify(src, 'Zoo ticket purchased. Access is now active automatically.', 'success')
    else
        notify(src, 'Not enough money for a zoo ticket.', 'error')
    end
end)

RegisterNetEvent('astro-zoo:server:feedPen', function(penKey)
    local src = source
    local player = getPlayer(src)
    local pen = Config.AnimalPens[penKey]
    local s = ZooState.pens[penKey]
    if not player or not pen or not s then return end
    local allowed = hasAccess(src)
    if not allowed then
        notify(src, 'You need zoo access first.', 'error')
        return
    end
    local itemName = pen.foodItem or Config.FeedItemName or (Config.Items and Config.Items.Feed)
    if not hasItem(src, player, itemName, 1) then
        notify(src, ('You need %s to feed this enclosure.'):format(itemName), 'error')
        return
    end
    removeItem(src, player, itemName, 1)
    s.lastFeed = os.time()
    s.hunger = clamp(s.hunger + 16)
    s.stimulation = clamp(s.stimulation + 8)
    s.mood = clamp(s.mood + 10)
    setReaction(s, 'feeding', 45)
    recalcState(penKey)
    syncState()
    notify(src, ('You fed the %s.'):format(pen.label), 'success')
end)

RegisterNetEvent('astro-zoo:server:observePen', function(penKey)
    local src = source
    local pen = Config.AnimalPens[penKey]
    local s = ZooState.pens[penKey]
    if not pen or not s then return end
    local allowed = hasAccess(src)
    if not allowed then
        notify(src, 'You need zoo access first.', 'error')
        return
    end
    s.lastObserve = os.time()
    s.stimulation = clamp(s.stimulation + 4)
    s.mood = clamp(s.mood + 2)
    setReaction(s, 'observing', 20)
    recalcState(penKey)
    syncState()
end)

RegisterNetEvent('astro-zoo:server:cleanViewingArea', function(penKey)
    local src = source
    local pen = Config.AnimalPens[penKey]
    local s = ZooState.pens[penKey]
    if not pen or not s then return end
    local allowed = hasAccess(src)
    if not allowed then
        notify(src, 'You need zoo access first.', 'error')
        return
    end
    s.cleanliness = clamp(s.cleanliness + 12)
    s.mood = clamp(s.mood + 6)
    setReaction(s, 'cleaning', 35)
    recalcState(penKey)
    syncState()
    notify(src, ('You cleaned up near the %s board.'):format(pen.label), 'success')
end)

RegisterNetEvent('astro-zoo:server:applyConsumableStatus', function(isDrink, label)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    if Framework.type == 'qb' then
        local metadata = player.PlayerData.metadata or {}
        if isDrink then
            player.Functions.SetMetaData('thirst', math.min(100, (metadata.thirst or 0) + 20))
        else
            player.Functions.SetMetaData('hunger', math.min(100, (metadata.hunger or 0) + 20))
        end
        TriggerClientEvent('hud:client:UpdateNeeds', src, player.PlayerData.metadata.hunger, player.PlayerData.metadata.thirst)
    else
        TriggerClientEvent('esx_status:add', src, isDrink and 'thirst' or 'hunger', 200000)
    end

    notify(src, ('Consumed %s.'):format(label or 'item'), 'success')
end)

exports('HasZooAccess', function(src)
    return hasAccess(src)
end)
