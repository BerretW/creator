fx_version "adamant"
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SpoiledMouse'
version '1.0'
description 'aprts_sleepRP'

games {"rdr3"}

client_scripts {'config.lua','client.lua','events.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','server.lua','config.lua'}

