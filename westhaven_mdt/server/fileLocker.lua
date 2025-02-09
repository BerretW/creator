FileLockerOpened = {}

RegisterServerEvent("westhaven_mdt:server:openFileLocker")
AddEventHandler("westhaven_mdt:server:openFileLocker", function(id)
  local source = source
  local invConfig = GetConfigForLocker()
  local invName = GetStationInventoryName(id)
  local name = __('fileLocker')
  jo.framework:createInventory(invName,name,invConfig)
  jo.framework:openInventory(source,invName,name,invConfig,whitelist)
  FileLockerOpened[source] = invName
end)

RegisterServerEvent(GetCurrentResourceName()..":server:closeInventory", function()
  local source = source
  if not FileLockerOpened[source] then return end
  jo.framework:removeInventory(FileLockerOpened[source])
  FileLockerOpened[source] = nil
end)