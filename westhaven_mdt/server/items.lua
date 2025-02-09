if Config.openingMode == "item" then
  MySQL.ready(SetTimeout(1000, function()
    jo.framework:registerUseItem(Config.items.mdt, true, function(source,data)
      CurrentMDTIds[source] = data.metadata.mdt_id
      CurrentMDTStations[source] = data.metadata.station
      TriggerClientEvent('westhaven_mdt:client:useMDT',source,data.metadata)
      return true
    end)
  end)
  )
end