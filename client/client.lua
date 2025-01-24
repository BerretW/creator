playerIllness = nil
clothes = {}
-- local Prompt = nil
-- local promptGroup = GetRandomIntInRange(0, 0xffffff)
function debugPrint(msg)
    if Config.Debug then
        print("^1[aprts_medicalAtention]^0 " .. msg)
    end
end
TempCompensation = 0
otherPlayer = nil
otherPlayerIllness = nil
diagnosis = {
    poslech = {
        done = false,
        parts = {"teplota", "jazyk", "mandle"}
    },
    usta = {
        done = false,
        parts = {"uzliny", "krk", "plice", "tep"}
    },
    hmat = {
        done = false,
        parts = {"hlen", "oci", "nos", "kuze", "vyrazka", "nekroza"}
    },
    detaily = {
        done = false,
        parts = {"poceni", "bricho"}
    }
}

function notify(text)
    TriggerEvent('notifications:notify', "NEMOC", text, 10000)
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- local function prompt()
--     Citizen.CreateThread(function()
--         local str = "Sběr Dehtu"
--         local wait = 0
--         Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
--         PromptSetControlAction(Prompt, 0x760A9C6F)
--         str = CreateVarString(10, 'LITERAL_STRING', str)
--         PromptSetText(Prompt, str)
--         PromptSetEnabled(Prompt, true)
--         PromptSetVisible(Prompt, true)
--         PromptSetHoldMode(Prompt, true)
--         PromptSetGroup(Prompt, promptGroup)
--         PromptRegisterEnd(Prompt)
--     end)
-- end

function StartAnimation(Anim)
    debugPrint("Playing animation: " .. Anim.dict)
    RequestAnimDict(Anim.dict)
    while not HasAnimDictLoaded(Anim.dict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), Anim.dict, Anim.name, 1.0, 1.0, -1, 17, 1.0, false, false, false)
end

function EndAnimation(Anim)
    RemoveAnimDict(Anim.dict)
    StopAnimTask(PlayerPedId(), Anim.dict, Anim.name, 1.0)
end

function PlayAnimation(Anim)
    -- print("Playing animation: " .. Anim.dict)
    FreezeEntityPosition(PlayerPedId(), true)
    StartAnimation(Anim)
    Citizen.Wait(Anim.time)
    EndAnimation(Anim)
    FreezeEntityPosition(PlayerPedId(), false)
end

function GetNameOfZone(coords)
    local name = ""
    local zone = Citizen.InvokeNative(0x43AD8FC02B429D33, coords.x, coords.y, coords.z, 10)

    -- debugPrint(tostring(zone))
    for k, v in pairs(Config.States) do
        if zone == v then
            name = k
        end
    end

    return name
end
function getTempCompensation()
    local components = exports.vorp_character:GetAllPlayerComponents()

    local tempCompensation = 0
    for key, component in pairs(components) do
        local state = LocalPlayer.state[key]

        if state ~= nil then
            component.state = state
            -- print("Component: ",key, component.state)
            if Config.Components[key] ~= nil and component.state == true then
                component.tempCompensation = Config.Components[key]
                tempCompensation = tempCompensation + Config.Components[key]
            end
        end
    end
    TempCompensation = tempCompensation
end

Citizen.CreateThread(function()
    -- prompt()
    while true do
        local pause = 1000
        Citizen.Wait(pause)
        getTempCompensation()
        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)
        if playerIllness == nil then

        else
            playerIllness.duration = playerIllness.duration - 1
            if playerIllness.duration <= 0 then
                playerIllness = nil
                TriggerServerEvent("aprts_medicalAtention:Server:playerGetCured")
            end
        end

    end
end)

function haveStetoskop()
    if exports["aprts_tools"]:GetEquipedTool() == Config.Tool1 then
        return true
    end
    return false
end

local function makeSick(illnessName)
    local illness = Config.Illnesses[illnessName]
    if illness then
        notify("Najednou se cítíš mizerně, najdi lékaře!")
        playerIllness = illness
        TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick", playerIllness)
    else
        debugPrint("Nemoc neexistuje")
    end
