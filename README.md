# CX Speed Cameras (Qbox)
cx-speedcameras is a FiveM resource for Qbox servers that implements speed cameras to detect and fine players for exceeding speed limits. It features configurable camera locations, tiered fines, visual and audio effects.

# Changelog
- **CHANGE**: Added Discord webhooks for Speed Notifications. Set this in `server/server.lua`
- **FIX**: Before all players recieved the fine, flash, audio when triggering a speedcamera. this is now set to drivers only.
- **FIX**: Flash now is shorter to make it feel more like a actual flash.
# Coming Soon
- Add a check to see if its a player owned vehicle or not.
- Include Police Dispatch Notifications
# Preview
**Click the thumbnail to watch on youtube!**
[![Watch the video](https://img.youtube.com/vi/ndhhUA55Grw/maxresdefault.jpg)](https://www.youtube.com/watch?v=ndhhUA55Grw)

## Features
- **Speed Cameras**: Detects player vehicles exceeding speed limits at defined locations, with configurable grace periods and cooldowns.
- **Tiered Fines**: Applies fines based on speed thresholds (e.g., $150 for >35 MPH, $500 for >90 MPH), deducted from the player's bank.
- **Camera Props**: Spawns `prop_cctv_pole_01a` objects at camera locations.
- **Map Blips**: Displays short-range blips for camera locations, toggleable in config.
- **Visual & Audio Effects**: Optional screen flash and camera shutter sound when speeding is detected.
- **Server-Side Notifications**: Uses `ox_lib:notify` for notifications, with fallbacks to `qbx_core:Notify` or GTA V native notifications.
- **Debug Toggle**: Configurable debug logging to track resource start, camera spawning, fine calculations, and notifications.
- **Emergency Vehicle Exemption**: Ignores emergency vehicles.
- **NWPD Emails**: Players get a detailed email with their fine that has been issued.
![Thumbnail](https://testing.strataservers.com/download/cx-speed.png)


