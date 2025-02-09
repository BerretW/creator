jo.callback.register("westhaven_mdt:server:saveReport", function(source,data)
  if data.id == "new" then
    local reportID = MySQL.insert.await('INSERT INTO westhaven_mdt_reports (citizen,title,summary,content) VALUES (@citizen,@title,@summary,@content)', {
      citizen = data.citizen,
      title = data.title,
      summary = data.summary,
      content = data.content,
    })
    data.id = reportID
    Reports[tonumber(data.id)] = data
    local metadata = {
      id = data.id,
      description = __('reportItemDesc'):format(reportID,data.title)
    }
    if Config.reportSyncMode == "mdt" then
      local invName = GetMDTInventoryName(CurrentMDTIds[source])
      jo.framework:addItemInInventory(source,invName,Config.items.report,1,metadata,false)
    elseif Config.reportSyncMode == "station" then
       local invName = GetStationInventoryName(CurrentMDTStations[source])
      jo.framework:addItemInInventory(source,invName,Config.items.report,1,metadata,false)
    end
    return true,reportID
  else
    local query = ""
    query = "UPDATE westhaven_mdt_reports SET dateUpdated = NOW(),"
    for key,_ in pairs (data) do
      if key ~= "id" and key ~= "dateUpdated" then
        query = query .. key .. " = @"..key..","
      end
    end
    query = query:sub(0,query:len() - 1)
    query = query .. " WHERE id = @id"
    MySQL.update.await(query,data)
    Reports[tonumber(data.id)] = table.merge(Reports[tonumber(data.id)], data)
    return true
  end
end)

jo.callback.register('westhaven_mdt:server:deleteReport', function(source,id)
  if not jo.hook.applyFilters('canDeleteReport',true,source,id) then
    return false
  end
  MySQL.update('DELETE FROM westhaven_mdt_reports WHERE id = ?',{id})
  Reports[tonumber(id)] = nil
  return true
end)