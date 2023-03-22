

require "ItemUtil"

SyncContainer = nil
PlayerInventory = nil
ItemsTable = nil
RawCommonTable = nil
--playerAssets = nil

function modifySyncContainer(newTable)

    if newTable == nil then
        return
    end

    --if isSinglePlayer() then
    --    DoModifyInventory(newTable)
    --else
    sendClientCommand(getPlayer(), "LRM", "ModifyInventory", { getPlayerId(getPlayer()), newTable })
    --end
end

function requestSavePost(newTable)
    sendClientCommand(getPlayer(), "LRM", "ResetInventory", { newTable })
end

local function OnServerCommand(module, command, arguments)

    if module == "LRM" then

        if command == "LRMCommandCallback" then
            handleCommandCallback(arguments)
        end

        if command == "SyncInventory" then

            initSycContainer(arguments[1])

        elseif command == "SyncCommentBoard" then

            buildCommonList(arguments[1])

        elseif command == "SyncPlayerInventory" then
            syncPlayerCommodity(arguments[1])

        elseif command == "SyncItemTable" then
            SyncItemTable(arguments[1])
        elseif command == "InitTradingData" then
            --getPlayer():Say("Sync Succeed")
            initSycContainer(arguments[1])
            syncPlayerCommodity(arguments[2])
            SyncItemTable(arguments[3])
            --SyncCommentBoard(arguments[4])

        elseif command == "SendPlayerCommodity" then
            doPackExpressBox(arguments[1])
        end


    end
end

local function EveryOneMinute()

    if SyncContainer == nil or PlayerInventory == nil then
        --local temp = getPlayerId(getPlayer())
        --if temp == nil then
        --    temp = "nil?"
        --end
        --getPlayer():Say("Request Sync" .. temp)
        sendClientCommand("LRM", "RequestInitData", { getPlayerId(getPlayer()) })
    else
        Events.EveryOneMinute.Remove(EveryOneMinute)
    end
end

Events.EveryOneMinute.Add(EveryOneMinute)
Events.OnServerCommand.Add(OnServerCommand)
