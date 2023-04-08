local lrmFileIndex = "LRM/LRMItemsTable.ini"

-- Salvataggio listino prezzi del market
function SaveLRMItemConfig(itemTable)
    if itemTable == nil then
        return false
    end
    local fileWriter = getFileWriter(lrmFileIndex, true, false)
    for k, v in pairs(itemTable) do
        fileWriter:writeln(k .. "=" .. tostring(v))
    end

    fileWriter:close()
    return true
end

-- Caricamento listino prezzi del market
function EnableLRMItemConfig()
    local fileReader = getFileReader(lrmFileIndex, true)
    local itemsTable = {}
	
    while true do
        local line = fileReader:readLine()
        if line == nil then
            fileReader:close()
            break
        else
            local item = luautils.split(line, "=")
            itemsTable[item[1]] = tonumber(item[2])
        end
    end
    return itemsTable
end