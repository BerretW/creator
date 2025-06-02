fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'
client_scripts {"@uiprompt/uiprompt.lua","client/dataview.lua",'config.lua', 'client/client.lua', 'client/npc.lua', 'client/commands.lua', 'client/gather.lua',
                'client/main.js'}

server_scripts {'@oxmysql/lib/MySQL.lua', 'config.lua', 'server/server.lua', 'server/time.lua'}

shared_scripts {'@jo_libs/init.lua','@ox_lib/init.lua'}

jo_libs {'notification'}
