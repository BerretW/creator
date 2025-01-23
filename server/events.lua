AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- MySQL:execute("SELECT * FROM aprts_clues", {}, function(result)
        --     for k, v in pairs(result) do
        --         v.coords = json.decode(v.coords)
        --         clues[v.id] = v

        --     end
        --     TriggerClientEvent("aprts_clue:Client:LoadClues", -1, clues)
        -- end)
    end
end)

RegisterServerEvent("aprts_charCreator:Server:defaults")
AddEventHandler("aprts_charCreator:Server:defaults", function()

    local user = Core.getUser(source) --[[@as User]]
    if not user then
        return
    end -- is player in session?
    local character = user.getUsedCharacter --[[@as Character]]
    local money = character.money
    character.removeCurrency(0, money)
    character.addCurrency(0, Config.DefaultMoney)
    for i = 1, #Config.DefaultWeapons do
        -- exports.vorp_inventory:createWeapon(source, Config.DefaultWeapons[i], 0, {},{})
        print(Config.DefaultWeapons[i])
        exports.vorp_inventory:createWeapon(source, Config.DefaultWeapons[i], {
            ["nothing"] = 0
        }, {}, {})
    end
    for k, v in pairs(Config.DefaultItems) do
        exports.vorp_inventory:addItem(source, k, v)

    end
end)

RegisterServerEvent("aprts_charCreator:Server:saveSkills")
AddEventHandler("aprts_charCreator:Server:saveSkills", function(skills)
    local user = Core.getUser(source) --[[@as User]]
    if not user then
        return
    end -- is player in session?
    local character = user.getUsedCharacter --[[@as Character]]

    while not character do
        character = user.getUsedCharacter
        Wait(200)
    end
    local charID = character.charIdentifier
    local playerSkills = exports.westhaven_skill:loadSkills()
    print("Defaultní skilly: ".. json.encode(playerSkills))
    for k, v in pairs(skills) do
        playerSkills[k].level= v
        playerSkills[k].experience = 0
    
    end
    print("Nové skilly: ".. json.encode(playerSkills))
    exports.westhaven_skill:saveSkillsPlayer(charID, playerSkills)
end)
