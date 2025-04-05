import lupa
from lupa import LuaRuntime

MOCK_FUNCS = """
function fx_version(...) end
function game(...) end
function games(...) end
function rdr3_warning(...) end
function lua54(...) end

function ui_page(val)
    _G["ui_page"] = val
end

function files(val)
    _G["files"] = val
end

function client_scripts(val)
    _G["client_scripts"] = val
end

function server_scripts(val)
    _G["server_scripts"] = val
end
"""

# Tohle je prázdný manifest
manifest_content = """ 
fx_version 'adamant'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'


ui_page 'nui/index.html'

client_scripts {
    'client/main.lua'
}

files {
    'nui/index.html',
    'nui/*.TTF',
    'nui/*.ttf',
    'nui/style.css',
    'nui/script.js',
    'nui/images/*.png'
}
"""  # naprosto prázdný

lua_code = MOCK_FUNCS + "\n" + manifest_content
print("---- Executed code ----")
print(lua_code)

lua = LuaRuntime()
lua.execute(lua_code)

print("OK, žádná chyba.")
