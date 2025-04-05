fx_version 'adamant'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'


ui_page 'nui/index.html'

client_scripts {
    'client/main.lua'
}
server_scripts {
    
}
files {
    'nui/index.html',
    'nui/*.TTF',
    'nui/*.ttf',
    'nui/style.css',
    'nui/script.js',
    'nui/images/*.png'
}
