# CX Speed Cameras (Qbox)

CX Speed Cameras is a FiveM resource designed for Qbox servers to implement automated speed cameras that detect and fine players for exceeding speed limits at configurable locations. The resource includes tiered fines, visual and audio effects, vehicle ownership checks, and integration with notification and email systems for a realistic experience.

## Features
- **Speed Detection**: Detects vehicles exceeding speed limits at predefined camera locations, with configurable grace periods and cooldowns to prevent spamming.
- **Vehicle Ownership Check**: Only issues fines for vehicles registered to the player in the `player_vehicles` database, notifying players without fines if the vehicle is not theirs.
- **Tiered Fines**: Applies fines based on speed thresholds, deducted from the player's bank account (configurable in `config.lua`).
- **Camera Props**: Spawns `prop_cctv_pole_01a` objects at camera locations to visually indicate their presence.
- **Map Blips**: Displays short-range blips on the map for camera locations, toggleable via configuration.
- **Visual and Audio Effects**: Includes an optional screen flash and camera shutter sound when speeding is detected.
- **Notifications**: Uses `ox_lib:notify` for modern notifications, with fallbacks to `qbx_core:Notify` or GTA V native notifications for compatibility.
- **Email Notifications**: Sends detailed emails to players via the `npwd` phone system when fined, including speed, vehicle, and fine amount.
- **Emergency Vehicle Exemption**: Ignores emergency vehicles (class 18) to prevent fines for police, EMS, or fire vehicles.
- **Discord Webhook Support**: Logs speeding violations to a configurable Discord webhook with player, vehicle, speed, and fine details.
- **Debug Logging**: Toggleable debug mode to log resource startup, camera spawning, speed detection, ownership checks, and fine processing for troubleshooting.

## Preview
Watch the preview video on YouTube:
[![Preview Video](https://img.youtube.com/vi/ndhhUA55Grw/maxresdefault.jpg)](https://www.youtube.com/watch?v=ndhhUA55Grw)

## Installation
1. **Download the Resource**:
   - Clone or download the `cx-speedcameras` repository to your server's `resources` folder.
2. **Add to Server Configuration**:
   - Add `ensure cx-speedcameras` to your `server.cfg` file after dependencies (`oxmysql`, `qbx_core`, and optionally `ox_lib` or `npwd`).
3. **Dependencies**:
   - Required: `oxmysql` (for vehicle ownership checks), `qbx_core` (for player data and money management).
   - Optional: `ox_lib` (for enhanced notifications), `npwd` (for email notifications).
4. **Configure the Resource**:
   - Edit `config.lua` to set camera locations, fine thresholds, speed unit (MPH or KM/H), and other options.
   - Set `DISCORD_WEBHOOK` in `server.lua` to enable Discord logging (leave empty to disable).
5. **Start the Resource**:
   - Run `refresh` and `start cx-speedcameras` in your server console or restart the server.

## Configuration
The `config.lua` file allows customization of the resource. Key options include:

- `Config.Debug`: Enable (`true`) or disable (`false`) debug logging for troubleshooting.
- `Config.MPH`: Set to `true` for MPH or `false` for KM/H speed units.
- `Config.UseBlips`: Enable (`true`) or disable (`false`) map blips for camera locations.
- `Config.UseFlashEffect`: Enable (`true`) or disable (`false`) screen flash effect on detection.
- `Config.UseCameraSound`: Enable (`true`) or disable (`false`) camera shutter sound.
- `Config.FinePlayers`: Enable (`true`) or disable (`false`) automatic bank deductions for fines.
- `Config.GracePeriod`: Additional speed allowance (in MPH or KM/H) above the limit before fining.
- `Config.Cooldown`: Minimum time (in seconds) between camera triggers for the same camera.
- `Config.Cameras`: List of camera locations with coordinates (`vector4`) and speed limits.
- `Config.Fines`: Tiered fine amounts based on speed thresholds.
- `Config.SpeedingNotification`: Message template for fine notifications.

Example `config.lua`:
```lua
Config = {}
Config.Debug = true
Config.MPH = true
Config.UseBlips = true
Config.UseFlashEffect = true
Config.UseCameraSound = true
Config.FinePlayers = true
Config.GracePeriod = 5
Config.Cooldown = 10
Config.Cameras = {
    {coords = vector4(200.0881, -812.6038, 30.0, 111.9241), speedLimit = 35},
    ...
}
Config.Fines = {
    {minSpeed = 35, fine = 150},
    {minSpeed = 40, fine = 300},
    ...
}
Config.SpeedingNotification = 'You were caught speeding by a camera! Fine issued.'