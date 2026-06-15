local QBCore = exports['qb-core']:GetCoreObject()
print('[custom_f1] client.lua loaded')
local lastAppearance = nil
local restoringAppearance = false
local autoRespawning = false
local autoRespawnDelay = 60000
local autoRespawnPoint = vector4(-286.44, -985.46, 31.08, 246.78)
local weaponShop = {
    coords = vector4(-258.84, -973.77, 31.22, 160.76),
    model = `s_m_m_highsec_01`,
    label = 'Weapon Service',
    items = {
        { label = 'SNS Pistol', item = 'weapon_snspistol', price = 2500 },
        { label = 'Pistol', item = 'weapon_pistol', price = 4000 },
        { label = 'Pistol Mk II', item = 'weapon_pistol_mk2', price = 9000 },
        { label = 'Combat Pistol', item = 'weapon_combatpistol', price = 6500 },
        { label = 'Pistol .50', item = 'weapon_pistol50', price = 12000 },
        { label = 'Vintage Pistol', item = 'weapon_vintagepistol', price = 5500 },
        { label = 'Revolver', item = 'weapon_revolver', price = 35000 },
        { label = 'Flare Gun', item = 'weapon_flaregun', price = 15000 },
        { label = 'Flare Ammo x5', item = 'ammo-flare', price = 1000, count = 5 },
        { label = 'Bandage x10', item = 'bandage', price = 1000, count = 10 },
        { label = 'PistolAmmo x60', item = 'ammo-22', price = 1200, count = 60 },
    }
}
local rentalShop = {
    coords = vector4(-286.44, -985.46, 31.08, 246.78),
    spawn = vector4(-251.78, -994.84, 29.57, 250.93),
    model = `s_m_m_autoshop_01`,
    vehicle = 'sultan',
    price = 500,
    label = 'Sultan Rental',
}
local rentedVehicle = nil
local rentalDeleteTime = nil
local safeZoneProtected = false
local arenaReturnCoords = nil
local spectating = false
local duelHud = nil
local duelCancelSent = false
local damagePopups = {}
local damageHealthCache = {}
local damageArmorCache = {}
local eventHubPed = nil
local blackMarketPed = nil
local airdropBlip = nil
local airdropRadiusBlip = nil
local dynamicRedzoneBlip = nil
local dynamicRedzoneRadius = nil
local safeZoneShowcase = {}
local nextShowcaseRefresh = 0
local serverTimeBase = 0
local serverTimerBase = 0
local redZone = {
    coords = vector3(-1474.455, -2716.211, 13.944),
    radius = 175.0,
    active = true,
    endsAt = nil,
}
local eventHub = {
    coords = vector4(-261.8, -975.53, 31.22, 251.64),
    model = `s_m_y_dealer_01`,
    label = 'PvP Event Hub',
}
local blackMarket = {
    coords = vector4(-1171.2, -1572.1, 4.66, 125.0),
    model = `g_m_y_mexgoon_02`,
    label = 'Black Market',
}
local airdropState = nil
local arenaZone = {
    coords = vector4(-1954.28, 2998.22, 225.35, 239.99),
    spawnA = vector4(-1966.0, 3007.0, 225.35, 145.0),
    spawnB = vector4(-1942.5, 2989.6, 225.35, 325.0),
    radius = 58.0,
    label = 'Duel Arena',
}
local safeZone = {
    coords = vector3(-261.84, -975.45, 31.22),
    radius = 60.0,
    blipColor = 2,
    blipAlpha = 110,
    label = 'Safe Zone',
}
local garageVehicles = {
    { label = 'Sultan', model = 'sultan' },
    { label = 'Buffalo', model = 'buffalo' },
    { label = 'Bati 801', model = 'bati' },
}
local drawText3D
local restoreAppearanceAfterRespawn

local function drawRespawnCountdown(seconds)
    SetTextFont(4)
    SetTextScale(0.0, 0.48)
    SetTextColour(255, 255, 255, 230)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(('Auto respawn: %02d'):format(seconds))
    EndTextCommandDisplayText(0.5, 0.9)
end

local function drawRentalCountdown(seconds)
    SetTextFont(4)
    SetTextScale(0.0, 0.34)
    SetTextColour(255, 255, 255, 230)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(false)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(('Vehicle delete: %02d'):format(seconds))
    EndTextCommandDisplayText(0.84, 0.52)
end

local function respawnAtSafeZone(delay)
    CreateThread(function()
        Wait(delay or 0)

        local ped = PlayerPedId()
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(10)
        end

        NetworkResurrectLocalPlayer(safeZone.coords.x, safeZone.coords.y, safeZone.coords.z, 0.0, true, false)
        ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, safeZone.coords.x, safeZone.coords.y, safeZone.coords.z, false, false, false)
        SetEntityHeading(ped, 247.79)
        SetEntityHealth(ped, 200)
        ClearPedBloodDamage(ped)
        ClearPedTasksImmediately(ped)
        restoreAppearanceAfterRespawn()
        Wait(250)
        DoScreenFadeIn(500)
    end)
end

local function getServerNow()
    if serverTimeBase <= 0 then
        return math.floor(GetGameTimer() / 1000)
    end

    return serverTimeBase + math.floor((GetGameTimer() - serverTimerBase) / 1000)
end

local function formatDuration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return ('%02d:%02d'):format(math.floor(seconds / 60), seconds % 60)
end

local drawPopupText3D

