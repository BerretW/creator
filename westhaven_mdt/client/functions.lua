function UpdateMDTData()
  jo.forceUpdateMe()
   for _,station in pairs (Config.stations) do
    if #(jo.meCoords-station.location) < station.distanceSync then
      return TriggerServerEvent("westhaven_mdt:server:UpdateMDTData",station.id)
    end
  end
  TriggerServerEvent("westhaven_mdt:server:UpdateMDTData",false)
end