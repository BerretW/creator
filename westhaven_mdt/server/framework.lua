-------------
-- When item is removed from locker
-------------
RegisterServerEvent("vorp_inventory:TakeFromCustom")
AddEventHandler("vorp_inventory:TakeFromCustom", function(obj)
  local source = source
  if not MDTInventoryOpened[source] then return end
  if not Config.keepReportInsideMDTInventoryWhenDrag then return end
  local data = json.decode(obj)
  ItemTransfered[source] = data
end)