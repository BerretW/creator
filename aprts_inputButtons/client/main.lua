local aprts_inputButtons = {}
local resourceName = GetCurrentResourceName()

function aprts_inputButtons:getAnswer(prompt, options, timeout, backgroundImage)
    local p = promise.new()

    -- Zobraz NUI a pošli data
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        prompt = prompt,
        options = options,
        backgroundImage = backgroundImage
    })

    -- Event handler pro odpověď z NUI
    RegisterNUICallback('selectOption', function(data, cb)
        SetNuiFocus(false, false)
        p:resolve(data.value)
        cb('ok')
    end)

    -- Event handler pro zavření NUI (timeout nebo zavření)
    RegisterNUICallback('close', function(data, cb)
        SetNuiFocus(false, false)
        p:resolve(nil)
        cb('ok')
    end)

    -- Timeout
    Citizen.SetTimeout(timeout, function()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "close"
        })
        p:resolve(nil)
    end)

    -- Čekej na výsledek
    return Citizen.Await(p)
end

-- Exportuj funkci
exports('getAnswer', function(prompt, options, timeout, backgroundImage)
    return aprts_inputButtons:getAnswer(prompt, options, timeout, backgroundImage)
end)

-- register command to open test prompt
local Debug = false
if Debug == true then

    RegisterCommand("testPrompt", function()

        local options = {{
            label = "Ano",
            value = 1,
            image = "check.png"
        }, {
            label = "Ne",
            value = 2,
            image = "cross.png"
        }, {
            label = "Možná",
            value = 3
        }}
        local timeout = 10000
        local backgroundImage = "black_paper.png"

        local answer = exports.aprts_inputButtons:getAnswer("Chceš pokračovat?", options, timeout, backgroundImage)

        print(answer)
    end, false)
end
