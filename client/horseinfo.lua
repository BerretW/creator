-- credits to `i just stole a kia` for the research
local ANIMAL_INFO_UIAPP_HASH = GetHashKey("SHOP_BROWSING") -- Hash of the card UI App
local GAME_EVENT_TRIGGER_HASH = GetHashKey("EVENT_PLAYER_PROMPT_TRIGGERED") -- Hash of the game event we"re looking for

-- Data for the info card UI ("m_" just for intellisense sake to make my life a bit easier).
local m_InfoCardData = {
    -- If we"re showing an info card currently
    bShowing = false,
    -- Which entity we"re showing the info card currently for
    iEntity = 0,
    -- Model of the entity.
    hEntityModel = 0,
    -- Data binding containers stored so we can remove them later on cleanup.
    tDataBinding = {}
}

local eTamingState = {
    [0] = "ATS_INVALID",
    [1] = "ATS_INACTIVE",
    [2] = "ATS_TARGET_DETECTED",
    [3] = "ATS_CALLED_OUT",
    [4] = "ATS_MOUNTABLE",
    [5] = "ATS_BEING_PATTED",
    [6] = "ATS_BREAKING_ACTIVE",
    [7] = "ATS_SPOOKED",
    [8] = "ATS_RETREATING",
    [9] = "ATS_FLEEING"
}

local ePedAttribute={
	PA_HEALTH,
	PA_STAMINA,
	PA_SPECIALABILITY,
	PA_COURAGE,
	PA_AGILITY,
	PA_SPEED,
	PA_ACCELERATION,
	PA_BONDING,
	SA_HUNGER,
	SA_FATIGUED,
	SA_INEBRIATED,
	SA_POISONED,
	SA_BODYHEAT,
	SA_BODYWEIGHT,
	SA_OVERFED,
	SA_SICKNESS,
	SA_DIRTINESS,
	SA_DIRTINESSHAT,
	MTR_STRENGTH,
	MTR_GRIT,
	MTR_INSTINCT,
	PA_UNRULINESS,
	SA_DIRTINESSSKIN
};

---Listens for a game event
---@param iEventGroup integer Which group/channel of events we should listen to
---@param hWhichEvent integer Hash of the event we are specifically looking for
---@param iEventDataSize integer Data size of the event. See the github link above.
---@param tOutTable table Table we will write event data into if the event triggers.
---@return boolean b Returns if we successfully got data of the event
local function ListenForPromptEvent(iEventGroup, hWhichEvent, iEventDataSize, tOutTable)
    local iNumEvents = GetNumberOfEvents(iEventGroup)
    if iNumEvents > 0 then
        for i = 0, iNumEvents do
            local hEventName = GetEventAtIndex(iEventGroup, i)

            if hEventName == hWhichEvent then
                local EventDataStruct = DataView.ArrayBuffer(iEventDataSize * 8)
                EventDataStruct:SetInt32(8 * 0, 0)
                EventDataStruct:SetInt32(8 * 1, 0)
                EventDataStruct:SetInt32(8 * 2, 0)
                EventDataStruct:SetInt32(8 * 3, 0)
                EventDataStruct:SetInt32(8 * 4, 0)
                EventDataStruct:SetInt32(8 * 5, 0)
                EventDataStruct:SetInt32(8 * 6, 0)

                -- just to make it easier we"ll just write the data to a passed table
                local bDataExists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, EventDataStruct:Buffer(),
                    iEventDataSize) -- GET_EVENT_DATA
                if bDataExists then
                    tOutTable[1] = EventDataStruct:GetInt32(8 * 0)
                    tOutTable[2] = EventDataStruct:GetInt32(8 * 1)
                    tOutTable[3] = EventDataStruct:GetInt32(8 * 2)
                    tOutTable[4] = EventDataStruct:GetInt32(8 * 3)
                    tOutTable[5] = EventDataStruct:GetInt32(8 * 4)
                    tOutTable[6] = EventDataStruct:GetInt32(8 * 5)
                    tOutTable[7] = EventDataStruct:GetInt32(8 * 6)
                else
                    print("ListenForPromptEvent: bDataExists was false?!")
                    return false
                end

                return true
            end
        end
    end

    return false
