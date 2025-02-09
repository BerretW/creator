author "JUMP ON studios : shop.jumpon-studios.com"
documentation 'https://docs.jumpon-studios.com'
version '1.1.0'
package_id '6237591'
addon_scripts {}
dependencies_version_min 'jo_libs:1.5.0'

fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'

jo_libs {
  'table',
  'hook',
  'callback',
  'notification',
  'dataview',
  'prompt',
  'utils',
  'me',
  'entity',
  'version-checker',
  'database',
  'framework-bridge'
}

escrow_ignore {
  'shared/config.lua',
  'overwriteConfig.lua',
  'shared/lang.lua',
  'overwriteLang.lua',
}

shared_scripts {
  '@jo_libs/init.lua',
  'shared/config.lua',
  'overwriteConfig.lua',
  'shared/lang.lua',
  'overwriteLang.lua',
}

client_scripts {
  'client/**.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/**.lua',
}

ui_page "html/index.html"

files {
	"html/**.html",
	"html/**.js",
	"html/**.css",
	"html/**.ttf",
	"html/**.png",
	"html/**.gif",
}

dependencies {
  'oxmysql',
  'jo_libs',
  '/server:6231',
  '/onesync'
}

escrow_ignore {
  'server/*',
  'shared/*'
}