# 007: Agent Under Fire (GameCube) Speedometer
![Screenshot 2024-04-14 212814](https://github.com/FitterSpace/AUF-Speedometer/assets/22065181/0823af77-fdb4-4b62-bcd2-e664cb55ac76)

## Features:

Displays the player's movement speed, falling speed, position, angles, health, and inputs.

The Dolphin 5.0 LUA script allows you to jump by holding Y instead of pressing it, but I removed this from the BizHawk version.

## How to Use:

### BizHawk (recommended):
1) Download [this development version of BizHawk](https://tasvideos.org/Forum/Topics/23347) that supports GameCube games.
2) When you start the game, open the LUA console under the "Tools" menu, open the script, then press the play button.

### Dolphin (Legacy):
1) Download the latest version of [Dolphin 5.0 Lua Core](https://github.com/SwareJonge/Dolphin-Lua-Core)
2) Download this script and place it in the "Scripts" folder (Sys > Scripts)
3) Start running the North American version of 007: Agent Under Fire in the emulator
4) While the game is running, go to Tools > Execute Script
5) Find "AuF-Speedometer.lua" in the drop-down list and click "Start"

## Known Issues:
The script must be restarted upon loading a new map. This is because the memory addresses update when a new map is loaded, but the script never updates them.

This script only works for the on-foot levels. Driving levels are not supported at the moment.

Multiplayer is not supported. If a bot is in the match, its speed will be shown instead. If there are no bots, player 2's speed will be shown.

The PAL version is not supported.

Direction and Wishdir are undefined at 0.
