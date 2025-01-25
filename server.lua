-- server.lua
-- Inicializace databáze
-- MySQL.ready(function()
--     -- Vytvoříme tabulku pro knihy, pokud neexistuje
--     MySQL.Async.execute([[
--         CREATE TABLE IF NOT EXISTS books (
--             `id` int(11) NOT NULL AUTO_INCREMENT,
--             `item` varchar(255) DEFAULT '',
--             `title` varchar(255) NOT NULL,
--             `author` varchar(255) NOT NULL,
--             `pdf_url` varchar(500) NOT NULL,
--             PRIMARY KEY (`id`)
--             ) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
--             SET FOREIGN_KEY_CHECKS=1;
--     ]], {}, function(rowsChanged)
--         print('[Books] Tabulka knih je připravena.')
--     end)
-- end)
local MySQL = exports.oxmysql
local books = {}
-- Event pro uložení nové knihy
RegisterNetEvent('books:saveNewBook')
AddEventHandler('books:saveNewBook', function(title, author, pdfUrl)
    local _source = source

    MySQL:execute('INSERT INTO books (title, author, pdf_url) VALUES (@title, @author,@pdf) RETURNING id', {
        ['@title'] = title,
        ['@author'] = author,
        ['@pdf'] = pdfUrl
    }, function(result)
        MySQL:execute("UPDATE books SET item = 'book_" .. result[1].id .. "' WHERE id = @id", {
            ['@id'] = result[1].id
        })
        TriggerClientEvent('chat:addMessage', _source, {
            args = {'^2[Knihy]', 'Kniha ' .. title .. ' byla úspěšně vytvořena.'}
        })
    end)

    -- insert new book and add item

end)

-- Event pro získání seznamu knih
RegisterNetEvent('books:getBookList')
AddEventHandler('books:getBookList', function()
    local _source = source

    MySQL:execute('SELECT * FROM books', {}, function(results)
        TriggerClientEvent('books:sendBookList', _source, results)
        books = results
    end)
end)

-- Event pro získání dat knihy
RegisterNetEvent('books:getBook')
AddEventHandler('books:getBook', function(bookId)
    local _source = source

    MySQL:execute('SELECT * FROM books WHERE id = @id', {
        ['@id'] = bookId
    }, function(results)
        if results[1] then
            TriggerClientEvent('books:openBook', _source, results[1])
        else
            TriggerClientEvent('chat:addMessage', _source, {
                args = {'^1[Chyba]', 'Kniha nenalezena.'}
            })
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    MySQL:execute('SELECT * FROM books', {}, function(results)
        books = results
        for _, book in ipairs(books) do
            if book.item then
                exports.vorp_inventory:registerUsableItem(book.item, function(data)
                    local _source = data.source
                    exports.vorp_inventory:closeInventory(data.source)
                    TriggerClientEvent('books:openBook', _source, book)
                    print('open book' .. book.id)
                end)
            end
        end
    end)
end)
