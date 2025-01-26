-- File: fxmanifest.lua

fx_version "adamant"
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
games {"rdr3"}
author 'SpoiledMouse'
version '1.0'
description "APRTS Attachments - Synchronizace attachmentů pro RedM"


client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

shared_scripts {
    'config.lua'
}
