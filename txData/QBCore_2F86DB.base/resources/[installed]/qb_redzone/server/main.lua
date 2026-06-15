local QBCore = exports['qb-core']:GetCoreObject()
local killTracker = {}
local leaderboard = {}

local function getPlayerDisplayName(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local charinfo = Player.PlayerData.charinfo
        local firstName = charinfo.firstname or ""
        local lastName = charinfo.lastname or ""
        local fullName = (firstName .. " " .. lastName):gsub("^%s*(.-)%s*$", "%1")
        if fullName ~= "" then
            return fullName
        end
    end

    return GetPlayerName(playerId) or ("Player " .. tostring(playerId))
end

local function getPlayerStatsKey(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)

    if Player and Player.PlayerData then
        return Player.PlayerData.citizenid, getPlayerDisplayName(playerId)
    end

    return tostring(playerId), getPlayerDisplayName(playerId)
end

local function getKillDistance(killerId, victimId)
    local killerPed = GetPlayerPed(killerId)
    local victimPed = GetPlayerPed(victimId)

    if killerPed == 0 or victimPed == 0 then
        return 0
    end

    local killerCoords = GetEntityCoords(killerPed)
    local victimCoords = GetEntityCoords(victimPed)

    return math.floor(#(killerCoords - victimCoords))
end

local function sendRedzoneKillfeed(killerId, victimId, streak)
    if GetResourceState('b-killfeed') ~= 'started' then
        return
    end

    local ok, err = pcall(function()
        exports['b-killfeed']:CreateKillfeed({
            killer = getPlayerDisplayName(killerId),
            killerColor = "#ff3b30",
            victimColor = "#f2f2f2",
            victimName = getPlayerDisplayName(victimId),
            distance = getKillDistance(killerId, victimId),
            streak = tostring(streak or 1),
        })
    end)

    if not ok then
        print(("[qb_redzone] b-killfeed error: %s"):format(tostring(err)))
    end
end

RegisterNetEvent("qb_redzone:setBucket", function(inZone)
    local src = source
    if Config.UseBucket then
        SetPlayerRoutingBucket(src, inZone and Config.RedzoneBucket or 0)
    end
end)

RegisterNetEvent("qb_redzone:exitZone", function(kills)
    local src = source
    if kills and kills > 0 then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney('cash', kills * Config.KillReward, "redzone-kill-reward")
            TriggerClientEvent('chat:addMessage', -1, {
                args = { string.format("%s%s exited the redzone with a killstreak of %d", Config.ChatPrefix, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, kills) }
            })
        end
    end
    killTracker[src] = nil
    local citizenid = getPlayerStatsKey(src)
    if leaderboard[citizenid] then
        leaderboard[citizenid].current = 0
    end
end)

RegisterNetEvent("qb_redzone:playerDied", function()
    local src = source
    local kills = killTracker[src]
    if kills and kills > 0 then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            TriggerClientEvent('chat:addMessage', -1, {
                args = { string.format("%s%s died with a killstreak of %d", Config.ChatPrefix, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, kills) }
            })
            Player.Functions.AddMoney('cash', kills * Config.KillReward, "redzone-kill-reward")
        end
    end
    killTracker[src] = nil
    local citizenid = getPlayerStatsKey(src)
    if leaderboard[citizenid] then
        leaderboard[citizenid].current = 0
    end
end)

RegisterNetEvent('qb_redzone:registerKillFor', function(serverKillerId)
    local victimId = source
    if serverKillerId and serverKillerId > 0 and serverKillerId ~= victimId then
        killTracker[serverKillerId] = (killTracker[serverKillerId] or 0) + 1
        local citizenid, name = getPlayerStatsKey(serverKillerId)
        leaderboard[citizenid] = leaderboard[citizenid] or { name = name, total = 0, best = 0, current = 0 }
        leaderboard[citizenid].name = name
        leaderboard[citizenid].total = leaderboard[citizenid].total + 1
        leaderboard[citizenid].current = killTracker[serverKillerId]
        leaderboard[citizenid].best = math.max(leaderboard[citizenid].best, leaderboard[citizenid].current)

        TriggerClientEvent("qb_redzone:killFeed", serverKillerId, killTracker[serverKillerId])
        sendRedzoneKillfeed(serverKillerId, victimId, killTracker[serverKillerId])

        -- Announce killstreaks
        local streaks = Config.KillstreakAnnounce or {5, 10, 15, 20, 25, 30, 40, 50}
        for _, v in ipairs(streaks) do
            if killTracker[serverKillerId] == v then
                local Player = QBCore.Functions.GetPlayer(serverKillerId)
                if Player then
                    TriggerClientEvent('chat:addMessage', -1, {
                        args = { string.format("%s%s is on a %d killstreak!", Config.ChatPrefix, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, v) }
                    })
                end
                break
            end
        end
    end
end)

RegisterCommand('rzleaderboard', function(source)
    local rows = {}

    for _, stats in pairs(leaderboard) do
        rows[#rows + 1] = stats
    end

    table.sort(rows, function(a, b)
        if a.total == b.total then
            return a.best > b.best
        end

        return a.total > b.total
    end)

    if #rows == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            args = { Config.ChatPrefix, 'Leaderboard hooson baina' }
        })
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        args = { Config.ChatPrefix, 'Top redzone killers:' }
    })

    for i = 1, math.min(5, #rows) do
        TriggerClientEvent('chat:addMessage', source, {
            args = { Config.ChatPrefix, string.format('%d. %s - %d kills | best streak %d', i, rows[i].name, rows[i].total, rows[i].best) }
        })
    end
end, false)
