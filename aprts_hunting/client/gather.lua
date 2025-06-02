-- Check for Animals being skinned/plucked/stored
Animals = {}
local inGameItems = {}

RegisterNetEvent("RSGCore:Client:pushItems")
AddEventHandler("RSGCore:Client:pushItems", function(items)
    inGameItems = items
    -- debugPrint("Items loaded")
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerServerEvent("aprts_hunting:Server:getWeapons")
    TriggerServerEvent("RSGCore:Server:getItems")
end)

local function getFPS()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime
    return frame
end

function fpsTimer()
    local minFPS = 15
    local maxFPS = 165
    local minSpeed = 0
    local maxSpeed = 15
    local fps = math.max(getFPS(), minFPS)
    local coefficient = 1 - (fps - minFPS) / (maxFPS - minFPS)
    return math.max(minSpeed, math.min(maxSpeed, minSpeed + coefficient * (maxSpeed - minSpeed)))
end

Citizen.CreateThread(function()
    while true do
        local pause = 0
        local size = GetNumberOfEvents(0)
        if size > 0 then
            pause = 0
            for index = 0, size - 1 do
                local event = GetEventAtIndex(0, index)
                if event == 1376140891 then

                    local eventDataSize = 3
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0) -- looter                   
                    eventDataStruct:SetInt32(8, 0) -- entity ID
                    eventDataStruct:SetInt32(16, 0) -- success
                    eventDataStruct:SetInt32(24, 0) -- success
                    eventDataStruct:SetInt32(32, 0) -- success


                    debugPrint("Hunting Event Found")
                    local view = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, index, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if not view then
                        debugPrint("View data is nil")
                        goto continue
                    end
                    
                    local pedGathered = eventDataStruct:GetInt32(8)
                    local ped = eventDataStruct:GetInt32(0)
                    local bool_unk = eventDataStruct:GetInt32(16)

                    if not pedGathered or not ped or bool_unk == nil then
                        debugPrint("Invalid event data: " .. json.encode(view))
                        goto continue
                    end

                    local model = GetEntityModel(pedGathered)
                    local Outfit = tonumber(GetPedMetaOutfitHash(pedGathered, 1))
                    if not model or model == 0 then
                        debugPrint("Model is nil or invalid")
                        goto continue
                    end

                    if bool_unk == 1 then
                        local player = PlayerPedId()
                        if player ~= ped then
                            debugPrint("Player is not the one who gathered")
                            goto continue
                        end

                        debugPrint("Checking animal: " .. model)
                        local found = false
                        for i, row in pairs(Animals) do
                            if model == Animals[i].model and Outfit == Animals[i].outfit then
                                local label = Animals[i].label or Animals[i].name
                                debugPrint("Animal found " .. label .. " ID: " .. Animals[i].id)
                                found = true
                                local items = json.decode(Animals[i].item or "[]")
                                if not items then
                                    debugPrint("Error decoding items: " .. tostring(Animals[i].item))
                                    goto continue
                                end
                                -- TriggerServerEvent('westhaven_skill:increase', Config.Skill, 1)

                                TriggerServerEvent("aprts_hunting:Server:GetReward", Animals[i].id)

                                break
                            end
                        end

                        if not found then
                            print("Zvíře, které jsi stáhnul, není v databázi. Model: " .. model .. " Outfit: " .. Outfit)
                        end
                    end
                end
                ::continue::
            end
        end
        Citizen.Wait(math.max(1, pause))
    end
    debugPrint("HAPALO")
end)