local function drawDuelHud()
    if not duelHud then
        return
    end

    DrawRect(0.5, 0.105, 0.42, 0.118, 6, 10, 18, 255)
    DrawRect(0.395, 0.105, 0.18, 0.092, 15, 82, 145, 230)
    DrawRect(0.605, 0.105, 0.18, 0.092, 145, 25, 35, 230)

    SetTextFont(4)
    SetTextScale(0.0, 0.34)
    SetTextColour(255, 215, 95, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(('DUEL ROUND %s / %s'):format(duelHud.round or 1, duelHud.firstTo or 3))
    EndTextCommandDisplayText(0.5, 0.052)

    SetTextFont(4)
    SetTextScale(0.0, 0.31)
    SetTextColour(105, 195, 255, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(duelHud.aName or 'A')
    EndTextCommandDisplayText(0.395, 0.084)

    SetTextFont(4)
    SetTextScale(0.0, 0.42)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(('%s : %s'):format(duelHud.aScore or 0, duelHud.bScore or 0))
    EndTextCommandDisplayText(0.5, 0.083)

    SetTextFont(4)
    SetTextScale(0.0, 0.31)
    SetTextColour(255, 120, 120, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(duelHud.bName or 'B')
    EndTextCommandDisplayText(0.605, 0.084)

    SetTextFont(4)
    SetTextScale(0.0, 0.24)
    SetTextColour(220, 235, 255, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName('BLUE TEAM        VS        RED TEAM')
    EndTextCommandDisplayText(0.5, 0.125)
end

local function drawDamagePopups()
    local now = GetGameTimer()

    for i = #damagePopups, 1, -1 do
        local popup = damagePopups[i]

        if now > popup.expires then
            table.remove(damagePopups, i)
        else
            local player = GetPlayerFromServerId(popup.target)

            if player and player ~= -1 then
                local ped = GetPlayerPed(player)

                if ped and ped ~= 0 and DoesEntityExist(ped) then
                    local coords = GetEntityCoords(ped)
                    local progress = 1.0 - ((popup.expires - now) / popup.duration)
                    local height = (popup.height or 0.9) - (progress * 0.32)
                    local alpha = math.max(0, math.floor(230 * (1.0 - progress)))
                    drawPopupText3D(vector3(coords.x + (popup.offsetX or 0.46), coords.y + (popup.offsetY or 0.18), coords.z + height), ('-%s%%'):format(popup.percent), popup.colour, 0.34, alpha)
                end
            end
        end
    end
end

local function notify(description, type)
    if lib and lib.notify then
        lib.notify({ description = description, type = type or 'inform' })
    else
        QBCore.Functions.Notify(description, type or 'primary')
    end
end

local function chatLine(prefix, message)
    TriggerEvent('chat:addMessage', {
        color = { 80, 180, 255 },
        args = { prefix or 'Server', message }
    })
end

local function loadModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    return model
end

local function createServicePed(data)
    local model = loadModel(data.model)
    local ped = CreatePed(0, model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, true)

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetModelAsNoLongerNeeded(model)

    return ped
end

local function setNamedBlip(existing, coords, sprite, color, scale, label, radius)
    if existing then
        RemoveBlip(existing)
    end

    local blip = radius and AddBlipForRadius(coords.x, coords.y, coords.z, radius) or AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipColour(blip, color)
    SetBlipAlpha(blip, radius and 145 or 255)

    if not radius then
        SetBlipSprite(blip, sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, scale or 0.8)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
    end

    return blip
end

local function refreshDynamicRedzone()
    if not redZone.active then
        if dynamicRedzoneBlip then RemoveBlip(dynamicRedzoneBlip) end
        if dynamicRedzoneRadius then RemoveBlip(dynamicRedzoneRadius) end
        dynamicRedzoneBlip = nil
        dynamicRedzoneRadius = nil
        return
    end

    dynamicRedzoneBlip = setNamedBlip(dynamicRedzoneBlip, redZone.coords, 310, 38, 1.1, 'MGrande BlueZone')
    dynamicRedzoneRadius = setNamedBlip(dynamicRedzoneRadius, redZone.coords, 1, 38, 1.0, 'MGrande BlueZone', redZone.radius)
end

local function refreshBlackMarket()
    if blackMarketPed and DoesEntityExist(blackMarketPed) then
        DeleteEntity(blackMarketPed)
    end

    blackMarketPed = createServicePed(blackMarket)
end

local function openBlackMarket()
    lib.registerContext({
        id = 'custom_black_market',
        title = 'Black Market',
        options = {
            { title = 'Armor - $5000', icon = 'shield', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:blackMarketBuy', 'armor') end },
            { title = 'PistolAmmo x160 - $3000', icon = 'box', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:blackMarketBuy', 'ammo') end },
            { title = 'Revolver - $42000', icon = 'gun', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:blackMarketBuy', 'revolver') end },
        }
    })
    lib.showContext('custom_black_market')
end

local function openHubCommandBoard()
    lib.registerContext({
        id = 'custom_hub_commands',
        title = 'Command Board',
        menu = 'custom_event_hub',
        options = {
            { title = '/leaderboard', description = 'Rank, aimscore, season, battle pass, prestige bugdiig neg dor harna.', icon = 'bar-chart-3' },
            { title = '/duel [id] [money]', description = 'Best of 3 wager duel ehluulne.', icon = 'swords' },
            { title = '/teamarena', description = 'Maze Bank Arena ruu team PvP-d ochno.', icon = 'users' },
            { title = '/airdrop', description = 'Active airdrop baival GPS deer temdeglene.', icon = 'package' },
            { title = '/settag TAG, /bounty [id] [money]', description = 'Clan tag bolon bounty system.', icon = 'badge' },
            { title = '/daily', description = 'Daily PvP mission progress harna, duussan bol reward avna.', icon = 'calendar-check' },
            { title = '/duelbet [id] [money] [blue/red/id]', description = 'Duel uzej bgaa ued winner deer bet tavina.', icon = 'badge-dollar-sign' },
        }
    })
    lib.showContext('custom_hub_commands')
end

local function openProgressHub()
    local ok, data = pcall(function()
        return lib.callback.await('custom_f1_rob_radio:getProgressHub', false)
    end)

    if not ok or not data then
        lib.registerContext({
            id = 'custom_progress_hub',
            title = 'Leaderboard Hub',
            options = {
                { title = 'Progress data achaallaj chadsangui', description = 'custom_f1_rob_radio server callback ajillaj bga esehiig shalgana.', icon = 'triangle-alert' },
            }
        })
        lib.showContext('custom_progress_hub')
        return
    end

    local redzoneLeft = data.redZoneActive == false and 'Inactive' or (data.redZoneEndsAt and formatDuration((data.redZoneEndsAt or 0) - getServerNow()) or '00:00')
    local airdropLeft = 'Inactive'
    if data.airdropLocked and data.airdropUnlocksAt then
        airdropLeft = 'Unlocks in ' .. formatDuration((data.airdropUnlocksAt or 0) - getServerNow())
    elseif data.airdropEndsAt then
        airdropLeft = 'Ends in ' .. formatDuration((data.airdropEndsAt or 0) - getServerNow())
    end
    local progress = math.min(100, math.floor(tonumber(data.bpProgress or 0) or 0))
    local options = {
        {
            title = ('%s | Rank %s | Level %s'):format(data.name or 'Player', data.rank or 'Bronze', data.bpLevel or 1),
            description = ('EXP %s/100 -> Level %s | BP XP %s | Next reward: %s'):format(progress, (data.bpLevel or 1) + 1, data.bpXp or 0, data.nextBpReward or 'Max'),
            progress = progress,
            icon = 'user',
        },
        {
            title = ('Kills %s | Deaths %s | K/D %s'):format(data.kills or 0, data.deaths or 0, data.kd or '0.00'),
            description = ('Streak %s | Best streak %s | Robs %s | Playtime %s min'):format(data.streak or 0, data.bestStreak or 0, data.robs or 0, data.playtime or 0),
            icon = 'bar-chart-3',
        },
        {
            title = ('Aimscore: %s'):format(data.aimBest or 0),
            description = 'Aim range deer avsan hamgiin sain score.',
            icon = 'crosshair',
        },
        {
            title = ('Season %s | Points %s'):format(data.season or 1, data.seasonPoints or 0),
            description = ('Prestige %s | MGrande BlueZone %s | Airdrop %s'):format(data.prestige or 0, redzoneLeft, airdropLeft),
            icon = 'trophy',
        },
        {
            title = 'Daily PvP Missions',
            description = ('Kills %s/10 | Duel %s/1 | Airdrop %s/1 | Headshot %s/3%s'):format(
                math.min(data.dailyKills or 0, 10),
                math.min(data.dailyDuelWins or 0, 1),
                math.min(data.dailyAirdrops or 0, 1),
                math.min(data.dailyHeadshots or 0, 3),
                data.dailyClaimed and ' | Claimed' or ''
            ),
            icon = 'calendar-check',
            onSelect = function() ExecuteCommand('daily') end
        },
        {
            title = 'Battle Pass',
            description = ('Claimed %s/%s | EXP status %s%%'):format(data.bpClaimedCount or 0, data.bpLevels or 0, progress),
            progress = progress,
            icon = 'star',
            onSelect = function() TriggerServerEvent('custom_f1_rob_radio:claimBattlePass') end
        },
        {
            title = 'Prestige Claim',
            description = '100 kill hursen bol prestige avna.',
            icon = 'award',
            onSelect = function() TriggerServerEvent('custom_f1_rob_radio:prestige') end
        },
    }

    if data.leaderboard and #data.leaderboard > 0 then
        options[#options + 1] = { title = 'Leaderboard Top 5', icon = 'list' }

        for _, row in ipairs(data.leaderboard) do
            options[#options + 1] = {
                title = ('#%s %s'):format(row.place, row.name),
                description = ('%s | %s kills | %s deaths | K/D %s'):format(row.rank, row.kills, row.deaths, row.kd),
                icon = 'medal',
            }
        end
    else
        options[#options + 1] = { title = 'Leaderboard hooson baina', icon = 'list' }
    end

    lib.registerContext({
        id = 'custom_progress_hub',
        title = 'Leaderboard Hub',
        options = options
    })
    lib.showContext('custom_progress_hub')
end

local function openDuelDialog()
    local input = lib.inputDialog('Duel', {
        { type = 'select', label = 'Mode', required = true, default = '1', options = {
            { label = '1vs1', value = '1' },
            { label = '2vs2', value = '2' },
            { label = '3vs3', value = '3' },
            { label = '4vs4', value = '4' },
            { label = '5vs5', value = '5' },
        } },
        { type = 'number', label = 'Player ID (1vs1 enemy)', required = false, min = 1 },
        { type = 'input', label = 'Your team IDs (2v2+)', required = false, placeholder = '2vs2: 1 teammate, 3vs3: 2 teammates' },
        { type = 'input', label = 'Enemy team IDs (2v2+)', required = false, placeholder = 'Comma separated IDs' },
        { type = 'number', label = 'Money', required = true, min = 100 },
        { type = 'number', label = 'Rounds', default = 3, required = true, min = 1, max = 10 },
    })

    if input then
        TriggerServerEvent('custom_f1_rob_radio:duelRequest', tonumber(input[2]), tonumber(input[5]), tonumber(input[6]), tonumber(input[1]), input[3], input[4])
    end
end

local function openEventHub()
    local ok, status = pcall(function()
        return lib.callback.await('custom_f1_rob_radio:getHubStatus', false)
    end)
    status = ok and status or {}
    local airdropText = status.airdropActive and 'Active' or 'Inactive'
    if status.airdropLocked and status.airdropUnlocksAt then
        airdropText = 'Locked ' .. formatDuration((status.airdropUnlocksAt or 0) - getServerNow())
    end
    local saleText = status.salePercent and status.salePercent > 0 and (status.salePercent .. '% OFF') or 'Off'
    local kd = status.deaths and status.deaths > 0 and string.format('%.2f', (status.kills or 0) / status.deaths) or string.format('%.2f', status.kills or 0)
    local redzoneText = status.redZoneActive == false and 'Inactive' or (status.redZoneEndsAt and formatDuration((status.redZoneEndsAt or 0) - getServerNow()) or '00:00')

    lib.registerContext({
        id = 'custom_event_hub',
        title = 'PvP Event Hub',
        options = {
            {
                title = ('Status: %s | Rank: %s | Sale: %s'):format(status.online or 0, status.rank or 'Bronze', saleText),
                description = ('Season %s | BP XP %s | MGrande BlueZone %s | Airdrop %s'):format(status.season or 1, status.bpXp or 0, redzoneText, airdropText),
                icon = 'activity',
                disabled = true
            },
            {
                title = ('My Profile: %s kills | K/D %s | Streak %s'):format(status.kills or 0, kd, status.streak or 0),
                description = ('Prestige %s | Deaths %s | Online %s'):format(status.prestige or 0, status.deaths or 0, status.online or 0),
                icon = 'user',
                onSelect = openProgressHub
            },
            { title = 'Leaderboard Hub', description = 'Rank, aimscore, season, battle pass, prestige bugdiig neg dor harna.', icon = 'bar-chart-3', onSelect = openProgressHub },
            { title = 'Duel', description = 'Player ID, money, round count songood duel hiine.', icon = 'swords', onSelect = openDuelDialog },
            { title = 'Team Arena', description = arenaZone.label, icon = 'users', onSelect = function() ExecuteCommand('teamarena') end },
            { title = 'Airdrop GPS', description = ('Status: %s'):format(airdropText), icon = 'package', onSelect = function() ExecuteCommand('airdrop') end },
            { title = 'Weapon Shop GPS', description = 'Balanced weapon/ammo/bandage shop.', icon = 'gun', onSelect = function() SetNewWaypoint(weaponShop.coords.x, weaponShop.coords.y) end },
            { title = 'Safezone Garage GPS', description = 'Free basic vehicles.', icon = 'car', onSelect = function() SetNewWaypoint(rentalShop.coords.x, rentalShop.coords.y) end },
            { title = 'Command Board', description = 'Buh shine command-iin tailbar.', icon = 'list', onSelect = openHubCommandBoard },
        }
    })
    lib.showContext('custom_event_hub')
end

local function drawWorldPrompt(coords, text)
    SetDrawOrigin(coords.x, coords.y, coords.z + 1.0, 0)
    SetTextFont(4)
    SetTextScale(0.0, 0.34)
    SetTextColour(255, 255, 255, 235)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function drawText3D(coords, text, colour)
    colour = colour or { 255, 255, 255 }
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextFont(4)
    SetTextScale(0.0, 0.28)
    SetTextColour(colour[1], colour[2], colour[3], 235)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function drawPopupText3D(coords, text, colour, scale, alpha)
    colour = colour or { 255, 80, 80 }
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextFont(7)
    SetTextScale(0.0, scale or 0.48)
    SetTextColour(colour[1], colour[2], colour[3], alpha or 255)
    SetTextCentre(true)
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function openWeaponShop()
    local options = {}

    for _, item in ipairs(weaponShop.items) do
        options[#options + 1] = {
            title = ('%s - $%s'):format(item.label, item.price),
            icon = 'gun',
            onSelect = function()
                TriggerServerEvent('custom_f1_rob_radio:buyWeapon', item.item)
            end
        }
    end

    lib.registerContext({
        id = 'custom_weapon_service',
        title = weaponShop.label,
        options = options
    })
    lib.showContext('custom_weapon_service')
end

local function spawnRentalVehicle()
    local paid = lib.callback.await('custom_f1_rob_radio:rentSultan', false)

    if not paid then
        return
    end

    QBCore.Functions.SpawnVehicle(rentalShop.vehicle, function(vehicle)
        local plate = ('RENT%s'):format(math.random(100, 999))

        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, rentalShop.spawn.w)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetVehicleDirtLevel(vehicle, 0.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        rentedVehicle = vehicle
        rentalDeleteTime = nil
        TriggerServerEvent('custom_f1_rob_radio:registerRentalVehicle', VehToNet(vehicle))
        notify('Sultan tureeslegdlee', 'success')
    end, rentalShop.spawn, true)
end

local function spawnGarageVehicle(model)
    local spawn = rentalShop.spawn

    QBCore.Functions.SpawnVehicle(model, function(vehicle)
        local plate = ('SAFE%s'):format(math.random(100, 999))

        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, spawn.w)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetVehicleDirtLevel(vehicle, 0.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        rentedVehicle = vehicle
        rentalDeleteTime = nil
        notify(('Garage vehicle gargalaa: %s'):format(model), 'success')
    end, spawn, true)
end

local function openGarageMenu()
    local options = {}

    for _, vehicle in ipairs(garageVehicles) do
        options[#options + 1] = {
            title = vehicle.label,
            icon = 'car',
            onSelect = function()
                spawnGarageVehicle(vehicle.model)
            end
        }
    end

    lib.registerContext({
        id = 'custom_safezone_garage',
        title = 'Safezone Garage',
        options = options
    })
    lib.showContext('custom_safezone_garage')
end

local function openSkinMenu()
    local skins = {
        { label = 'Black', tint = 0 },
        { label = 'Green', tint = 1 },
        { label = 'Gold', tint = 2 },
        { label = 'Pink', tint = 3 },
        { label = 'Army', tint = 4 },
        { label = 'Platinum', tint = 7 },
    }
    local options = {}

    for _, skin in ipairs(skins) do
        options[#options + 1] = {
            title = ('%s - $5000'):format(skin.label),
            icon = 'palette',
            onSelect = function()
                TriggerServerEvent('custom_f1_rob_radio:buyWeaponSkin', skin.tint, skin.label)
            end
        }
    end

    lib.registerContext({
        id = 'custom_weapon_skins',
        title = 'Weapon Skins',
        options = options
    })
    lib.showContext('custom_weapon_skins')
end

local function startAimRange()
    local score = 0
    local endTime = GetGameTimer() + 30000

    notify('Aim range ehlee. 30 sec dotor buudaad score awna.', 'inform')

    CreateThread(function()
        while GetGameTimer() < endTime do
            if IsPedShooting(PlayerPedId()) then
                score = score + 1
                Wait(120)
            end

            Wait(0)
        end

        TriggerServerEvent('custom_f1_rob_radio:aimScore', score)
    end)
end

local function showStarterGuide()
    chatLine('Guide', '/safezone - safe zone GPS')
    chatLine('Guide', '/redzone - MGrande BlueZone GPS')
    chatLine('Guide', '/weaponprice - weapon shop une harah')
    chatLine('Guide', '/kit, /daily - starter reward')
    chatLine('Guide', '/arena, /leavearena - PvP arena')
    chatLine('Guide', '/garage - safezone vehicle')
    chatLine('Guide', '/rank, /stats, /leaderboard - progress harah')
    chatLine('Guide', '/bp, /season, /prestige - battle pass/season progress')
    chatLine('Guide', '/duel [id] [money], /duelaccept - wager duel')
    chatLine('Guide', '/airdrop - event GPS')
    chatLine('Guide', '/settag TAG, /bounty [id] [money] - clan tag/bounty')
end

local function openRentalShop()
    lib.registerContext({
        id = 'custom_sultan_rental',
        title = rentalShop.label,
        options = {
            {
                title = ('Rent Sultan - $%s'):format(rentalShop.price),
                icon = 'car',
                onSelect = spawnRentalVehicle
            }
        }
    })
    lib.showContext('custom_sultan_rental')
end

local function applyWeaponShopPrices(prices)
    if type(prices) ~= 'table' then
        return
    end

    for _, shopItem in ipairs(weaponShop.items) do
        local price = tonumber(prices[shopItem.item])

        if price then
            shopItem.price = price
        end
    end
end

local function openWeaponShopPriceMenu()
    local options = {}

    for _, shopItem in ipairs(weaponShop.items) do
        local itemName = shopItem.item
        local label = shopItem.label

        options[#options + 1] = {
            title = ('%s - $%s'):format(label, shopItem.price),
            icon = 'dollar-sign',
            onSelect = function()
                local input = lib.inputDialog(('Set %s price'):format(label), {
                    { type = 'number', label = 'Price', default = shopItem.price, required = true, min = 0 }
                })

                if input and input[1] then
                    TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', {
                        shopPrices = {
                            [itemName] = tonumber(input[1])
                        }
                    })
                end
            end
        }
    end

    lib.registerContext({
        id = 'custom_weapon_shop_prices',
        title = 'Weapon Shop Prices',
        menu = 'custom_admin_menu',
        options = options
    })
    lib.showContext('custom_weapon_shop_prices')
end

local function openAirdropRewardsMenu(rewards)
    if not rewards then
        local config = lib.callback.await('custom_f1_rob_radio:getAdminConfig', false)
        rewards = config and config.airdropRewards or {}
    end

    rewards = rewards or {}
    local options = {}

    for index, reward in ipairs(rewards) do
        local item = reward.item or 'unknown'
        local count = tonumber(reward.count) or 1

        options[#options + 1] = {
            title = ('Slot %s: %s x%s'):format(index, item, count),
            icon = 'package',
            onSelect = function()
                local input = lib.inputDialog(('Airdrop slot %s'):format(index), {
                    { type = 'input', label = 'Item name', default = item, required = true },
                    { type = 'number', label = 'Count', default = count, required = true, min = 1 },
                    { type = 'checkbox', label = 'Remove this slot' },
                })

                if input then
                    if input[3] then
                        TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', { removeAirdropReward = index })
                    else
                        TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', {
                            airdropReward = {
                                slot = index,
                                item = input[1],
                                count = tonumber(input[2]),
                            }
                        })
                    end
                end
            end
        }
    end

    options[#options + 1] = {
        title = 'Add new reward slot',
        icon = 'plus',
        onSelect = function()
            local input = lib.inputDialog('Add airdrop reward', {
                { type = 'input', label = 'Item name', default = 'bandage', required = true },
                { type = 'number', label = 'Count', default = 1, required = true, min = 1 },
            })

            if input then
                TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', {
                    airdropReward = {
                        slot = #rewards + 1,
                        item = input[1],
                        count = tonumber(input[2]),
                    }
                })
            end
        end
    }

    lib.registerContext({
        id = 'custom_airdrop_rewards',
        title = 'Airdrop Rewards',
        menu = 'custom_event_admin',
        options = options
    })
    lib.showContext('custom_airdrop_rewards')
end

local function openRedZoneLocationsMenu()
    local config = lib.callback.await('custom_f1_rob_radio:getAdminConfig', false)
    local locations = config and config.redZoneLocations or {}
    local options = {}

    for index, location in ipairs(locations) do
        options[#options + 1] = {
            title = location.name or ('Location ' .. index),
            description = ('X %.1f | Y %.1f | Z %.1f'):format(location.x or 0.0, location.y or 0.0, location.z or 0.0),
            icon = 'map-pin',
            onSelect = function()
                TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', { redZoneLocation = index })
            end
        }
    end

    lib.registerContext({
        id = 'custom_redzone_locations',
        title = 'MGrande BlueZone Spawns',
        menu = 'custom_event_admin',
        options = options
    })
    lib.showContext('custom_redzone_locations')
end

local function openCustomAdminMenu()
    local config = lib.callback.await('custom_f1_rob_radio:getAdminConfig', false)

    if not config or not config.allowed then
        return notify('Admin erh heregtei', 'error')
    end

    applyWeaponShopPrices(config.shopPrices)

    lib.registerContext({
        id = 'custom_admin_menu',
        title = 'Custom Settings',
        options = {
            {
                title = ('Rental price: $%s'):format(rentalShop.price),
                icon = 'dollar-sign',
                onSelect = function()
                    local input = lib.inputDialog('Set rental price', {
                        { type = 'number', label = 'Price', default = rentalShop.price, required = true, min = 0 }
                    })

                    if input and input[1] then
                        TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', { rentalPrice = tonumber(input[1]) })
                    end
                end
            },
            {
                title = ('Safe zone radius: %s'):format(safeZone.radius),
                icon = 'shield',
                onSelect = function()
                    local input = lib.inputDialog('Set safe zone radius', {
                        { type = 'number', label = 'Radius', default = safeZone.radius, required = true, min = 1 }
                    })

                    if input and input[1] then
                        TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', { safeZoneRadius = tonumber(input[1]) })
                    end
                end
            },
            {
                title = 'Weapon shop item prices',
                icon = 'gun',
                onSelect = openWeaponShopPriceMenu
            },
            {
                title = 'Event admin panel',
                icon = 'calendar',
                onSelect = function()
                    lib.registerContext({
                        id = 'custom_event_admin',
                        title = 'Event Admin',
                        menu = 'custom_admin_menu',
                        options = {
                            { title = 'Start Airdrop', icon = 'package', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'airdrop') end },
                            { title = 'Start Airdrop Here', description = 'Ooriin zogsoj bgaa gazart airdrop buulgana.', icon = 'map-pin', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'airdrop_here') end },
                            {
                                title = 'Start Airdrop Coords',
                                description = 'Hussen X/Y/Z deer airdrop buulgana.',
                                icon = 'crosshair',
                                onSelect = function()
                                    local input = lib.inputDialog('Airdrop Coords', {
                                        { type = 'number', label = 'X', required = true },
                                        { type = 'number', label = 'Y', required = true },
                                        { type = 'number', label = 'Z', required = true },
                                    })

                                    if input then
                                        TriggerServerEvent('custom_f1_rob_radio:adminStartAirdropCoords', {
                                            x = tonumber(input[1]),
                                            y = tonumber(input[2]),
                                            z = tonumber(input[3])
                                        })
                                    end
                                end
                            },
                            { title = 'Airdrop rewards', icon = 'box', onSelect = function() openAirdropRewardsMenu() end },
                            { title = 'Start MGrande BlueZone', icon = 'play', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'bluezone_start') end },
                            { title = 'Stop MGrande BlueZone', icon = 'square', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'bluezone_stop') end },
                            { title = 'BlueZone spawn locations', icon = 'map-pin', onSelect = openRedZoneLocationsMenu },
                            { title = 'Rotate BlueZone', icon = 'map', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'rotate_redzone') end },
                            { title = 'Season Reset', icon = 'refresh-cw', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'season_reset') end },
                            { title = 'Sale 20%', icon = 'badge-percent', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'sale_20') end },
                            { title = 'Sale Off', icon = 'x', onSelect = function() TriggerServerEvent('custom_f1_rob_radio:adminAction', 'sale_off') end },
                        }
                    })
                    lib.showContext('custom_event_admin')
                end
            },
            {
                title = 'Set respawn point here',
                icon = 'map-pin',
                onSelect = function()
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)

                    TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', {
                        respawnPoint = { x = coords.x, y = coords.y, z = coords.z, w = GetEntityHeading(ped) }
                    })
                end
            },
            {
                title = 'Set Sultan spawn here',
                icon = 'car',
                onSelect = function()
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)

                    TriggerServerEvent('custom_f1_rob_radio:adminUpdateConfig', {
                        rentalSpawn = { x = coords.x, y = coords.y, z = coords.z, w = GetEntityHeading(ped) }
                    })
                end
            }
        }
    })
    lib.showContext('custom_admin_menu')
