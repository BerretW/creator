fx_version "adamant"
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SpoiledMouse'
version '1.0'
description 'aprts_vzor'

games {"rdr3"}

client_scripts {'config.lua','client/client.lua','client/events.lua','client/renderer.lua','client/visualizer.lua','client/commands.lua','client/nui.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','config.lua','server/server.lua','server/events.lua','server/commands.lua',}


ui_page "client/html/index.html"
files {
    "client/html/index.html",
    "client/html/style.css",
    "client/html/script.js",
    "client/html/images/*.jpg"
}