end

exports("getSick", makeSick)

local function getCured()
    playerIllness = nil
    TriggerServerEvent("aprts_medicalAtention:Server:playerGetCured")
end
exports("getCured", getCured)

local function getIllness()
    return playerIllness
end
exports("getIllness", getIllness)

local function getIllnesses()
    return Config.Illnesses
end

function infectPlayers()
    local bandada = LocalPlayer.state.IsBandanaOn
    if bandada then
        debugPrint("Nemůžeš nakazit nikoho s bandanou")
    else
        debugPrint("Nakazuji hráče")
        TriggerServerEvent("aprts_medicalAtention:Server:infectPlayers", playerIllness, GetEntityCoords(PlayerPedId()))
    end

end

function changeHealth(ped, inner, outer)
    if inner then
        local health = GetAttributeCoreValue(ped, 0)
        local newhealth = health + inner

        if (newhealth > 100) then
            newhealth = 100
        end

        Citizen.InvokeNative(0xC6258F41D86676E0, ped, 0, newhealth)
        debugPrint("Změna vnitřního zdraví na: " .. newhealth)
    end
    if outer then
        local health = GetEntityHealth(ped, 0)
        local newhealth = health + outer
        SetEntityHealth(ped, newhealth, 0)
        debugPrint("Změna vnějšího zdraví na: " .. newhealth)
    end
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000 * 60 * 1
        Citizen.Wait(pause)
        local playerPed = PlayerPedId()
        if playerIllness then
            TriggerServerEvent("aprts_medicalAtention:Server:updateTime", playerIllness.duration)
            local anim = {}
            anim.dict = playerIllness.symptoms.animDict
            anim.name = playerIllness.symptoms.animBody
            anim.time = playerIllness.symptoms.animTime
            -- if IsPedOnMount(playerPed) then
            --     if playerIllness.symptoms.horseDict then
            --         anim.dict = playerIllness.symptoms.horseDict
            --         anim.name = playerIllness.symptoms.horseBody
            --     end
            -- end
            -- random chance to play Animation
            local chance = math.random(1, 100)

            if chance <= 60 then
                local stamina = GetAttributeCoreValue(PlayerPedId(), 1)
                debugPrint("Stamina: " .. stamina)
                local health = GetEntityHealth(playerPed)
                debugPrint("Health: " .. health)
                SetAttributeCoreValue(PlayerPedId(), 1, stamina + playerIllness.symptoms.stamina)

                stamina = GetAttributeCoreValue(PlayerPedId(), 1)
                debugPrint("Stamina: " .. stamina)
                debugPrint("Snižuji vodu o : " .. playerIllness.symptoms.water)
                debugPrint("Snižuji jídlo o : " .. playerIllness.symptoms.food)

                changeHealth(playerPed, playerIllness.symptoms.innerHealth, playerIllness.symptoms.outerHealth)
                TriggerEvent('vorpmetabolism:changeValue', 'Thirst', playerIllness.symptoms.water)
                TriggerEvent('vorpmetabolism:changeValue', 'Hunger', playerIllness.symptoms.food)
                PlayAnimation(anim)
                infectPlayers()
            end

        else
            if GetTemperatureAtCoords(GetEntityCoords(playerPed)) + TempCompensation <= Config.ColdTemp then
                if Config.StaminaBorder >= GetAttributeCoreValue(PlayerPedId(), 1) then
                    debugPrint("Stamina: " .. GetAttributeCoreValue(PlayerPedId()))
                    for _, illness in pairs(Config.Illnesses) do
                        local chance = math.random(1, 100)
                        local rain = GetRainLevel() > 0.0
                        local snow = GetSnowLevel() > 0.0
                        local stateChance =
                            Config.stateIllnesses[GetNameOfZone(GetEntityCoords(playerPed))][illness.name]
                        debugPrint("Chance: " .. chance .. " Illness chance: " .. illness.chance .. " State Chance " ..
                                       stateChance)
                        if IsEntityInWater(playerPed) then
                            chance = chance - 30
                        end
                        if rain then
                            chance = chance - 5
                        end
                        if snow then
                            chance = chance - 15
                            -- SetSnowCoverageType(2)
                        end
                        if chance <= illness.chance + stateChance then
                            notify("Najednou se cítíš mizerně, najdi lékaře!")
                            debugPrint("Najednou se cítíš mizerně, najdi lékaře!" .. illness.name)
                            playerIllness = illness
                            TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick", playerIllness)
                            break
                        end
                    end
                end
            end
        end
    end