end

---Returns a text label representing a horse"s coat
---@param hModel integer Model hash of the horse
---@return string Coat
function GetHorseCoatFromModel(hModel)
    print("GetHorseCoatFromModel: ", hModel)
    local tReturns = {
        [GetHashKey("A_C_HORSE_AMERICANPAINT_GREYOVERO")] = "COAT_GREYOVERO",
        [GetHashKey("A_C_HORSE_AMERICANSTANDARDBRED_BLACK")] = "COAT_BLACK",
        [GetHashKey("A_C_HORSE_AMERICANSTANDARDBRED_BUCKSKIN")] = "COAT_BUCKSKIN",
        [GetHashKey("A_C_HORSE_AMERICANSTANDARDBRED_PALOMINODAPPLE")] = "COAT_PALDAP",
        [GetHashKey("A_C_HORSE_AMERICANSTANDARDBRED_SILVERTAILBUCKSKIN")] = "COAT_SILVERTAILBUCKSKIN",
        [GetHashKey("A_C_HORSE_ANDALUSIAN_DARKBAY")] = "COAT_DARKBAY",
        [GetHashKey("A_C_HORSE_ANDALUSIAN_ROSEGRAY")] = "COAT_ROSEGREY",
        [GetHashKey("A_C_HORSE_ANDALUSIAN_PERLINO")] = "COAT_PERLINO",
        [GetHashKey("A_C_HORSE_APPALOOSA_BLANKET")] = "COAT_BLANKET",
        [GetHashKey("A_C_HORSE_APPALOOSA_LEOPARDBLANKET")] = "COAT_LEOPBLANKET",
        [GetHashKey("A_C_HORSE_APPALOOSA_FEWSPOTTED_PC")] = "COAT_FEWSPOTTED",
        [GetHashKey("A_C_HORSE_APPALOOSA_BROWNLEOPARD")] = "COAT_BRLEOP",
        [GetHashKey("A_C_HORSE_APPALOOSA_LEOPARD")] = "COAT_LEOP",
        [GetHashKey("A_C_HORSE_ARABIAN_BLACK")] = "COAT_BLACK",
        [GetHashKey("A_C_HORSE_ARABIAN_REDCHESTNUT_PC")] = "COAT_REDCH",
        [GetHashKey("A_C_HORSE_ARABIAN_ROSEGREYBAY")] = "COAT_ROSEGREYBAY",
        [GetHashKey("A_C_HORSE_ARABIAN_WARPEDBRINDLE_PC")] = "COAT_WARPEDBRINDLE",
        [GetHashKey("A_C_HORSE_ARABIAN_WHITE")] = "COAT_WHITE",
        [GetHashKey("A_C_HORSE_ARDENNES_BAYROAN")] = "COAT_BAYR",
        [GetHashKey("A_C_HORSE_ARDENNES_STRAWBERRYROAN")] = "COAT_STRAWR",
        [GetHashKey("A_C_HORSE_ARDENNES_IRONGREYROAN")] = "COAT_IRONGREYR",
        [GetHashKey("A_C_HORSE_BELGIAN_BLONDCHESTNUT")] = "COAT_BLONDCH",
        [GetHashKey("A_C_HORSE_BELGIAN_MEALYCHESTNUT")] = "COAT_MEALYCH",
        [GetHashKey("A_C_HORSE_DUTCHWARMBLOOD_SEALBROWN")] = "COAT_SEALBR",
        [GetHashKey("A_C_HORSE_DUTCHWARMBLOOD_CHOCOLATEROAN")] = "COAT_CHOCR",
        [GetHashKey("A_C_HORSE_HUNGARIANHALFBRED_FLAXENCHESTNUT")] = "COAT_FLAXCH",
        [GetHashKey("A_C_HORSE_HUNGARIANHALFBRED_PIEBALDTOBIANO")] = "COAT_PIETOB",
        [GetHashKey("A_C_HORSE_HUNGARIANHALFBRED_DARKDAPPLEGREY")] = "COAT_DAPDARKGREY",
        [GetHashKey("A_C_HORSE_KENTUCKYSADDLE_BLACK")] = "COAT_BLACK",
        [GetHashKey("A_C_HORSE_KENTUCKYSADDLE_BUTTERMILKBUCKSKIN_PC")] = "COAT_BUTTERMILKBUCKSKIN",
        [GetHashKey("A_C_HORSE_KENTUCKYSADDLE_CHESTNUTPINTO")] = "COAT_CHPIN",
        [GetHashKey("A_C_HORSE_KENTUCKYSADDLE_GREY")] = "COAT_GREY",
        [GetHashKey("A_C_HORSE_KENTUCKYSADDLE_SILVERBAY")] = "COAT_SILVERBAY",
        [GetHashKey("A_C_HORSE_MISSOURIFOXTROTTER_AMBERCHAMPAGNE")] = "COAT_AMBCHA",
        [GetHashKey("A_C_HORSE_MISSOURIFOXTROTTER_SILVERDAPPLEPINTO")] = "COAT_SILVERDAPPINT",
        [GetHashKey("A_C_HORSE_MORGAN_BAY")] = "COAT_BAY",
        [GetHashKey("A_C_HORSE_MORGAN_BAYROAN")] = "COAT_BAYR",
        [GetHashKey("A_C_HORSE_MORGAN_FLAXENCHESTNUT")] = "COAT_FLAXCH",
        [GetHashKey("A_C_HORSE_MORGAN_LIVERCHESTNUT_PC")] = "COAT_LIVERCH",
        [GetHashKey("A_C_HORSE_MORGAN_PALOMINO")] = "COAT_PAL",
        [GetHashKey("A_C_HORSE_MUSTANG_GRULLODUN")] = "COAT_GRULDUN",
        [GetHashKey("A_C_HORSE_MUSTANG_WILDBAY")] = "COAT_WILDBAY",
        [GetHashKey("A_C_HORSE_MUSTANG_TIGERSTRIPEDBAY")] = "COAT_TIGSTRBAY",
        [GetHashKey("A_C_HORSE_NOKOTA_BLUEROAN")] = "COAT_BLUER",
        [GetHashKey("A_C_HORSE_NOKOTA_WHITEROAN")] = "COAT_WHITER",
        [GetHashKey("A_C_HORSE_NOKOTA_REVERSEDAPPLEROAN")] = "COAT_REVDAPR",
        [GetHashKey("A_C_HORSE_SHIRE_DARKBAY")] = "COAT_DARKBAY",
        [GetHashKey("A_C_HORSE_SHIRE_LIGHTGREY")] = "COAT_LGREY",
        [GetHashKey("A_C_HORSE_SUFFOLKPUNCH_SORREL")] = "COAT_SORREL",
        [GetHashKey("A_C_HORSE_SUFFOLKPUNCH_REDCHESTNUT")] = "coat_redch",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_BLACKRABICANO")] = "COAT_BLACKRAB",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_CHESTNUT")] = "COAT_CH",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_DAPPLEBAY")] = "COAT_DAPBAY",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_GOLDPALOMINO_PC")] = "COAT_GOLDPALOMINO",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_REDROAN")] = "COAT_REDR",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_FLAXENROAN")] = "COAT_FLAXR",
        [GetHashKey("A_C_HORSE_THOROUGHBRED_BLOODBAY")] = "COAT_BLBAY",
        [GetHashKey("A_C_HORSE_THOROUGHBRED_DAPPLEGREY")] = "COAT_DAPGREY",
        [GetHashKey("A_C_HORSE_THOROUGHBRED_BRINDLE")] = "COAT_BRINDLE",
        [GetHashKey("A_C_HORSE_THOROUGHBRED_BLACKCHESTNUT")] = "COAT_BLACKCH",
        [GetHashKey("A_C_HORSE_THOROUGHBRED_REVERSEDAPPLEBLACK")] = "COAT_REVDAPBLACK",
        [GetHashKey("A_C_HORSE_TURKOMAN_DARKBAY")] = "COAT_DARKBAY",
        [GetHashKey("A_C_HORSE_TURKOMAN_GOLD")] = "COAT_GOLD",
        [GetHashKey("A_C_HORSE_TURKOMAN_SILVER")] = "COAT_SILVER",
        [GetHashKey("A_C_HORSEMULE_01")] = "COAT_NONE",
        [GetHashKey("A_C_DONKEY_01")] = "COAT_NONE",
        [GetHashKey("A_C_HORSE_TENNESSEEWALKER_MAHOGANYBAY")] = "COAT_MAHBAY",
        [GetHashKey("A_C_HORSE_SHIRE_RAVENBLACK")] = "COAT_RAVBLACK",
        [GetHashKey("A_C_HORSE_BUELL_WARVETS")] = "COAT_CHEMGOLD",
        [GetHashKey("A_C_HORSE_JOHN_ENDLESSSUMMER")] = "COAT_SEALBR",
        [GetHashKey("A_C_HORSE_WINTER02_01")] = "COAT_SILVERBAY",
        [GetHashKey("A_C_HORSE_EAGLEFLIES")] = "COAT_SPLASHWHITE",
        [GetHashKey("A_C_HORSE_GANG_BILL")] = "COAT_BROWNR",
        [GetHashKey("A_C_HORSE_GANG_CHARLES")] = "COAT_GREYSNOWCAPSPOTTED",
        [GetHashKey("A_C_HORSE_GANG_CHARLES_ENDLESSSUMMER")] = "COAT_GREYROANSABINO",
        [GetHashKey("A_C_HORSE_GANG_DUTCH")] = "COAT_ALBINO",
        [GetHashKey("A_C_HORSE_GANG_HOSEA")] = "COAT_SILVER",
        [GetHashKey("A_C_HORSE_AMERICANPAINT_OVERO")] = "COAT_OVERO",
        [GetHashKey("A_C_HORSE_AMERICANPAINT_TOBIANO")] = "COAT_TOB",
        [GetHashKey("A_C_HORSE_MURFREEBROOD_MANGE_03")] = "COAT_BLACKRAB",
        [GetHashKey("A_C_HORSE_MURFREEBROOD_MANGE_02")] = "COAT_BLUER",
        [GetHashKey("A_C_HORSE_MP_MANGY_BACKUP")] = "COAT_MANGY", -- or COAT_NONE? In latest game builds
        [GetHashKey("A_C_HORSE_MURFREEBROOD_MANGE_01")] = "COAT_BLANKET",
        [GetHashKey("A_C_HORSE_MUSTANG_GOLDENDUN")] = "COAT_GOLDENDUN",
        [GetHashKey("A_C_HORSE_MISSOURIFOXTROTTER_SABLECHAMPAGNE")] = "COAT_SABLECHAMP",
        [GetHashKey("A_C_HORSE_HUNGARIANHALFBRED_LIVERCHESTNUT")] = "COAT_LIVERCH",
        [GetHashKey("A_C_HORSE_ARABIAN_REDCHESTNUT")] = "COAT_REDCH",
        [GetHashKey("A_C_HORSE_ARABIAN_GREY")] = "COAT_GREY",
        [GetHashKey("A_C_HORSE_AMERICANPAINT_SPLASHEDWHITE")] = "COAT_SPLASHWHITE",
        [GetHashKey("A_C_HORSE_APPALOOSA_BLACKSNOWFLAKE")] = "COAT_BLACKSNO",
        [GetHashKey("A_C_HORSE_AMERICANSTANDARDBRED_LIGHTBUCKSKIN")] = "COAT_LIGHTBUCKSKIN",
        [GetHashKey("A_C_HORSEMULEPAINTED_01")] = "BREED_MULE_PAINTED",
        [GetHashKey("A_C_HORSE_GANG_UNCLE_ENDLESSSUMMER")] = "COAT_FEWSPOTBUCKSKIN",
        [GetHashKey("A_C_HORSE_GANG_UNCLE")] = "COAT_SABINO",
        [GetHashKey("A_C_HORSE_GANG_TRELAWNEY")] = "COAT_BRLEOP",
        [GetHashKey("A_C_HORSE_GANG_SEAN")] = "COAT_SILVERTAILBUCKSKIN",
        [GetHashKey("A_C_HORSE_GANG_SADIE_ENDLESSSUMMER")] = "COAT_DARKBAYROAN",
        [GetHashKey("A_C_HORSE_GANG_SADIE")] = "COAT_GOLDDAP",
        [GetHashKey("A_C_HORSE_GANG_MICAH")] = "COAT_BLACK",
        [GetHashKey("A_C_HORSE_DUTCHWARMBLOOD_SOOTYBUCKSKIN")] = "COAT_SOOTYBUCKSKIN",
        [GetHashKey("A_C_HORSE_GANG_LENNY")] = "COAT_LIGHTPALOMINO",
        [GetHashKey("A_C_HORSE_GANG_KIERAN")] = "COAT_FLAXR",
        [GetHashKey("A_C_HORSE_GANG_KAREN")] = "COAT_SMOKYBLACK",
        [GetHashKey("A_C_HORSE_GANG_JOHN")] = "COAT_SILVERDARKBAY",
        [GetHashKey("A_C_HORSE_GANG_JAVIER")] = "COAT_GREYOVERO"
    }
    print("GetHorseCoatFromModel: ", tReturns[hModel])
    return tReturns[hModel] or "none"
