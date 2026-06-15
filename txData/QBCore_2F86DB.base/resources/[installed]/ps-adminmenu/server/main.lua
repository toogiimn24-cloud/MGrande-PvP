local coreResource = Config.Core == "qbx_core" and "qb-core" or Config.Core
QBCore = exports[coreResource]:GetCoreObject()

local function openAdminMenu(source)
    TriggerClientEvent('ps-adminmenu:client:OpenUI', source)
end

lib.addCommand('admin', {
    help = 'Open the admin menu',
    restricted = 'qbcore.mod'
}, openAdminMenu)

lib.addCommand('adminmenu', {
    help = 'Open the admin menu',
    restricted = 'qbcore.mod'
}, openAdminMenu)

RegisterNetEvent('ps-adminmenu:server:ValidateClientAction', function(key, selectedData, event, perms)
    local src = source
    if not CheckPerms(src, perms) then return end
    TriggerClientEvent(event, src, key, selectedData)
end)

RegisterNetEvent('ps-adminmenu:server:ValidateCommand', function(command, perms)
    local src = source
    if not CheckPerms(src, perms) then return end
    
    if command == 'vector2' or command == 'vector3' or command == 'vector4' or command == 'heading' then
        TriggerClientEvent('ps-adminmenu:client:CopyCoords', src, command)
    elseif command == 'setammo' then
        TriggerClientEvent('ps-adminmenu:client:SetAmmoCommand', src)
    end
end)
