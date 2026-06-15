if not Framework.QBCore() then return end

local client = client

local QBCore = exports["qb-core"]:GetCoreObject()

local PlayerData = QBCore.Functions.GetPlayerData()

local function normalizePlayerData(data)
    data = data or {}
    data.charinfo = data.charinfo or {}
    data.metadata = data.metadata or {}
    data.job = data.job or { name = "unemployed", grade = { level = 0 } }
    data.gang = data.gang or { name = "none", grade = { level = 0 } }
    data.job.grade = data.job.grade or { level = 0 }
    data.gang.grade = data.gang.grade or { level = 0 }

    return data
end

PlayerData = normalizePlayerData(PlayerData)

local function getRankInputValues(rankList)
    local rankValues = {}
    for k, v in pairs(rankList) do
        rankValues[#rankValues + 1] = {
            label = v.name,
            value = k
        }
    end
    return rankValues
end

local function setClientParams()
    PlayerData = normalizePlayerData(PlayerData)
    client.job = PlayerData.job
    client.gang = PlayerData.gang
    client.citizenid = PlayerData.citizenid
end

function Framework.GetPlayerGender()
    PlayerData = normalizePlayerData(PlayerData)
    if PlayerData.charinfo.gender == 1 then
        return "Female"
    end
    return "Male"
end

function Framework.UpdatePlayerData()
    PlayerData = normalizePlayerData(QBCore.Functions.GetPlayerData())
    setClientParams()
end

function Framework.HasTracker()
    local data = normalizePlayerData(QBCore.Functions.GetPlayerData())
    return data.metadata["tracker"]
end

function Framework.CheckPlayerMeta()
    PlayerData = normalizePlayerData(PlayerData)
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"]
end

function Framework.IsPlayerAllowed(citizenid)
    return citizenid == PlayerData.citizenid
end

function Framework.GetRankInputValues(type)
    local grades = QBCore.Shared.Jobs[client.job.name].grades
    if type == "gang" then
        grades = QBCore.Shared.Gangs[client.gang.name].grades
    end
    return getRankInputValues(grades)
end

function Framework.GetJobGrade()
    return client.job.grade.level
end

function Framework.GetGangGrade()
    return client.gang.grade.level
end

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(JobInfo)
    PlayerData = normalizePlayerData(PlayerData)
    PlayerData.job = JobInfo
    client.job = JobInfo
    ResetBlips()
end)

RegisterNetEvent("QBCore:Client:OnGangUpdate", function(GangInfo)
    PlayerData = normalizePlayerData(PlayerData)
    PlayerData.gang = GangInfo
    client.gang = GangInfo
    ResetBlips()
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty
        client.job = PlayerData.job
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Framework.UpdatePlayerData()
    InitAppearance()
end)

RegisterNetEvent("qb-clothes:client:CreateFirstCharacter", function()
    QBCore.Functions.GetPlayerData(function(pd)
        PlayerData = normalizePlayerData(pd)
        setClientParams()
        InitializeCharacter(Framework.GetGender(true))
    end)
end)

function Framework.CachePed()
    return nil
end

function Framework.RestorePlayerArmour()
    Framework.UpdatePlayerData()
    if PlayerData and PlayerData.metadata then
        Wait(1000)
        SetPedArmour(cache.ped, PlayerData.metadata["armor"])
    end
end