end

RegisterCommand('customadmin', openCustomAdminMenu, false)

RegisterCommand('redzone', function()
    if not redZone.active then
        return notify('MGrande BlueZone odoohondoo inactive baina', 'error')
    end

    SetNewWaypoint(redZone.coords.x, redZone.coords.y)
    notify(('MGrande BlueZone GPS deer temdeglelee. Radius: %sm'):format(math.floor(redZone.radius)), 'success')
end, false)

RegisterCommand('thtp', function(_, args)
    if not redZone.active then
        return notify('MGrande BlueZone inactive baina', 'error')
    end

    local side = math.max(1, math.min(2, tonumber(args[1]) or 1))
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local direction = coords - redZone.coords

    if #(direction) < 1.0 then
        direction = vector3(1.0, 0.0, 0.0)
    else
        direction = direction / #(direction)
    end

    if side == 2 then
        direction = direction * -1.0
    end

    local target = redZone.coords + (direction * (redZone.radius + 50.0))
    DoScreenFadeOut(150)
    Wait(180)
    RequestCollisionAtCoord(target.x, target.y, target.z)
    SetEntityCoordsNoOffset(ped, target.x, target.y, target.z + 1.0, false, false, false)

    local timeout = GetGameTimer() + 1600
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        RequestCollisionAtCoord(target.x, target.y, target.z)
        Wait(50)
    end

    local foundGround, groundZ = GetGroundZFor_3dCoord(target.x, target.y, target.z + 80.0, false)
    SetEntityCoordsNoOffset(ped, target.x, target.y, (foundGround and groundZ or target.z) + 0.4, false, false, false)
    DoScreenFadeIn(150)
    notify(('MGrande BlueZone taliin %s deer teleport hiilee'):format(side), 'success')
end, false)

