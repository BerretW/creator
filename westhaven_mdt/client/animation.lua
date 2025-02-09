local AnimationData = {
  look = {
    dict = "amb_work@world_human_clipboard@male_a@react_look@active_look",
    name_prefix = "active_look_"
  },
  clipboardModel = 'p_clipboard02x',
  pensilModel = 'p_pen01x',
  props = {},
  processing = false,
  lastLook = ""
}

local function DeleteAnimationProps()
  for _,entity in pairs (AnimationData.props) do
    jo.entity.delete(entity)
  end
  AnimationData.props = {}
end

local function PlayAnimationDirection(direction)
  if AnimationData.lastLook == direction then return end
  AnimationData.lastLook = direction
  TaskPlayAnim(jo.me, AnimationData.look.dict, AnimationData.look.name_prefix..direction, 1.0,1.0, -1, 25, 0.1, false, 0, false)
end

function StopClipboardAnimation()
  AnimationData.processing = false
  AnimationData.lastLook = ''
  ClearPedTasks(jo.me)
  jo.utils.releaseGameData(AnimationData.look.dict)
  Wait(700)
  DeleteAnimationProps()
end

function StartClipboardAnimation()
  CreateThread(function()
    if AnimationData.processing then return end
    AnimationData.processing = true

    jo.utils.loadGameData(AnimationData.look.dict,true)
    jo.utils.loadGameData(AnimationData.clipboardModel, true)
    jo.utils.loadGameData(AnimationData.pensilModel, true)

    local clipboard = CreateObject(AnimationData.clipboardModel, GetEntityCoords(jo.me), true, true, false)
    table.insert(AnimationData.props,clipboard)
	  local boneIndex = GetEntityBoneIndexByName(jo.me, "SKEL_L_HAND")
    AttachEntityToEntity(clipboard, jo.me, boneIndex, 0.15, 0.04, 0.15, 210.0, 270.0, -20.0, true, true, false, true,  1, true)
    jo.utils.releaseGameData(AnimationData.clipboardModel)

    local pensil = CreateObject(AnimationData.pensilModel, GetEntityCoords(jo.me), true, true, false)
    table.insert(AnimationData.props,pensil)
	  boneIndex = GetEntityBoneIndexByName(jo.me, "SKEL_R_HAND")
    AttachEntityToEntity(pensil, jo.me, boneIndex, 0.08, 0.04, -0.1, 0.0, 0.0, 0.0, true, true, false, true,  1, true)
    jo.utils.releaseGameData(AnimationData.pensilModel)

    while MDTOpen do
      local camR = GetGameplayCamRelativeHeading()
      if camR < -45 then --look right
        PlayAnimationDirection("right")
      elseif camR > 45 then --look left
        PlayAnimationDirection("left")
      else
        PlayAnimationDirection("front")
      end
      Wait(100)
    end
    StopClipboardAnimation()
  end)
end

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  DeleteAnimationProps()
end)