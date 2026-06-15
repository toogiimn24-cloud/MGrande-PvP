--[[
    https://discord.gg/b-dev
    https://discord.gg/b-dev
    https://discord.gg/b-dev
    https://discord.gg/b-dev
    https://discord.gg/b-dev
    https://discord.gg/b-dev
]]
Framework = {
    --[[
        Here you can edit anything related to the framework.
        You can add your own functions, edit the existing ones, etc.
    ]]

    --Variables please leave these alone

    object = nil, --This is the object that will be returned when you call the framework
    playerData = nil, --This is the player data that will be returned when you call the framework

    --[[
        This framework.lua features functions related to money, jobs, items, identifiers, etc. if there is anything you want to add to this framework please do so.
    ]]
}

--[[
    Framework Load Function
]]

function Framework:Load()
    -- Config check for the framework

    if BDEV.Framework == "esx" then
        Framework.object = exports["es_extended"]:getSharedObject()

        if not IsDuplicityVersion() then
            
            -- loop to check if the object is loaded

            while Framework.object.GetPlayerData().job == nil do
                Wait(150)
            end

            -- set the player data
            Framework.playerData = Framework.object.GetPlayerData()

            -- Register the event to update the player data (job)
            RegisterNetEvent("esx:setJob", function(job)
                Framework.playerData.job = job
            end)
        end

        print("BDEV: Loaded ESX Framework")
    elseif BDEV.Framework == "qbcore" then
        Framework.object = exports["qb-core"]:GetCoreObject()

        if not IsDuplicityVersion() then
            -- loop to check if the object is loaded
            while Framework.object.Functions.GetPlayerData().job == nil do
                Citizen.Wait(50)
            end

            -- set the player data
            Framework.playerData = Framework.object.Functions.GetPlayerData()

            -- Register the event to update the player data 
            RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
                Framework.playerData = val
            end)
        end
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

--[[
    Framework Main Functions

    These functions are the main functions like triggering callbacks
]]

function Framework:registerCallback(name, cb)
    -- check if the enviormnent is server 
    if not IsDuplicityVersion() then
        return print("BDEV: You can only register callbacks on the server side.")
    end

    if BDEV.Framework == "esx" then
        Framework.object.RegisterServerCallback(name, cb)

        print("BDEV: Registered callback: " .. name)
    elseif BDEV.Framework == "qbcore" then
        Framework.object.Functions.CreateCallback(name, cb)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:triggerCallback(name, cb, ...)
    -- check if the enviroment is client
    if IsDuplicityVersion() then
        return print("BDEV: You can only trigger callbacks on the client side.")
    end

    if BDEV.Framework == 'esx' then
        Framework.object.TriggerServerCallback(name, function(...)
            cb(...)
        end, ...)

        print("BDEV: Triggered callback: " .. name)
    elseif BDEV.Framework == 'qbcore' then
        Framework.object.Functions.TriggerCallback(name, function(...)
            cb(...)
        end, ...)
    end
end

function Framework:RegisterUsableItem(item, cb)
    if BDEV.Framework == "esx" then
        Framework.object.RegisterUsableItem(item, cb)
    elseif BDEV.Framework == "qbcore" then
        Framework.object.Functions.CreateUseableItem(item, cb)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

--[[
    Framework Functions
]]

function Framework:GetPlayerData()
    if not IsDuplicityVersion() then
        if BDEV.Framework == "esx" then
            return Framework.object.GetPlayerData()
        elseif BDEV.Framework == "qbcore" then
            return Framework.object.Functions.GetPlayerData()
        else
            --[[
                Here you can add your own framework support.
            ]]
        end
    end
end

function Framework:GetPlayerObject(source)
    if IsDuplicityVersion() then
        if BDEV.Framework == "esx" then
            return Framework.object.GetPlayerFromId(source)
        elseif BDEV.Framework == "qbcore" then
            return Framework.object.Functions.GetPlayer(source)
        else
            --[[
                Here you can add your own framework support.
            ]]
        end
    end
end



function Framework:getIdentifier(source) -- server side only
    if BDEV.Framework == "esx" then
        local playerData = Framework.object.GetPlayerFromId(source)

        return playerData.identifier
    elseif BDEV.Framework == "qbcore" then
        local playerData = Framework.object.Functions.GetPlayer(source)

        return playerData.PlayerData.citizenid
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getAccountMoney(source, account) -- server side only
    if BDEV.Framework == "esx" then
        local playerData = Framework.object.GetPlayerFromId(source)

        if playerData.getAccount(account) ~= nil then
            return playerData.getAccount(account).money
        else
            return 0
        end
    elseif BDEV.Framework == "qbcore" then
        local playerData = Framework.object.Functions.GetPlayer(source)

        -- check if the account is money because qbcore has not type called "money"

        if account == "money" then
            account = "cash"
        end

        return Player.Functions.GetMoney(account)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getName(source)
    if BDEV.Framework == "esx" then
        local playerData = Framework.object.GetPlayerFromId(source)

        return playerData.getName()
    elseif BDEV.Framework == "qbcore" then
        local playerData = Framework.object.Functions.GetPlayer(source)

        return playerData.PlayerData.charinfo.firstname .. " " .. playerData.PlayerData.charinfo.lastname
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getJob(playerObject)
    if IsDuplicityVersion() then
        if BDEV.Framework == "esx" then
            return playerObject.job
        elseif BDEV.Framework == "qbcore" then
            return playerObject.job
        else
            --[[
                Here you can add your own framework support.
            ]]
        end
    else

        if BDEV.Framework == "esx" then
            return Framework.playerData.job
        elseif BDEV.Framework == "qbcore" then
            return Framework.playerData.job
        else
            --[[
                Here you can add your own framework support.
            ]]
        end
    end
