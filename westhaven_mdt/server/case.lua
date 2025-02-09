jo.callback.register("westhaven_mdt:server:saveCase", function(source,data)
    if data.id == "new" then
        local caseID = MySQL.insert.await('INSERT INTO westhaven_mdt_cases (title,text,sheriffId,state,updatedDate) VALUES (@title,@text,@sheriffId,@state,@updatedDate)', {
            title = data.title,
            text = data.text,
            sheriffId = data.sheriffId,
            state = data.state,
            updatedDate = os.date('%Y-%m-%d %H:%M:%S')
        })
        data.id = caseID
        Cases[tonumber(data.id)] = data
        return true,caseID
    else
        local query = ""
        query = "UPDATE westhaven_mdt_cases SET updatedDate = CURRENT_TIMESTAMP(),"
        for key,_ in pairs (data) do
            data.id = tonumber(data.id)
            data.createdDate = nil
            if key ~= "id" and key ~= "updatedDate" and key ~= "createdDate" then
                query = query .. key .. " = @"..key..","
            end
        end
        query = query:sub(0,query:len() - 1)
        query = query .. " WHERE id = @id"
        MySQL.update.await(query,data)
        Cases[tonumber(data.id)] = table.merge(Cases[tonumber(data.id)], data)
        return true
    end
end)

local function timestampToDatetime(timestamp)
    local seconds = timestamp / 1000 -- Převést milisekundy na sekundy
    return os.date('%Y-%m-%d %H:%M:%S', seconds)
end