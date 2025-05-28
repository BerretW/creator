-------------------------------------------
---------JOB Override Limits---------------
local job = "rancher"
if LocalPlayer.state.Character then

    if LocalPlayer.state.Character.Job == job then
        Config.maxWalkedAnimals = Config.maxWalkedAnimals * LocalPlayer.state.Character.Grade
    end
end

--------------------------------------------