end)
local function playHealingAnimation(ped,duration)
    local animationDict = "mini_games@story@mob4@heal_jules@bandage@arthur"
    local animationName = "bandage_fast"

    -- Load the animation dictionary
    RequestAnimDict(animationDict)
    while not HasAnimDictLoaded(animationDict) do
        Wait(100)
    end

    -- Play the animation
    TaskPlayAnim(ped, animationDict, animationName, 1.0, 1.0, duration, 1, 0, false, false, false)
end

function healSelf(percent)
    -- Input validation
    if type(percent) ~= "number" or percent <= 0 then
        print("healSelf: Invalid percentage value.")
        return
    end

    local playerPed = PlayerPedId()
    if not DoesEntityExist(playerPed) then
        print("healSelf: Player Ped does not exist.")
        return
    end

    -- Získání aktuálního innerHealth
    local innerHealth = Citizen.InvokeNative(0x36731AC041289BB1, playerPed, 0)
    innerHealth = tonumber(innerHealth) or 0
    innerHealth = math.max(0, math.min(MAX_INNER_HEALTH, innerHealth)) -- Omezení mezi 0 a MAX_INNER_HEALTH

    -- Získání aktuálního entityHealth
    local entityHealth = GetEntityHealth(playerPed)
    entityHealth = tonumber(entityHealth) or 0
    entityHealth = math.max(0, math.min(MAX_ENTITY_HEALTH, entityHealth)) -- Omezení mezi 0 a MAX_ENTITY_HEALTH

    -- Výpočet množství zdraví k přidání
    local innerHealAmount = percent -- InnerHealth max je 100, takže přímo procento
    local entityHealAmount = (percent / 100) * MAX_ENTITY_HEALTH -- Procento z 600

    -- Výpočet nových hodnot zdraví, zajištění nepřekročení maxima
    local newInnerHealth = math.min(MAX_INNER_HEALTH, innerHealth + innerHealAmount)
    local newEntityHealth = math.min(MAX_ENTITY_HEALTH, entityHealth + entityHealAmount)

    -- Zjištění skutečného množství vyléčeného zdraví
    local actualInnerHeal = newInnerHealth - innerHealth
    local actualEntityHeal = newEntityHealth - entityHealth

    -- Kontrola, zda je třeba léčit
    if actualInnerHeal <= 0 and actualEntityHeal <= 0 then
        print("healSelf: Zdraví je již na maximum.")
        return
    end

   

    -- Aktualizace innerHealth
    Citizen.InvokeNative(0xC6258F41D86676E0, playerPed, 0, newInnerHealth)

    -- Aktualizace entityHealth
    SetEntityHealth(playerPed, math.floor(newEntityHealth), playerPed)

    -- Čekání na dokončení léčení (můžete upravit dle potřeby)
    local healingDuration = percent * 1000 -- Např. 15 * 100 = 1500 ms (1.5 sekundy)
     -- Přehrání léčení animace
     playHealingAnimation(playerPed,healingDuration)
    Wait(healingDuration)

    -- Volitelné: Znovu nastavení nebo další akce po léčení
    -- Citizen.InvokeNative(0xC6258F41D86676E0, playerPed, 0, 1) -- Příklad: Reset AttributeCoreValue

    print(string.format("healSelf: Vyléčeno %d%%. Nové Inner Health: %d, Nové Entity Health: %d", percent,
        newInnerHealth, math.floor(newEntityHealth)))
