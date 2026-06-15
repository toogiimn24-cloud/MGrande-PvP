local QBCore = exports['qb-core']:GetCoreObject()
local inZone, currentZone = false, nil
local forcedWeapon = nil
local killCount = 0
local zoneBlips = {}
local savedAppearance = nil

local function isCoordsInsideRedzone(coords)
    for name, zone in pairs(Config.Zones) do
        if #(coords - zone.center) < zone.radius then
            return true, name, zone
        end
    end

    return false, nil, nil
end

local function safeGetAppearance(ped)
    if GetResourceState('illenium-appearance') ~= 'started' then
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

local function safeSetAppearance(appearance)
    if not appearance or GetResourceState('illenium-appearance') ~= 'started' then
        return
    end

    pcall(function()
        exports['illenium-appearance']:setPlayerAppearance(appearance)
    end)
end

local function makePedUsable(ped)
    ped = ped or PlayerPedId()

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

local function ShowKillCounterUI(kills)
    SendNUIMessage({
        action = "show",
        kills = kills or 0,
        money = (kills or 0) * Config.KillReward
    })
end

local function HideKillCounterUI()
    SendNUIMessage({ action = "hide" })
end

-- Blips and markers
CreateThread(function()
    for name, zone in pairs(Config.Zones) do
        if zone.blip and zone.blip.enabled then
            local blip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
            SetBlipSprite(blip, zone.blip.sprite or 161)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, zone.blip.scale or 1.2)
            SetBlipColour(blip, zone.blip.color or 1)
            SetBlipAsShortRange(blip, false)
            SetBlipHighDetail(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.label or name or "Redzone")
            EndTextCommandSetBlipName(blip)
            zoneBlips[#zoneBlips+1] = {blip = blip}
        end
        if zone.radiusBlip and zone.radiusBlip.enabled then
            local radiusBlip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
            SetBlipColour(radiusBlip, zone.radiusBlip.color or 1)
            SetBlipAlpha(radiusBlip, zone.radiusBlip.alpha or 100)
            SetBlipHighDetail(radiusBlip, true)
            if zoneBlips[#zoneBlips] then
                zoneBlips[#zoneBlips].radius = radiusBlip
            else
                zoneBlips[#zoneBlips+1] = {radius = radiusBlip}
            end
        end
    end
end)

-- Marker drawing
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local myCoords = GetEntityCoords(ped)
        for name, zone in pairs(Config.Zones) do
            if #(myCoords - zone.center) < (zone.radius + 50.0) then
                DrawMarker(
                    zone.marker.type,
                    zone.center.x, zone.center.y, zone.center.z-1,
                    0, 0, 0, 0, 0, 0,
                    zone.radius*2, zone.radius*2, zone.marker.height,
                    zone.marker.r, zone.marker.g, zone.marker.b, zone.marker.a,
                    false, true, 2, false, nil, nil, false
                )
            end
        end
    end
end)

-- Zone detection
CreateThread(function()
    while true do
        Wait(250)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local foundZone, foundZoneName, foundZoneDef = isCoordsInsideRedzone(coords)

        if foundZone and not inZone then
            inZone = true
            currentZone = foundZoneName
            savedAppearance = safeGetAppearance(ped) or savedAppearance
            killCount = 0
            ShowKillCounterUI(killCount)
            if Config.UseBucket then
                TriggerServerEvent("qb_redzone:setBucket", true)
            end
            giveZoneWeapon(foundZoneDef.weapon)
            if lib and lib.notify then
                lib.notify({
                    title = "Redzone",
                    description = "You entered the redzone!",
                    type = "warning"
                })
            end
        elseif not foundZone and inZone then
            stripZoneWeapon()
            TriggerServerEvent("qb_redzone:setBucket", false)
            inZone = false
            currentZone = nil
            HideKillCounterUI()
            TriggerServerEvent('qb_redzone:exitZone', killCount)
            killCount = 0
            if lib and lib.notify then
                lib.notify({
                    title = "Redzone",
                    description = "You left the redzone!",
                    type = "info"
                })
            end
        end
    end
end)

RegisterNetEvent("qb_redzone:killFeed", function(kills)
    killCount = kills
    ShowKillCounterUI(killCount)
end)

exports('isPlayerInRedzone', function()
    return inZone or false
end)

function handleRedzoneDeath()
    local diedInRedzone = isCoordsInsideRedzone(GetEntityCoords(PlayerPedId()))
    if not diedInRedzone then
        return
    end

    local respawnTime = Config.RespawnTime or 5
    savedAppearance = savedAppearance or safeGetAppearance(PlayerPedId())

    showRespawnTimer(respawnTime)

    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do Wait(10) end

    local ped = PlayerPedId()
    local point = Config.RespawnPoints[math.random(#Config.RespawnPoints)]
    NetworkResurrectLocalPlayer(point.x, point.y, point.z, 0.0, true, false)
    ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, point.x, point.y, point.z, false, false, false)
    SetEntityHealth(ped, 200)
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    makePedUsable(ped)

    if savedAppearance then
        safeSetAppearance(savedAppearance)
        Wait(750)
        ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, point.x, point.y, point.z, false, false, false)
        SetEntityHealth(ped, 200)
        makePedUsable(ped)
    end

    DoScreenFadeIn(800)

    SetPedInfiniteAmmo(ped, false, 0)
    forcedWeapon = nil
    SetPlayerInvincible(PlayerId(), false)
    TriggerServerEvent("qb_redzone:playerDied")
    if Config.UseBucket then
        TriggerServerEvent("qb_redzone:setBucket", false)
    end
    inZone = false
    HideKillCounterUI()
    killCount = 0
end

function showRespawnTimer(seconds)
    for i = seconds, 1, -1 do
        if lib and lib.showTextUI then
            lib.showTextUI(string.format("Respawning in: %02d", i), {
                position = 'middle-center',
                style = { backgroundColor = '#800000c0', color = '#fff', fontSize = 48 }
            })
        end
        Wait(1000)
    end
    if lib and lib.hideTextUI then
        lib.hideTextUI()
    end
end

function giveZoneWeapon(weaponName)
    if not weaponName then
        forcedWeapon = nil
        return
    end

    local ped = PlayerPedId()
    local weaponHash = GetHashKey(weaponName)

    if weaponHash then
        SetPedInfiniteAmmo(ped, false, weaponHash)
    end

    forcedWeapon = nil
end

function stripZoneWeapon()
    local ped = PlayerPedId()
    SetPedInfiniteAmmo(ped, false, 0)
    forcedWeapon = nil
end

-- Death/killer tracking
local lastHealth = nil
CreateThread(function()
    while true do
        Wait(50)
        if inZone then
            local ped = PlayerPedId()
            if not IsEntityDead(ped) and IsEntityVisible(ped) then
                savedAppearance = safeGetAppearance(ped) or savedAppearance
            end

            local health = GetEntityHealth(ped)
            local killer = GetPedSourceOfDeath(ped)
            local stillInRedzone = isCoordsInsideRedzone(GetEntityCoords(ped))
            if lastHealth and stillInRedzone and health < lastHealth and health <= 101 then
                local killerServerId = nil
                for i = 0, 255 do
                    if NetworkIsPlayerActive(i) and GetPlayerPed(i) == killer and i ~= PlayerId() then
                        killerServerId = GetPlayerServerId(i)
                        break
                    end
                end
                if killerServerId and killerServerId ~= GetPlayerServerId(PlayerId()) then
                    TriggerServerEvent('qb_redzone:registerKillFor', killerServerId)
                end
                handleRedzoneDeath()
            end
            lastHealth = health
        else
            lastHealth = GetEntityHealth(PlayerPedId())
        end
    end
end)
