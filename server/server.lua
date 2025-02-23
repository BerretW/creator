function notifyClient(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "Prodej", message, 4000)
end

