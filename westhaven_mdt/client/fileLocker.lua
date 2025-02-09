local InFileLockerZone = false

if Config.openingMode == "command" then return end
if Config.reportSyncMode == "global" then return end

local function LoopStations()
  for key,station in ipairs (Config.stations) do
    while #(jo.meCoords - station.location) < station.distancePrompt do
      if not InFileLockerZone then
        InFileLockerZone = true
        jo.callback.triggerServer('westhaven_mdt:server:canManageFileLocker', function(canManage)
          if canManage then
            if Config.reportSyncMode == "mdt" then
              jo.prompt.create('interaction',__('openFileLocker'),Config.keys.fileLockerAccess,500)
            end
            if Config.openingMode == "item" then
              jo.prompt.create('interaction',__('getMDT'),Config.keys.getMDT,500)
            end
          end
        end, key)
      end
      if jo.prompt.isCompleted('interaction',Config.keys.fileLockerAccess) then
        jo.prompt.waitRelease(Config.keys.fileLockerAccess)
        openFileLocker(station.id)
      end
      if jo.prompt.isCompleted('interaction', Config.keys.getMDT) then
        TriggerServerEvent("westhaven_mdt:server:giveMDT",key)
      end
      Wait(100)
    end
    if InFileLockerZone then
      InFileLockerZone = false
      jo.prompt.deleteGroup('interaction')
    end
  end
  SetTimeout(1000,LoopStations)
end
SetTimeout(1000,LoopStations)

function openFileLocker(id)
  TriggerServerEvent("westhaven_mdt:server:openFileLocker",id)
end