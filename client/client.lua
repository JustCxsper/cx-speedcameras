AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[DEBUG] Starting Cxspers Speed Cameras")
    end
end)

local PlayerId = GetPlayerServerId(PlayerId())
local lastTriggered = {}

local function IsEmergencyVehicle(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    return vehicleClass == 18
end

Citizen.CreateThread(function()
    if not Config.UseBlips then return end
    local propModel = GetHashKey('prop_cctv_pole_01a')  -- Camera prop
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do Wait(0) end

    for i, camera in ipairs(Config.Cameras) do
        -- Create blip
        local blip = AddBlipForCoord(camera.coords.x, camera.coords.y, camera.coords.z)
        SetBlipSprite(blip, 184)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.4)
        SetBlipColour(blip, 46)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Speed Camera")
        EndTextCommandSetBlipName(blip)
        --if Config.Debug then
        --    print("[DEBUG] Blips Created", camera.coords)
        --end

        -- Spawn camera object with rotation
        local prop = CreateObject(propModel, camera.coords.x, camera.coords.y, camera.coords.z, false, false, false)
        SetEntityHeading(prop, camera.coords.w)  -- Apply heading from vector4
        FreezeEntityPosition(prop, true)  -- Lock in place
        if Config.Debug then
            print("Camera Spawned - Speed Limit: " .. camera.speedLimit .. ", Location: " .. tostring(camera.coords) .. ", Heading: " .. camera.coords.w)
        end
    end
    SetModelAsNoLongerNeeded(propModel)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if not IsEmergencyVehicle(vehicle) then
                local speed = GetEntitySpeed(vehicle) * 3.6
                if Config.MPH then speed = speed * 0.621371 end

                for i, camera in ipairs(Config.Cameras) do
                    local dist = #(GetEntityCoords(vehicle) - vector3(camera.coords.x, camera.coords.y, camera.coords.z))
                    if dist < 60.0 then  -- Detection radius
                        sleep = 0
                        local limit = camera.speedLimit + Config.GracePeriod
                        if speed > limit and (not lastTriggered[i] or (GetGameTimer() - lastTriggered[i]) > Config.Cooldown * 1000) then
                            local driverPed = GetPedInVehicleSeat(vehicle, -1)
                            if playerPed == driverPed then
                                TriggerServerEvent('cx-speedcameras:server:checkFine', speed, camera.speedLimit, i)
                                if Config.UseFlashEffect then
                                    SetFlash(0, 0, 200, 4000, 200)
                                    if Config.Debug then
                                        print("[DEBUG] Flash Effect Activated")
                                    end
                                end
                                if Config.UseCameraSound then
                                    PlaySoundFrontend(-1, "Camera_Shoot", "Phone_SoundSet_Default", true)
                                    if Config.Debug then
                                        print("[DEBUG] Shutter Sound Activated")
                                    end
                                end
                            end
                            lastTriggered[i] = GetGameTimer()
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)