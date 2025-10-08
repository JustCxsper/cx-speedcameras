local function GetFine(speed)
    local selectedFine = 0
    for i = #Config.Fines, 1, -1 do
        local tier = Config.Fines[i]
        if speed >= tier.minSpeed then
            selectedFine = tier.fine
            if Config.Debug then
                print("[DEBUG] GetFine: Speed " .. math.floor(speed) .. " " .. (Config.MPH and "MPH" or "KM/H") .. ", Selected fine: $" .. selectedFine .. " (minSpeed: " .. tier.minSpeed .. ")")
            end
            return selectedFine
        end
    end
    if Config.Debug then
        print("[DEBUG] GetFine: Speed " .. math.floor(speed) .. " " .. (Config.MPH and "MPH" or "KM/H") .. ", No fine applied")
    end
    return selectedFine
end

RegisterNetEvent('cx-speedcameras:server:checkFine', function(speed, limit, cameraIndex, vehName, plate)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then
        if Config.Debug then
            print("[DEBUG] Player not found for source: " .. src)
        end
        return
    end

    local fine = GetFine(speed)
    if fine > 0 and Config.FinePlayers then
        local success = player.Functions.RemoveMoney('bank', fine, 'speed-camera-fine')
        if Config.Debug then
            print("[DEBUG] RemoveMoney: Player " .. player.PlayerData.name .. ", Fine $" .. fine .. ", Success: " .. tostring(success))
        end
        
        local notifyData = {
            title = 'Speed Camera',
            description = Config.SpeedingNotification .. ' Amount: $' .. fine,
            type = 'success',
            duration = 5000
        }
        if exports.ox_lib then
            TriggerClientEvent('ox_lib:notify', src, notifyData)
        elseif exports.qbx_core.Notify then
            if Config.Debug then
                print("[DEBUG] ox_lib server notification failed, using qbx_core:Notify")
            end
            exports.qbx_core:Notify(src, notifyData.description, 'success', 5000)
        else
            if Config.Debug then
                print("[DEBUG] ox_lib and qbx_core:Notify failed, using GTA V fallback")
            end
            TriggerClientEvent('cx-speedcameras:client:notify', src, notifyData.description)
        end
        if Config.Debug then
            print(('[DEBUG] Speed camera fine: Player %s fined $%d for %d %s at camera %d'):format(player.PlayerData.name, fine, math.floor(speed), Config.MPH and "MPH" or "KM/H", cameraIndex))
        end

        -- Send embed with vehicle, plate, and static image
        local embed = {
            {
                title = "🚨 Speeding Violation Caught",
                description = string.format(
                    "**Player:** %s (ID: %s)\n**Vehicle:** %s (Plate: %s)\n**Speed:** %.0f %s (Limit: %d)\n**Location:** Speed Camera #%d\n**Fine:** $%d",
                    player.PlayerData.name,
                    player.PlayerData.citizenid,
                    vehName or "Unknown Vehicle",
                    plate or "Unknown Plate",
                    speed,
                    Config.MPH and "MPH" or "KM/H",
                    limit,
                    cameraIndex,
                    fine
                ),
                color = 16711680,
                image = {
                    url = 'https://pbs.twimg.com/profile_images/1520485937679151104/ifeyV77d_400x400.png' -- Replace with your static image URL
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }

        local payload = json.encode({
            username = "LSPD Speed Camera",
            embeds = embed
        })

        if Config.Debug then
            print("[DEBUG] Sending Discord payload: " .. payload)
        end

        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
            if err == 200 or err == 204 then
                if Config.Debug then print("[DEBUG] Embed posted to Discord") end
            else
                print("[ERROR] Discord webhook failed: " .. err .. " - " .. (text or "No response"))
            end
        end, 'POST', payload, { ['Content-Type'] = 'application/json' })
    end

    TriggerClientEvent('cx-speedcameras:client:receiveFine', src, speed, limit, fine, cameraIndex)
end)