end

local function ClampValue(value, min, max)
    if value > max then
        return max
    elseif value < min then
        return min
    else
        return value
    end
end

---Launches the horse details UI app if the entity is a horse
---@param iEntity integer ID of the horse entity
---@param hModel integer Model hash of the horse entity
local function ShowHorseDetailsOnCard(iEntity, hModel)
    local iInfoBox = DatabindingAddDataContainerFromPath("", "InfoBox") -- Add the info box container
    m_InfoCardData.tDataBinding.iInfoBox = iInfoBox -- Save data for the info box container for future use. This data is deleted on cleanup.
    -- local horseName = GetStringFromHashKey(GetDiscoverableNameHashAndTypeForEntity(iEntity))
    -- print(horseName)
    DatabindingAddDataString(iInfoBox, "itemLabel",
        GetStringFromHashKey(GetDiscoverableNameHashAndTypeForEntity(iEntity))) -- Sets the title of the card.

    DatabindingAddDataBool(iInfoBox, "showHorseStats", true) -- Shows horse stats.
    DatabindingAddDataBool(iInfoBox, "isVisible", true) -- Makes info box visible.

    DatabindingAddDataString(iInfoBox, "HorseCoat", GetHorseCoatFromModel(hModel)) -- Sets the horse coat text.

    -- Set the horse speed value
    DatabindingAddDataInt(iInfoBox, "HorseSpeedValue", GetAttributeBaseRank(iEntity, 5) + 1)
    DatabindingAddDataInt(iInfoBox, "HorseSpeedMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseSpeedMaxValue", 10)

    local iBaseRank = GetAttributeBaseRank(iEntity, 5) + 1
    local iBonusRank = GetAttributeBonusRank(iEntity, 5)
    local iStatValue = ClampValue(iBaseRank + iBonusRank, 0, 10)

    DatabindingAddDataInt(iInfoBox, "HorseSpeedEquipmentValue", iStatValue)
    DatabindingAddDataInt(iInfoBox, "HorseSpeedEquipmentMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseSpeedEquipmentMaxValue", 10)

    DatabindingAddDataInt(iInfoBox, "HorseSpeedCapacityValue", ClampValue(iBaseRank + 3, 0, 10))
    DatabindingAddDataInt(iInfoBox, "HorseSpeedCapacityMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseSpeedCapacityMaxValue", 10)

    -- Set the horse acceleration value
    iBaseRank = GetAttributeBaseRank(iEntity, 6) + 1

    DatabindingAddDataInt(iInfoBox, "HorseAccValue", iBaseRank)
    DatabindingAddDataInt(iInfoBox, "HorseAccMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseAccMaxValue", 10)

    iBonusRank = GetAttributeBonusRank(iEntity, 6)
    iStatValue = ClampValue(iBaseRank + iBonusRank, 0, 10)

    DatabindingAddDataInt(iInfoBox, "HorseAccEquipmentValue", iStatValue)
    DatabindingAddDataInt(iInfoBox, "HorseAccEquipmentMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseAccEquipmentMaxValue", 10)

    DatabindingAddDataInt(iInfoBox, "HorseAccCapacityValue", ClampValue(iBaseRank + 2, 0, 10))
    DatabindingAddDataInt(iInfoBox, "HorseAccCapacityMinValue", 0)
    DatabindingAddDataInt(iInfoBox, "HorseAccCapacityMaxValue", 10)

    -- Set the horse handling value
    local iHandling = GetAttributeRank(iEntity, 4)

    if iHandling == 0 or iHandling == 1 then
        iHandling = 0
    elseif iHandling == 2 or iHandling == 3 then
        iHandling = 1
    elseif iHandling == 4 or iHandling == 5 then
        iHandling = 2
    elseif iHandling == 6 or iHandling == 7 or iHandling == 8 or iHandling == 9 then
        iHandling = 3
    end

    local sHandlingTextLabel = "HORSE_HANDLING_HEAVY"

    if iHandling == 1 then
        sHandlingTextLabel = "HORSE_HANDLING_STANDARD"
    elseif iHandling == 2 then
        sHandlingTextLabel = "HORSE_HANDLING_RACE"
    elseif iHandling == 3 then
        sHandlingTextLabel = "HORSE_HANDLING_ELITE"
    end

    DatabindingAddDataString(iInfoBox, "HorseHandling", sHandlingTextLabel)
