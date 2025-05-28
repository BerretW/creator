local Prompt = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local Progressbar = exports["feather-progressbar"]:initiate()
local menuOpen = false
lostAnimals = {}

local function prompt()
    Citizen.CreateThread(function()
        local str = "Otevřít"
        local wait = 0
        Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        PromptSetHoldMode(Prompt, true)
        PromptSetGroup(Prompt, promptGroup)
        PromptRegisterEnd(Prompt)
    end)
end

local function OpenShellterMenu(coords)
    menuOpen = true
    FreezeEntityPosition(PlayerPedId(), true)
    local id = "shellter_menu"

    local mainMenu = jo.menu.create(id, {
        title = "VyberZvíře",
        onEnter = function()
        end,
        onBack = function()
            jo.menu.show(false)
            menuOpen = false
            FreezeEntityPosition(PlayerPedId(), false)
        end,
        onExit = function()
        end
    })
    if table.count(lostAnimals) > 0 then

        for _, animal in pairs(lostAnimals) do
            local animalCfg = Config.Animals[animal.breed]

            if animal.age < animalCfg.dieAge then
                local price = (animalCfg.dieAge - animal.age) * 10
                mainMenu:addItem({
                    title = animal.name or animal.breed,
                    description = (animal.name or animal.breed) .. " Druh: " .. animal.breed .. " Věk: " .. animal.age,
                    price = {
                        money = price
                    },
                    onActive = function(currentData)

                    end,
                    onClick = function(currentData)
                        if price <= LocalPlayer.state.Character.Money then

                            TriggerServerEvent("aprts_ranch:Server:takeAnimal", animal.id, true, coords)
                            TriggerServerEvent("aprts_ranch:Server:removeMoney", price)
                        else
                            notify("Nemáš dostatek peněz.")

                        end
                        FreezeEntityPosition(PlayerPedId(), false)
                        jo.menu.show(false)
                        Wait(1000)
                        menuOpen = false
                    end,
                    onChange = function(currentData)

                    end,
                    onExit = function(currentData)

                    end
                })
            end
        end

        mainMenu:send()

        jo.menu.setCurrentMenu(id)
        jo.menu.show(true)
    else
        menuOpen = false
        FreezeEntityPosition(PlayerPedId(), false)
        notify("Nemáš žádné zvíře, které bys mohl vzít z útulku.")
    end
end
local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end
local function spawnNPC(model, x, y, z, h)
    local modelHash = LoadModel(model)
    local npc_ped = CreatePed(model, x, y, z, false, false, false, false)
    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    -- print('npc_ped: ' .. npc_ped)
    SetEntityHeading(npc_ped, h or 0.0)
    SetEntityCanBeDamaged(npc_ped, false)
    SetEntityInvincible(npc_ped, true)
    FreezeEntityPosition(npc_ped, true)
    SetBlockingOfNonTemporaryEvents(npc_ped, true)
    SetEntityCompletelyDisableCollision(npc_ped, false, false)

    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 6)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 0)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 1)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 2)

    SetModelAsNoLongerNeeded(modelHash)
    return npc_ped
end
local function handleNPC(playerPos)
    for _, shellter in ipairs(Config.Shelters) do
        local distance = #(playerPos - shellter.npcCoords)
        if distance < Config.RenderDistance then
            if not DoesEntityExist(shellter.npc) then
                shellter.npc = spawnNPC(shellter.model, shellter.npcCoords.x, shellter.npcCoords.y,
                    shellter.npcCoords.z, shellter.heading)
            end
        else
            if DoesEntityExist(shellter.npc) then
                DeleteEntity(shellter.npc)
                shellter.npc = nil
            end
        end
    end
end

Citizen.CreateThread(function()
    prompt()
    while true do
        local pause = 1000
        if menuOpen == false then

            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed, false)
            handleNPC(playerPos)
            for _, shellter in ipairs(Config.Shelters) do
                local distance = #(playerPos - shellter.npcCoords)
                if distance < 1.5 then
                    if Config.Job == LocalPlayer.state.Character.Job then

                        local name = CreateVarString(10, 'LITERAL_STRING', "Útulek")
                        PromptSetActiveGroupThisFrame(promptGroup, name)

                        if PromptHasHoldModeCompleted(Prompt) then
                            Citizen.Wait(1000)
                            OpenShellterMenu(shellter.coords)
                        end
                        pause = 0
                    end
                end
            end
        end
        Citizen.Wait(pause)
    end
end)

RegisterNetEvent("aprts_ranch:Client:removeLostAnimal")
AddEventHandler("aprts_ranch:Client:removeLostAnimal", function(id)
    -- notify("Zvíře bylo úspěšně vzato z útulku.")
    lostAnimals[id] = nil
end)
