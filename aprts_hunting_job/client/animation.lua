local runningAnimation = nil
local mainProp = nil
local Anim = Config.Animation

function PlayAnimation(Anim)
    print("Playing animation: " .. Anim.dict)
    if time == nil then
        time = 8000
    end

    EquipTool(Anim.prop)

    StartAnimation(Anim)
    Citizen.Wait(Anim.time)
    EndAnimation()
    if equipProp then
        UnEquipTool()
    end
end

function EquipTool(prop)
    HidePedWeapons(PlayerPedId(), true)
    if mainProp then
        DeleteObject(mainProp)
    end

    print("Equipping tool: " .. prop.model)
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    mainProp = CreateObject(prop.model, x, y, z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(ped, prop.bone)
    AttachEntityToEntity(mainProp, ped, boneIndex, prop.coords.x, prop.coords.y, prop.coords.z, prop.coords.xr,
        prop.coords.yr, prop.coords.zr, true, true, false, true, 1, true)
end

function UnEquipTool()
    if mainProp then
        DeleteEntity(mainProp)
    else
        print("No prop to unequip")
    end
end

function StartAnimation(Anim)
    runningAnimation = Anim
    RequestAnimDict(Anim.dict)
    while not HasAnimDictLoaded(Anim.dict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), Anim.dict, Anim.name, 1.0, 1.0, -1, Anim.flag, 1.0, false, false, false)
end

function EndAnimation(anim)
    if runningAnimation == nil then
        return
    end
    RemoveAnimDict(runningAnimation.dict)
    StopAnimTask(PlayerPedId(), runningAnimation.dict, runningAnimation.name, 1.0)
    runningAnimation = nil
end

function EndAnimations()
    ClearPedTasksImmediately(PlayerPedId())
    runningAnimation = nil
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        EndAnimations()
        UnEquipTool()
    end
end)