end

---Sets information for an animal that is not a horse
---@param iEntity integer
local function ShowAnimalDetailsOnCard(iEntity)
    local iInfoBox = DatabindingAddDataContainerFromPath("", "InfoBox") -- Add info box container
    m_InfoCardData.tDataBinding.iInfoBox = iInfoBox -- Store in memory for cleanup/later usage
    DatabindingAddDataBool(iInfoBox, "isVisible", true) -- Make box visible
    -- Set title. Ideally this would be done with VarString but i couldn"t get it to work for some reason.

    DatabindingAddDataString(iInfoBox, "itemLabel", horseName)
    DatabindingAddDataHash(iInfoBox, "itemDescription", CompendiumGetShortDescriptionFromPed(iEntity)) -- Set description
end

---Activates an info card for an animal. Do note that the animal must be focused with rightclick or binoculars!
---@param b boolean true activates the card and false clears it
---@param iEntity integer ID of the entity.
local function SetAnimalInfoCardActive(b, iEntity)
    if b and not m_InfoCardData.bShowing then
        if not DoesEntityExist(iEntity) or not IsEntityAPed(iEntity) then -- Check if the entity is valid
            print("SetAnimalInfoCardActive: Invalid iEntity")
            return
        end

        local hModel = GetEntityModel(iEntity)
        local bHorse = IsThisModelAHorse(hModel) == 1
        local iEntry = bHorse and -649639953 or -1645363952

        -- Ensure no UI is active.
        if not m_InfoCardData.bShowing and CanLaunchUiappByHashWithEntry(ANIMAL_INFO_UIAPP_HASH, iEntry) ~= 1 then
            print("SetAnimalInfoCardActive: Can not launch the ui app, is any other ui app active by any chance?")
            if IsUiappActiveByHash(ANIMAL_INFO_UIAPP_HASH) ~= 1 then
                return
            end
        end

        -- If Animal Info uiapp isn"t active, launch it
        if IsUiappActiveByHash(ANIMAL_INFO_UIAPP_HASH) ~= 1 then
            LaunchUiappByHashWithEntry(ANIMAL_INFO_UIAPP_HASH, iEntry)
        end

        -- If this is a horse, show horse details, if not then show animal details
        if bHorse then
            ShowHorseDetailsOnCard(iEntity, hModel)
        else
            ShowAnimalDetailsOnCard(iEntity)
        end

        SetShowInfoCard(PlayerId(), true) -- Changes Show Info prompt to Hide Info
        -- Set some script data.
        m_InfoCardData.iEntity = iEntity
        m_InfoCardData.bShowing = true
        m_InfoCardData.hEntityModel = GetEntityModel(iEntity)
    elseif not b and m_InfoCardData.bShowing then
        -- Release the data binding from memory.
        for k, v in pairs(m_InfoCardData.tDataBinding) do
            DatabindingRemoveDataEntry(v)
        end
        m_InfoCardData.tDataBinding = {}

        m_InfoCardData.bShowing = false

        if IsUiappActiveByHash(ANIMAL_INFO_UIAPP_HASH) == 1 then
            CloseUiappByHash(ANIMAL_INFO_UIAPP_HASH)
        end

        SetShowInfoCard(PlayerId(), false) -- Changes Hide Info prompt to Show Info
        m_InfoCardData.iEntity = 0
        m_InfoCardData.hEntityModel = 0
    end