end

function GetClosestPlayer(DoctorPed)
    local players = GetActivePlayers()
    local closestDistance = 2.01
    local closestPlayer = -1

    for index, value in ipairs(players) do
        local target = GetPlayerPed(tonumber(value))
        if (target ~= DoctorPed) then
            local distance = #(GetEntityCoords(GetPlayerPed(value)) - GetEntityCoords(DoctorPed))
            if (closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer
end

function healPatient(percent)
    local DoctorPed = GetPlayerPed(PlayerId())
    local closePlayer = GetClosestPlayer(DoctorPed)
    local closePed = GetPlayerPed(closePlayer)
    local nearestPlayer = GetNearestPlayerToEntity(closePed)
    local nearestPlayerServerId = GetPlayerServerId(nearestPlayer)
    local health = GetEntityHealth(closePed)
    local newHealth = health + percent * 5
    local doctorCoords = GetEntityCoords(DoctorPed)
    local targetPed = GetEntityCoords(closePed)
    local distance = #(doctorCoords - targetPed)

    if distance < 2.0 then
        -- PlayAnim(DoctorPed, "script_mp@player@healing", "healing_male")
        TriggerServerEvent("aprts_medicalAtention:Server:HealPatient", nearestPlayerServerId, newHealth)
    else

        health = GetEntityHealth(DoctorPed)
        newHealth = health + percent * 5
        -- PlayAnim(DoctorPed, "mech_inventory@item@stimulants@inject@quick", "quick_stimulant_inject_rhand")
        SetEntityHealth(DoctorPed, newHealth)
        notify("Léčím na  " .. newHealth)
        -- Citizen.InvokeNative(0xC6258F41D86676E0, DoctorPed, 0, 1)
    end
end

function PatientHealing(value)
    local playerPed = GetPlayerPed(PlayerId())

    SetEntityHealth(playerPed, value)
end

CreateThread(function()
    while true do
        Wait(0)
        local size = GetNumberOfEvents(0)
        if size > 0 then
            for i = 0, size - 1 do
                local event = Citizen.InvokeNative(0xA85E614430EFF816, 0, i) -- GetEventAtIndex
                -- print("Event: " .. event)
                if event == 402722103 then -- EVENT_ENTITY_DAMAGED
                    -- print("Event: " .. event)
                    local eventDataSize = 9
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0) -- damaged                   
                    eventDataStruct:SetInt32(8, 0) -- Cause Ped Id
                    eventDataStruct:SetInt32(16, 0) -- WeaponHash
                    eventDataStruct:SetInt32(24, 0) -- AmmoHash

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        local damaged = eventDataStruct:GetInt32(0)
                        local causePedId = eventDataStruct:GetInt32(8)
                        local weaponHash = eventDataStruct:GetInt32(16)
                        local ammoHash = eventDataStruct:GetInt32(24)
                        if damaged == PlayerPedId() then

                            debugPrint("Cause Ped Id: " .. causePedId)
                            debugPrint("Weapon Hash: " .. weaponHash)
                            debugPrint("Ammo Hash: " .. ammoHash)
                            if weaponHash == GetHashKey("weapon_snake") then
                                local health = GetEntityHealth(PlayerPedId())
                                local newHealth = health - 10
                                SetEntityHealth(PlayerPedId(), newHealth)
                                notify("Kousl tě had!")
                                local chance = math.random(1, 100)
                                if chance <= 50 then
                                    if playerIllness == nil then
                                        playerIllness = Config.Illnesses["badblood"]
                                        TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick", playerIllness)
                                    else
                                        if playerIllness.priority < Config.Illnesses["badblood"].priority then
                                            playerIllness = Config.Illnesses["badblood"]
                                            TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick",
                                                playerIllness)
                                        end
                                    end
                                end
                            end

                        end
                    end
                end
            end
        end
    end
end)
