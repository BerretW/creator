-- File: editor.lua

RegisterCommand("editattach", function()
    local equippedItems = {}
    for item, data in pairs(equipedAttachments) do
        table.insert(equippedItems, item)
    end

    if #equippedItems == 0 then
        notify("Nemáte nasazené žádné attachmenty.")
        return
    end

    -- Vytvoření menu pro výběr attachmentu
    local attachmentEditorMenu = jo.menu.create("attachmentEditor", {
        title = "Editor Attachmentů",
        subtitle = "Vyberte attachment pro úpravu"
    })

    for _, item in ipairs(equippedItems) do
        attachmentEditorMenu:addItem({
            title = item,
            type = "button",
            onClick = function()
                openAttachmentMenu(item)
            end
        })
    end

    -- Přidání položky pro zavření menu
    attachmentEditorMenu:addItem({
        title = "Zavřít",
        type = "button",
        onClick = function()
            attachmentEditorMenu:close()
        end
    })

    attachmentEditorMenu:send()

    jo.menu.setCurrentMenu("attachmentEditor")
    jo.menu.show(true)
end, false)

function openAttachmentMenu(item)
    local Tool = Config.Items[item]
    if not Tool then
        notify("Neplatný attachment.")
        return
    end

    -- Načtení vlastní pozice a rotace z KVP (Key-Value Pairs)
    local customPos = GetResourceKvpString('aprts_attachments_' .. item .. '_pos')
    local customRot = GetResourceKvpString('aprts_attachments_' .. item .. '_rot')
    if customPos and customRot then
        customPos = json.decode(customPos)
        customRot = json.decode(customRot)
    else
        customPos = Tool.coords
        customRot = { xr = Tool.coords.xr, yr = Tool.coords.yr, zr = Tool.coords.zr }
    end

    -- Vytvoření menu pro úpravu pozice a rotace
    local attachmentPositionEditorMenu = jo.menu.create("attachmentPositionEditor", {
        title = "Upravit " .. item,
        subtitle = "Úprava pozice a rotace"
    })

    -- Pomocná funkce pro vytváření sliderů
    local function addSlider(menu, titlePrefix, currentValue, min, max, step, onChange)

        -- menu:addItem({
        --     title = "Podrost",
        --     sliders = {{
        --         type = "grid",
        --         labels = {'Vůbec', 'Naplno'},
        --         values = {{
        --             current = 0.0,
        --             max = 1.0,
        --             min = 0.0
        --         }}
        --     }, {
        --         type = "palette",
        --         title = "tint",
        --         tint = "tint_hair",
        --         max = 135,
        --         current = 135
        --     }},
        --     onChange = function(currentData)
        --         local category = "hair"
        --         local value = currentData.item.sliders[1].value[1]
        --         local overlay = Config.Overlays[category]
        --         overlay.opacity = value
        --         overlay.id = 0
        --         overlay.tint0 = currentData.item.sliders[2].current
        --         debugPrint("intenzita: " .. value)
        --         ApplyOverlay(category, overlay)
        --     end
        -- })

        local sliderItem = {
            title = titlePrefix .. ": " .. tostring(currentValue),
            sliders = {{
                type = "grid",
                labels = {'Vůbec', 'Naplno'},
                values = {{
                    current = 0.0,
                    max = max,
                    min = min
                }}
            }},

            onChange = function(currentData)
                onChange(currentData.item.sliders[1].value[1])
            end
        }
        menu:addItem(sliderItem)
    end

    -- Přidání sliderů pro pozici X, Y, Z
    addSlider(attachmentPositionEditorMenu, "Upravit X", customPos.x, -1.0, 1.0, 0.1, function(newValue)
        customPos.x = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_pos', json.encode(customPos))
        print("Setting KVP:" .. 'aprts_attachments_' .. item .. '_pos', json.encode(customPos))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentPosition', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    addSlider(attachmentPositionEditorMenu, "Upravit Y", customPos.y, -1.0, 1.0, 0.1, function(newValue)
        customPos.y = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_pos', json.encode(customPos))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentPosition', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    addSlider(attachmentPositionEditorMenu, "Upravit Z", customPos.z, -1.0, 1.0, 0.1, function(newValue)
        customPos.z = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_pos', json.encode(customPos))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentPosition', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    -- Přidání sliderů pro rotaci XR, YR, ZR
    addSlider(attachmentPositionEditorMenu, "Upravit XR", customRot.xr, -180.0, 180.0, 1.0, function(newValue)
        customRot.xr = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_rot', json.encode(customRot))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentRotation', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    addSlider(attachmentPositionEditorMenu, "Upravit YR", customRot.yr, -180.0, 180.0, 1.0, function(newValue)
        customRot.yr = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_rot', json.encode(customRot))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentRotation', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    addSlider(attachmentPositionEditorMenu, "Upravit ZR", customRot.zr, -180.0, 180.0, 1.0, function(newValue)
        customRot.zr = newValue
        SetResourceKvp('aprts_attachments_' .. item .. '_rot', json.encode(customRot))
        TriggerServerEvent('aprts_attachments:server:UpdateAttachmentRotation', item, customPos, customRot)
        updateLocalAttachment(item, customPos, customRot)
    end)

    -- Přidání položky pro zavření menu
    attachmentPositionEditorMenu:addItem({
        title = "Zavřít",
        type = "button",
        onClick = function()
            attachmentPositionEditorMenu:close()
        end
    })

    attachmentPositionEditorMenu:send()

    jo.menu.setCurrentMenu("attachmentPositionEditor")
    jo.menu.show(true)
end

function updateLocalAttachment(item, pos, rot)
    print("Updating local attachment:", item, pos, rot)
    if equipedAttachments[item] and equipedAttachments[item].obj then
        local ped = PlayerPedId()
        local boneIndex = GetEntityBoneIndexByName(ped, Config.Items[item].bone)
        AttachEntityToEntity(equipedAttachments[item].obj, ped, boneIndex, pos.x, pos.y, pos.z, 
            rot.xr, rot.yr, rot.zr, true, true, false, true, 1, true)
        print("Attachment updated locally:", item)
    else
        print("Attachment not found locally:", item)
    end
end

-- Registrace klientských událostí pro aktualizaci pozice a rotace ostatních hráčů
RegisterNetEvent('aprts_attachments:client:UpdateOtherPlayerAttachment')
AddEventHandler('aprts_attachments:client:UpdateOtherPlayerAttachment', function(playerId, item, pos, rot)
    if playerAttachments[playerId] and playerAttachments[playerId][item] then
        local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
        if not ped or ped == 0 then
            return
        end

        local attachmentObj = playerAttachments[playerId][item]
        if attachmentObj then
            -- Aktualizace pozice a rotace attachmentu
            AttachEntityToEntity(attachmentObj, ped, GetEntityBoneIndexByName(ped, Config.Items[item].bone), 
                pos.x, pos.y, pos.z, rot.xr, rot.yr, rot.zr, true, true, false, true, 1, true)
        end
    end
end)
