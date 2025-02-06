fx_version "adamant"
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SpoiledMouse'
version '1.0'
description 'aprts_charCreator'

games {"rdr3"}

client_scripts {'config.lua', 'client/creator.lua', 'client/menu.lua','client/skill_menu.lua', 'client/client.lua', 'client/events.lua',
                'client/renderer.lua', 'client/visualizer.lua', 'client/commands.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua', 'config.lua', 'server/server.lua', 'server/events.lua', 'server/commands.lua'}
ui_page "nui://jo_libs/nui/menu/index.html"

shared_scripts {'@jo_libs/init.lua', '@ox_lib/init.lua'}

jo_libs {'menu', 'input'}
ox_libs {'Interface', 'pedTexture'}
