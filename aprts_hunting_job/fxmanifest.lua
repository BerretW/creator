fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'

client_scripts {"@uiprompt/uiprompt.lua",'config.lua', 'client/client.lua', 'client/events.lua','client/renderer.lua', 'client/animation.lua'}

server_scripts {'@oxmysql/lib/MySQL.lua', 'config.lua', 'server/server.lua', 'server/events.lua'}

shared_scripts {'@jo_libs/init.lua','@ox_lib/init.lua' }

