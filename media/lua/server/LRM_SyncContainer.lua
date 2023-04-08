-- classe di gestione comandi ricevuti dal server o mandati al client

-- sync container del server(?)
local function sendInventory(player, table)
    if isSinglePlayer() then
        initSycContainer(table)
    else
        if player then
            sendServerCommand(player, "LRM", "SyncInventory", { table })
        else
            sendServerCommand("LRM", "SyncInventory", { table })
        end
    end
end

-- sync comment board (TODO risolvere problema overflow commenti)
local function sendCommentBoard(player, table)
    --if isSinglePlayer() then
    --    buildCommonList(table)
        --SyncCommentBoard(table)
   -- else
     --   if player then
     --       sendServerCommand(player, "LRM", "SyncCommentBoard", { table })
     --   else
     --       sendServerCommand("LRM", "SyncCommentBoard", { table })
      --  end
   -- end
end

-- sync player inventory
local function sendPlayerInventory(player, table)
    if isSinglePlayer() then
        syncPlayerCommodity(table)
    else
        if player then
            sendServerCommand(player, "LRM", "SyncPlayerInventory", { table })
        else
            sendServerCommand("LRM", "SyncPlayerInventory", { table })
        end
    end
end

-- sync lista item disponibili nel market
local function sendItemTable(player, table)
    if isSinglePlayer() then
        SyncItemTable(table)
    else
        if player then
            sendServerCommand(player, "LRM", "SyncItemTable", { table })
        else
            sendServerCommand("LRM", "SyncItemTable", { table })
        end
    end
end

-- get della lista commenti, se non esiste la crea (per ora la crea sempre per evitare problemi)
local function getOrCreateCommentBoard()
    --if getGameTime():getModData().CommentBoard == nil then
        getGameTime():getModData().CommentBoard = {}
    --end

    return getGameTime():getModData().CommentBoard
end

-- get della lista item disponibili nel market, se non esiste la crea
local function getOrCreateShopInventory(table)
    if getGameTime():getModData().ShopInventory == nil then
        getGameTime():getModData().ShopInventory = {}
    end

    if table ~= nil then
        getGameTime():getModData().ShopInventory = table
    end

    return getGameTime():getModData().ShopInventory
end

-- get dei pacchi di un player, se non esiste la crea (in verita' e' pure un set)
local function getOrCreatePlayerCommodity(pId, table, player)

    if table ~= nil then
        getGameTime():getModData().LRMPlayerInventory = table
    else

        if getGameTime():getModData().LRMPlayerInventory == nil then
            getGameTime():getModData().LRMPlayerInventory = {}
            getGameTime():getModData().LRMPlayerInventory.items = {}
            getGameTime():getModData().LRMPlayerInventory.players = {}
        end

        if getGameTime():getModData().LRMPlayerInventory.players[pId] == nil then
            getGameTime():getModData().LRMPlayerInventory.players[pId] = {
                playerId = pId,
                score = SandboxVars.LRM.InitAssets / 100,
                comment = {}
            }
        end

        for _,v in pairs(getGameTime():getModData().LRMPlayerInventory.items) do
            if v.orderTime == nil then
                v.orderTime = getGameTime():getWorldAgeHours()
            end
        end


        if player and getGameTime():getModData().LRMPlayerInventory.players[pId].username == nil then
            getGameTime():getModData().LRMPlayerInventory.players[pId].username = player:getUsername()
        end

        if not getGameTime():getModData().LRMPlayerInventory.players[pId].banned then
            getGameTime():getModData().LRMPlayerInventory.players[pId].banned = false
        end

    end
    return getGameTime():getModData().LRMPlayerInventory
end

-- aggiornamento commenti, se removeByTime e' settato rimuove il commento con quel time (TODO risolvere problema overflow commenti)
local function updateComment(player, content, removeByTime)
    --local comments = getOrCreateCommentBoard()
    --if removeByTime then
     --   for k, v in pairs(comments) do
    --        if v.time == removeByTime then
    --            v.visible = false
    --        end
     --   end
    --else
    --    if content == nil then
    --        return
    --    end
    --    local comment = {}
      --  comment.author = player:getUsername()
     --   comment.time = os.date('%Y-%m-%d %H:%M:%S', getTimestamp() + SandboxVars.LRM.TimeZoneOffset * 60 * 60 )
     --   comment.visible = true
     --   comment.content = content

    --    table.insert(comments, 1, comment)
    --end


    --if removeByTime then
    --    table.remove(comments, removeByTime)
    --else
    --
    --end

    --getGameTime():getModData().CommentBoard = comments
    --sendCommentBoard(nil, getGameTime():getModData().CommentBoard)
