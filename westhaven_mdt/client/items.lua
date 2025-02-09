RegisterNetEvent("westhaven_mdt:client:useMDT", function(metadata)
  if Config.citizensSyncMode == "station" and not metadata.station then
    return eprint('Metadata is missing !')
  end
  ShowMDT()
end)
