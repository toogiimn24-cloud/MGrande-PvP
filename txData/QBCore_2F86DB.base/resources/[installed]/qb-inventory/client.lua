local function itemName(item)
    if type(item) == 'table' then
        return item.name or item.item
    end

    return item
end

local function hasItem(items, amount)
    amount = amount or 1

    if GetResourceState('ox_inventory') ~= 'started' then
        return false
    end

    if type(items) == 'table' and not itemName(items) then
        for _, item in pairs(items) do
            local name = itemName(item)
            local requiredAmount = type(item) == 'table' and (item.amount or item.count) or amount

            if not name or (exports.ox_inventory:Search('count', name) or 0) < (requiredAmount or amount) then
                return false
            end
        end

        return true
    end

    local name = itemName(items)
    local requiredAmount = type(items) == 'table' and (items.amount or items.count) or amount

    return name and (exports.ox_inventory:Search('count', name) or 0) >= (requiredAmount or amount)
end

exports('HasItem', hasItem)

RegisterNetEvent('qb-inventory:client:ItemBox', function() end)
RegisterNetEvent('qb-inventory:client:requiredItems', function() end)
RegisterNetEvent('qb-inventory:client:CheckWeapon', function() end)
