Incapacitated = false

local usingOx = false
local flashLoop = false

local function getPlayersNearby(pos, radius)
    local nearbyPlayers = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        if ped ~= -1 then
            local pedPos = GetEntityCoords(ped)
            local distance = #(pos - pedPos)

            if distance <= radius then
                nearbyPlayers[#nearbyPlayers + 1] = GetPlayerServerId(playerId)
            end
        end
    end

    return nearbyPlayers
end

local function handleFlashbang()
    CreateThread(function()
        while flashLoop do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local obj = GetClosestObjectOfType(pos, 50.0, `w_ex_flashbang`, false, false, false)

            if IsPedShooting(ped) then
                if obj > 1 then
                    SetEntityAsMissionEntity(obj, true, true)
                    NetworkRegisterEntityAsNetworked(obj)
                    Wait(2500)
                    
                    local bangPos = GetEntityCoords(obj)
                    local nearbyPlayers = getPlayersNearby(bangPos, Config.FlashbangRadius + 0.0)
                    local entity = ObjToNet(obj)

                    TriggerServerEvent('next-flashbang:detonate', bangPos, nearbyPlayers, entity)
                    AddExplosion(bangPos, 25, 0.0, true, false, 2.0)
                end
            end
            Wait(0)
        end
    end)
end

local function playEmote(duration)
    local ped = PlayerPedId()
    local animDict = "missminuteman_1ig_2"
    local animName = "tasered_2"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration, 49, 0, false, false, false)

    Wait(duration)

    ClearPedTasks(ped)
end

local function applyFlashSlowLook(duration, sensitivityScale)
    local startTime = GetGameTimer()

    CreateThread(function()
        local pitch = GetGameplayCamRelativePitch()
        local heading = 0.0
    
        while Incapacitated and (GetGameTimer() - startTime < duration) do
            DisableControlAction(0, 220, true) -- Look Left/Right
            DisableControlAction(0, 221, true) -- Look Up/Down
    
            local lookX = GetDisabledControlNormal(0, 220)
            local lookY = GetDisabledControlNormal(0, 221)
    
            local damp = sensitivityScale or 0.25
            heading = heading - (lookX * damp * 10.0)
            pitch = pitch - (lookY * damp * 10.0)
    
            pitch = math.max(-70.0, math.min(42.0, pitch))
    
            SetGameplayCamRelativeHeading(heading)
            SetGameplayCamRelativePitch(pitch, 1.0)
    
            Wait(0)
        end
    end)
end

local function clearFlashbangEffects(duration)
    local ped = PlayerPedId()
    local fadeDuration = duration or 1000
    local startTime = GetGameTimer()
    local endTime = startTime + fadeDuration

    CreateThread(function()
        while GetGameTimer() < endTime do
            local now = GetGameTimer()
            local progress = (now - startTime) / fadeDuration
            local strength = 1.0 - progress

            SetTimecycleModifierStrength(strength)

            Wait(0)
        end

        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(ped, 0.0)
        ResetPedStrafeClipset(ped)
        SetPedMotionBlur(ped, false)
        SetPedIsDrunk(ped, false)
        StopGameplayCamShaking(true)
    end)
end

local function applyFlashbangEffect()
    CreateThread(function()
        local ped = PlayerPedId()
        SetTimecycleModifier("REDMIST_blend")
        SetTimecycleModifierStrength(1.0)
        SetPedMotionBlur(ped, true)
        SetPedIsDrunk(ped, true)
        ShakeGameplayCam('HAND_SHAKE', 5.0)

        Wait(Config.FlashbangDuration * 1000)
        Incapacitated = false

        clearFlashbangEffects(1500)
        FlashbangAftermath()
    end)
end

if GetResourceState('ox_inventory') == 'started' then
    usingOx = true

    local currentHash
    AddEventHandler('ox_inventory:currentWeapon', function(weapon)
        if weapon then
            local hash = weapon.hash
            if currentHash and currentHash == hash then return end
            currentHash = hash

            if hash == `WEAPON_FLASHBANG` then
                flashLoop = true
                handleFlashbang()
            end
        else
            currentHash = nil
            flashLoop = false
        end
    end)
end

RegisterNetEvent('next-flashbang:flash', function(pos, distance)
    if not CanBeFlashed(pos, distance) then return end

    CreateThread(function()
        BeforeFlashbang()
    end)

    RequestModel(`a_c_rat`)
    while not HasModelLoaded(`a_c_rat`) do
        Wait(5)
    end

    local ped = PlayerPedId()
    local rat = CreatePed(0, `a_c_rat`, pos, 0, false)
    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(pos.x, pos.y, pos.z, 0)

    if distance <= Config.StunRadius + 0.0 then
        Incapacitated = true

        CreateThread(function()
            DisableControls()
        end)

        if not IsPedInAnyVehicle(ped, false) then
            if Config.RagdollEnabled then
                local time = Config.RagdollTime * 1000
                SetPedToRagdoll(ped, time, time, 0)
            end
        end

        if Config.Disarm then
            if usingOx then
                TriggerEvent('ox_inventory:disarm', true)
            else
                SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            end
        end

        if Config.SlowMovement then
            applyFlashSlowLook(Config.FlashbangDuration * 1000, Config.SlowMovementScale)
        end

        applyFlashbangEffect()
    elseif HasEntityClearLosToEntityInFront(ped, rat) and OnScreen then
        CreateThread(function()
            ShakeGameplayCam('HAND_SHAKE', 1.0)
            local scale = math.max(0.0, math.min(1.0, 1 - (distance / Config.FlashbangRadius)))
            local duration = Config.FlashbangDuration * 1000 * scale

            playEmote(duration)

            StopGameplayCamShaking(true)
            FlashbangAftermath()
        end)
    end

    local timer = GetGameTimer()
    while DoesEntityExist(rat) and GetGameTimer() - timer < 1000 do
        pcall(DeleteEntity, rat)
        Wait(50)

        if not DoesEntityExist(rat) then
            break
        end
    end
end)

exports('onFlashbang', function()
    if not usingOx then
        local ped = PlayerPedId()
        while IsPedArmed(ped, 2) do
            if not flashLoop and GetSelectedPedWeapon(ped) == `WEAPON_FLASHBANG` then
                flashLoop = true
                handleFlashbang()
            end
            Wait(1000)
        end

        flashLoop = false
    end
end)