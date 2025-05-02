RegisterNetEvent('next-flashbang:detonate', function(pos, players, entity)
    if not CanDetonateFlashbang(source) then return end

    if #pos == 0 or type(pos) ~= 'vector3' or type(players) ~= 'table' then
        PunishPlayer(source, 'Invalid flashbang parameters provided.')
        return
    end

    local flashbang = NetworkGetEntityFromNetworkId(entity)
    if not flashbang or not DoesEntityExist(flashbang) then
        PunishPlayer(source, 'Invalid flashbang entity provided.')
        return
    end

    local timer = GetGameTimer()
    while DoesEntityExist(flashbang) and GetGameTimer() - timer < 1000 do
        pcall(DeleteEntity, flashbang)
        Wait(50)

        if not DoesEntityExist(flashbang) then
            break
        end
    end

    for _, id in ipairs(players) do
        local playerPed = GetPlayerPed(id)
        if playerPed and DoesEntityExist(playerPed) then
            local playerPos = GetEntityCoords(playerPed, false)
            local distance = #(playerPos - pos)
            if distance <= Config.FlashbangRadius + 0.0 then
                TriggerClientEvent('next-flashbang:flash', id, pos, distance)
            end
        end
    end
end)