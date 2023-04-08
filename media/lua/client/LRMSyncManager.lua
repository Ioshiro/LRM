require "ItemUtil"

-- classe di supporto per la gestione dei dati di trading
-- sincronizza i dati con il server tramite sendClientCommand

SyncContainer = nil
PlayerInventory = nil
ItemsTable = nil
RawCommonTable = nil

-- manda la table da sincronizzare al server
function modifySyncContainer(newTable)
    if newTable == nil then
        return
    end

    sendClientCommand(getPlayer(), "LRM", "ModifyInventory", { getPlayerId(getPlayer()), newTable })
end

-- manda la table con cui resettare il contenitore al server
function requestSavePost(newTable)
    sendClientCommand(getPlayer(), "LRM", "ResetInventory", { newTable })
end

-- gestione dei comandi ricevuti dal server
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
            initSycContainer(arguments[1])
            syncPlayerCommodity(arguments[2])
            SyncItemTable(arguments[3])
            --SyncCommentBoard(arguments[4]) -- TODO gestire overflow commenti 
        elseif command == "SendPlayerCommodity" then
            doPackExpressBox(arguments[1])
        end
    end
end

-- inizializza il contenitore di trading (TODO da cambiare con evento onload?)
local function EveryOneMinute()
    if SyncContainer == nil or PlayerInventory == nil then
        sendClientCommand("LRM", "RequestInitData", { getPlayerId(getPlayer()) })
    else
        Events.EveryOneMinute.Remove(EveryOneMinute)
    end
end

Events.EveryOneMinute.Add(EveryOneMinute)
Events.OnServerCommand.Add(OnServerCommand)