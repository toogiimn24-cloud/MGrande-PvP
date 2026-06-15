local function checkDiscordRole(discordId, callback)
    local url = "https://discord.com/api/v10/guilds/" .. Config.GuildID .. "/members/" .. discordId

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.roles then
                for _, roleId in ipairs(data.roles) do
                    if roleId == Config.WhitelistRoleID then
                        callback(true)
                        return
                    end
                end
            end
            callback(false)
        else
            print("[Whitelist] Discord API алдаа: " .. tostring(statusCode))
            callback(false)
        end
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.DiscordBotToken,
        ["Content-Type"] = "application/json"
    })
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local discordId = nil

    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == "discord:" then
            discordId = string.sub(id, 9)
            break
        end
    end

    if not discordId then
        deferrals.done("❌ Discord акаунт холбоогүй байна!\nFiveM-д Discord холбоно уу.")
        return
    end

    deferrals.defer()
    deferrals.update("⏳ Whitelist шалгаж байна...")

    checkDiscordRole(discordId, function(isWhitelisted)
        if isWhitelisted then
            deferrals.done()
            print("[Whitelist] ✅ " .. name .. " орлоо.")
        else
            deferrals.done(Config.KickMessage)
            print("[Whitelist] ❌ " .. name .. " whitelist-д байхгүй.")
        end
    end)
end)