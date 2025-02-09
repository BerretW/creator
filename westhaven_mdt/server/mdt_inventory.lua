RegisterServerEvent(GetCurrentResourceName()..":server:closeInventory", function()
  local source = source
  if not MDTInventoryOpened[source] then return end
  jo.framework:removeInventory(MDTInventoryOpened[source])
  MDTInventoryOpened[source] = nil
end)

RegisterServerEvent("westhaven_mdt:server:openMDTInventory")
AddEventHandler("westhaven_mdt:server:openMDTInventory", function(_source)
  local source = _source or source
  if (not source) then return end
  if (not CurrentMDTIds[source]) then return end

  local invName = GetMDTInventoryName(CurrentMDTIds[source])
  MDTInventoryOpened[source] = invName
  local name = __('mdt')
  local config = GetConfigForLocker()
  jo.framework:createInventory(invName,name,config)
  jo.framework:openInventory(source,invName)
end)

RegisterServerEvent("westhaven_mdt:server:removeItem")
AddEventHandler("westhaven_mdt:server:removeItem", function(name,id,count,metadata)
  local source = source
  if not MDTInventoryOpened[source] then return end
  if not ItemTransfered[source] then return end
  if ItemTransfered[source].id ~= GetMDTInventoryName(CurrentMDTIds[source]) then return end
  ItemTransfered[source] = false
  jo.framework:removeInventory(MDTInventoryOpened[source])
  local invName = GetMDTInventoryName(CurrentMDTIds[source])
  jo.framework:addItemInInventory(source,invName,Config.items.report,1,metadata,true)
  TriggerEvent("westhaven_mdt:server:openMDTInventory",source)
end)