end

function Framework:setJob(playerObject, job)
    -- check if the enviroment is server
    if not IsDuplicityVersion() then
        return print("BDEV: You can only set jobs on the server side.")
    end

    if BDEV.Framework == "esx" then
        playerObject.setJob(job)
    elseif BDEV.Framework == "qbcore" then
        playerObject.Functions.SetJob(job)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getItem(playerObject, itemName)
    -- check if the enviroment is server
    if not IsDuplicityVersion() then
        return print("BDEV: You can only get items on the server side.")
    end

    if BDEV.Framework == "esx" then
        return playerObject.getInventoryItem(itemName)
    elseif BDEV.Framework == "qbcore" then
        return playerObject.Functions.GetItemByName(itemName)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:addItem(playerObject, itemName, amount)
    -- check if the enviroment is server
    if not IsDuplicityVersion() then
        return print("BDEV: You can only add items on the server side.")
    end

    if BDEV.Framework == "esx" then
        playerObject.addInventoryItem(itemName, amount)
    elseif BDEV.Framework == "qbcore" then
        playerObject.Functions.AddItem(itemName, amount)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:removeItem(playerObject, itemName, amount)
    -- check if the enviorment is server

    if not IsDuplicityVersion() then
        return print("BDEV: You can only remove items on the server side.")
    end

    if BDEV.Framework == "esx" then

        if playerObject.getInventoryItem(itemName).count >= amount then
            playerObject.removeInventoryItem(itemName, amount)
        else
            print("BDEV: You can't remove more items than the player has.")
        end
    elseif BDEV.Framework == "qbcore" then

        if playerObject.Functions.GetItemByName(itemName).amount >= amount then
            playerObject.Functions.RemoveItem(itemName, amount)
        else
            print("BDEV: You can't remove more items than the player has.")
        end
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:addWeapon(source, weaponName, ammo)
    if IsDuplicityVersion() then

        if BDEV.Framework == "esx" then
            local playerObject = Framework.object.GetPlayerFromId(source)

            playerObject.addWeapon(weaponName, ammo)
        elseif BDEV.Framework == "qbcore" then
            local playerObject = Framework.object.Functions.GetPlayer(source)

            playerObject.Functions.AddItem(weaponName, 1, false, { ammo = ammo })
        else
            --[[
                Here you can add your own framework support.
            ]]
        end
    end
end

function Framework:getPlayerGroup(source)
    -- check if the enviroment is server
    if not IsDuplicityVersion() then
        return print("BDEV: You can only get player groups on the server side.")
    end

    if BDEV.Framework == "esx" then
        local playerObject = Framework.object.GetPlayerFromId(source)

        return playerObject.getGroup()
    elseif BDEV.Framework == "qbcore" then
        return Framework.object.Functions.GetPermission(source)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getAccountMoney(source, account)
    if BDEV.Framework == "esx" then
        if IsDuplicityVersion() then
            return Framework.object.GetPlayerFromId(source).getAccount(account).money
        else
            return Framework.object.GetPlayerData().accounts[account].money
        end
    elseif BDEV.Framework == "qbcore" then
        if IsDuplicityVersion() then
            return Framework.object.Functions.GetPlayer(source).PlayerData.money[account]
        else
            return Framework.object.Functions.GetPlayerData().money[account]
        end
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:getAccounts(source)
    if BDEV.Framework == "esx" then
        if IsDuplicityVersion() then
            return Framework.object.GetPlayerFromId(source).getAccounts()
        else
            return Framework.object.GetPlayerData().accounts
        end
    elseif BDEV.Framework == "qbcore" then
        if IsDuplicityVersion() then
            return Framework.object.Functions.GetPlayer(source).PlayerData.money
        else
            return Framework.object.Functions.GetPlayerData().money
        end
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:addAccountMoney(source, account, amount)
    if BDEV.Framework == "esx" then
        local playerData = Framework.object.GetPlayerFromId(source)

        if playerData.getAccount(account) ~= nil then
            playerData.addAccountMoney(account, amount)
        end
    elseif BDEV.Framework == "qbcore" then
        local playerData = Framework.object.Functions.GetPlayer(source)

        -- check if the account is money because qbcore has not type called "money"

        if account == "money" then
            account = "cash"
        end

        Player.Functions.AddMoney(account, amount)
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:removeAccountMoney(source, account, amount)
    if BDEV.Framework == "esx" then
        local playerData = Framework.object.GetPlayerFromId(source)

        if playerData.getAccount(account) ~= nil and playerData.getAccount(account).money >= amount then
            playerData.removeAccountMoney(account, amount)
        end
    elseif BDEV.Framework == "qbcore" then
        local playerData = Framework.object.Functions.GetPlayer(source)

        -- check if the account is money because qbcore has not type called "money"

        if account == "money" then
            account = "cash"
        end

        if Player.Functions.GetMoney(account) >= amount then
            Player.Functions.RemoveMoney(account, amount)
        end
    else
        --[[
            Here you can add your own framework support.
        ]]
    end
end

function Framework:isAllowed(playerObject, permissionObject)
    if playerObject then
        for key, value in pairs(permissionObject) do
            if value == playerObject.group then
                return true
            end
        end
    end

    return false
end 
