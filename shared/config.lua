Config = {}

Config.Debug = true

Config.MPH = true -- Speed unit true = MPH, false = KMH
Config.UseBlips = true
Config.UseFlashEffect = true
Config.UseCameraSound = true
Config.FinePlayers = true

-- Speed limit grace period (km/h or mph over limit before triggering)
Config.GracePeriod = 5

-- Cooldown between triggers per player (seconds)
Config.Cooldown = 10

Config.Cameras = {
    {coords = vector4(200.0881, -812.6038, 30.0, 111.9241), speedLimit = 35},
    {coords = vector4(-232.2226, -687.2715, 32.2644, 142.4031), speedLimit = 35},
    {coords = vector4(297.6145, -785.9840, 28.2100, 142.3997), speedLimit = 35},
    {coords = vector4(252.3645, -206.0084, 53.0, 106.0831), speedLimit = 35},
    {coords = vector4(549.0251, -1043.8633, 36.1711, 81.6666), speedLimit = 35},
}

Config.Fines = {
    {minSpeed = 35, fine = 150},
    {minSpeed = 40, fine = 300},
    {minSpeed = 50, fine = 500},
    {minSpeed = 60, fine = 750},
    {minSpeed = 75, fine = 900},
    {minSpeed = 100, fine = 1250},
    {minSpeed = 125, fine = 1750},
}

Config.SpeedingNotification = 'You were caught speeding by a camera! Fine issued.'