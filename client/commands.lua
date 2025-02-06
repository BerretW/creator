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
local function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped or PlayerPedId(), false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped or PlayerPedId(), true)
end
local function ApplyShopItemToPed(comp, ped)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, false, false)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, true, false)
end
local function IsPedReadyToRender(ped)
    repeat
        Wait(0)
    until Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped or PlayerPedId())
end

-- RegisterCommand("ApplyShopItemToPed", function(source, args, rawCommand)
--     local ped = PlayerPedId()
--     local item = tonumber("0x" .. args[1])
--     print(item)
--     IsPedReadyToRender()
--     ApplyShopItemToPed(item)
--     UpdatePedVariation()
-- end, false)

-- RegisterCommand("EquipMetaPedOutfit", function(source, args, rawCommand)
--     local ped = PlayerPedId()
--     local outfit = tonumber("0x" .. args[1])
--     print(outfit)
--     EquipMetaPedOutfit(outfit, ped)
--     Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
--     UpdatePedVariation(ped)
--     IsPedReadyToRender(ped)
--     UpdatePedVariation(ped)
-- end, false)
