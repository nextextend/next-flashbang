-- Implement your own logic here. This function is called right before a flashbang will affect them. Cancel it with this function if you want.
function CanBeFlashed(position, distance)
    return true
end

-- Limit player functions right before the flashbang will affect them. This function is ran in a thread, so yielding won't work. Should also not return anything.
function BeforeFlashbang()
    -- GlobalState.blockEmotes = true
end

function DisableControls()
    while Incapacitated do
        DisableControlAction(0, 25, true) -- Aim / Right Mouse Button
        DisableControlAction(0, 63, true) -- Vehicle Turn Left (A / Left Arrow)
        DisableControlAction(0, 64, true) -- Vehicle Turn Right (D / Right Arrow)
        DisableControlAction(0, 71, true) -- Vehicle Accelerate (W)
        DisableControlAction(0, 72, true) -- Vehicle Brake/Reverse (S)
        DisableControlAction(0, 75, true) -- Vehicle Exit (F)
        Wait(0)
    end
end

-- This function is called when the flashbang effect has stopped. If you have set certain states on a player using the before function, undo them here. Should also not return anything.
function FlashbangAftermath()
    -- GlobalState.blockEmotes = false
end