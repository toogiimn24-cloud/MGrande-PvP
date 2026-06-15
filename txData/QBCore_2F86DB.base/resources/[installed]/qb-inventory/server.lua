local function itemName(item)
    if type(item) == 'table' then
        return item.name or item.item
    end

    return item
end

local function itemMetadata(metadata)
    if metadata == false then return nil end
    return metadata or nil
end

local function hasItem(source, items, amount)
    amount = amount or 1

    if GetResourceState('ox_inventory') ~= 'started' then
        return false
    end

    if type(items) == 'table' and not itemName(items) then
        for _, item in pairs(items) do
            local name = itemName(item)
            local requiredAmount = type(item) == 'table' and (item.amount or item.count) or amount

            if not name or (exports.ox_inventory:Search(source, 'count', name) or 0) < (requiredAmount or amount) then
                return false
            end
        end

        return true
    end

    local name = itemName(items)
    local requiredAmount = type(items) == 'table' and (items.amount or items.count) or amount

    return name and (exports.ox_inventory:Search(source, 'count', name) or 0) >= (requiredAmount or amount)
end

local function addItem(source, item, amount, slot, metadata)
    local name = itemName(item)
    if not name then return false end

    return exports.ox_inventory:AddItem(source, name, amount or 1, itemMetadata(metadata), slot)
end

local function removeItem(source, item, amount, slot, reason)
    local name = itemName(item)
    if not name then return false end

    return exports.ox_inventory:RemoveItem(source, name, amount or 1, nil, slot)
end

local function getItemByName(source, item)
    local slots = exports.ox_inventory:Search(source, 'slots', itemName(item))
    return slots and slots[1]
end

local function getItemsByName(source, item)
    return exports.ox_inventory:Search(source, 'slots', itemName(item)) or {}
end

local function openInventory(source, identifier, data)
    if type(data) == 'table' and data.maxweight and data.slots then
        exports.ox_inventory:RegisterStash(identifier, data.label or identifier, data.slots, data.maxweight, data.owner)
    end

    return exports.ox_inventory:forceOpenInventory(source, 'stash', identifier)
end

local function openInventoryById(source, targetId)
    return exports.ox_inventory:forceOpenInventory(source, 'player', tonumber(targetId))
end

local function createInventory(identifier, data)
    if type(data) == 'table' then
        return exports.ox_inventory:RegisterStash(identifier, data.label or identifier, data.slots or 50, data.maxweight or data.maxWeight or 100000, data.owner)
    end
end

local function createShop(shopData)
    local name = shopData.name or shopData.label
    if not name then return end

    exports.ox_inventory:RegisterShop(name, {
        name = shopData.label or name,
        inventory = shopData.items or {},
        locations = shopData.coords or shopData.locations
    })
end

local function openShop(source, name)
    return exports.ox_inventory:forceOpenInventory(source, 'shop', { type = name })
end

local function useItem(source, item)
    local name = itemName(item)
    if not name or GetResourceState('qb-core') ~= 'started' then return end

    local QBCore = exports['qb-core']:GetCoreObject()
    local usableItem = QBCore.Functions.CanUseItem(name)

    if usableItem and usableItem.func then
        return usableItem.func(source, item)
    end
end

exports('HasItem', hasItem)
exports('AddItem', addItem)
exports('RemoveItem', removeItem)
exports('GetItemByName', getItemByName)
exports('GetItemsByName', getItemsByName)
exports('OpenInventory', openInventory)
exports('OpenInventoryById', openInventoryById)
exports('CreateInventory', createInventory)
exports('CreateShop', createShop)
exports('OpenShop', openShop)
exports('UseItem', useItem)

exports('LoadInventory', function()
    return {}
end)

exports('SaveInventory', function()
    return true
end)

RegisterNetEvent('qb-inventory:server:snowball', function(action)
    if action == 'remove' then
        removeItem(source, 'weapon_snowball', 1)
    end
end)
