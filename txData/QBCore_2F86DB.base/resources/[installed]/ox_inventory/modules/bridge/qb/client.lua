local QBCore = exports['qb-core']:GetCoreObject()

local function setGroups()
    local playerData = QBCore.Functions.GetPlayerData()
    local groups = {}

    if playerData.job and playerData.job.name then
        groups[playerData.job.name] = playerData.job.grade and playerData.job.grade.level or 0
    end

    if playerData.gang and playerData.gang.name then
        groups[playerData.gang.name] = playerData.gang.grade and playerData.gang.grade.level or 0
    end

    client.setPlayerData('groups', groups)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    setGroups()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    client.onLogout()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', setGroups)
RegisterNetEvent('QBCore:Client:OnGangUpdate', setGroups)

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value then client.onLogout() end
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
    for name, value in pairs(values) do
        if value > 100 or value < -100 then
            value = value * 0.0001
        end

        local currentValue = client.player:get(name) or 0
        client.player:setr(name, lib.math.clamp(currentValue + value, 0, 100))
    end
end
