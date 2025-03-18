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
manifest_content = ""  # naprosto prázdný

lua_code = MOCK_FUNCS + "\n" + manifest_content
print("---- Executed code ----")
print(lua_code)

lua = LuaRuntime()
lua.execute(lua_code)

print("OK, žádná chyba.")
