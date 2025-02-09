if (Config.openingMode == "command") then
  if (Config.citizensSyncMode == "station") then
    eprint('Config.citizensSyncMode = "station" only compatible with Config.openingMode = "item"')
  end
  if (Config.reportSyncMode == "station") then
    eprint('Config.reportSyncMode = "station" only compatible with Config.openingMode = "item"')
  end
end

RegisterServerEvent("westhaven_mdt:server:UpdateMDTData", function(ClosestStation)
  local source = source
  local citizensFiltered = {}
  if Config.citizensSyncMode == "global" then
    citizensFiltered = Citizens
  else
    citizensFiltered = GetCitizensFromStation(CurrentMDTStations[source])
  end

  local reportsFiltered = {}
  if Config.reportSyncMode == "global" then
    for _,data in pairs (Reports) do
      reportsFiltered[#reportsFiltered+1] = data
    end
  elseif Config.reportSyncMode == "station" then
    reportsFiltered = GetReportsFromStation(CurrentMDTStations[source])
  elseif Config.reportSyncMode == "mdt" then
    reportsFiltered = GetReportsFromPlayer(CurrentMDTIds[source])
    if ClosestStation then
      local reportsStation = GetReportsFromStation(ClosestStation)
      for _,data in pairs (reportsStation) do
        local found = false
        for _,data2 in pairs (reportsFiltered) do
          if data2.id == data.id then
            found = true
            break
          end
        end
        if not found then
          reportsFiltered[#reportsFiltered+1] = data
        end
      end
    end
  end

  TriggerClientEvent("westhaven_mdt:client:updateMDTData",source,citizensFiltered,reportsFiltered,Sheriffs, Cases)
end)

jo.callback.register('westhaven_mdt:server:canManageFileLocker',  function(source,key)
  local source = source
  local playerJob = jo.framework:getJob(source)
  local canManage = #Config.stations[key].jobs == 0
  for _,job in pairs (Config.stations[key].jobs) do
    if job == playerJob then
      canManage = true
      break
    end
  end
  canManage = jo.hook.applyFilters('canManageFileLocker',canManage,source)
  return canManage
end)

RegisterServerEvent("westhaven_mdt:server:giveMDT")
AddEventHandler("westhaven_mdt:server:giveMDT", function(key)
  local source = source
  if not jo.hook.applyFilters('canGetMDT',true,source,key) then return end

  local station = Config.stations[key]
  local metadata = {
    station=station.id,
    mdt_id = GenerateUniqueMDTId(source),
    description = __('mdtDescription'):format(station.name)
  }
  jo.framework:giveItem(source,Config.items.mdt,1,metadata)
  jo.notif.rightSuccess(source,__('mdtGot'))
end)