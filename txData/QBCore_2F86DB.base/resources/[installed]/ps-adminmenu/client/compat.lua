RegisterNetEvent('hospital:client:Revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPlayerInvincible(PlayerId(), false)

    TriggerServerEvent('hospital:server:SetDeathStatus', false)
    TriggerServerEvent('hospital:server:SetLaststandStatus', false)
end)

