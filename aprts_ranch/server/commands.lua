-- příkaz na vynucení updatu zvířat
RegisterCommand("updateAnimals", function(source, args, rawCommand)

    local _source = source
    -- notify(_source, "Probíhá update zvířat")
    for railing_id, railing in pairs(railings) do
        -- Získej zvířata v ohradě
        -- notify(_source, "Probíhá update zvířat v ohradě " .. railing_id)

        local animalsInRailing = getAnimalsInRailing(railing_id)
        for _, animal in pairs(animalsInRailing) do
            debugPrint("Update zvířete " .. animal.id)
            -- notify(_source, "U zvířete " .. animal.id .. " proběhl update hodnot")
            updateAnimalStats(animal)
        end

        checkForBreeding(railing_id, animalsInRailing)
    end
end, false)
