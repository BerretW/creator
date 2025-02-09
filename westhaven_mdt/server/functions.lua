function GetCitizensFromStation(station)
  local citizensFiltered = {}
  for _,citizen in pairs (Citizens) do
    if citizen.station == station then
      citizensFiltered[#citizensFiltered+1] = citizen
    end
  end
  return citizensFiltered
end

function GetMDTInventoryName(mdtId)
  return ("mdt:%s"):format(mdtId)
end

function GetStationInventoryName(station)
  return ("fileLocker:%s"):format(station)
end

function GetReportsFromStation(station)
  local reports = {}
  local invName = GetStationInventoryName(station)
  local invItems = jo.framework:getItemsFromInventory(0,invName)
  for _,item in pairs (invItems) do
    if item.item == Config.items.report then
      local metadata = item.metadata
      reports[#reports+1] = Reports[metadata.id]
    end
  end
  return reports
end

function GenerateUniqueMDTId(source)
  local identifiers = jo.framework:getUserIdentifiers(source)
  return identifiers.identifier:sub(-8)..':'..identifiers.charid .. ':'..os.time()
end

function GetReportsFromPlayer(mdtId)
  local reports = {}
  local invName = GetMDTInventoryName(mdtId)
  local invItems = jo.framework:getItemsFromInventory(0,invName)
  for _,item in pairs (invItems) do
    if item.item == Config.items.report then
      local metadata = item.metadata
      reports[#reports+1] = Reports[metadata.id]
    end
  end
  return reports
end

function GetConfigForLocker()
  return {
    maxSlots = 1000,
    maxWeight = 10000,
    acceptWeapons = false,
    shared = true,
    ignoreStackLimit = true,
    whitelist = {
      {item = Config.items.report, limit = 10000}
    }
  }
end