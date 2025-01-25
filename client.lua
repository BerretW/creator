-- client.lua
local Debug = false
-- Otevření knihy
RegisterNetEvent('books:openBook')
AddEventHandler('books:openBook', function(bookData)
    local pdfUrl = bookData.pdf_url

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openBook',
        pdfUrl = pdfUrl
    })
end)

-- Callback pro zavření NUI knihy
RegisterNUICallback('closeBook', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Callback pro zavření formuláře nové knihy
RegisterNUICallback('closeBookForm', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Callback pro uložení nové knihy
RegisterNUICallback('saveNewBook', function(data, cb)
    local title = data.title
    local author = data.author
    local pdfUrl = data.pdfUrl

    -- Validace vstupů
    if title == '' or author == '' or pdfUrl == '' then
        TriggerEvent('chat:addMessage', {
            args = {'^1[Chyba]', 'Prosím, vyplň všechny údaje.'}
        })
        cb('error')
        return
    end

    -- Pošleme data na server pro uložení
    TriggerServerEvent('books:saveNewBook', title, author, pdfUrl)
    cb('ok')
end)
if Debug == true then

    -- Příkaz pro zobrazení seznamu knih
    RegisterCommand('knihy', function()
        -- Požádáme server o seznam knih
        TriggerServerEvent('books:getBookList')
    end)

    -- Přidáme příkaz 'kniha' pro otevření knihy podle ID
    RegisterCommand('kniha', function(source, args, rawCommand)
        local idknihy = tonumber(args[1])
        if idknihy then
            TriggerServerEvent('books:getBook', idknihy)
        else
            TriggerEvent('chat:addMessage', {
                args = {'^1[Chyba]', 'Zadejte platné ID knihy.'}
            })
        end
    end)
    -- Otevření formuláře pro novou knihu
    RegisterCommand('novakniha', function()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openNewBookForm'
        })
    end)

end
-- Event pro zobrazení seznamu knih
RegisterNetEvent('books:sendBookList')
AddEventHandler('books:sendBookList', function(books)
    -- Zobrazíme seznam knih v chatu a umožníme hráči vybrat knihu
    TriggerEvent('chat:addMessage', {
        args = {'^2[Seznam knih]'}
    })
    for i, book in ipairs(books) do
        TriggerEvent('chat:addMessage', {
            args = {'^3[' .. book.id .. ']', book.title .. ' od ' .. book.author}
        })
    end

    -- Požádáme hráče o výběr knihy
    Citizen.CreateThread(function()
        Citizen.Wait(100)
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 2)

        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Citizen.Wait(0)
        end

        if GetOnscreenKeyboardResult() then
            local result = GetOnscreenKeyboardResult()
            local bookIndex = tonumber(result)

            if bookIndex then
                -- Pošleme žádost na server o otevření knihy
                local idknihy = tonumber(bookIndex)
                TriggerServerEvent('books:getBook', idknihy)
            else
                TriggerEvent('chat:addMessage', {
                    args = {'^1[Chyba]', 'Neplatný výběr.'}
                })
            end
        end
    end)
end)
