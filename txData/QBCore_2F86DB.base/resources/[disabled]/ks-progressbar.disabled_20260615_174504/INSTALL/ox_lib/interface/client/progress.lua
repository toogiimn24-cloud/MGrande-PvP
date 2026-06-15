local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local playerState = LocalPlayer.state
local createdProps = {}


---@class ProgressPropProps
---@field model string
---@field bone? number
---@field pos vector3
---@field rot vector3
---@field rotOrder? number

---@class ProgressProps
---@field label? string
---@field icon? string
---@field sublabel? string
---@field duration number
---@field useWhileDead? boolean
---@field allowRagdoll? boolean
---@field allowCuffed? boolean
---@field allowFalling? boolean
---@field allowSwimming? boolean
---@field canCancel? boolean
---@field anim? { dict?: string, clip: string, flag?: number, blendIn?: number, blendOut?: number, duration?: number, playbackRate?: number, lockX?: boolean, lockY?: boolean, lockZ?: boolean, scenario?: string, playEnter?: boolean }
---@field prop? ProgressPropProps | ProgressPropProps[]
---@field disable? { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean }

local function createProp(ped, prop)
    lib.requestModel(prop.model)
    local coords = GetEntityCoords(ped)
    local object = CreateObject(prop.model, coords.x, coords.y, coords.z, false, false, false)

    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true,
        true, false, true, prop.rotOrder or 0, true)
    SetModelAsNoLongerNeeded(prop.model)

    return object
end

local function interruptProgress(data)
    if not data.useWhileDead and IsEntityDead(cache.ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(cache.ped) then return true end
    if not data.allowCuffed and IsPedCuffed(cache.ped) then return true end
    if not data.allowFalling and IsPedFalling(cache.ped) then return true end
    if not data.allowSwimming and IsPedSwimming(cache.ped) then return true end
end

local isFivem = cache.game == 'fivem'

local controls = {
    INPUT_LOOK_LR = isFivem and 1 or 0xA987235F,
    INPUT_LOOK_UD = isFivem and 2 or 0xD2047988,
    INPUT_SPRINT = isFivem and 21 or 0x8FFC75D6,
    INPUT_AIM = isFivem and 25 or 0xF84FA74F,
    INPUT_MOVE_LR = isFivem and 30 or 0x4D8FB4C1,
    INPUT_MOVE_UD = isFivem and 31 or 0xFDA83190,
    INPUT_DUCK = isFivem and 36 or 0xDB096B85,
    INPUT_VEH_MOVE_LEFT_ONLY = isFivem and 63 or 0x9DF54706,
    INPUT_VEH_MOVE_RIGHT_ONLY = isFivem and 64 or 0x97A8FD98,
    INPUT_VEH_ACCELERATE = isFivem and 71 or 0x5B9FD4E2,
    INPUT_VEH_BRAKE = isFivem and 72 or 0x6E1F639B,
    INPUT_VEH_EXIT = isFivem and 75 or 0xFEFAB9B4,
    INPUT_VEH_MOUSE_CONTROL_OVERRIDE = isFivem and 106 or 0x39CCABD5
}

---@param data ProgressProps
local function startProgress(data)
    local wasSuccessful = nil
    playerState.invBusy = true
    progress = data

    local action = {
        duration = data.duration,
        label = data.label or 'Processing...',
        sublabel = data.sublabel,
        icon = data.icon or 'fas fa-cog', -- Default icon
        canCancel = data.canCancel,
        useWhileDead = data.useWhileDead,
        animation = nil,
        controlDisables = data.disable 
    }

    if data.anim then
        action.animation = {
            animDict = data.anim.dict,
            anim = data.anim.clip,
            flags = data.anim.flag or 49

        }
    end

    exports['ks-progressbar']:start(action, function()
        wasSuccessful = true
    end, function()
        wasSuccessful = false
    end)

    if data.prop then
        playerState:set('lib:progressProps', data.prop, true)
    end

    local disable = data.disable

    while wasSuccessful == nil do
        if disable then
            if disable.mouse then
                DisableControlAction(0, controls.INPUT_LOOK_LR, true)
                DisableControlAction(0, controls.INPUT_LOOK_UD, true)
                DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
            end
            if disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
                DisableControlAction(0, controls.INPUT_MOVE_LR, true)
                DisableControlAction(0, controls.INPUT_MOVE_UD, true)
                DisableControlAction(0, controls.INPUT_DUCK, true)
            end
            if disable.sprint and not disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
            end
            if disable.car then
                DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
                DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
                DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
            end
            if disable.combat then
                DisableControlAction(0, controls.INPUT_AIM, true)
                DisablePlayerFiring(cache.playerId, true)
            end
        end

        if interruptProgress(data) then
            exports['ks-progressbar']:cancelprogress()
        end

        Wait(0)
    end

    -- Cleanup
    if data.prop then
        playerState:set('lib:progressProps', nil, true)
    end

    progress = nil
    playerState.invBusy = false

    return wasSuccessful
end

---@param data ProgressProps
---@return boolean?
function lib.progressBar(data)
    while progress ~= nil do Wait(0) end

    if not interruptProgress(data) then
        return startProgress(data)
    end
end

---@param data ProgressProps
---@return boolean?
function lib.progressCircle(data)
    return lib.progressBar(data)
end

function lib.cancelProgress()
    if not progress then return end

    exports['ks-progressbar']:cancelprogress()
end

---@return boolean
function lib.progressActive()
    return progress and true
end

local function deleteProgressProps(serverId)
    local playerProps = createdProps[serverId]
    if not playerProps then return end
    for i = 1, #playerProps do
        local prop = playerProps[i]
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    createdProps[serverId] = nil
end

RegisterNetEvent('onPlayerDropped', function(serverId)
    deleteProgressProps(serverId)
end)

AddStateBagChangeHandler('lib:progressProps', nil, function(bagName, key, value, reserved, replicated)
    if replicated then return end

    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end

    local ped = GetPlayerPed(ply)
    local serverId = GetPlayerServerId(ply)

    if not value then
        return deleteProgressProps(serverId)
    end

    createdProps[serverId] = {}
    local playerProps = createdProps[serverId]

    if value.model then
        playerProps[#playerProps + 1] = createProp(ped, value)
    else
        for i = 1, #value do
            local prop = value[i]

            if prop then
                playerProps[#playerProps + 1] = createProp(ped, prop)
            end
        end
    end
end)