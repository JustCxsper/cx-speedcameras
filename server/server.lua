local DISCORD_WEBHOOK = ''
-- To disable, set DISCORD_WEBHOOK = ''

if Config.Debug then print("[DEBUG] Loading cx-speedcameras server.lua") end

local function GetFine(speed)
    local selectedFine = 0
    for i = #Config.Fines, 1, -1 do
        local tier = Config.Fines[i]
        if speed >= tier.minSpeed then
            selectedFine = tier.fine
            if Config.Debug then
                print(("[DEBUG] GetFine: Speed %d %s, Selected fine: $%d (minSpeed: %d)"):format(
                    math.floor(speed),
                    Config.MPH and "MPH" or "KM/H",
                    selectedFine,
                    tier.minSpeed
                ))
            end
            return selectedFine
        end
    end

    if Config.Debug then
        print(("[DEBUG] GetFine: Speed %d %s, No fine applied"):format(
            math.floor(speed),
            Config.MPH and "MPH" or "KM/H"
        ))
    end
    return selectedFine
end

RegisterNetEvent('cx-speedcameras:server:checkFine', function(speed, limit, cameraIndex, vehName, plate)
    local src = source
    if Config.Debug then print("[DEBUG] checkFine: Triggered for source " .. src .. ", Speed: " .. speed .. ", Limit: " .. limit) end
    local player = exports.qbx_core:GetPlayer(src)
    if not player then
        if Config.Debug then
            print("[DEBUG] Player not found for source: " .. tostring(src))
        end
        return
    end

    local isOwned = false
    local result = exports.oxmysql:executeSync('SELECT 1 FROM player_vehicles WHERE citizenid = :citizenid AND plate = :plate', {
        citizenid = player.PlayerData.citizenid,
        plate = plate
    })
    if result and #result > 0 then
        isOwned = true
    end

    if Config.Debug then
        print(("[DEBUG] Vehicle ownership check: Plate %s, Owned: %s"):format(plate, tostring(isOwned)))
    end

    if not isOwned then
        if Config.Debug then
            print("[DEBUG] Vehicle not owned by player; skipping fine.")
        end
        local notifyText = 'You were caught speeding, but no fine was issued as the vehicle is not registered to you.'
        if exports.ox_lib then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Speed Camera',
                description = notifyText,
                type = 'inform',
                duration = 5000
            })
        elseif exports.qbx_core.Notify then
            exports.qbx_core:Notify(src, notifyText, 'inform', 5000)
        else
            TriggerClientEvent('cx-speedcameras:client:notify', src, notifyText)
        end
        return
    end

    local fine = GetFine(speed)
    if fine <= 0 then
        if Config.Debug then print("[DEBUG] No fine applied (fine = 0)") end
        TriggerClientEvent('cx-speedcameras:client:receiveFine', src, speed, limit, fine, cameraIndex)
        return
    end

    if Config.FinePlayers then
        local success = player.Functions.RemoveMoney('bank', fine, 'speed-camera-fine')
        if Config.Debug then
            print(("[DEBUG] RemoveMoney: Player %s, Fine $%d, Success: %s"):format(player.PlayerData.name, fine, tostring(success)))
        end
    end

    local notifyText = ('%s Amount: $%d'):format(Config.SpeedingNotification, fine)
    if exports.ox_lib then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Speed Camera',
            description = notifyText,
            type = 'success',
            duration = 5000
        })
    elseif exports.qbx_core.Notify then
        exports.qbx_core:Notify(src, notifyText, 'success', 5000)
    else
        TriggerClientEvent('cx-speedcameras:client:notify', src, notifyText)
    end

    if DISCORD_WEBHOOK and DISCORD_WEBHOOK ~= '' then
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
                    url = 'https://testing.strataservers.com/cx-scripts/speedcam.png'
                },
                footer = {
                    text = "LSPD Speed Enforcement System"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }

        local payload = json.encode({
            username = "LSPD Speed Camera",
            embeds = embed
        })

        if Config.Debug then print("[DEBUG] Sending Discord payload (webhook configured).") end

        PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers)
            if err == 200 or err == 204 then
                if Config.Debug then print("[DEBUG] Embed posted to Discord successfully.") end
            else
                print(("[ERROR] Discord webhook failed: %s - %s"):format(tostring(err), text or "No response"))
            end
        end, 'POST', payload, { ['Content-Type'] = 'application/json' })
    else
        if Config.Debug then print("[DEBUG] DISCORD_WEBHOOK not configured; skipping Discord post.") end
    end

    if Config.Debug then print("[DEBUG] Triggering client:receiveFine for source " .. src) end
    TriggerClientEvent('cx-speedcameras:client:receiveFine', src, speed, limit, fine, cameraIndex)
end)