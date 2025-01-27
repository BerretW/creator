fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
games {'rdr3', 'gta5'}

client_scripts {"@uiprompt/uiprompt.lua",'locale.lua', 'client/dataview.lua', 'client/cl_main.lua', 'client/client.lua', 'client/designer.lua','client/bags.lua',
                'config.lua', 'client/horseinfo.lua', 'client/call.lua', 'client/flee.lua', 'client/commands.lua',
                'client/npc.lua', 'client/shop.lua','client/menu.lua', 'client/prompt.lua','client/horsePromprs.lua','client/attributes.lua','keys.lua'}

server_scripts {'locale.lua', 'server/sv_main.lua', 'config.lua','server/attributes.lua', '@mysql-async/lib/MySQL.lua','server/items.lua', 'comp.lua'}

shared_scripts {'@jo_libs/init.lua', 'horses.lua', 'comp.lua'}
ui_page {"nui://jo_libs/nui/menu/index.html"}
jo_libs {'menu', 'notification'}
