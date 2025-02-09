if Config.openingMode == "command" then
  RegisterCommand(Config.commands.openMDT, function()
    ShowMDT()
  end)
  TriggerEvent('chat:addSuggestion', '/'..Config.commands.openMDT, __('commandOpenMDT'))
end