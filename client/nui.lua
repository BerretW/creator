-- client/nui.lua
local nuiOpen = false
local currentDiaryData = {}
local currentColors = {}
local currentPage = 1
local nuiFocus = false
local pageCount = 0
local hasPen = false

function openDiaryNUI(data, colors)
    if nuiOpen then
        closeDiaryNUI()
        return
    end
    currentDiaryData = data
    currentColors = colors
    currentPage = 1
    pageCount = data.pages
    nuiOpen = true
    SendNUIMessage({
        action = "open",
        data = currentDiaryData,
        colors = currentColors,
        page = currentPage,
        pageCount = pageCount
    })
    SetNuiFocus(true, true)
    nuiFocus = true

end

function closeDiaryNUI()
    if not nuiOpen then
        return
    end
    nuiOpen = false
    currentDiaryData = {}
    currentColors = {}
    currentPage = 1
    pageCount = 0
    SendNUIMessage({
        action = "close"
    })
    SetNuiFocus(false, false)
    nuiFocus = false
end

function updatePageInUI(page)
    currentPage = page
    SendNUIMessage({
        action = "updatePage",
        page = currentPage
    })
end
RegisterNUICallback('saveData', function(data)
    currentDiaryData = data
    debugPrint("Data: " .. json.encode(currentDiaryData))
    -- Zde bude logika pro uložení dat deníku zpět do itemu
end)
RegisterNUICallback('changePage', function(direction)
    if direction == 'next' then
        if currentPage < pageCount then
            updatePageInUI(currentPage + 1)
        end
    elseif direction == 'prev' then
        if currentPage > 1 then
            updatePageInUI(currentPage - 1)
        end
    end
end)

RegisterNUICallback('nuiFocus', function(focus)
    nuiFocus = focus
end)

RegisterNUICallback('close', function()
    closeDiaryNUI()
end)
RegisterNetEvent('aprts_diary:Client:openDiary')
AddEventHandler('aprts_diary:Client:openDiary', function(data, colors)
    debugPrint("Opening diary")
    debugPrint("Data: " .. json.encode(data))
    openDiaryNUI(data, colors)
end)

Citizen.CreateThread(function()
    while true do
        local pause = 10
        if nuiFocus then
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            if IsControlJustReleased(0, 200) then
                SendNUIMessage({
                    action = 'changePage',
                    direction = 'prev'
                })
            end
            if IsControlJustReleased(0, 201) then
                SendNUIMessage({
                    action = 'changePage',
                    direction = 'next'
                })
            end
        else
            if nuiOpen then
                closeDiaryNUI()
            end

        end
        Citizen.Wait(pause)
    end
end)
