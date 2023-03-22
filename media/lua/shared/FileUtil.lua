
local lrmFileIndex = "LRM/LRMItemsTable.ini"

--local selectedFileText = "LRM/%s.ini"

--function getLRMValueFileList()
--    local fileReader = getFileReader(lrmFileIndex, true)
--
--
--    local fileNames
--    while true do
--        local line = fileReader:readLine()
--        if line == nil then
--            fileReader:close()
--            break
--        else
--            if fileNames == nil then
--                fileNames = {}
--            end
--
--            table.insert(fileNames, line)
--        end
--    end
--
--    if fileNames == nil then
--        fileNames = { "Default" }
--    end
--
--    return fileNames
--end

--function SetLRMValueFileList(fileList)
--    if fileList == nil then
--        return
--    end
--
--    local file = getFileWriter(lrmFileIndex, true, false)
--    file:writeln(tostring(index))
--    for _, v in pairs(fileList) do
--        file:writeln(v)
--    end
--    file:close()
--
--end

function SaveLRMItemConfig(itemTable)

    --local fileNames = getLRMValueFileList()

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

function EnableLRMItemConfig()
    --if fileName == nil then
    --    return nil
    --end
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