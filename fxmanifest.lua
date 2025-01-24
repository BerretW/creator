fx_version "adamant"
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SpoiledMouse'
version '1.0'
description 'aprts_medicalAtention'

games {"rdr3"}

client_scripts {'config.lua','client/dataview.lua','client/client.lua','client/medic.lua','client/events.lua','client/renderer.lua','client/visualizer.lua','client/commands.lua',}
server_scripts {'@oxmysql/lib/MySQL.lua','config.lua','server/server.lua','server/events.lua','server/commands.lua','server/items.lua'}
