local QBCore = exports['qb-core']:GetCoreObject()
print('[pvpcore] server.lua loaded')

local lastRob = {}
local robbingTargets = {}
local rentalVehicles = {}
local kitCooldowns = {}
local playerStats = {}
local reports = {}
local dailyCooldowns = {}
local bountyTargets = {}
local streakContracts = {}
local blueZoneKills = {}
local duelBets = {}
local salePercent = 0
local seasonNumber = 1
local activeDuels = {}
local pendingDuels = {}
local pendingTeamDuels = {}
local duelBucketCounter = 5000
local teamDuelCounter = 0
local resolveDuelBets
local blackMarketLocations = {
    vector4(-1171.2, -1572.1, 4.66, 125.0),
    vector4(711.6, -966.9, 30.4, 270.0),
    vector4(1391.1, 3606.2, 38.94, 205.0),
}
local redZoneLocations = {
    { name = 'LSIA Runway', coords = vector3(-1037.0, -2992.0, 13.9) },
    { name = 'LSIA Hangars', coords = vector3(-1255.0, -2888.0, 13.9) },
    { name = 'Docks Terminal', coords = vector3(1026.0, -3075.0, 5.9) },
    { name = 'Elysian Island', coords = vector3(338.0, -2750.0, 6.0) },
    { name = 'Cypress Flats', coords = vector3(880.0, -2200.0, 30.5) },
    { name = 'El Burro Heights', coords = vector3(1380.0, -1620.0, 52.0) },
    { name = 'La Mesa Yard', coords = vector3(720.0, -1370.0, 26.2) },
    { name = 'Mirror Park Lake', coords = vector3(1130.0, -650.0, 57.0) },
    { name = 'Vinewood Bowl', coords = vector3(690.0, 574.0, 130.5) },
    { name = 'Kortz Center', coords = vector3(-2240.0, 264.0, 174.6) },
}
local blackMarketIndex = 1
local redZoneDuration = 600
local airdropDuration = 900
local airdropUnlockDelay = 300
local airdropRadius = 350.0
local redZone = {
    coords = vector3(1026.0, -3075.0, 5.9),
    radius = 175.0,
    active = true,
    endsAt = os.time() + redZoneDuration,
}
local duelArena = {
    center = { x = -1954.28, y = 2998.22, z = 225.35, w = 239.99 },
    a = { x = -1966.0, y = 3007.0, z = 225.35, w = 145.0 },
    b = { x = -1942.5, y = 2989.6, z = 225.35, w = 325.0 },
    firstTo = 3,
}
local duelModeArenas = {
    [1] = { center = vector3(-1954.28, 2998.22, 225.35), a = vector4(-1966.0, 3007.0, 225.35, 145.0), b = vector4(-1942.5, 2989.6, 225.35, 325.0), radius = 34.0, spacing = 3.0 },
    [2] = { center = vector3(-1964.28, 3004.22, 225.35), a = vector4(-1975.5, 3013.2, 225.35, 145.0), b = vector4(-1953.0, 2995.2, 225.35, 325.0), radius = 36.0, spacing = 4.0 },
    [3] = { center = vector3(-1916.0, 3004.0, 225.35), a = vector4(-1930.5, 3015.5, 225.35, 145.0), b = vector4(-1901.5, 2992.5, 225.35, 325.0), radius = 48.0, spacing = 4.5 },
    [4] = { center = vector3(-1954.28, 2998.22, 225.35), a = vector4(-1970.5, 3011.2, 225.35, 145.0), b = vector4(-1938.0, 2985.2, 225.35, 325.0), radius = 54.0, spacing = 4.5 },
    [5] = { center = vector3(-1954.28, 2998.22, 225.35), a = vector4(-1971.5, 3012.0, 225.35, 145.0), b = vector4(-1937.0, 2984.4, 225.35, 325.0), radius = 58.0, spacing = 4.5 },
}
local runtimeConfig = {
    rentalPrice = 500,
    safeZoneRadius = 60.0,
    blackMarket = { x = -1171.2, y = -1572.1, z = 4.66, w = 125.0 },
    redZone = { x = 1026.0, y = -3075.0, z = 5.9, radius = redZone.radius, active = redZone.active, endsAt = redZone.endsAt },
    airdrop = { active = false, coords = { x = 0, y = 0, z = 0 }, radius = airdropRadius, endsAt = nil, unlocksAt = nil },
}

local validShopItems = {
    weapon_snspistol = { label = 'SNS Pistol', count = 1, price = 2500 },
    weapon_pistol = { label = 'Pistol', count = 1, price = 4000 },
    weapon_pistol_mk2 = { label = 'Pistol Mk II', count = 1, price = 9000 },
    weapon_combatpistol = { label = 'Combat Pistol', count = 1, price = 6500 },
    weapon_pistol50 = { label = 'Pistol .50', count = 1, price = 12000 },
    weapon_vintagepistol = { label = 'Vintage Pistol', count = 1, price = 5500 },
    weapon_revolver = { label = 'Revolver', count = 1, price = 35000 },
    weapon_flaregun = { label = 'Flare Gun', count = 1, price = 15000 },
    ['ammo-flare'] = { label = 'Flare Ammo x5', count = 5, price = 1000 },
    bandage = { label = 'Bandage x10', count = 10, price = 1000 },
    ['ammo-22'] = { label = 'PistolAmmo x60', count = 60, price = 1200 },
}
local rentalPrice = runtimeConfig.rentalPrice
local ranks = {
    { name = 'Bronze', kills = 0 },
    { name = 'Silver', kills = 10 },
    { name = 'Gold', kills = 25 },
    { name = 'Diamond', kills = 50 },
    { name = 'Elite', kills = 100 },
}
local streakRewards = {
    [5] = { item = 'ammo-22', count = 30, label = 'PistolAmmo x30' },
    [10] = { item = 'bandage', count = 5, label = 'Bandage x5' },
    [15] = { money = 1500, label = '$1500 bank' },
}
local battlePassRewards = {
    [1] = { xp = 150, item = 'bandage', count = 5, label = 'Bandage x5' },
    [2] = { xp = 350, item = 'ammo-22', count = 80, label = 'PistolAmmo x80' },
    [3] = { xp = 700, money = 5000, label = '$5000 bank' },
    [4] = { xp = 1200, item = 'weapon_snspistol', count = 1, label = 'SNS Pistol' },
    [5] = { xp = 1800, money = 15000, label = '$15000 bank' },
}
local airdropRewards = {
    { item = 'bandage', count = 25 },
    { item = 'ammo-22', count = 200 },
    { item = 'weapon_combatpistol', count = 1 },
}
local notify
local getDisplayName
local getStats

local function getShopPrices()
    local prices = {}

    for item, data in pairs(validShopItems) do
        prices[item] = math.floor(data.price * ((100 - salePercent) / 100))
    end

    return prices
end

local function getRankName(kills)
    local rank = ranks[1].name

    for _, data in ipairs(ranks) do
        if kills >= data.kills then
            rank = data.name
        end
    end

    return rank
end

local function syncRuntime(target)
    runtimeConfig.shopPrices = getShopPrices()
    runtimeConfig.serverTime = os.time()
    runtimeConfig.redZone.active = redZone.active
    runtimeConfig.redZone.endsAt = redZone.endsAt
    TriggerClientEvent('custom_f1_rob_radio:updateConfig', target or -1, runtimeConfig)
end

local function addBattlePassXp(source, amount)
    local stats = getStats(source)
    stats.bpXp = (stats.bpXp or 0) + amount
    stats.seasonPoints = (stats.seasonPoints or 0) + amount
end

local function getDailyKey()
    return os.date('%Y-%m-%d')
end

local function getDailyProgress(stats)
    local key = getDailyKey()

    stats.daily = stats.daily or {}
    if stats.daily.key ~= key then
        stats.daily = {
            key = key,
            kills = 0,
            duelWins = 0,
            airdrops = 0,
            headshots = 0,
            claimed = false,
        }
    end

    return stats.daily
end

local function addDailyProgress(source, field, amount)
    local stats = getStats(source)
    local daily = getDailyProgress(stats)
    daily[field] = (daily[field] or 0) + (amount or 1)
end

local function prestigePrefix(stats)
    local prestige = stats and tonumber(stats.prestige or 0) or 0

    if prestige >= 10 then
        return '^6[P' .. prestige .. ']^7 '
    elseif prestige >= 5 then
        return '^5[P' .. prestige .. ']^7 '
    elseif prestige >= 1 then
        return '^3[P' .. prestige .. ']^7 '
    end

    return ''
end

local function getStyledName(source)
    local stats = getStats(source)
    local tag = stats.tag and ('[%s] '):format(stats.tag) or ''
    return prestigePrefix(stats) .. tag .. getDisplayName(source)
end

