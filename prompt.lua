local PromptPlay = nil
local PromptStop = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local function prompt()
    Citizen.CreateThread(function()
        local str = "Přehrát"

        PromptPlay = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PromptPlay, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PromptPlay, str)
        PromptSetEnabled(PromptPlay, true)
        PromptSetVisible(PromptPlay, true)
        PromptSetHoldMode(PromptPlay, true)
        PromptSetGroup(PromptPlay, promptGroup)
        PromptRegisterEnd(PromptPlay)


        str = "Stop/Vyndat"

        PromptStop = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PromptStop, 0xF3830D8E)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PromptStop, str)
        PromptSetEnabled(PromptStop, true)
        PromptSetVisible(PromptStop, true)
        PromptSetHoldMode(PromptStop, true)
        PromptSetGroup(PromptStop, promptGroup)
        PromptRegisterEnd(PromptStop)
    end)
end

CreateThread(function()
    prompt()
    while true do
        local pause = 1000
        local phono = GetClosestPhonograph()
        if phono then
            pause = 0
            local coords = GetEntityCoords(phono)

            local name = CreateVarString(10, 'LITERAL_STRING', "Phonofraph")
            PromptSetActiveGroupThisFrame(promptGroup, name)
            if PromptHasHoldModeCompleted(PromptPlay) then
                local handle = GetHandleFromCoords(coords)
                TriggerServerEvent("phonograph:Server:playDrum", handle)
                Wait(1000)
            end
            if PromptHasHoldModeCompleted(PromptStop) then
                local handle = GetHandleFromCoords(coords)
                TriggerServerEvent("phonograph:Server:removeDrum", handle)
                Wait(1000)
            end
        end
        Wait(pause)
    end
end)

