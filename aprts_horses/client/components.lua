function createComponentsMenu()
    
    local horse = myHorse.ped
    if not horse then
        return
    end
    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(horse), true) > 5.0 then
        return
    end
    local menuUD = "menu_" .. horse
    local mainMenu = jo.menu.create(menuUD, {
        title = "Tvůj Kůň",
        onEnter = function()
            
        end,
        onBack = function()
            jo.menu.show(false)
            FreezeEntityPosition(PlayerPedId(), false)
        end,
        onExit = function()
           
        end
    })
    for cat, comp in pairs(myHorseComp) do
        if comp ~= 0 then
            mainMenu:addItem({
                title = cat,

                onClick = function()
                    local options = {{
                        label = "Ano",
                        value = true,
                        image = "check.png"
                    }, {
                        label = "Ne",
                        value = false,
                        image = "cross.png"
                    }}
                    local timeout = 10000
                    local backgroundImage = "black_paper.png"

                    local answer = exports.aprts_inputButtons:getAnswer("Chceš odebrat tuto součást?", options,
                        timeout, backgroundImage)
                    if answer == true then
                        myHorseComp[cat] = 0
                        SetRandomOutfitVariation(myHorse.ped, true)
                        if myHorseComp then
                            for k, v in pairs(myHorseComp) do
                                ApplyShopItemToPed(myHorse.ped, v, true, true, true)
                            end
                        end
                        TriggerServerEvent("aprts_horses:equipHorseComponent", myHorse.id, myHorseComp)
                        TriggerServerEvent("aprts_horses:Server:returnComp", comp)
                        jo.menu.show(false)
                        FreezeEntityPosition(PlayerPedId(), false)
                    end
                end,
                onBack = function()
                    jo.menu.show(false)
                    FreezeEntityPosition(PlayerPedId(), false)
                end
            })
        end
    end

    mainMenu:send()
    FreezeEntityPosition(PlayerPedId(), true)
    local keepHistoric = false
    local resetMenu = true
    jo.menu.setCurrentMenu(menuUD, keepHistoric, resetMenu)
    jo.menu.show(true)
end
