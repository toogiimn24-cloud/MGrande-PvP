local Inventory = require 'modules.inventory.server'
local QBCore = exports['qb-core']:GetCoreObject()

local function getGroups(playerData)
    local groups = {}

    if playerData.job and playerData.job.name then
        groups[playerData.job.name] = playerData.job.grade and playerData.job.grade.level or 0
    end

    if playerData.gang and playerData.gang.name then
        groups[playerData.gang.name] = playerData.gang.grade and playerData.gang.grade.level or 0
    end

    return groups
end

local function setupPlayer(player)
    if not player or not player.PlayerData then return end

    local playerData = player.PlayerData
    playerData.identifier = playerData.citizenid
    playerData.name = ('%s %s'):format(playerData.charinfo.firstname, playerData.charinfo.lastname)

    server.setPlayerInventory(playerData)

    local accounts = Inventory.GetAccountItemCounts(playerData.source)
    if not accounts then return end

    for account in pairs(accounts) do
        local moneyType = account == 'money' and 'cash' or account
        Inventory.SetItem(playerData.source, account, playerData.money[moneyType] or 0)
    end
end

AddEventHandler('QBCore:Server:PlayerLoaded', setupPlayer)

AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local player = QBCore.Functions.GetPlayer(source)
    setupPlayer(player)
end)
AddEventHandler('QBCore:Server:PlayerDropped', server.playerDropped)
AddEventHandler('QBCore:Server:OnPlayerUnload', server.playerDropped)

AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    local inventory = Inventory(source)
    if not inventory or not inventory.player then return end

    if inventory.player.jobName then
        inventory.player.groups[inventory.player.jobName] = nil
    end

    inventory.player.jobName = job.name
    inventory.player.groups[job.name] = job.grade and job.grade.level or 0
end)

AddEventHandler('QBCore:Server:OnGangUpdate', function(source, gang)
    local inventory = Inventory(source)
    if not inventory or not inventory.player then return end

    if inventory.player.gangName then
        inventory.player.groups[inventory.player.gangName] = nil
    end

    inventory.player.gangName = gang.name
    inventory.player.groups[gang.name] = gang.grade and gang.grade.level or 0
end)

SetTimeout(500, function()
    for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
        setupPlayer(player)
    end
end)

function server.UseItem(source, itemName, data)
    local usableItem = QBCore.Functions.CanUseItem(itemName)
    if not usableItem or not usableItem.func then return end

    return usableItem.func(source, data)
end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    local groups = getGroups(player)

    return {
        source = player.source,
        name = player.name or ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
        groups = groups,
        sex = player.charinfo.gender,
        dateofbirth = player.charinfo.birthdate,
        jobName = player.job and player.job.name,
        gangName = player.gang and player.gang.name,
    }
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
    local accounts = Inventory.GetAccountItemCounts(inv)
    local player = QBCore.Functions.GetPlayer(inv.id)

    if not player then return end

    player.Functions.SetPlayerData('items', inv.items)

    if not accounts then return end

    for account, amount in pairs(accounts) do
        local moneyType = account == 'money' and 'cash' or account
        if player.Functions.GetMoney(moneyType) ~= amount then
            player.Functions.SetMoney(moneyType, amount, ('Sync %s with inventory'):format(account))
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, license)
    local player = QBCore.Functions.GetPlayer(inv.id)
    local licences = player and player.PlayerData.metadata and player.PlayerData.metadata.licences

    return licences and licences[license]
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    local player = QBCore.Functions.GetPlayer(inv.id)
    if not player then return end

    local licences = player.PlayerData.metadata.licences or {}

    if licences[license.name] then
        return false, 'already_have'
    elseif Inventory.GetItem(inv, 'money', false, true) < license.price then
        return false, 'can_not_afford'
    end

    Inventory.RemoveItem(inv, 'money', license.price)
    licences[license.name] = true
    player.Functions.SetMetaData('licences', licences)

    return true, 'have_purchased'
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end

    local job = player.PlayerData.job
    local gang = player.PlayerData.gang

    return (job and job.name == group and (job.isboss or job.grade and job.grade.isboss))
        or (gang and gang.name == group and (gang.isboss or gang.grade and gang.grade.isboss))
end

---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
    return GetVehicleNumberPlateText(entityId)
end