RegisterCommand('safezone', function()
    SetNewWaypoint(safeZone.coords.x, safeZone.coords.y)
    local distance = math.floor(#(GetEntityCoords(PlayerPedId()) - safeZone.coords))
    notify(('Safe zone GPS deer temdeglelee. Zai: %sm'):format(distance), 'success')
end, false)

RegisterCommand('weaponprice', function()
    chatLine('Weapon Shop', 'Odoogiin uniin jagsaalt:')

    for _, shopItem in ipairs(weaponShop.items) do
        chatLine('Weapon Shop', ('%s - $%s'):format(shopItem.label, shopItem.price))
    end
end, false)

RegisterCommand('report', function(_, args)
    local message = table.concat(args, ' ')

    if message == '' then
        return notify('/report [asuudal]', 'error')
    end

    TriggerServerEvent('custom_f1_rob_radio:createReport', message)
end, false)

RegisterCommand('stats', function()
    notify('Stats harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('leaderboard', function()
    openProgressHub()
end, false)

RegisterCommand('garage', openGarageMenu, false)

RegisterCommand('skin', openSkinMenu, false)

RegisterCommand('weaponskin', openSkinMenu, false)

RegisterCommand('aimrange', startAimRange, false)

RegisterCommand('guide', showStarterGuide, false)

RegisterCommand('hub', openEventHub, false)

RegisterCommand('pvphub', openEventHub, false)

RegisterCommand('bp', function()
    notify('Battle Pass harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('battlepass', function()
    notify('Battle Pass harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('season', function()
    notify('Season info harahdaa /leaderboard ashiglana', 'inform')
end, false)

RegisterCommand('prestige', function()
    TriggerServerEvent('custom_f1_rob_radio:prestige')
end, false)

RegisterCommand('duel', function(_, args)
    TriggerServerEvent('custom_f1_rob_radio:duelRequest', tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
end, false)

RegisterCommand('duelaccept', function()
    TriggerServerEvent('custom_f1_rob_radio:duelAccept')
end, false)

RegisterCommand('dueldecline', function()
    TriggerServerEvent('custom_f1_rob_radio:duelDecline')
end, false)

RegisterCommand('teamarena', function()
    SetEntityCoordsNoOffset(PlayerPedId(), arenaZone.coords.x + math.random(-24, 24), arenaZone.coords.y + math.random(-24, 24), arenaZone.coords.z, false, false, false)
    SetEntityHeading(PlayerPedId(), arenaZone.coords.w)
    notify('Team arena ruu orloo', 'success')
end, false)

RegisterCommand('airdrop', function()
    if not airdropState or not airdropState.active then
        return notify('Odoohondoo active airdrop alga', 'error')
    end

    SetNewWaypoint(airdropState.coords.x, airdropState.coords.y)
    if airdropState.locked then
        local left = airdropState.unlocksAt and formatDuration(airdropState.unlocksAt - getServerNow()) or '05:00'
        notify(('Airdrop GPS deer temdeglelee. Uhah hurtel: %s'):format(left), 'inform')
    else
        notify('Airdrop GPS deer temdeglelee. Odoo uhaj bolno', 'success')
    end
end, false)

RegisterCommand('blackmarket', function()
    notify('Black Market nuuts location; map/GPS deer haragdahgui', 'inform')
end, false)

RegisterCommand('arena', function()
    local ped = PlayerPedId()
    arenaReturnCoords = GetEntityCoords(ped)
    SetEntityCoordsNoOffset(ped, arenaZone.coords.x, arenaZone.coords.y, arenaZone.coords.z, false, false, false)
    SetEntityHeading(ped, arenaZone.coords.w)
    notify('Arena ruu orloo. Garahdaa /leavearena', 'success')
end, false)

RegisterCommand('leavearena', function()
    local ped = PlayerPedId()

    if arenaReturnCoords then
        SetEntityCoordsNoOffset(ped, arenaReturnCoords.x, arenaReturnCoords.y, arenaReturnCoords.z, false, false, false)
        arenaReturnCoords = nil
    else
        SetEntityCoordsNoOffset(ped, safeZone.coords.x, safeZone.coords.y, safeZone.coords.z, false, false, false)
    end

    notify('Arena-s garlaa', 'success')
end, false)

RegisterNetEvent('custom_f1_rob_radio:updateConfig', function(data)
    if data.serverTime then
        serverTimeBase = math.floor(data.serverTime)
        serverTimerBase = GetGameTimer()
    end

    if data.rentalPrice then
        rentalShop.price = data.rentalPrice
    end

    if data.safeZoneRadius then
        safeZone.radius = data.safeZoneRadius
    end

    if data.respawnPoint then
        autoRespawnPoint = vector4(data.respawnPoint.x, data.respawnPoint.y, data.respawnPoint.z, data.respawnPoint.w)
    end

    if data.rentalSpawn then
        rentalShop.spawn = vector4(data.rentalSpawn.x, data.rentalSpawn.y, data.rentalSpawn.z, data.rentalSpawn.w)
    end

    if data.redZone then
        redZone.coords = vector3(data.redZone.x, data.redZone.y, data.redZone.z)
        redZone.radius = data.redZone.radius or redZone.radius
        redZone.active = data.redZone.active ~= false
        redZone.endsAt = data.redZone.endsAt
        refreshDynamicRedzone()
    end

    if data.blackMarket then
        blackMarket.coords = vector4(data.blackMarket.x, data.blackMarket.y, data.blackMarket.z, data.blackMarket.w)
        refreshBlackMarket()
    end

    if data.airdrop then
        airdropState = data.airdrop
        if airdropBlip then RemoveBlip(airdropBlip) end
        if airdropRadiusBlip then RemoveBlip(airdropRadiusBlip) end
        airdropBlip = nil
        airdropRadiusBlip = nil
        if airdropState.active then
            airdropBlip = setNamedBlip(nil, vector3(airdropState.coords.x, airdropState.coords.y, airdropState.coords.z), 94, 46, 0.9, 'Airdrop')
            airdropRadiusBlip = setNamedBlip(nil, vector3(airdropState.coords.x, airdropState.coords.y, airdropState.coords.z), 1, 1, 1.0, 'Airdrop Zone', airdropState.radius or 350.0)
        end
    end

    applyWeaponShopPrices(data.shopPrices)

    notify('Custom settings updated', 'success')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    if airdropRadiusBlip then RemoveBlip(airdropRadiusBlip) end
end)

local function getClosestServerId()
    local player, distance = QBCore.Functions.GetClosestPlayer()

    if player == -1 or not distance or distance > 2.0 then
        return nil
    end

    return GetPlayerServerId(player)
end

local function requestRob()
    local targetServerId = getClosestServerId()

    if not targetServerId then
        return notify('Rob hiih hun oir alga', 'error')
    end

    TriggerServerEvent('custom_f1_rob_radio:robPlayer', targetServerId)
end

RegisterCommand('rob', requestRob, false)

local function getCurrentAppearance()
    if GetResourceState('illenium-appearance') ~= 'started' then
        return nil
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 then
        return nil
    end

    local ok, appearance = pcall(function()
        return exports['illenium-appearance']:getPedAppearance(ped)
    end)

    if ok then
        return appearance
    end

    return nil
end

local function makePedUsable()
    local ped = PlayerPedId()

    if not ped or ped == 0 then
        return
    end

    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 0)
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
end

function restoreAppearanceAfterRespawn()
    if restoringAppearance then
        return
    end

    restoringAppearance = true

    CreateThread(function()
        Wait(750)
        makePedUsable()

        if GetResourceState('illenium-appearance') == 'started' then
            TriggerEvent('illenium-appearance:client:reloadSkin', true)
            Wait(1500)

            if lastAppearance then
                pcall(function()
                    exports['illenium-appearance']:setPlayerAppearance(lastAppearance)
                end)
            end
        end

        Wait(250)
        makePedUsable()
        restoringAppearance = false
    end)
end

local function isInRedzone()
    local ped = PlayerPedId()

    if not ped or ped == 0 then
        return false
    end

    return redZone.active and #(GetEntityCoords(ped) - redZone.coords) <= redZone.radius
end

local function autoRespawnAt()
    if autoRespawning or isInRedzone() then
        return
    end

    autoRespawning = true

    CreateThread(function()
        local endTime = GetGameTimer() + autoRespawnDelay

        while GetGameTimer() < endTime do
            if isInRedzone() then
                autoRespawning = false
                return
            end

            local remaining = math.ceil((endTime - GetGameTimer()) / 1000)
            drawRespawnCountdown(remaining)
            Wait(0)
        end

        if isInRedzone() then
            autoRespawning = false
            return
        end

        local ped = PlayerPedId()
        if ped and ped ~= 0 and IsEntityDead(ped) then
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Wait(10)
            end

            NetworkResurrectLocalPlayer(autoRespawnPoint.x, autoRespawnPoint.y, autoRespawnPoint.z, autoRespawnPoint.w, true, false)
            ped = PlayerPedId()
            SetEntityCoordsNoOffset(ped, autoRespawnPoint.x, autoRespawnPoint.y, autoRespawnPoint.z, false, false, false)
            SetEntityHeading(ped, autoRespawnPoint.w)
            SetEntityHealth(ped, 200)
            ClearPedTasksImmediately(ped)
            makePedUsable()

            restoreAppearanceAfterRespawn()

            Wait(500)
            DoScreenFadeIn(500)
        end

        autoRespawning = false
    end)
end

AddEventHandler('baseevents:onPlayerDied', function()
    lastAppearance = getCurrentAppearance() or lastAppearance
    local _, bone = GetPedLastDamageBone(PlayerPedId())
    TriggerServerEvent('custom_f1_rob_radio:recordDeath', nil, { headshot = bone == 31086 })

    if isInRedzone() then
        notify('MGrande BlueZone: 5 sec daraa Safe Zone ruu spawn hiine', 'inform')
        respawnAtSafeZone(5000)
        return
    end

    autoRespawnAt()
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    lastAppearance = getCurrentAppearance() or lastAppearance
    local ped = PlayerPedId()
    local killer = GetPedSourceOfDeath(ped)
    local killerServerId = nil

    if killer and killer ~= 0 then
        for _, player in ipairs(GetActivePlayers()) do
            if GetPlayerPed(player) == killer and player ~= PlayerId() then
                killerServerId = GetPlayerServerId(player)
                break
            end
        end
    end

    local _, bone = GetPedLastDamageBone(ped)
    TriggerServerEvent('custom_f1_rob_radio:recordDeath', killerServerId, { headshot = bone == 31086 })

    if isInRedzone() then
        notify('MGrande BlueZone: 5 sec daraa Safe Zone ruu spawn hiine', 'inform')
        respawnAtSafeZone(5000)
        return
    end

    autoRespawnAt()
end)

AddEventHandler('playerSpawned', function()
    restoreAppearanceAfterRespawn()
end)

RegisterNetEvent('hospital:client:Revive', function()
    restoreAppearanceAfterRespawn()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    lastAppearance = nil
    restoreAppearanceAfterRespawn()
    SetTimeout(3500, showStarterGuide)
end)

RegisterNetEvent('custom_f1_rob_radio:eventAnnouncement', function(message)
    notify(message, 'inform')
    chatLine('Event', message)
end)

RegisterNetEvent('custom_f1_rob_radio:blueZoneDisarm', function()
    SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
end)

RegisterNetEvent('custom_f1_rob_radio:airdropAlarm', function()
    CreateThread(function()
        for _ = 1, 8 do
            PlaySoundFrontend(-1, 'MP_IDLE_TIMER', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            PlaySoundFrontend(-1, 'TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET', true)
            Wait(420)
        end
    end)
end)

AddEventHandler('ox_inventory:usedItem', function(name)
    if name ~= 'bandage' then
        return
    end

    local ped = PlayerPedId()
    SetEntityHealth(ped, math.min(200, GetEntityHealth(ped) + 35))
    SetPedArmour(ped, math.min(100, GetPedArmour(ped) + 25))
    notify('хөөрөг хэрэглэв: health +35, armor +25', 'success')
end)

RegisterNetEvent('ox_inventory:removeDrop', function(dropId)
    if airdropState and airdropState.dropId == dropId then
        if airdropBlip then
            RemoveBlip(airdropBlip)
            airdropBlip = nil
        end
        if airdropRadiusBlip then
            RemoveBlip(airdropRadiusBlip)
            airdropRadiusBlip = nil
        end

        airdropState = nil
        TriggerServerEvent('custom_f1_rob_radio:airdropRemoved', dropId)
    end
end)

RegisterNetEvent('custom_f1_rob_radio:showStats', function(stats)
    stats = stats or {}
    chatLine('Stats', ('Rank: %s | Kills: %s | Deaths: %s | K/D: %s | Streak: %s | Best: %s | Robs: %s | Playtime: %s min'):format(
        stats.rank or 'Bronze',
        stats.kills or 0,
        stats.deaths or 0,
        stats.kd or '0.00',
        stats.streak or 0,
        stats.bestStreak or 0,
        stats.robs or 0,
        stats.playtime or 0
    ))
end)

RegisterNetEvent('custom_f1_rob_radio:duelTeleport', function(coords)
    local ped = PlayerPedId()
    local x = coords.x + 0.0
    local y = coords.y + 0.0
    local z = (coords.z or 225.35) + 0.0

    arenaReturnCoords = GetEntityCoords(PlayerPedId())
    duelCancelSent = false
    DoScreenFadeOut(150)
    Wait(180)
    FreezeEntityPosition(ped, true)
    RequestCollisionAtCoord(x, y, z)
    NewLoadSceneStartSphere(x, y, z, 80.0, 0)
    SetEntityCoordsNoOffset(ped, x, y, z + 1.0, false, false, false)

    local timeout = GetGameTimer() + 1800
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        RequestCollisionAtCoord(x, y, z)
        Wait(50)
    end

    NewLoadSceneStop()
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)
    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(150)
    notify('Duel ehlee', 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:duelHud', function(data)
    duelHud = data
    duelCancelSent = false
end)

RegisterNetEvent('custom_f1_rob_radio:duelEnd', function(message)
    duelHud = nil
    duelCancelSent = false
    notify(message or 'Duel duuslaa', 'success')
    respawnAtSafeZone(800)
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then
        return
    end

    local victim = args[1]
    local attacker = args[2]

    if attacker ~= PlayerPedId() or not victim or victim == 0 or not IsEntityAPed(victim) or not IsPedAPlayer(victim) then
        return
    end

    local targetPlayer = NetworkGetPlayerIndexFromPed(victim)
    local targetServerId = targetPlayer and GetPlayerServerId(targetPlayer)

    if not targetServerId or targetServerId <= 0 then
        return
    end

    local beforeHealth = damageHealthCache[targetServerId] or (GetEntityHealth(victim) + 0.0)
    local beforeArmor = damageArmorCache[targetServerId] or (GetPedArmour(victim) + 0.0)

    SetTimeout(0, function()
        if not DoesEntityExist(victim) then
            return
        end

        local afterHealth = GetEntityHealth(victim) + 0.0
        local afterArmor = GetPedArmour(victim) + 0.0
        damageHealthCache[targetServerId] = afterHealth
        damageArmorCache[targetServerId] = afterArmor
        local armorDamage = math.max(0, math.floor(beforeArmor - afterArmor))
        local healthDamage = math.max(0, math.floor(beforeHealth - afterHealth))

        if armorDamage > 0 then
            damagePopups[#damagePopups + 1] = {
                target = targetServerId,
                percent = math.max(1, math.min(100, math.floor((armorDamage / 100.0) * 100))),
                colour = { 55, 165, 255 },
                offsetX = 0.56,
                offsetY = 0.22,
                height = 0.98,
                duration = 900,
                expires = GetGameTimer() + 900,
            }
        end

        if healthDamage > 0 then
            damagePopups[#damagePopups + 1] = {
                target = targetServerId,
                percent = math.max(1, math.min(100, math.floor((healthDamage / 200.0) * 100))),
                colour = { 255, 55, 55 },
                offsetX = armorDamage > 0 and 0.72 or 0.56,
                offsetY = armorDamage > 0 and 0.28 or 0.22,
                height = armorDamage > 0 and 0.82 or 0.98,
                duration = 900,
                expires = GetGameTimer() + 900,
            }
        end
    end)
end)

RegisterNetEvent('custom_f1_rob_radio:deathRecap', function(data)
    data = data or {}
    chatLine('Death Recap', ('Killed by: %s | Weapon: %s | Distance: %sm | Streak: %s | Bounty: $%s%s'):format(
        data.killer or 'Unknown',
        data.weapon or 'Unknown',
        data.distance or 0,
        data.streak or 0,
        data.bounty or 0,
        data.headshot and ' | HEADSHOT' or ''
    ))
end)

RegisterNetEvent('custom_f1_rob_radio:applyWeaponTint', function(tint)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    if weapon and weapon ~= `WEAPON_UNARMED` then
        SetPedWeaponTintIndex(ped, weapon, tonumber(tint) or 0)
    else
        notify('Gartaa buu bariad skin songono uu', 'error')
    end
end)

RegisterNetEvent('custom_f1_rob_radio:spectatePlayer', function(targetServerId)
    local targetPlayer = GetPlayerFromServerId(targetServerId)

    if targetPlayer == -1 then
        return notify('Spectate target oldsongui', 'error')
    end

    local targetPed = GetPlayerPed(targetPlayer)

    if not targetPed or targetPed == 0 then
        return notify('Spectate target ped alga', 'error')
    end

    spectating = true
    NetworkSetInSpectatorMode(true, targetPed)
    notify(('Spectate ehlee: %s'):format(targetServerId), 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:stopSpectate', function()
    if spectating then
        NetworkSetInSpectatorMode(false, PlayerPedId())
        spectating = false
    end

    notify('Spectate zogsooloo', 'success')
end)

RegisterNetEvent('custom_f1_rob_radio:clearSafeVehicles', function()
    local deleted = 0
    local vehicles = GetGamePool('CVehicle')

    for i = 1, #vehicles do
        local vehicle = vehicles[i]

        if DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - safeZone.coords) <= safeZone.radius then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)

            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end

            deleted = deleted + 1
        end
    end

    TriggerServerEvent('custom_f1_rob_radio:clearSafeVehiclesResult', deleted)
end)

AddEventHandler('onClientMapStart', function()
    Wait(2000)

    if GetResourceState('spawnmanager') == 'started' then
        exports.spawnmanager:setAutoSpawn(false)
    end
end)

CreateThread(function()
    for _ = 1, 5 do
        Wait(2000)

        if GetResourceState('spawnmanager') == 'started' then
            exports.spawnmanager:setAutoSpawn(false)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(3000)

        local ped = PlayerPedId()
        if ped and ped ~= 0 and not IsEntityDead(ped) and IsEntityVisible(ped) then
            lastAppearance = getCurrentAppearance() or lastAppearance
        end
    end
end)

CreateThread(function()
    createServicePed(weaponShop)
    createServicePed(rentalShop)
    eventHubPed = createServicePed(eventHub)
    refreshBlackMarket()
    refreshDynamicRedzone()

    local weaponBlip = AddBlipForCoord(weaponShop.coords.x, weaponShop.coords.y, weaponShop.coords.z)
    SetBlipSprite(weaponBlip, 110)
    SetBlipDisplay(weaponBlip, 4)
    SetBlipScale(weaponBlip, 0.75)
    SetBlipColour(weaponBlip, 1)
    SetBlipAsShortRange(weaponBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(weaponShop.label)
    EndTextCommandSetBlipName(weaponBlip)

    local rentalBlip = AddBlipForCoord(rentalShop.coords.x, rentalShop.coords.y, rentalShop.coords.z)
    SetBlipSprite(rentalBlip, 225)
    SetBlipDisplay(rentalBlip, 4)
    SetBlipScale(rentalBlip, 0.75)
    SetBlipColour(rentalBlip, 2)
    SetBlipAsShortRange(rentalBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(rentalShop.label)
    EndTextCommandSetBlipName(rentalBlip)

    setNamedBlip(nil, eventHub.coords, 304, 3, 0.8, eventHub.label)
end)

CreateThread(function()
    while true do
        local sleep = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local weaponDistance = #(coords - vector3(weaponShop.coords.x, weaponShop.coords.y, weaponShop.coords.z))
        local rentalDistance = #(coords - vector3(rentalShop.coords.x, rentalShop.coords.y, rentalShop.coords.z))
        local eventDistance = #(coords - vector3(eventHub.coords.x, eventHub.coords.y, eventHub.coords.z))
        local marketDistance = #(coords - vector3(blackMarket.coords.x, blackMarket.coords.y, blackMarket.coords.z))

        if weaponDistance <= 2.0 then
            sleep = 0
            drawWorldPrompt(weaponShop.coords, '[E] Weapon Service')
            if IsControlJustPressed(0, 38) then
                openWeaponShop()
            end
        elseif rentalDistance <= 2.0 then
            sleep = 0
            drawWorldPrompt(rentalShop.coords, '[E] Sultan Rental')
            if IsControlJustPressed(0, 38) then
                openRentalShop()
            end
        elseif eventDistance <= 2.0 then
            sleep = 0
            drawWorldPrompt(eventHub.coords, '[E] Duel')
            if IsControlJustPressed(0, 38) then
                openDuelDialog()
            end
        elseif marketDistance <= 2.0 then
            sleep = 0
            drawWorldPrompt(blackMarket.coords, '[E] Black Market')
            if IsControlJustPressed(0, 38) then
                openBlackMarket()
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local hubDistance = #(coords - vector3(eventHub.coords.x, eventHub.coords.y, eventHub.coords.z))
        local marketDistance = #(coords - vector3(blackMarket.coords.x, blackMarket.coords.y, blackMarket.coords.z))
        local arenaDistance = #(coords - vector3(arenaZone.coords.x, arenaZone.coords.y, arenaZone.coords.z))
        local redzoneDistance = #(coords - redZone.coords)
        local airdropDistance = airdropState and airdropState.active and #(coords - vector3(airdropState.coords.x, airdropState.coords.y, airdropState.coords.z)) or 99999.0

        if hubDistance <= 18.0 then
            sleep = 0
            drawText3D(vector3(eventHub.coords.x, eventHub.coords.y, eventHub.coords.z + 1.25), 'PvP EVENT HUB', { 90, 180, 255 })
            drawText3D(vector3(eventHub.coords.x, eventHub.coords.y, eventHub.coords.z + 1.05), '/hub | Duel | Battle Pass | Events', { 255, 255, 255 })
        end

        if marketDistance <= 18.0 then
            sleep = 0
            drawText3D(vector3(blackMarket.coords.x, blackMarket.coords.y, blackMarket.coords.z + 1.25), 'BLACK MARKET', { 255, 90, 90 })
            drawText3D(vector3(blackMarket.coords.x, blackMarket.coords.y, blackMarket.coords.z + 1.05), 'Armor | Ammo | Revolver', { 255, 255, 255 })
        end

        local safeDistance = #(coords - safeZone.coords)
        if safeDistance <= safeZone.radius + 30.0 then
            sleep = 0

            if GetGameTimer() >= nextShowcaseRefresh then
                nextShowcaseRefresh = GetGameTimer() + 8000
                CreateThread(function()
                    local ok, rows = pcall(function()
                        return lib.callback.await('custom_f1_rob_radio:getSafeZoneShowcase', false)
                    end)

                    if ok and rows then
                        safeZoneShowcase = rows
                    end
                end)
            end

            drawText3D(vector3(safeZone.coords.x, safeZone.coords.y, safeZone.coords.z + 2.4), 'SAFEZONE TOP PLAYERS', { 80, 255, 130 })
            for i, row in ipairs(safeZoneShowcase or {}) do
                drawText3D(vector3(safeZone.coords.x, safeZone.coords.y, safeZone.coords.z + 2.2 - (i * 0.18)), ('#%s %s | %s kills | P%s | Best %s'):format(i, row.name or 'Unknown', row.kills or 0, row.prestige or 0, row.streak or 0), { 255, 255, 255 })
            end
        end

        if arenaDistance <= 140.0 then
            sleep = 0
            DrawMarker(1, arenaZone.coords.x, arenaZone.coords.y, arenaZone.coords.z - 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, arenaZone.radius * 2.0, arenaZone.radius * 2.0, 1.2, 80, 150, 255, 70, false, false, 2, false, nil, nil, false)
            drawText3D(vector3(arenaZone.coords.x, arenaZone.coords.y, arenaZone.coords.z + 1.2), 'DUEL ARENA', { 90, 180, 255 })
        end

        local redzoneVisualRadius = redZone.radius

        if redZone.active and redzoneDistance <= redzoneVisualRadius + 85.0 then
            sleep = 0
            local left = redZone.endsAt and formatDuration(redZone.endsAt - getServerNow()) or '00:00'
            DrawMarker(28, redZone.coords.x, redZone.coords.y, redZone.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, redzoneVisualRadius, redzoneVisualRadius, redzoneVisualRadius, 0, 175, 255, 92, false, false, 2, false, nil, nil, false)
            DrawMarker(1, redZone.coords.x, redZone.coords.y, redZone.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, redZone.radius * 2.0, redZone.radius * 2.0, 1.5, 0, 190, 255, 70, false, false, 2, false, nil, nil, false)
            drawText3D(vector3(redZone.coords.x, redZone.coords.y, redZone.coords.z + 3.0), ('MGRANDE BLUEZONE | %s'):format(left), { 0, 190, 255 })
        end

        if airdropDistance <= 90.0 then
            sleep = 0
            local label = 'AIRDROP'
            if airdropState.locked and airdropState.unlocksAt then
                label = 'AIRDROP LOCKED | ' .. formatDuration(airdropState.unlocksAt - getServerNow())
            elseif airdropState.endsAt then
                label = 'AIRDROP OPEN | ' .. formatDuration(airdropState.endsAt - getServerNow())
            end

            DrawMarker(1, airdropState.coords.x, airdropState.coords.y, airdropState.coords.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0, 24.0, 1.4, 255, 205, 80, 95, false, false, 2, false, nil, nil, false)
            drawText3D(vector3(airdropState.coords.x, airdropState.coords.y, airdropState.coords.z + 2.1), label, { 255, 205, 80 })
            drawText3D(vector3(airdropState.coords.x, airdropState.coords.y, airdropState.coords.z + 1.85), 'Stay nearby for the timer', { 255, 255, 255 })
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    local centerBlip = AddBlipForCoord(safeZone.coords.x, safeZone.coords.y, safeZone.coords.z)
    SetBlipSprite(centerBlip, 487)
    SetBlipDisplay(centerBlip, 4)
    SetBlipScale(centerBlip, 0.9)
    SetBlipColour(centerBlip, safeZone.blipColor)
    SetBlipAsShortRange(centerBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(safeZone.label)
    EndTextCommandSetBlipName(centerBlip)

    local radiusBlip = AddBlipForRadius(safeZone.coords.x, safeZone.coords.y, safeZone.coords.z, safeZone.radius)
    SetBlipColour(radiusBlip, safeZone.blipColor)
    SetBlipAlpha(radiusBlip, safeZone.blipAlpha)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        SetPedSuffersCriticalHits(ped, true)
        SetPedConfigFlag(ped, 438, true)
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inSafeZone = #(coords - safeZone.coords) <= safeZone.radius

        if inSafeZone then
            if not safeZoneProtected then
                safeZoneProtected = true
            end

            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true) -- attack
            DisableControlAction(0, 25, true) -- aim
            DisableControlAction(0, 37, true) -- weapon wheel
            DisableControlAction(0, 44, true) -- cover
            DisableControlAction(0, 45, true) -- reload
            DisableControlAction(0, 140, true) -- melee light
            DisableControlAction(0, 141, true) -- melee heavy
            DisableControlAction(0, 142, true) -- melee alternate
            DisableControlAction(0, 143, true) -- melee block
            DisableControlAction(0, 257, true) -- attack 2
            DisableControlAction(0, 263, true) -- melee attack 1
            DisableControlAction(0, 264, true) -- melee attack 2
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

            for _, player in ipairs(GetActivePlayers()) do
                local otherPed = GetPlayerPed(player)
                if otherPed ~= ped then
                    SetEntityNoCollisionEntity(ped, otherPed, true)
                    SetEntityNoCollisionEntity(otherPed, ped, true)
                end
            end

            local vehicles = GetGamePool('CVehicle')
            for i = 1, #vehicles do
                local vehicle = vehicles[i]
                if #(GetEntityCoords(vehicle) - safeZone.coords) <= safeZone.radius + 10.0 then
                    SetEntityNoCollisionEntity(ped, vehicle, true)
                    SetEntityNoCollisionEntity(vehicle, ped, true)

                    for _, player in ipairs(GetActivePlayers()) do
                        local otherPed = GetPlayerPed(player)
                        SetEntityNoCollisionEntity(otherPed, vehicle, true)
                        SetEntityNoCollisionEntity(vehicle, otherPed, true)
                    end

                    for j = i + 1, #vehicles do
                        local otherVehicle = vehicles[j]
                        if #(GetEntityCoords(otherVehicle) - safeZone.coords) <= safeZone.radius + 10.0 then
                            SetEntityNoCollisionEntity(vehicle, otherVehicle, true)
                            SetEntityNoCollisionEntity(otherVehicle, vehicle, true)
                        end
                    end
                end
            end

            Wait(0)
        else
            if safeZoneProtected then
                safeZoneProtected = false
                SetEntityInvincible(ped, false)
                SetPlayerInvincible(PlayerId(), false)
            end

            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if duelHud then
            drawDuelHud()
        else
            Wait(300)
        end

    end
end)

CreateThread(function()
    while true do
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)

            if ped and ped ~= 0 and DoesEntityExist(ped) and ped ~= PlayerPedId() then
                local serverId = GetPlayerServerId(player)
                damageHealthCache[serverId] = GetEntityHealth(ped) + 0.0
                damageArmorCache[serverId] = GetPedArmour(ped) + 0.0
            end
        end

        Wait(500)
    end
end)

CreateThread(function()
    while true do
        if #damagePopups > 0 then
            Wait(0)
            drawDamagePopups()
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()

        DisableControlAction(0, 44, true) -- Q / cover
        SetPlayerCanUseCover(PlayerId(), false)

        if IsPedInCover(ped, false) then
            ClearPedTasksImmediately(ped)
        end

        Wait(0)
    end
end)

CreateThread(function()
    local nextFlareAirdrop = 0

    while true do
        local sleep = 250
        local ped = PlayerPedId()

        if IsPedShooting(ped) and GetSelectedPedWeapon(ped) == `WEAPON_FLAREGUN` then
            sleep = 0
            local now = GetGameTimer()

            if now >= nextFlareAirdrop then
                local hit, impactCoords = GetPedLastWeaponImpactCoord(ped)

                if hit then
                    nextFlareAirdrop = now + 30000
                    TriggerServerEvent('custom_f1_rob_radio:flareAirdropRequest', {
                        x = impactCoords.x,
                        y = impactCoords.y,
                        z = impactCoords.z
                    })
                    notify('Flare signal ilgeelee. Airdrop 5 sec daraa ehlelne', 'inform')
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if duelHud then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local arena = duelHud.arena or {}
            local arenaCenter = vector3(arena.x or arenaZone.coords.x, arena.y or arenaZone.coords.y, arena.z or arenaZone.coords.z)
            local arenaRadius = arena.radius or arenaZone.radius

            if not duelCancelSent and #(coords - arenaCenter) > arenaRadius then
                duelCancelSent = true
                TriggerServerEvent('custom_f1_rob_radio:duelCancel', 'arena boundary')
            end

            Wait(250)
        else
            duelCancelSent = false
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if rentedVehicle and DoesEntityExist(rentedVehicle) then
            local ped = PlayerPedId()
            local inVehicle = IsPedInVehicle(ped, rentedVehicle, false)

            if inVehicle then
                rentalDeleteTime = nil
            else
                rentalDeleteTime = rentalDeleteTime or (GetGameTimer() + 30000)
                local remaining = math.ceil((rentalDeleteTime - GetGameTimer()) / 1000)

                if remaining > 0 then
                    drawRentalCountdown(remaining)
                else
                    SetEntityAsMissionEntity(rentedVehicle, true, true)
                    DeleteVehicle(rentedVehicle)
                    if DoesEntityExist(rentedVehicle) then
                        DeleteEntity(rentedVehicle)
                    end
                    rentedVehicle = nil
                    rentalDeleteTime = nil
                end
            end
        else
            rentedVehicle = nil
            rentalDeleteTime = nil
            Wait(750)
        end
    end
end)

CreateThread(function()
    local driveByBlocked = false

    while true do
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            if not driveByBlocked then
                driveByBlocked = true
                SetPlayerCanDoDriveBy(PlayerId(), false)
            end

            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true) -- attack
            DisableControlAction(0, 25, true) -- aim
            DisableControlAction(0, 68, true) -- vehicle aim
            DisableControlAction(0, 69, true) -- vehicle attack
            DisableControlAction(0, 70, true) -- vehicle attack 2
            DisableControlAction(0, 91, true) -- passenger aim
            DisableControlAction(0, 92, true) -- passenger attack
            DisableControlAction(0, 114, true) -- fly attack
            DisableControlAction(0, 257, true) -- attack 2
            DisableControlAction(0, 331, true) -- vehicle fly attack 2
            Wait(0)
        else
            if driveByBlocked then
                driveByBlocked = false
                SetPlayerCanDoDriveBy(PlayerId(), true)
            end

            Wait(300)
        end
    end
end)

CreateThread(function()
    while not lib do
        Wait(100)
    end

    lib.addRadialItem({
        id = 'custom_rob_player',
        label = 'Rob',
        icon = 'hand',
        onSelect = requestRob
    })
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if IsPedArmed(ped, 4) and not IsPedInAnyVehicle(ped, false) then
            SetPedMoveRateOverride(ped, 1.18)
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.18)
        else
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end

        SetWeaponsNoAutoreload(false)

        if not IsPedInAnyVehicle(ped, false) and IsPedArmed(ped, 4) then
            local weapon = GetSelectedPedWeapon(ped)

            if weapon and weapon ~= `WEAPON_UNARMED` then
                local _, clipAmmo = GetAmmoInClip(ped, weapon)
                local totalAmmo = GetAmmoInPedWeapon(ped, weapon)

                if clipAmmo == 0 and totalAmmo > 0 and not IsPedReloading(ped) then
                    MakePedReload(ped)
                end
            end
        end

        Wait(150)
    end
end)
