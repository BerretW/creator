RegisterCommand("novydenik", function(source, args, rawCommand)
    
    exports.vorp_inventory:addItem(source, "aprts_diary_1", 1, demoDiaryData)
    
end, false)