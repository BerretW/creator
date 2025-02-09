jo.callback.register("westhaven_mdt:server:saveCitizen", function(source,data)
  data.station = CurrentMDTStations[source] or "global"
  if data.id == "new" then
    local citizenID = MySQL.insert.await('INSERT INTO westhaven_mdt_citizens VALUES (NULL,@station,@firstname,@lastname,@alias,@age,@eyecolor,@haircolor,@marks,@pictureFace,@pictureSide)', data)
    data.id = citizenID
    Citizens[#Citizens+1] = data
    return true,citizenID
  else
    local query = ""
    query = "UPDATE westhaven_mdt_citizens SET "
    for key,_ in pairs (data) do
      if key ~= "id" then
        query = query .. key .. " = @"..key..","
      end
    end
    query = query:sub(0,query:len() - 1)
    query = query .. " WHERE id = @id"
    MySQL.update.await(query,data)
    for key,citizen in pairs (Citizens) do
      if tonumber(citizen.id) == tonumber(data.id) then
        Citizens[key] = table.merge(citizen, data)
        break
      end
    end
    return true
  end
end)

jo.callback.register('westhaven_mdt:server:deletePicture', function(source,citizenID,side)
  if not jo.hook.applyFilters('deletePicture',true,source,citizenID,side) then
    return false
  end

  MySQL.update('UPDATE westhaven_mdt_citizens SET '..side..' = "" WHERE id = ?',{citizenID})
  for key,citizen in pairs (Citizens) do
    if tonumber(citizen.id) == tonumber(citizenID) then
      Citizens[key][side] = ''
      break
    end
  end
  return true
end)