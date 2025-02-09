function DefaultCb(cb)
  cb({ok=true})
end

function manageDisplayMDT(value)
  if not jo.hook.applyFilters('canOpenMDT',true) then
    return
  end
  MDTOpen = value
	if not LangInitialize then
		Lang = jo.hook.applyFilters('updateLangForNUI',Lang)
		SendNUIMessage({
      event="updateLang",
      data = {
        lang = Lang
      }
    })
    SendNUIMessage({
      event="updateConfiguration",
      data = {
        needInventory = Config.reportSyncMode == "mdt"
      }
    })
      SendNUIMessage({
        event="updateType",
        data = {
          type = "sheriff"
        }
      })
      SendNUIMessage({
        event="updateSheriff",
        data = {
          sheriff = {
            id = LocalPlayer.state.Character.CharId,
            grade = LocalPlayer.state.Character.Grade
          }
        }
      })
      SendNUIMessage({
      event="updateGapBetweenYears",
      data = {year = Config.gapWithRealYear}
    })
		LangInitialize = true
		Wait(100)
	end
	if not value then
		SetNuiFocus(false, false)
	else
		StartClipboardAnimation()
    UpdateMDTData()
		SetNuiFocus(true, true)
	end
	SendNUIMessage({
    event = 'show',
    data = {value = value}
  })
end

CreateThread(function()
	ClearPedTasksImmediately(PlayerPedId())
end)

function ShowMDT()
  return manageDisplayMDT(true)
end

function HideMDT()
  return manageDisplayMDT(false)
end

RegisterNUICallback('close', function(data,cb)
  DefaultCb(cb)
  HideMDT()
end)

RegisterNUICallback('switchUpDown', function(data,cb)
  DefaultCb(cb)
  if data.isDown then
		SetNuiFocus(false, false)
    jo.prompt.create('interaction', __('backToClipboard'), Config.keys.backToClipboard, 500)
    jo.prompt.create('interaction', __('close'), "INPUT_FRONTEND_CANCEL", 500)
    CreateThread(function()
      while true do
        if jo.prompt.isCompleted('interaction',Config.keys.backToClipboard) then
          while IsDisabledControlPressed(0,joaat(Config.keys.backToClipboard)) or IsControlPressed(0,joaat(Config.keys.backToClipboard)) do
            Wait(100)
          end
		      SetNuiFocus(true, true)
          SendNUIMessage({
            event = 'switchUpDown'
          })
          break
        end
        if jo.prompt.isCompleted('interaction',"INPUT_FRONTEND_CANCEL") then
          HideMDT()
          break
        end
        Wait(100)
      end
      jo.prompt.deleteGroup('interaction')
    end)
  end
end)

RegisterNUICallback('saveCitizen', function(data,cb)
  jo.callback.triggerServer("westhaven_mdt:server:saveCitizen",function(success,citizenId)
    if not success then
      cb({success = false})
    else
      cb({success = true, id = citizenId})
    end
  end, data)
end)

RegisterNUICallback('saveReport', function(data,cb)
   jo.callback.triggerServer("westhaven_mdt:server:saveReport",function(success,reportId)
    if not success then
      cb({success = false})
    else
      cb({success = true, id = reportId})
    end
  end, data)
end)

RegisterNUICallback('saveCase', function(data,cb)
  jo.callback.triggerServer("westhaven_mdt:server:saveCase",function(success,caseId)
    if not success then
      cb({success = false})
    else
      cb({success = true, id = caseId})
    end
  end, data)
end)

RegisterNUICallback('openMDTInventory', function(data,cb)
  DefaultCb(cb)
  HideMDT()
  TriggerServerEvent("westhaven_mdt:server:openMDTInventory")
end)

RegisterNUICallback('deleteReport', function(data,cb)
  jo.callback.triggerServer('westhaven_mdt:server:deleteReport', function(success)
    cb({success = success})
  end, data.id)
end)

RegisterNUICallback('deletePicture', function(data,cb)
  jo.callback.triggerServer('westhaven_mdt:server:deletePicture', function(success)
    cb({success=success})
  end,data.citizenID,data.side)
end)