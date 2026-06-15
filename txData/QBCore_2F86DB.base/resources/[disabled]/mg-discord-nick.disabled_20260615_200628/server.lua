local QBCore = exports['qb-core']:GetCoreObject()

local function trim(value)
    if type(value) ~= 'string' then
        value = tostring(value or '')
    end

    return value:match('^%s*(.-)%s*$')
end

local function hasValue(value)
    return trim(value) ~= ''
end

local function getDiscordId(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        local discordId = identifier:match('discord:(%d+)')
        if discordId then
            return discordId
        end
    end

    return nil
end

local function buildNickname(src)
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then
        return Config.UnregisteredNickname
    end

    local charinfo = Player.PlayerData.charinfo
    local firstname = trim(charinfo.firstname)
    local lastname = trim(charinfo.lastname)
    local citizenid = trim(Player.PlayerData.citizenid)

    if not hasValue(firstname) or not hasValue(lastname) or not hasValue(citizenid) then
        return Config.UnregisteredNickname
    end

    return ('%s %s | %s'):format(firstname, lastname, citizenid)
end

local function logDiscordResult(statusCode, src, nickname)
    local playerName = GetPlayerName(src) or ('ID ' .. tostring(src))

    if statusCode == 200 or statusCode == 204 then
        print(('[mg-discord-nick] 200/204 success: %s nickname set to "%s"'):format(playerName, nickname))
    elseif statusCode == 401 then
        print(('[mg-discord-nick] 401 invalid bot token: failed to update %s nickname'):format(playerName))
    elseif statusCode == 403 then
        print(('[mg-discord-nick] 403 bot permission/role hierarchy problem: failed to update %s nickname'):format(playerName))
    elseif statusCode == 404 then
        print(('[mg-discord-nick] 404 guild/member not found: failed to update %s nickname'):format(playerName))
    else
        print(('[mg-discord-nick] Discord API status %s: failed to update %s nickname'):format(tostring(statusCode), playerName))
    end
end

local function setDiscordNickname(src)
    local discordId = getDiscordId(src)
    if not discordId then
        print(('[mg-discord-nick] Discord identifier not found for player ID %s'):format(tostring(src)))
        return
    end

    local nickname = buildNickname(src)
    local endpoint = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(Config.GuildId, discordId)
    local body = json.encode({ nick = nickname })

    PerformHttpRequest(endpoint, function(statusCode)
        logDiscordResult(statusCode, src, nickname)
    end, 'PATCH', body, {
        ['Authorization'] = 'Bot ' .. Config.BotToken,
        ['Content-Type'] = 'application/json',
    })
end

local function setNicknameDelayed(src, delay)
    SetTimeout(delay or 1000, function()
        if GetPlayerName(src) then
            setDiscordNickname(src)
        end
    end)
end

AddEventHandler('playerJoining', function()
    setNicknameDelayed(source, 8000)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player and Player.PlayerData and Player.PlayerData.source
    if src then
        setNicknameDelayed(src, 1000)
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    setNicknameDelayed(source, 1000)
end)

RegisterCommand('testnick', function(source)
    if source == 0 then
        print('[mg-discord-nick] /testnick is in-game only.')
        return
    end

    setDiscordNickname(source)
end, false)