end

---Should be called once the resource stops.
function CleanupAnimalInfoHud()
    SetAnimalInfoCardActive(false, 0)
end

---Should be called every frame.
function UpdateAnimalInfoThisFrame()
    local iPlayerID = PlayerId() -- Our player ID

    if m_InfoCardData.bShowing then -- If the card UI is showing
        -- This code block handles changing animals with binoculars
        local _, iEntity = GetPlayerTargetEntity(iPlayerID)
        local hEntityModel = GetEntityModel(iEntity)
        local bIsModelDifferent = hEntityModel ~= m_InfoCardData.hEntityModel

        -- We looked at a different entity
        if m_InfoCardData.iEntity ~= iEntity then
            if bIsModelDifferent then -- We"re looking at a different animal, so let"s close the card
                SetAnimalInfoCardActive(false, iEntity)
            elseif not bIsModelDifferent then -- The animal is the same, let"s just update the entity in the card data table
                m_InfoCardData.iEntity = iEntity
                m_InfoCardData.hEntityModel = hEntityModel
            end
        end
    end

    -- Returns if this ui prompt is active https://i.imgur.com/z4qY6XT.png
    -- We check if this is 1 because the native returns 0 if this is false and lua thinks that "not 0" is false
    if GetIsPlayerUiPromptActive(iPlayerID, 35) == 1 then
        local tOutTable = {}

        if ListenForPromptEvent(0, GAME_EVENT_TRIGGER_HASH, 10, tOutTable) then
            local iPromptType, b, iEntity, d, e, f, g = table.unpack(tOutTable)

            if iPromptType == 35 and b == 16 and d == 0 then
                SetAnimalInfoCardActive(not m_InfoCardData.bShowing, iEntity)
                if IsEntityAPed(iEntity) then
                    local hModel = GetEntityModel(iEntity)
                    if IsThisModelAHorse(hModel) == 1 then
                        -- sendNotification(GetHorseTamingState(iEntity))
                    else
                        -- sendNotification("Not Horse")
                    end
                else
                    -- sendNotification("Not a ped")
                end

            end
        end
    else
        if m_InfoCardData.bShowing then
            SetAnimalInfoCardActive(false, 0) -- close the card when we stop focusing on an entity
        end
    end
end

-- Example use
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupAnimalInfoHud()
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        UpdateAnimalInfoThisFrame()
    end
end)
