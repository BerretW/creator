if Config.Debug then
    TriggerEvent("chat:addSuggestion", "/" .. "isOnline", "zkontrouje jestli je hřáč online", {})
    RegisterCommand("isOnline", function(source, args, rawCommand)

        if Player(args[1]).state.IsInSession then
            TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "Hráč je online")
        else
            TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "Hráč není online")
        end

    end, false)
end