end

-- init/get/set lista item disponibili nel market
local function getOrCreateItemTable(table)
    if table ~= nil then
        getGameTime():getModData().LRMItemTable = table
    else
        if getGameTime():getModData().LRMItemTable == nil then
            getGameTime():getModData().LRMItemTable = ItemValueTable
        end
    end

    return getGameTime():getModData().LRMItemTable
end

-- aggiunge un item alla lista item disponibili nel market
local function updateItemTable(item)
    if item == nil or getScriptManager():getItem(item[1]) == nil then
        return
    end

    local table = getOrCreateItemTable()
    table[item[1]] = item[2]

    table = getOrCreateItemTable(table)

    sendItemTable(nil, table)
end

-- aggiorna il bilancio di un player con il valore di un item
local function updatePlayerScore(commodities, pId, score)
    print("updatePlayerScore: Before:" .. tostring(commodities.players[pId].score))
    commodities.players[pId].score = commodities.players[pId].score + score
    print("updatePlayerScore: After:" .. tostring(commodities.players[pId].score))
    commodities = getOrCreatePlayerCommodity(pId, commodities)
end

-- gestione dei comandi mandati dal client
-- ResetInventory : resetta l'inventario del market
-- ModifyInventory : modifica l'inventario del market con item del player
-- GetContainer : ritorna l'inventario del market (TODO capire perche' non viene usato)
-- GetPlayerCommodity : ritorna l'inventario o pacchi di un player (TODO capire perche' non viene usato)
-- UpdatePlayerScore : aggiorna il bilancio di un player
-- UpdatePlayerData : aggiorna i pacchi di un player
-- UpdateItemTable : aggiorna la lista prezzi item nel market (utilizzabile solo da admin)
-- AddPlayerCommodity : aggiunge un pacchetto di un player
-- RequestPlayerCommodity : richiede un pacchetto di un player tramite id (lo compra)
-- RequestInitData : richiede i dati iniziali del market/pacchi player/lstino prezzi item
-- RequestCommentBoard : richiede la lista commenti
-- LRMAddComment : aggiunge un commento alla lista commenti
-- RequestBackLRMItemConfig : backup della lista prezzi item
-- RequestRestoreLRMItemConfig/RequestResetLRMItemConfig : restore/reset della lista prezzi item
local function OnClientCommand(module, command, player, args)
    if module == "LRM" then
        if command == "ResetInventory" then
            getOrCreateShopInventory(args[1])
            sendInventory(nil, args[1])
        --elseif command == "GetContainer" then
        --    sendInventory(player, getOrCreateShopInventory(nil))
        elseif command == "ModifyInventory" then
            local pId = args[1]
            local commodities = getOrCreatePlayerCommodity(pId, nil, player)
            if commodities.players[pId] == nil or commodities.players[pId].banned then
                return
            end
            DoModifyInventory(args[2])
            sendInventory(nil, getOrCreateShopInventory(nil))
        --elseif command == "GetPlayerCommodity" then
        --    local commodities = getOrCreatePlayerCommodity(player, player, nil)
        --    sendPlayerInventory(nil, commodities)
        --if getGameTime():getModData().LRMPlayerInventory.args[1] == nil then
        --end
        elseif command == "UpdatePlayerScore" then
            local pId = args[1]
            local commodities = getOrCreatePlayerCommodity(pId, nil, player)
            updatePlayerScore(commodities, pId, args[2])
            --commodities = getOrCreatePlayerCommodity(player, commodities)
            sendPlayerInventory(player, commodities)
        elseif command == "UpdatePlayerData" then
            if args == nil then
                return
            end
            local pId = args[1].playerId
            local commodities = getOrCreatePlayerCommodity(pId, nil, player)
            commodities.players[pId] = args[1]
            commodities = getOrCreatePlayerCommodity(pId, commodities)
            --updatePlayerScore(commodities, getPlayerId(player), args[1])
            sendPlayerInventory(nil, commodities)
        elseif command == "UpdateItemTable" then
            if getOnlinePlayers() ~= nil and player:getAccessLevel() == "None" then
                return
            end
            updateItemTable(args)
        elseif command == "AddPlayerCommodity" then
            if args == nil or args[1] == nil then
                return
            end
            local pId = (args[1].sellerId)
            local commodities = getOrCreatePlayerCommodity(pId, nil)
            if commodities.players[pId].banned then
                return
            end
            if not args[1].id then
                local id = tostring(table_length(commodities.items) + 1)
                args[1].id = id
            end
            commodities.items[args[1].id] = args[1]
            commodities = getOrCreatePlayerCommodity(pId, commodities)
            sendPlayerInventory(nil, commodities)
        elseif command == "RequestPlayerCommodity" then
            local pId = args[1]
            local goodsId = args[2]
            local commodities = getOrCreatePlayerCommodity(pId, nil)
            local goodsData = commodities.items[goodsId]

            if goodsData == nil or goodsData.isFinish then
                -- TODO *** questa parte e' la piu' critica, ogni tanto viene chiamata a caso ***
                commodities.items[goodsId] = nil
                commodities = getOrCreatePlayerCommodity(pId, commodities)
                sendPlayerInventory(nil, commodities)
                return
            end

            if commodities.players[goodsData.sellerId].banned == true then
                return
            end

            if (goodsData.sellerId) == pId then
                updatePlayerScore(commodities, (goodsData.sellerId), -(goodsData.weight * SandboxVars.LRM.SelfExpressFee / 100))
            else
                updatePlayerScore(commodities, pId, -(goodsData.price + goodsData.weight * SandboxVars.LRM.ExpressFee / 100))
                updatePlayerScore(commodities, (goodsData.sellerId), goodsData.price)
            end
            goodsData.isFinish = true
            -- crea pacco
            if isSinglePlayer() then
                doPackExpressBox(goodsData)
            else
                sendServerCommand(player, "LRM", "SendPlayerCommodity", { goodsData })
            end
            -- TODO *** questa parte e' la piu' critica, ogni tanto cancella tutti i pacchi o il penultimo boh***
            commodities.items[goodsId] = nil
            commodities = getOrCreatePlayerCommodity(pId, commodities)
            sendPlayerInventory(nil, commodities)
        elseif command == "RequestInitData" then
            local pId = args[1]
            local shopData = getOrCreateShopInventory(nil)
            local commodities = getOrCreatePlayerCommodity(pId, nil, player)
            local itemTable = getOrCreateItemTable(nil)
            if isSinglePlayer() then
                initSycContainer(shopData)
                syncPlayerCommodity(commodities)
                SyncItemTable(itemTable)
            else
                sendServerCommand(player, "LRM", "InitTradingData", { shopData, commodities, itemTable })
            end
        elseif command == "RequestCommentBoard" then
            sendCommentBoard(player, getOrCreateCommentBoard())
        elseif command == "LRMAddComment" then
            if args[2] ~= nil and player:getAccessLevel() == "None" then
                return
            end

            updateComment(player, args[1], args[2])

        elseif command == "RequestBackLRMItemConfig" then
            local isSucceed = true
            local msg = "Operate Successful"
            if not isSinglePlayer() and player:getAccessLevel() ~= "Admin" then
                isSucceed = false
                msg = "Only Admin Can do that"
            else
                isSucceed = SaveLRMItemConfig(getOrCreateItemTable(nil))
                if not isSucceed then
                    msg = "Operate Failed"
                end
            end

            local result = {}
            result.command = command
            result.isSucceed = isSucceed
            result.msg = msg

            if isSinglePlayer() then
                handleCommandCallback(result)
            else
                sendServerCommand(player, "LRM", "LRMCommandCallback", result)
            end


        elseif command == "RequestRestoreLRMItemConfig" or command == "RequestResetLRMItemConfig" then
            local isSucceed = true
            local msg = "Operate Successful"
            if not isSinglePlayer() and player:getAccessLevel() ~= "Admin" then
                isSucceed = false
                msg = "Only Admin Can do that"
            else
                local table = getOrCreateItemTable(EnableLRMItemConfig())
                if command == "RequestResetLRMItemConfig" then
                    table = BackupOfItemValueTable
                end
                sendItemTable(nil, table)
            end

            local result = {}
            result.command = command
            result.isSucceed = isSucceed
            result.msg = msg

            if isSinglePlayer() then
                handleCommandCallback(result)
            else
                sendServerCommand(player, "LRM", "LRMCommandCallback", result)
            end
        end
    end
end

Events.OnClientCommand.Add(OnClientCommand)