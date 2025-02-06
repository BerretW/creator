
RegisterCommand("startCreator", function(source, args, rawCommand)

    ShutdownLoadingScreen()
    ShowBusyspinnerWithText("Nahrává se tvorba postavy")
    Wait(500)
    InCharacterCreator = true
    Wait(2000)
    BusyspinnerOff()
    DoScreenFadeIn(1000)
    -- exports.weathersync:setSyncEnabled(true)
    Setup()
end, false)

RegisterNetEvent("vorpcharacter:startCharacterCreator")
AddEventHandler("vorpcharacter:startCharacterCreator", function()

    DoScreenFadeOut(1000)
    Wait(1000)

    ShutdownLoadingScreen()
    ShowBusyspinnerWithText("Nahrává se tvorba postavy")
    Wait(500)
    InCharacterCreator = true
    Wait(2000)
    BusyspinnerOff()
    DoScreenFadeIn(1000)
    -- exports.weathersync:setSyncEnabled(true)
    Setup()
end)