local function claimAvailableBattlePass(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local stats = getStats(source)
    stats.bpClaimed = stats.bpClaimed or {}

    if not Player then
        return
    end

    local claimedAny = false

    for level, reward in ipairs(battlePassRewards) do
        if (stats.bpXp or 0) >= reward.xp and not stats.bpClaimed[level] then
            stats.bpClaimed[level] = true
            claimedAny = true

            if reward.item then
                exports.ox_inventory:AddItem(source, reward.item, reward.count)
            elseif reward.money then
                Player.Functions.AddMoney('bank', reward.money, 'battle-pass-reward')
            end

            notify(source, ('Battle Pass level %s reward: %s'):format(level, reward.label), 'success')
        end
    end

    if not claimedAny then
        notify(source, 'Claim hiih battle pass reward alga baina', 'error')
    end
end

local function sendDuelHud(duel)
    if duel.teamA and duel.teamB then
        local arena = duel.arena or duelModeArenas[duel.mode or 1] or duelModeArenas[1]
        local payload = {
            aName = ('Blue Team (%sv%s)'):format(duel.mode or 1, duel.mode or 1),
            bName = ('Red Team (%sv%s)'):format(duel.mode or 1, duel.mode or 1),
            aScore = duel.scores.blue or 0,
            bScore = duel.scores.red or 0,
            round = duel.round or 1,
            firstTo = duel.firstTo or duelArena.firstTo,
            arena = { x = arena.center.x, y = arena.center.y, z = arena.center.z, radius = arena.radius },
        }

        for _, playerId in ipairs(duel.players) do
            TriggerClientEvent('custom_f1_rob_radio:duelHud', playerId, payload)
        end

        return
    end

    local payload = {
        aId = duel.a,
        bId = duel.b,
        aName = GetPlayerName(duel.a) or tostring(duel.a),
        bName = GetPlayerName(duel.b) or tostring(duel.b),
        aScore = duel.scores[duel.a] or 0,
        bScore = duel.scores[duel.b] or 0,
        round = duel.round or 1,
        firstTo = duel.firstTo or duelArena.firstTo,
        arena = { x = duelArena.center.x, y = duelArena.center.y, z = duelArena.center.z, radius = duelModeArenas[1].radius },
    }

    TriggerClientEvent('custom_f1_rob_radio:duelHud', duel.a, payload)
    TriggerClientEvent('custom_f1_rob_radio:duelHud', duel.b, payload)
end

local function getDuelSpawn(arena, side, index, total)
    local base = side == 'blue' and arena.a or arena.b
    local center = arena.center or vector3(duelArena.center.x, duelArena.center.y, duelArena.center.z)
    local spacing = arena.spacing or 4.0
    local offset = (index - ((total + 1) / 2)) * spacing
    local forwardX = base.x - center.x
    local forwardY = base.y - center.y
    local length = math.sqrt((forwardX * forwardX) + (forwardY * forwardY))

    if length < 0.01 then
        forwardX = 0.0
        forwardY = 1.0
        length = 1.0
    end

    forwardX = forwardX / length
    forwardY = forwardY / length

    local sideX = -forwardY
    local sideY = forwardX

    return {
        x = base.x + (sideX * offset),
        y = base.y + (sideY * offset),
        z = (base.z or center.z) + 0.35,
        w = base.w,
    }
end

local function resetDuelRound(duel)
    if duel.teamA and duel.teamB then
        local arena = duel.arena or duelModeArenas[duel.mode or 1] or duelModeArenas[1]

        for _, playerId in ipairs(duel.players) do
            TriggerClientEvent('hospital:client:Revive', playerId)
        end

        SetTimeout(800, function()
            for i, playerId in ipairs(duel.teamA) do
                TriggerClientEvent('custom_f1_rob_radio:duelTeleport', playerId, getDuelSpawn(arena, 'blue', i, #duel.teamA))
            end

            for i, playerId in ipairs(duel.teamB) do
                TriggerClientEvent('custom_f1_rob_radio:duelTeleport', playerId, getDuelSpawn(arena, 'red', i, #duel.teamB))
            end

            sendDuelHud(duel)
        end)

        return
    end

    TriggerClientEvent('hospital:client:Revive', duel.a)
    TriggerClientEvent('hospital:client:Revive', duel.b)

    SetTimeout(800, function()
        TriggerClientEvent('custom_f1_rob_radio:duelTeleport', duel.a, duelArena.a)
        TriggerClientEvent('custom_f1_rob_radio:duelTeleport', duel.b, duelArena.b)
        sendDuelHud(duel)
    end)
end

local function endDuel(duel, message, refund, winnerKey)
    if not duel then
        return
    end

    local players = duel.players or { duel.a, duel.b }
    resolveDuelBets(duel, winnerKey, refund)

    for _, playerId in ipairs(players) do
        activeDuels[playerId] = nil
        SetPlayerRoutingBucket(playerId, 0)
    end

    if refund and duel.amount and duel.amount > 0 then
        for _, playerId in ipairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerId)

            if Player then
                Player.Functions.AddMoney('bank', duel.amount, 'duel-cancel-refund')
            end
        end
    end

    for _, playerId in ipairs(players) do
        TriggerClientEvent('custom_f1_rob_radio:duelEnd', playerId, message or 'Duel cancelled')
        TriggerClientEvent('hospital:client:Revive', playerId)
    end
end

local function isAdmin(source)
    return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')
end

local itemAliases = {
    pistolammo = 'ammo-22',
    ['pistol-ammo'] = 'ammo-22',
    ['pistol_ammo'] = 'ammo-22',
    ammo22 = 'ammo-22',
    ['ammo-22'] = 'ammo-22',
    ['22ammo'] = 'ammo-22',
    ['ammo-pistol'] = 'ammo-22',
    ['ammo_pistol'] = 'ammo-22',
    snspistol = 'weapon_snspistol',
    sns = 'weapon_snspistol',
    pistol = 'weapon_pistol',
    pistolmk2 = 'weapon_pistol_mk2',
    ['pistol-mk2'] = 'weapon_pistol_mk2',
    ['pistol_mk2'] = 'weapon_pistol_mk2',
    combatpistol = 'weapon_combatpistol',
    ['combat-pistol'] = 'weapon_combatpistol',
    ['combat_pistol'] = 'weapon_combatpistol',
    pistol50 = 'weapon_pistol50',
    ['pistol-50'] = 'weapon_pistol50',
    ['pistol_50'] = 'weapon_pistol50',
    vintagepistol = 'weapon_vintagepistol',
    ['vintage-pistol'] = 'weapon_vintagepistol',
    ['vintage_pistol'] = 'weapon_vintagepistol',
    revolver = 'weapon_revolver',
}

local function addUnique(list, seen, value)
    if value and value ~= '' and not seen[value] then
        seen[value] = true
        list[#list + 1] = value
    end
end

local function getItemCandidates(item)
    local raw = tostring(item or ''):lower():gsub('^%s*(.-)%s*$', '%1')
    local compact = raw:gsub('%s+', '')
    local underscore = compact:gsub('-', '_')
    local hyphen = compact:gsub('_', '-')
    local candidates = {}
    local seen = {}

    addUnique(candidates, seen, itemAliases[compact])
    addUnique(candidates, seen, itemAliases[underscore])
    addUnique(candidates, seen, itemAliases[hyphen])
    addUnique(candidates, seen, compact)
    addUnique(candidates, seen, underscore)
    addUnique(candidates, seen, hyphen)

    if hyphen:sub(1, 7) == 'weapon-' then
        addUnique(candidates, seen, hyphen:gsub('-', '_'))
    end

    if underscore:sub(1, 7) == 'weapon_' then
        addUnique(candidates, seen, underscore)
    end

    return candidates
end

local function itemExists(item)
    if item == '' then
        return false
    end

    local ok, oxItem = pcall(function()
        return exports.ox_inventory:Items(item)
    end)

    if ok and oxItem then
        return true
    end

    return QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] ~= nil
end

local function resolveItemName(item)
    local candidates = getItemCandidates(item)

    for _, candidate in ipairs(candidates) do
        if itemExists(candidate) then
            return candidate
        end
    end

    return candidates[1] or ''
end

local function addItemFlexible(target, item, count)
    local candidates = getItemCandidates(item)
    local validated = {}
    local hasValidated = false

    for _, candidate in ipairs(candidates) do
        if itemExists(candidate) then
            hasValidated = true
            validated[#validated + 1] = candidate
        end
    end

    local list = hasValidated and validated or candidates

    for _, candidate in ipairs(list) do
        local ok, added = pcall(function()
            return exports.ox_inventory:AddItem(target, candidate, count)
        end)

        if ok and added then
            return true, candidate
        end
    end

    return false, list[1] or ''
end

local function copyAirdropRewards()
    local rewards = {}

    for i, reward in ipairs(airdropRewards) do
        rewards[i] = {
            item = reward.item,
            count = reward.count,
        }
    end

    return rewards
end

local function getAirdropDropItems()
    local items = {}

    for _, reward in ipairs(airdropRewards) do
        if reward.item and reward.count and reward.count > 0 then
            items[#items + 1] = { reward.item, reward.count }
        end
    end

    if #items == 0 then
        items[#items + 1] = { 'bandage', 25 }
    end

    return items
end

local function getRedZoneLocationList()
    local locations = {}

    for i, location in ipairs(redZoneLocations) do
        locations[i] = {
            name = location.name,
            x = location.coords.x,
            y = location.coords.y,
            z = location.coords.z,
        }
    end

    return locations
end

local function parseIdList(value)
    local ids = {}
    local seen = {}

    for token in tostring(value or ''):gmatch('[^,%s]+') do
        local id = tonumber(token)

        if id and id > 0 and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end

    return ids
end

local function containsId(list, id)
    for _, value in ipairs(list or {}) do
        if value == id then
            return true
        end
    end

    return false
end

local function startTeamDuel(request)
    local players = {}

    for _, playerId in ipairs(request.teamA) do
        players[#players + 1] = playerId
    end

    for _, playerId in ipairs(request.teamB) do
        players[#players + 1] = playerId
    end

    for _, playerId in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)

        if not Player or activeDuels[playerId] or Player.Functions.GetMoney('bank') < request.amount then
            return notify(request.from, 'Team duel ehluuleh bolomjgui. Player/money/active duel shalgana', 'error')
        end
    end

    for _, playerId in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        Player.Functions.RemoveMoney('bank', request.amount, 'team-duel-wager')
        pendingDuels[playerId] = nil
    end

    duelBucketCounter = duelBucketCounter + 1
    local duel = {
        teamA = request.teamA,
        teamB = request.teamB,
        players = players,
        amount = request.amount,
        mode = request.mode,
        arena = request.arena,
        bucket = duelBucketCounter,
        scores = { blue = 0, red = 0 },
        round = 1,
        firstTo = request.rounds,
    }

    for _, playerId in ipairs(players) do
        activeDuels[playerId] = duel
        SetPlayerRoutingBucket(playerId, duelBucketCounter)
    end

    resetDuelRound(duel)
end

function notify(source, description, type)
    TriggerClientEvent('QBCore:Notify', source, description, type or 'primary')
end

local function finishBlueZoneMvp()
    local bestId, bestKills = nil, 0

    for playerId, kills in pairs(blueZoneKills) do
        if kills > bestKills and QBCore.Functions.GetPlayer(playerId) then
            bestId = playerId
            bestKills = kills
        end
    end

    if bestId and bestKills > 0 then
        local Player = QBCore.Functions.GetPlayer(bestId)

        if Player then
            Player.Functions.AddMoney('bank', 7500, 'bluezone-mvp')
            exports.ox_inventory:AddItem(bestId, 'bandage', 5)
            addBattlePassXp(bestId, 100)
            addDailyProgress(bestId, 'blueMvp', 1)
            TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('MGrande BlueZone MVP: %s - %s kills | Reward $7500 + хөөрөг x5'):format(getStyledName(bestId), bestKills))
        end
    end

    blueZoneKills = {}
end

function resolveDuelBets(duel, winnerKey, refund)
    local bets = duel and duel.bets

    if not bets or #bets == 0 then
        return
    end

    local winners, losingPool = {}, 0

    for _, bet in ipairs(bets) do
        local Player = QBCore.Functions.GetPlayer(bet.source)

        if Player then
            if refund then
                Player.Functions.AddMoney('bank', bet.amount, 'duel-bet-refund')
                notify(bet.source, ('Duel bet butsaj orloo: $%s'):format(bet.amount), 'inform')
            elseif tostring(bet.pick) == tostring(winnerKey) then
                winners[#winners + 1] = bet
            else
                losingPool = losingPool + bet.amount
            end
        end
    end

    if refund then
        return
    end

    local totalWinnerStake = 0
    for _, bet in ipairs(winners) do
        totalWinnerStake = totalWinnerStake + bet.amount
    end

    for _, bet in ipairs(winners) do
        local Player = QBCore.Functions.GetPlayer(bet.source)
        local bonus = totalWinnerStake > 0 and math.floor((bet.amount / totalWinnerStake) * losingPool) or 0
        local payout = bet.amount + bonus

        if Player then
            Player.Functions.AddMoney('bank', payout, 'duel-bet-win')
            notify(bet.source, ('Duel bet yallaa: $%s'):format(payout), 'success')
        end
    end
end

local function chatMessage(source, prefix, message)
    TriggerClientEvent('chat:addMessage', source, {
        color = { 80, 180, 255 },
        args = { prefix or 'Server', message }
    })
end

function getDisplayName(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        local fullName = ((info.firstname or '') .. ' ' .. (info.lastname or '')):gsub('^%s*(.-)%s*$', '%1')

        if fullName ~= '' then
            return fullName
        end
    end

    return GetPlayerName(source) or ('Player ' .. tostring(source))
end

local function getStatsKey(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player and Player.PlayerData and Player.PlayerData.citizenid then
        return Player.PlayerData.citizenid
    end

    return tostring(source)
end

function getStats(source)
    local key = getStatsKey(source)
    playerStats[key] = playerStats[key] or {
        name = getDisplayName(source),
        kills = 0,
        deaths = 0,
        robs = 0,
        currentStreak = 0,
        bestStreak = 0,
        tag = nil,
        joinedAt = os.time(),
    }
    playerStats[key].name = getDisplayName(source)
    return playerStats[key]
end

RegisterNetEvent('custom_f1_rob_radio:buyWeapon', function(item)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local shopItem = validShopItems[item]

    if not Player or not item or not shopItem then
        return notify(source, 'Hudaldan avalt buruu baina', 'error')
    end

    local count = shopItem.count
    local price = math.floor(shopItem.price * ((100 - salePercent) / 100))

    if Player.Functions.GetMoney('bank') < price then
        return notify(source, 'Banknii mongo hurehgui baina', 'error')
    end

    if not Player.Functions.RemoveMoney('bank', price, 'weapon-service-purchase') then
        return notify(source, 'Tulbur avah bolomjgui baina', 'error')
    end

    local ok, addedItem = addItemFlexible(source, item, count)
    if not ok then
        Player.Functions.AddMoney('bank', price, 'weapon-service-refund')
        return notify(source, 'Inventory duuren baina', 'error')
    end

    print(('[custom_f1] %s bought %sx %s for $%s bank'):format(GetPlayerName(source) or source, count, addedItem, price))
    notify(source, ('%s avlaa'):format(shopItem.label or item), 'success')
end)

AddEventHandler('QBCore:Server:OnPlayerLoaded', function(Player)
    if Player and Player.PlayerData then
        syncRuntime(Player.PlayerData.source)
    end
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if Player and Player.PlayerData then
        syncRuntime(Player.PlayerData.source)
    end
end)

lib.callback.register('custom_f1_rob_radio:rentSultan', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local price = rentalPrice

    if not Player then
        return false
    end

    if Player.Functions.GetMoney('bank') < price then
        notify(source, 'Banknii mongo hurehgui baina', 'error')
        return false
    end

    if not Player.Functions.RemoveMoney('bank', price, 'sultan-rental') then
        notify(source, 'Tulbur avah bolomjgui baina', 'error')
        return false
    end

    print(('[custom_f1] %s rented Sultan for $%s bank'):format(GetPlayerName(source) or source, price))
    return true
end)

lib.callback.register('custom_f1_rob_radio:getAdminConfig', function(source)
    if not isAdmin(source) then
        return { allowed = false }
    end

    local data = {}
    for k, v in pairs(runtimeConfig) do
        data[k] = v
    end
    data.shopPrices = getShopPrices()
    data.airdropRewards = copyAirdropRewards()
    data.redZoneLocations = getRedZoneLocationList()
    data.allowed = true
    return data
end)

lib.callback.register('custom_f1_rob_radio:getHubStatus', function(source)
    local stats = getStats(source)

    return {
        online = #QBCore.Functions.GetPlayers(),
        season = seasonNumber,
        rank = getRankName(stats.kills or 0),
        bpXp = stats.bpXp or 0,
        prestige = stats.prestige or 0,
        salePercent = salePercent,
        airdropActive = runtimeConfig.airdrop and runtimeConfig.airdrop.active == true,
        airdropLocked = runtimeConfig.airdrop and runtimeConfig.airdrop.locked == true,
        airdropUnlocksAt = runtimeConfig.airdrop and runtimeConfig.airdrop.unlocksAt,
        kills = stats.kills or 0,
        deaths = stats.deaths or 0,
        streak = stats.currentStreak or 0,
        redZoneEndsAt = redZone.endsAt,
        redZoneActive = redZone.active,
    }
end)

lib.callback.register('custom_f1_rob_radio:getSafeZoneShowcase', function()
    local rows = {}

    for _, rowStats in pairs(playerStats) do
        rows[#rows + 1] = rowStats
    end

    table.sort(rows, function(a, b)
        if (a.kills or 0) == (b.kills or 0) then
            return (a.bestStreak or 0) > (b.bestStreak or 0)
        end

        return (a.kills or 0) > (b.kills or 0)
    end)

    local top = {}
    for i = 1, math.min(3, #rows) do
        local prestige = tonumber(rows[i].prestige or 0) or 0
        local prestigeTag = prestige > 0 and ('[P%s] '):format(prestige) or ''
        top[#top + 1] = {
            name = prestigeTag .. (rows[i].tag and ('[%s] %s'):format(rows[i].tag, rows[i].name) or rows[i].name),
            kills = rows[i].kills or 0,
            prestige = prestige,
            streak = rows[i].bestStreak or 0,
        }
    end

    return top
end)

lib.callback.register('custom_f1_rob_radio:getProgressHub', function(source)
    local stats = getStats(source)
    local rows = {}
    local deaths = stats.deaths > 0 and stats.deaths or 1
    local nextReward = nil
    local claimedCount = 0

    stats.bpClaimed = stats.bpClaimed or {}

    for level, reward in ipairs(battlePassRewards) do
        if stats.bpClaimed[level] then
            claimedCount = claimedCount + 1
        elseif not nextReward then
            nextReward = ('Level %s - %s'):format(level, reward.label)
        end
    end

    for _, rowStats in pairs(playerStats) do
        rows[#rows + 1] = rowStats
    end

    table.sort(rows, function(a, b)
        if a.kills == b.kills then
            return a.deaths < b.deaths
        end

        return a.kills > b.kills
    end)

    local leaderboard = {}
    for i = 1, math.min(5, #rows) do
        local rowDeaths = rows[i].deaths > 0 and rows[i].deaths or 1
        local prestige = tonumber(rows[i].prestige or 0) or 0
        local prestigeTag = prestige > 0 and ('[P%s] '):format(prestige) or ''
        local displayName = prestigeTag .. (rows[i].tag and ('[%s] %s'):format(rows[i].tag, rows[i].name) or rows[i].name)
        leaderboard[#leaderboard + 1] = {
            place = i,
            name = displayName,
            rank = getRankName(rows[i].kills),
            kills = rows[i].kills,
            deaths = rows[i].deaths,
            kd = string.format('%.2f', rows[i].kills / rowDeaths),
        }
    end

    local bpXp = stats.bpXp or 0
    local bpLevel = math.floor(bpXp / 100) + 1
    local bpProgress = bpXp % 100
    local daily = getDailyProgress(stats)

    return {
        name = getDisplayName(source),
        rank = getRankName(stats.kills),
        kills = stats.kills,
        deaths = stats.deaths,
        kd = string.format('%.2f', stats.kills / deaths),
        robs = stats.robs,
        streak = stats.currentStreak or 0,
        bestStreak = stats.bestStreak or 0,
        playtime = math.floor((os.time() - stats.joinedAt) / 60),
        aimBest = stats.aimBest or 0,
        season = seasonNumber,
        seasonPoints = stats.seasonPoints or 0,
        prestige = stats.prestige or 0,
        bpXp = bpXp,
        bpLevel = bpLevel,
        bpProgress = bpProgress,
        bpClaimedCount = claimedCount,
        bpLevels = #battlePassRewards,
        nextBpReward = nextReward,
        dailyKills = daily.kills or 0,
        dailyDuelWins = daily.duelWins or 0,
        dailyAirdrops = daily.airdrops or 0,
        dailyHeadshots = daily.headshots or 0,
        dailyClaimed = daily.claimed == true,
        leaderboard = leaderboard,
        redZoneEndsAt = redZone.endsAt,
        redZoneActive = redZone.active,
        airdropEndsAt = runtimeConfig.airdrop and runtimeConfig.airdrop.endsAt,
        airdropUnlocksAt = runtimeConfig.airdrop and runtimeConfig.airdrop.unlocksAt,
        airdropLocked = runtimeConfig.airdrop and runtimeConfig.airdrop.locked == true,
    }
end)

RegisterNetEvent('custom_f1_rob_radio:adminUpdateConfig', function(data)
    local source = source

    if not isAdmin(source) or type(data) ~= 'table' then
        return
    end

    if data.rentalPrice then
        runtimeConfig.rentalPrice = math.max(0, tonumber(data.rentalPrice) or runtimeConfig.rentalPrice)
        rentalPrice = runtimeConfig.rentalPrice
    end

    if data.safeZoneRadius then
        runtimeConfig.safeZoneRadius = math.max(1, tonumber(data.safeZoneRadius) or runtimeConfig.safeZoneRadius)
    end

    if data.respawnPoint then
        runtimeConfig.respawnPoint = data.respawnPoint
    end

    if data.rentalSpawn then
        runtimeConfig.rentalSpawn = data.rentalSpawn
    end

    if type(data.shopPrices) == 'table' then
        for item, price in pairs(data.shopPrices) do
            price = math.floor(tonumber(price) or -1)

            if validShopItems[item] and price >= 0 then
                validShopItems[item].price = price
            end
        end

        runtimeConfig.shopPrices = getShopPrices()
    end

    if type(data.airdropReward) == 'table' then
        local slot = math.floor(tonumber(data.airdropReward.slot) or 0)
        local rawItem = data.airdropReward.item
        local item = resolveItemName(rawItem)
        local count = math.max(1, math.floor(tonumber(data.airdropReward.count) or 1))

        if slot >= 1 and slot <= 12 and item ~= '' and itemExists(item) then
            airdropRewards[slot] = { item = item, count = count }
            notify(source, ('Airdrop slot %s: %s x%s'):format(slot, item, count), 'success')
        else
            notify(source, 'Airdrop item buruu baina. Item name shalgana', 'error')
        end
    end

    if data.removeAirdropReward then
        local slot = math.floor(tonumber(data.removeAirdropReward) or 0)

        if slot >= 1 and slot <= #airdropRewards then
            table.remove(airdropRewards, slot)
            notify(source, ('Airdrop slot %s ustgalaa'):format(slot), 'success')
        end
    end

    if data.redZoneLocation then
        local index = math.floor(tonumber(data.redZoneLocation) or 0)
        local location = redZoneLocations[index]

        if location then
            redZone.coords = location.coords
            redZone.endsAt = os.time() + redZoneDuration
            runtimeConfig.redZone = { x = location.coords.x, y = location.coords.y, z = location.coords.z, radius = redZone.radius, endsAt = redZone.endsAt, name = location.name }
            notify(source, ('MGrande BlueZone: %s'):format(location.name), 'success')
        end
    end

    syncRuntime(-1)
    print(('[custom_f1] %s updated custom settings'):format(GetPlayerName(source) or source))
end)

RegisterNetEvent('custom_f1_rob_radio:registerRentalVehicle', function(netId)
    local source = source
    netId = tonumber(netId)

    if netId then
        rentalVehicles[source] = netId
    end
end)

RegisterNetEvent('custom_f1_rob_radio:robPlayer', function(targetServerId)
    local source = source
    targetServerId = tonumber(targetServerId)

    if not targetServerId or targetServerId == source then
        return notify(source, 'Rob hiih hun oldsongui', 'error')
    end

    local now = os.time()
    if lastRob[source] and now - lastRob[source] < 2 then
        return notify(source, 'Tur huleegeerei', 'error')
    end

    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(targetServerId)

    if not sourcePed or not targetPed or sourcePed == 0 or targetPed == 0 then
        return notify(source, 'Rob hiih hun oldsongui', 'error')
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    local targetCoords = GetEntityCoords(targetPed)

    if #(sourceCoords - targetCoords) > 2.0 then
        return notify(source, 'Heterhii hol baina', 'error')
    end

    local Target = QBCore.Functions.GetPlayer(targetServerId)
    local targetMeta = Target and Target.PlayerData and Target.PlayerData.metadata or {}
    local targetDead = targetMeta.isdead == true or GetEntityHealth(targetPed) <= 0
    local targetHandsUp = Player(targetServerId).state.canSteal == true

    if not targetDead and not targetHandsUp then
        return notify(source, 'Target X deer garaa orgoson esvel uhtsen bh yostoi', 'error')
    end

    if robbingTargets[targetServerId] and robbingTargets[targetServerId] ~= source then
        return notify(source, 'Ene huniig uur hun rob hiij baina', 'error')
    end

    lastRob[source] = now
    robbingTargets[targetServerId] = source
    getStats(source).robs = getStats(source).robs + 1
    exports.ox_inventory:forceOpenInventory(source, 'player', targetServerId)

    SetTimeout(60000, function()
        if robbingTargets[targetServerId] == source then
            robbingTargets[targetServerId] = nil
        end
    end)
end)

AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    if not playerId then return end

    for targetServerId, robberId in pairs(robbingTargets) do
        if robberId == playerId or targetServerId == inventoryId then
            robbingTargets[targetServerId] = nil
        end
    end
end)

RegisterNetEvent('custom_f1_rob_radio:recordDeath', function(killerServerId, deathMeta)
    local source = source
    deathMeta = type(deathMeta) == 'table' and deathMeta or {}
    local stats = getStats(source)
    local victimStreak = stats.currentStreak or 0
    local bountyAmount = bountyTargets[source] and bountyTargets[source].amount or 0
    stats.deaths = stats.deaths + 1
    stats.currentStreak = 0

    killerServerId = tonumber(killerServerId)

    local victimPed = GetPlayerPed(source)
    local victimInBlueZone = redZone.active and victimPed ~= 0 and #(GetEntityCoords(victimPed) - redZone.coords) <= redZone.radius

    if victimInBlueZone then
        exports.ox_inventory:ClearInventory(source, { 'money', 'cash' })
        TriggerClientEvent('ox_inventory:disarm', source, true)
        notify(source, 'MGrande BlueZone deer uhsun tul inventory tseverlegdlee. Cash uldlee', 'error')
    end

    if killerServerId and killerServerId > 0 and killerServerId ~= source then
        local killerStats = getStats(killerServerId)
        killerStats.kills = killerStats.kills + 1
        killerStats.currentStreak = (killerStats.currentStreak or 0) + 1
        killerStats.bestStreak = math.max(killerStats.bestStreak or 0, killerStats.currentStreak)
        addBattlePassXp(killerServerId, 50)
        addDailyProgress(killerServerId, 'kills', 1)

        local reward = streakRewards[killerStats.currentStreak]
        local Killer = QBCore.Functions.GetPlayer(killerServerId)

        if victimInBlueZone and Killer then
            blueZoneKills[killerServerId] = (blueZoneKills[killerServerId] or 0) + 1
            if not exports.ox_inventory:AddItem(killerServerId, 'money', 1000) then
                notify(killerServerId, 'Cash reward inventory-d orsongui. Inventory duuren baina', 'error')
            end
        end

        if killerStats.currentStreak >= 5 and killerStats.currentStreak % 5 == 0 and not streakContracts[killerServerId] then
            local amount = math.min(25000, 5000 + (killerStats.currentStreak * 500))
            streakContracts[killerServerId] = { amount = amount, streak = killerStats.currentStreak }
            bountyTargets[killerServerId] = { amount = amount, creator = 0 }
            TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('Streak Contract: %s %s streaktei боллоо. Bounty $%s'):format(getStyledName(killerServerId), killerStats.currentStreak, amount))
        end

        if deathMeta.headshot then
            killerStats.headshots = (killerStats.headshots or 0) + 1
            killerStats.headshotStreak = (killerStats.headshotStreak or 0) + 1
            addDailyProgress(killerServerId, 'headshots', 1)

            if killerStats.headshotStreak >= 3 then
                addBattlePassXp(killerServerId, 75)
                exports.ox_inventory:AddItem(killerServerId, 'ammo-22', 30)
                notify(killerServerId, 'Headshot Medal: 3 дараалсан headshot | +75 XP, PistolAmmo x30', 'success')
                TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('Sharpshooter Medal: %s 3 headshot дарааллаа'):format(getStyledName(killerServerId)))
                killerStats.headshotStreak = 0
            end
        else
            killerStats.headshotStreak = 0
        end

        if reward and Killer then
            if reward.item then
                exports.ox_inventory:AddItem(killerServerId, reward.item, reward.count)
            elseif reward.money then
                Killer.Functions.AddMoney('bank', reward.money, 'kill-streak-reward')
            end

            notify(killerServerId, ('%s kill streak reward: %s'):format(killerStats.currentStreak, reward.label), 'success')
        end

        local bounty = bountyTargets[source]
        if bounty and Killer then
            Killer.Functions.AddMoney('bank', bounty.amount, 'bounty-claimed')
            notify(killerServerId, ('Bounty avlaa: $%s (%s)'):format(bounty.amount, getDisplayName(source)), 'success')
            notify(source, ('Tanii bounty $%s duuslaa'):format(bounty.amount), 'error')
            bountyTargets[source] = nil
            streakContracts[source] = nil
        end

        local duel = activeDuels[source] or activeDuels[killerServerId]
        if duel and duel.teamA and duel.teamB and containsId(duel.players, source) and containsId(duel.players, killerServerId) then
            local killerSide = containsId(duel.teamA, killerServerId) and 'blue' or 'red'
            local victimSide = containsId(duel.teamA, source) and 'blue' or 'red'

            if killerSide ~= victimSide then
                duel.scores[killerSide] = (duel.scores[killerSide] or 0) + 1
                duel.round = (duel.round or 1) + 1
                sendDuelHud(duel)

                if duel.scores[killerSide] >= duel.firstTo then
                    local winners = killerSide == 'blue' and duel.teamA or duel.teamB
                    local reward = math.floor((duel.amount * #duel.players) / #winners)

                    for _, playerId in ipairs(winners) do
                        local Winner = QBCore.Functions.GetPlayer(playerId)

                        if Winner then
                            Winner.Functions.AddMoney('bank', reward, 'team-duel-wager-win')
                            notify(playerId, ('Team Duel yallaa: $%s'):format(reward), 'success')
                        end
                    end

                    for _, playerId in ipairs(winners) do
                        addDailyProgress(playerId, 'duelWins', 1)
                    end

                    endDuel(duel, ('Team Duel winner: %s'):format(killerSide == 'blue' and 'Blue Team' or 'Red Team'), false, killerSide)
                else
                    resetDuelRound(duel)
                end
            end
        elseif duel and (duel.a == source or duel.b == source) and (duel.a == killerServerId or duel.b == killerServerId) then
            duel.scores[killerServerId] = (duel.scores[killerServerId] or 0) + 1
            duel.round = (duel.round or 1) + 1
            sendDuelHud(duel)

            if duel.scores[killerServerId] >= duel.firstTo then
                if Killer then
                    Killer.Functions.AddMoney('bank', duel.amount * 2, 'duel-wager-win')
                    notify(killerServerId, ('Duel yallaa: $%s'):format(duel.amount * 2), 'success')
                end
                addDailyProgress(killerServerId, 'duelWins', 1)

                endDuel(duel, ('Duel winner: %s'):format(getDisplayName(killerServerId)), false, killerServerId)
            else
                notify(killerServerId, ('Round avlaa: %s/%s'):format(duel.scores[killerServerId], duel.firstTo), 'success')
                notify(source, 'Round aldlaa. Daraagiin round...', 'error')
                resetDuelRound(duel)
            end
        end

        local killerPed = GetPlayerPed(killerServerId)
        local victimPed = GetPlayerPed(source)
        local distance = 0

        if killerPed ~= 0 and victimPed ~= 0 then
            distance = math.floor(#(GetEntityCoords(killerPed) - GetEntityCoords(victimPed)))
        end

        TriggerClientEvent('custom_f1_rob_radio:deathRecap', source, {
            killer = getDisplayName(killerServerId),
            weapon = 'Unknown',
            headshot = deathMeta.headshot == true,
            distance = distance,
            streak = victimStreak,
            bounty = bountyAmount,
        })
    end
end)

RegisterNetEvent('custom_f1_rob_radio:requestStats', function()
    local source = source
    local stats = getStats(source)
    local deaths = stats.deaths > 0 and stats.deaths or 1

    TriggerClientEvent('custom_f1_rob_radio:showStats', source, {
        kills = stats.kills,
        deaths = stats.deaths,
        robs = stats.robs,
        rank = getRankName(stats.kills),
        streak = stats.currentStreak or 0,
        bestStreak = stats.bestStreak or 0,
        kd = string.format('%.2f', stats.kills / deaths),
        playtime = math.floor((os.time() - stats.joinedAt) / 60),
    })
end)

RegisterNetEvent('custom_f1_rob_radio:requestLeaderboard', function()
    local source = source
    local rows = {}

    for _, stats in pairs(playerStats) do
        rows[#rows + 1] = stats
    end

    table.sort(rows, function(a, b)
        if a.kills == b.kills then
            return a.deaths < b.deaths
        end

        return a.kills > b.kills
    end)

    if #rows == 0 then
        return chatMessage(source, 'Leaderboard', 'Odoohondoo stats alga baina')
    end

    chatMessage(source, 'Leaderboard', 'Top players:')

    for i = 1, math.min(5, #rows) do
        local deaths = rows[i].deaths > 0 and rows[i].deaths or 1
        local displayName = rows[i].tag and ('[%s] %s'):format(rows[i].tag, rows[i].name) or rows[i].name
        chatMessage(source, 'Leaderboard', ('%d. %s - %s | %s kills | %s deaths | K/D %s'):format(
            i,
            displayName,
            getRankName(rows[i].kills),
            rows[i].kills,
            rows[i].deaths,
            string.format('%.2f', rows[i].kills / deaths)
        ))
    end
end)

RegisterNetEvent('custom_f1_rob_radio:showBattlePass', function()
    local source = source
    local stats = getStats(source)
    chatMessage(source, 'Battle Pass', ('XP: %s'):format(stats.bpXp or 0))

    for level, reward in ipairs(battlePassRewards) do
        local claimed = stats.bpClaimed and stats.bpClaimed[level]
        chatMessage(source, 'Battle Pass', ('Level %s | %s XP | %s | %s'):format(level, reward.xp, reward.label, claimed and 'claimed' or 'not claimed'))
    end

    claimAvailableBattlePass(source)
end)

RegisterNetEvent('custom_f1_rob_radio:claimBattlePass', function()
    claimAvailableBattlePass(source)
end)

RegisterNetEvent('custom_f1_rob_radio:showSeason', function()
    local source = source
    local stats = getStats(source)
    chatMessage(source, 'Season', ('Season %s | Points: %s | Prestige: %s'):format(seasonNumber, stats.seasonPoints or 0, stats.prestige or 0))
end)

RegisterNetEvent('custom_f1_rob_radio:prestige', function()
    local source = source
    local stats = getStats(source)

    if (stats.kills or 0) < 100 then
        return notify(source, 'Prestige hiihd 100 kill heregtei', 'error')
    end

    stats.prestige = (stats.prestige or 0) + 1
    stats.kills = 0
    stats.deaths = 0
    stats.currentStreak = 0
    stats.bestStreak = 0
    notify(source, ('Prestige %s bolloo'):format(stats.prestige), 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:duelRequest', function(target, amount, rounds, mode, allyIds, enemyIds)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    target = tonumber(target)
    amount = math.floor(tonumber(amount) or 0)
    rounds = math.max(1, math.min(10, math.floor(tonumber(rounds) or duelArena.firstTo)))
    mode = math.max(1, math.min(5, math.floor(tonumber(mode) or 1)))

    if not Player or amount < 100 then
        return notify(source, '/duel [id] [money] [rounds]', 'error')
    end

    if mode > 1 then
        local teamA = { source }
        local allies = parseIdList(allyIds)
        local teamB = parseIdList(enemyIds)

        for _, playerId in ipairs(allies) do
            if playerId ~= source then
                teamA[#teamA + 1] = playerId
            end
        end

        if #teamA ~= mode or #teamB ~= mode then
            return notify(source, ('%sv%s duel-d team ID too buruu байна'):format(mode, mode), 'error')
        end

        for _, playerId in ipairs(teamA) do
            if not QBCore.Functions.GetPlayer(playerId) or activeDuels[playerId] then
                return notify(source, 'Team A player oldsongui/esvel active duel-tei', 'error')
            end
        end

        for _, playerId in ipairs(teamB) do
            if not QBCore.Functions.GetPlayer(playerId) or activeDuels[playerId] or containsId(teamA, playerId) then
                return notify(source, 'Team B player oldsongui/esvel active duel-tei', 'error')
            end
        end

        teamDuelCounter = teamDuelCounter + 1
        local request = {
            id = teamDuelCounter,
            from = source,
            teamA = teamA,
            teamB = teamB,
            amount = amount,
            rounds = rounds,
            mode = mode,
            arena = duelModeArenas[mode] or duelModeArenas[1],
            accepted = { [source] = true },
            expires = os.time() + 45,
        }

        pendingTeamDuels[request.id] = request

        for _, playerId in ipairs(teamA) do
            if playerId ~= source then
                pendingDuels[playerId] = { type = 'team', requestId = request.id, expires = request.expires }
                notify(playerId, ('%sv%s team duel invite. /duelaccept'):format(mode, mode), 'inform')
            end
        end

        for _, playerId in ipairs(teamB) do
            pendingDuels[playerId] = { type = 'team', requestId = request.id, expires = request.expires }
            notify(playerId, ('%sv%s team duel invite. /duelaccept'):format(mode, mode), 'inform')
        end

        notify(source, ('%sv%s team duel invite ilgeelee. Buh hun /duelaccept hiih heregtei'):format(mode, mode), 'success')
        return
    end

    if not target or not QBCore.Functions.GetPlayer(target) or target == source then
        return notify(source, '/duel [id] [money] [rounds]', 'error')
    end

    if activeDuels[source] or activeDuels[target] then
        return notify(source, 'Ta esvel target active duel-tei baina', 'error')
    end

    if Player.Functions.GetMoney('bank') < amount then
        return notify(source, 'Banknii mongo hurehgui baina', 'error')
    end

    pendingDuels[target] = { from = source, amount = amount, rounds = rounds, expires = os.time() + 30 }
    notify(source, ('Duel huselt ilgeelee: %s $%s | %s rounds'):format(target, amount, rounds), 'success')
    notify(target, ('%s chamd $%s duel huselt ilgeelee (%s rounds). /duelaccept esvel /dueldecline'):format(getDisplayName(source), amount, rounds), 'inform')
end)

RegisterNetEvent('custom_f1_rob_radio:duelAccept', function()
    local source = source
    local duel = pendingDuels[source]

    if not duel or duel.expires < os.time() then
        pendingDuels[source] = nil
        return notify(source, 'Active duel huselt alga', 'error')
    end

    if duel.type == 'team' then
        local request = pendingTeamDuels[duel.requestId]

        if not request or request.expires < os.time() then
            pendingDuels[source] = nil
            pendingTeamDuels[duel.requestId] = nil
            return notify(source, 'Team duel huselt duussan', 'error')
        end

        request.accepted[source] = true
        pendingDuels[source] = nil
        notify(source, 'Team duel accept hiilee', 'success')

        for _, playerId in ipairs(request.teamA) do
            if not request.accepted[playerId] then
                return
            end
        end

        for _, playerId in ipairs(request.teamB) do
            if not request.accepted[playerId] then
                return
            end
        end

        pendingTeamDuels[request.id] = nil
        startTeamDuel(request)
        return
    end

    local Challenger = QBCore.Functions.GetPlayer(duel.from)
    local Target = QBCore.Functions.GetPlayer(source)

    if not Challenger or not Target then
        pendingDuels[source] = nil
        return
    end

    if Challenger.Functions.GetMoney('bank') < duel.amount or Target.Functions.GetMoney('bank') < duel.amount then
        pendingDuels[source] = nil
        return notify(source, 'Duel money hurehgui baina', 'error')
    end

    Challenger.Functions.RemoveMoney('bank', duel.amount, 'duel-wager')
    Target.Functions.RemoveMoney('bank', duel.amount, 'duel-wager')
    duelBucketCounter = duelBucketCounter + 1
    activeDuels[duel.from] = {
        a = duel.from,
        b = source,
        amount = duel.amount,
        bucket = duelBucketCounter,
        scores = {
            [duel.from] = 0,
            [source] = 0,
        },
        round = 1,
        firstTo = duel.rounds or duelArena.firstTo,
    }
    activeDuels[source] = activeDuels[duel.from]
    pendingDuels[source] = nil
    SetPlayerRoutingBucket(duel.from, duelBucketCounter)
    SetPlayerRoutingBucket(source, duelBucketCounter)
    TriggerClientEvent('custom_f1_rob_radio:duelTeleport', duel.from, duelArena.a)
    TriggerClientEvent('custom_f1_rob_radio:duelTeleport', source, duelArena.b)
    sendDuelHud(activeDuels[source])
end)

RegisterNetEvent('custom_f1_rob_radio:duelDecline', function()
    pendingDuels[source] = nil
    notify(source, 'Duel declined', 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:duelCancel', function(reason)
    local source = source
    local duel = activeDuels[source]

    if not duel or (duel.a ~= source and duel.b ~= source) then
        return
    end

    local message = ('Duel cancelled: %s zone-s garlaa'):format(getDisplayName(source))
    if reason and reason ~= '' then
        message = ('%s (%s)'):format(message, tostring(reason):sub(1, 40))
    end

    endDuel(duel, message, true)
end)

RegisterNetEvent('custom_f1_rob_radio:createReport', function(message)
    local source = source
    message = tostring(message or ''):sub(1, 180)

    if message == '' then
        return
    end

    reports[#reports + 1] = {
        id = #reports + 1,
        source = source,
        name = getDisplayName(source),
        message = message,
        time = os.date('%H:%M:%S'),
    }

    notify(source, 'Report ilgeegdlee', 'success')

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        if isAdmin(playerId) then
            chatMessage(playerId, 'Report', ('#%s %s: %s'):format(#reports, getDisplayName(source), message))
        end
    end
end)

RegisterNetEvent('custom_f1_rob_radio:clearSafeVehiclesResult', function(count)
    local source = source

    if not isAdmin(source) then
        return
    end

    notify(source, ('Safe zone dotor %s vehicle tseverlelee'):format(tonumber(count) or 0), 'success')
end)

RegisterCommand('kit', function(source)
    if source == 0 then
        return
    end

    local now = os.time()
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if kitCooldowns[source] and now - kitCooldowns[source] < 600 then
        return notify(source, ('Kit dahin avah hurtel %s sec'):format(600 - (now - kitCooldowns[source])), 'error')
    end

    kitCooldowns[source] = now
    exports.ox_inventory:AddItem(source, 'bandage', 5)
    exports.ox_inventory:AddItem(source, 'ammo-22', 30)
    notify(source, 'Kit avlaa: Bandage x5, PistolAmmo x30', 'success')
end, false)

RegisterCommand('daily', function(source)
    if source == 0 then
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local stats = getStats(source)
    local daily = getDailyProgress(stats)
    local done = (daily.kills or 0) >= 10 and (daily.duelWins or 0) >= 1 and (daily.airdrops or 0) >= 1 and (daily.headshots or 0) >= 3

    chatMessage(source, 'Daily Missions', ('Kills %s/10 | Duel Wins %s/1 | Airdrop %s/1 | Headshots %s/3'):format(
        math.min(daily.kills or 0, 10),
        math.min(daily.duelWins or 0, 1),
        math.min(daily.airdrops or 0, 1),
        math.min(daily.headshots or 0, 3)
    ))

    if daily.claimed then
        return notify(source, 'Daily mission reward avsan baina', 'inform')
    end

    if not done then
        return notify(source, 'Daily mission bugd duusaagui baina', 'inform')
    end

    daily.claimed = true
    Player.Functions.AddMoney('bank', 7500, 'daily-mission-reward')
    exports.ox_inventory:AddItem(source, 'bandage', 10)
    exports.ox_inventory:AddItem(source, 'ammo-22', 120)
    addBattlePassXp(source, 150)
    notify(source, 'Daily missions complete: $7500, хөөрөг x10, PistolAmmo x120, +150 XP', 'success')
end, false)

RegisterCommand('rank', function(source)
    if source == 0 then
        return
    end

    notify(source, 'Rank/Stats harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('duelbet', function(source, args)
    if source == 0 then
        return
    end

    local watchedId = tonumber(args[1])
    local amount = math.floor(tonumber(args[2]) or 0)
    local pickArg = tostring(args[3] or ''):lower()
    local Player = QBCore.Functions.GetPlayer(source)
    local duel = watchedId and activeDuels[watchedId]

    if not Player or not duel or amount < 100 then
        return notify(source, '/duelbet [duelPlayerId] [money] [blue/red/playerId]', 'error')
    end

    if containsId(duel.players or { duel.a, duel.b }, source) then
        return notify(source, 'Ooriin duel deer bet tavihgui', 'error')
    end

    local pick = nil
    if duel.teamA and duel.teamB then
        if pickArg == 'blue' or pickArg == 'b' then
            pick = 'blue'
        elseif pickArg == 'red' or pickArg == 'r' then
            pick = 'red'
        end
    else
        local pickedId = tonumber(pickArg)
        if pickedId == duel.a or pickedId == duel.b then
            pick = pickedId
        end
    end

    if not pick then
        return notify(source, 'Bet songolt buruu. Team duel: blue/red, 1v1: playerId', 'error')
    end

    if Player.Functions.GetMoney('bank') < amount or not Player.Functions.RemoveMoney('bank', amount, 'duel-bet') then
        return notify(source, 'Banknii mongo hurehgui baina', 'error')
    end

    duel.bets = duel.bets or {}
    duel.bets[#duel.bets + 1] = { source = source, amount = amount, pick = pick }
    notify(source, ('Duel bet tavilaа: $%s -> %s'):format(amount, pick), 'success')
end, false)

RegisterCommand('bounty', function(source, args)
    if source == 0 then
        return
    end

    local target = tonumber(args[1])
    local amount = math.floor(tonumber(args[2]) or 0)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not target or not QBCore.Functions.GetPlayer(target) or target == source then
        return notify(source, '/bounty [id] [money]', 'error')
    end

    if amount < 1000 then
        return notify(source, 'Bounty hamgiin baga daa $1000', 'error')
    end

    if Player.Functions.GetMoney('bank') < amount then
        return notify(source, 'Banknii mongo hurehgui baina', 'error')
    end

    Player.Functions.RemoveMoney('bank', amount, 'bounty-created')
    bountyTargets[target] = {
        amount = (bountyTargets[target] and bountyTargets[target].amount or 0) + amount,
        creator = source,
    }

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 80, 80 },
        args = { 'Bounty', ('%s deer $%s bounty tavigdlaa'):format(getDisplayName(target), bountyTargets[target].amount) }
    })
end, false)

RegisterCommand('settag', function(source, args)
    if source == 0 then
        return
    end

    local tag = tostring(args[1] or ''):upper():gsub('[^A-Z0-9]', ''):sub(1, 5)
    local stats = getStats(source)

    if tag == '' then
        stats.tag = nil
        return notify(source, 'Tag arilla', 'success')
    end

    stats.tag = tag
    notify(source, ('Tag tavigdlaa: [%s]'):format(tag), 'success')
end, false)

local function openLuckyCase(source)
    if source == 0 then
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    local price = 2500

    if not Player or Player.Functions.GetMoney('bank') < price then
        return notify(source, 'Case avah banknii mongo hurehgui baina ($2500)', 'error')
    end

    local rewards = {
        { item = 'bandage', count = 25, label = 'Bandage x25' },
        { item = 'ammo-22', count = 150, label = 'PistolAmmo x150' },
        { item = 'weapon_snspistol', count = 1, label = 'SNS Pistol' },
        { money = 7500, label = '$7500 bank' },
    }
    local reward = rewards[math.random(#rewards)]

    Player.Functions.RemoveMoney('bank', price, 'lucky-case')

    if reward.item then
        exports.ox_inventory:AddItem(source, reward.item, reward.count)
    else
        Player.Functions.AddMoney('bank', reward.money, 'lucky-case-reward')
    end

    notify(source, ('Lucky case: %s'):format(reward.label), 'success')
end

RegisterCommand('case', function(source)
    openLuckyCase(source)
end, false)

RegisterCommand('luckybox', function(source)
    openLuckyCase(source)
end, false)

RegisterCommand('reports', function(source)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    if #reports == 0 then
        return chatMessage(source, 'Reports', 'Report alga baina')
    end

    chatMessage(source, 'Reports', 'Suuliin reportuud:')

    for i = math.max(1, #reports - 9), #reports do
        local report = reports[i]
        chatMessage(source, 'Reports', ('#%s [%s] %s (%s): %s'):format(report.id, report.time, report.name, report.source, report.message))
    end
end, false)

RegisterCommand('event', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    local message = table.concat(args, ' ')

    if message == '' then
        return notify(source, '/event [message]', 'error')
    end

    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, message)
end, false)

local function parseAirdropCoords(coords)
    if type(coords) ~= 'table' then
        return nil
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)

    if not x or not y or not z then
        return nil
    end

    return vector3(x, y, z)
end

local function startAirdrop(source, customCoords, sourceLabel)
    if runtimeConfig.airdrop and runtimeConfig.airdrop.active then
        if source and source > 0 then
            notify(source, 'Airdrop ali hediin active baina', 'error')
        end
        return false
    end

    local coords = parseAirdropCoords(customCoords) or vector3(-1142.0 + math.random(-80, 80), -1665.0 + math.random(-80, 80), 4.0)
    local unlocksAt = os.time() + airdropUnlockDelay
    local dropEndsAt = unlocksAt + airdropDuration

    runtimeConfig.airdrop = {
        active = true,
        locked = true,
        coords = { x = coords.x, y = coords.y, z = coords.z },
        radius = airdropRadius,
        unlocksAt = unlocksAt,
        endsAt = dropEndsAt,
        dropId = nil,
    }
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:airdropAlarm', -1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, (sourceLabel or 'Airdrop') .. ' buulaa! 5 minutiin daraa uhaj bolno')

    SetTimeout(airdropUnlockDelay * 1000, function()
        if not runtimeConfig.airdrop or not runtimeConfig.airdrop.active or runtimeConfig.airdrop.unlocksAt ~= unlocksAt then
            return
        end

        local dropItems = getAirdropDropItems()
        local dropId = exports.ox_inventory:CustomDrop('Airdrop', dropItems, coords, math.max(6, #dropItems), 8000, nil, `prop_box_wood02a_pu`)

        runtimeConfig.airdrop.locked = false
        runtimeConfig.airdrop.dropId = dropId
        syncRuntime(-1)
        TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Airdrop neegdlee! Odoo uhaj bolno')
    end)

    SetTimeout((airdropUnlockDelay + airdropDuration) * 1000, function()
        if runtimeConfig.airdrop and runtimeConfig.airdrop.endsAt == dropEndsAt then
            runtimeConfig.airdrop = { active = false, coords = { x = 0, y = 0, z = 0 }, radius = airdropRadius, endsAt = nil, unlocksAt = nil, dropId = nil }
            syncRuntime(-1)
            TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Airdrop duuslaa')
        end
    end)

    return true
end

RegisterNetEvent('custom_f1_rob_radio:airdropRemoved', function(dropId)
    if runtimeConfig.airdrop and runtimeConfig.airdrop.active and runtimeConfig.airdrop.dropId == dropId then
        addDailyProgress(source, 'airdrops', 1)
        runtimeConfig.airdrop = { active = false, coords = { x = 0, y = 0, z = 0 }, radius = airdropRadius, endsAt = nil, unlocksAt = nil, dropId = nil }
        syncRuntime(-1)
        notify(source, 'Daily mission: Airdrop progress +1', 'success')
    end
end)

RegisterNetEvent('custom_f1_rob_radio:flareAirdropRequest', function(coords)
    local source = source
    local dropCoords = parseAirdropCoords(coords)

    if not dropCoords then
        return notify(source, 'Flare coords buruu baina', 'error')
    end

    if runtimeConfig.airdrop and runtimeConfig.airdrop.active then
        return notify(source, 'Airdrop ali hediin active baina', 'error')
    end

    notify(source, 'Flare signal avlaa. Airdrop 5 sec daraa ehlelne', 'success')
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('Flare Race: %s airdrop duudlaa. 5 sec daraa drop zone garna!'):format(getStyledName(source)))

    SetTimeout(5000, function()
        if runtimeConfig.airdrop and runtimeConfig.airdrop.active then
            return
        end

        startAirdrop(source, { x = dropCoords.x, y = dropCoords.y, z = dropCoords.z }, 'Flare airdrop')
    end)
end)

RegisterNetEvent('custom_f1_rob_radio:adminStartAirdropCoords', function(coords)
    local source = source
    local dropCoords = parseAirdropCoords(coords)

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    if not dropCoords then
        return notify(source, 'Coords buruu baina', 'error')
    end

    startAirdrop(source, { x = dropCoords.x, y = dropCoords.y, z = dropCoords.z }, 'Admin airdrop')
end)

local function rotateRedzone()
    if not redZone.active then
        return
    end

    finishBlueZoneMvp()

    local location = redZoneLocations[math.random(#redZoneLocations)]
    if #(location.coords - redZone.coords) < 5.0 and #redZoneLocations > 1 then
        for _, possibleLocation in ipairs(redZoneLocations) do
            if #(possibleLocation.coords - redZone.coords) >= 5.0 then
                location = possibleLocation
                break
            end
        end
    end

    redZone.coords = location.coords
    redZone.endsAt = os.time() + redZoneDuration
    runtimeConfig.redZone = { x = location.coords.x, y = location.coords.y, z = location.coords.z, radius = redZone.radius, active = redZone.active, endsAt = redZone.endsAt, name = location.name }
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:blueZoneDisarm', -1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('MGrande BlueZone shine gazar: %s. /redzone'):format(location.name))
end

local function startBlueZone(source)
    redZone.active = true
    redZone.endsAt = os.time() + redZoneDuration
    runtimeConfig.redZone = { x = redZone.coords.x, y = redZone.coords.y, z = redZone.coords.z, radius = redZone.radius, active = true, endsAt = redZone.endsAt }
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'MGrande BlueZone ehlee. /redzone')
    if source and source > 0 then
        notify(source, 'MGrande BlueZone start hiilee', 'success')
    end
end

local function stopBlueZone(source)
    finishBlueZoneMvp()
    redZone.active = false
    redZone.endsAt = nil
    runtimeConfig.redZone = { x = redZone.coords.x, y = redZone.coords.y, z = redZone.coords.z, radius = redZone.radius, active = false, endsAt = nil }
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:blueZoneDisarm', -1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'MGrande BlueZone zogsoloo')
    if source and source > 0 then
        notify(source, 'MGrande BlueZone stop hiilee', 'success')
    end
end

local function resetSeason()
    seasonNumber = seasonNumber + 1

    for _, stats in pairs(playerStats) do
        stats.seasonPoints = 0
        stats.bpXp = 0
        stats.bpClaimed = {}
    end

    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('Season %s ehlee'):format(seasonNumber))
end

RegisterNetEvent('custom_f1_rob_radio:adminAction', function(action)
    local source = source

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    if action == 'airdrop' then
        startAirdrop(source)
    elseif action == 'airdrop_here' then
        local ped = GetPlayerPed(source)
        local coords = ped ~= 0 and GetEntityCoords(ped) or nil

        if not coords then
            return notify(source, 'Coords oldsongui', 'error')
        end

        startAirdrop(source, { x = coords.x, y = coords.y, z = coords.z }, 'Admin airdrop')
    elseif action == 'bluezone_start' then
        startBlueZone(source)
    elseif action == 'bluezone_stop' then
        stopBlueZone(source)
    elseif action == 'rotate_redzone' then
        rotateRedzone()
    elseif action == 'season_reset' then
        resetSeason()
    elseif action == 'sale_20' then
        salePercent = 20
        syncRuntime(-1)
        TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Weapon shop sale: 20% OFF')
    elseif action == 'sale_off' then
        salePercent = 0
        syncRuntime(-1)
        TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Weapon shop sale duuslaa')
    end
end)

RegisterNetEvent('custom_f1_rob_radio:blackMarketBuy', function(item)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local data = ({
        armor = { price = 5000, label = 'Armor', armor = 100 },
        ammo = { price = 3000, label = 'PistolAmmo x160', item = 'ammo-22', count = 160 },
        revolver = { price = 42000, label = 'Revolver', item = 'weapon_revolver', count = 1 },
    })[item]

    if not Player or not data then
        return
    end

    if Player.Functions.GetMoney('bank') < data.price then
        return notify(source, 'Banknii mongo hurehgui baina', 'error')
    end

    if not Player.Functions.RemoveMoney('bank', data.price, 'black-market') then
        return notify(source, 'Tulbur avah bolomjgui baina', 'error')
    end

    if data.armor then
        TriggerClientEvent('hospital:server:SetArmor', source, data.armor)
    elseif data.item then
        if not addItemFlexible(source, data.item, data.count) then
            Player.Functions.AddMoney('bank', data.price, 'black-market-refund')
            return notify(source, 'Inventory duuren baina', 'error')
        end
    end

    notify(source, ('Black market-s avlaa: %s'):format(data.label), 'success')
end)

RegisterCommand('airdropstart', function(source)
    if source ~= 0 and not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    startAirdrop(source)
end, false)

RegisterCommand('redzonerotate', function(source)
    if source ~= 0 and not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    rotateRedzone()
end, false)

RegisterCommand('seasonreset', function(source)
    if source ~= 0 and not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    resetSeason()
end, false)

RegisterCommand('sale', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    salePercent = math.max(0, math.min(90, math.floor(tonumber(args[1]) or 0)))
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, ('Weapon shop sale: %s%% OFF'):format(salePercent))
end, false)

RegisterCommand('saleoff', function(source)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    salePercent = 0
    syncRuntime(-1)
    TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Weapon shop sale duuslaa')
end, false)

RegisterNetEvent('custom_f1_rob_radio:buyWeaponSkin', function(tint, label)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    tint = tonumber(tint)

    if not Player or not tint or tint < 0 or tint > 31 then
        return
    end

    local price = 5000

    if Player.Functions.GetMoney('bank') < price then
        return notify(source, 'Weapon skin avah banknii mongo hurehgui baina', 'error')
    end

    Player.Functions.RemoveMoney('bank', price, 'weapon-skin')
    TriggerClientEvent('custom_f1_rob_radio:applyWeaponTint', source, tint)
    notify(source, ('Weapon skin avlaa: %s'):format(label or tint), 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:aimScore', function(score)
    local source = source
    score = math.floor(tonumber(score) or 0)
    local stats = getStats(source)
    stats.aimBest = math.max(stats.aimBest or 0, score)
    chatMessage(source, 'Aim Range', ('Score: %s | Best: %s'):format(score, stats.aimBest))
end)

RegisterCommand('aimscore', function(source)
    if source == 0 then
        return
    end

    notify(source, 'Aimscore harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('revivearea', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    local radius = tonumber(args[1]) or 20.0
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local revived = 0

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local ped = GetPlayerPed(playerId)

        if ped ~= 0 and #(GetEntityCoords(ped) - sourceCoords) <= radius then
            TriggerClientEvent('hospital:client:Revive', playerId)
            revived = revived + 1
        end
    end

    notify(source, ('%s hun revive hiilee'):format(revived), 'success')
end, false)

RegisterCommand('clearsafeveh', function(source)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    TriggerClientEvent('custom_f1_rob_radio:clearSafeVehicles', source)
end, false)

RegisterCommand('giveammo', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    local target = tonumber(args[1]) or source
    local count = tonumber(args[2]) or 50

    if not QBCore.Functions.GetPlayer(target) then
        return notify(source, 'Player oldsongui', 'error')
    end

    local added, item = addItemFlexible(target, 'pistolammo', count)

    if added then
        notify(source, ('%s player-d %s x%s ogloo'):format(target, item, count), 'success')
        notify(target, ('PistolAmmo x%s avlaa'):format(count), 'success')
    else
        notify(source, 'PistolAmmo ogch chadsangui. Inventory weight/item shalgana', 'error')
    end
end, false)

RegisterCommand('giveitem', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    local target = tonumber(args[1])
    local itemArg = args[2]
    local item = resolveItemName(itemArg)
    local count = math.max(1, math.floor(tonumber(args[3]) or 1))

    if not target or not QBCore.Functions.GetPlayer(target) then
        return notify(source, '/giveitem [id] [item] [count]', 'error')
    end

    if item == '' then
        return notify(source, '/giveitem [id] [item] [count]', 'error')
    end

    local added, addedItem = addItemFlexible(target, itemArg, count)

    if added then
        notify(source, ('%s player-d %s x%s ogloo'):format(target, addedItem, count), 'success')
        notify(target, ('%s x%s avlaa'):format(addedItem, count), 'success')
    else
        notify(source, ('Item ogch chadsangui: %s. Item name/inventory weight shalgana'):format(item), 'error')
    end
end, false)

RegisterCommand('spec', function(source, args)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    local target = tonumber(args[1])

    if not target or not QBCore.Functions.GetPlayer(target) then
        return notify(source, '/spec [id]', 'error')
    end

    TriggerClientEvent('custom_f1_rob_radio:spectatePlayer', source, target)
end, false)

RegisterCommand('specoff', function(source)
    if source == 0 then
        return
    end

    if not isAdmin(source) then
        return notify(source, 'Admin erh heregtei', 'error')
    end

    TriggerClientEvent('custom_f1_rob_radio:stopSpectate', source)
end, false)

CreateThread(function()
    Wait(5000)
    syncRuntime(-1)

    while true do
        Wait(1800000)
        blackMarketIndex = blackMarketIndex + 1
        if blackMarketIndex > #blackMarketLocations then
            blackMarketIndex = 1
        end

        local market = blackMarketLocations[blackMarketIndex]
        runtimeConfig.blackMarket = { x = market.x, y = market.y, z = market.z, w = market.w }
        syncRuntime(-1)
        TriggerClientEvent('custom_f1_rob_radio:eventAnnouncement', -1, 'Black Market shine gazar luu shiljlee')
    end
end)

CreateThread(function()
    Wait(5000)

    while true do
        Wait(redZoneDuration * 1000)
        rotateRedzone()
    end
end)

AddEventHandler('playerDropped', function()
    local droppedSource = source
    local netId = rentalVehicles[droppedSource]
    local droppedPed = GetPlayerPed(droppedSource)
    local droppedCoords = droppedPed ~= 0 and GetEntityCoords(droppedPed) or nil
    local droppedStats = getStats(droppedSource)
    local combatLogged = false

    if redZone.active and droppedCoords and #(droppedCoords - redZone.coords) <= redZone.radius then
        combatLogged = true
    end

    if bountyTargets[droppedSource] or (droppedStats.currentStreak and droppedStats.currentStreak > 0) then
        combatLogged = true
    end

    if activeDuels[droppedSource] then
        endDuel(activeDuels[droppedSource], ('Duel cancelled: %s disconnected'):format(getDisplayName(droppedSource)), true)
    end

    lastRob[droppedSource] = nil
    robbingTargets[droppedSource] = nil
    rentalVehicles[droppedSource] = nil
    kitCooldowns[droppedSource] = nil
    bountyTargets[droppedSource] = nil
    streakContracts[droppedSource] = nil
    blueZoneKills[droppedSource] = nil

    if combatLogged then
        for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
            if isAdmin(playerId) then
                chatMessage(playerId, 'Combat Log', ('%s disconnected in combat/redzone'):format(getDisplayName(droppedSource)))
            end
        end
    end

    if netId then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
            print(('[custom_f1] Deleted rental vehicle for dropped player %s'):format(droppedSource))
        end
    end

    for targetServerId, robberId in pairs(robbingTargets) do
        if robberId == droppedSource then
            robbingTargets[targetServerId] = nil
        end
    end
end)
