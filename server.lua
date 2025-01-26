-- gum = exports.gum_core:gumAPI()
local Core = exports.vorp_core:GetCore()
local stavInfo = {}


RegisterServerEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text)
	local _source = source
	drawtext = " "..text
	TriggerClientEvent('3dme:triggerDisplay', -1, drawtext, _source)
end)

RegisterServerEvent('3ddo:shareDisplay')
AddEventHandler('3ddo:shareDisplay', function(text)
	local _source = source
	drawtext = " "..text
	TriggerClientEvent('3ddo:triggerDisplay', -1, drawtext, _source)
 end)

RegisterServerEvent('3ddoc:shareDisplay')
AddEventHandler('3ddoc:shareDisplay', function(text)
	local _source = source
	drawtext = " "..text
	TriggerClientEvent('3ddoc:triggerDisplay', -1, drawtext, _source)
 end)

RegisterServerEvent('3dstav:shareDisplay')
AddEventHandler('3dstav:shareDisplay', function(text)
	local _source = source
	if text ~= nil then
        stavInfo[_source] = text.." -"
		TriggerClientEvent('3dstav:triggerDisplay', -1, stavInfo, source)
	end
end)
RegisterServerEvent('3dstav:stateDisable')
AddEventHandler('3dstav:stateDisable', function()
	local _source = source
    for k,v in pairs(stavInfo) do
        if tonumber(k) == tonumber(_source) then
            stavInfo[_source] = nil
            TriggerClientEvent('3dstav:triggerDisplay', -1, stavInfo, source)
            return false
        end
    end
end)
RegisterServerEvent('3dme:getState')
AddEventHandler('3dme:getState', function()
    TriggerClientEvent("3dme:getState", source, stavInfo)
end)


local function DiscordWeb(color, name, message, footer)
    local embed = {
        {
            ["color"] = color,
            ["title"] = "Chat",
            ["description"] = "**".. name .."** \n"..message,
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    PerformHttpRequest(Config.url, function(err, text, headers) end, 'POST', json.encode({username = Config.ServerName, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("aprts_3dme:Server:sendMessage")
AddEventHandler("aprts_3dme:Server:sendMessage", function(type, message)
	local Core = exports.vorp_core:GetCore()
	local _source = source
	local name = GetPlayerName(_source)
	local Character = Core.getUser(_source).getUsedCharacter
	local playerName = Character.firstname..' '..Character.lastname or 'Unknown'
	
	if Config.UseDiscord then
		DiscordWeb(Config.color, "OOC: "..name.." / IC: "..playerName, message, type)
	end
end)