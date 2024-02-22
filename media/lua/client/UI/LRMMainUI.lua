-- Classe principale UI di LRM (EXPRESS/COMMENTI/ADMIN)
local mainUI, detailUI, goodsDetailUI, itemDetailWindow, playerTradeMainUI
CommentBoardUI = nil

-- chiude tutte le finestre
function closeAllUI()
    if itemDetailWindow then
        itemDetailWindow:close()
    end
    if playerTradeMainUI then
        playerTradeMainUI:close()
    end
    if goodsDetailUI then
        goodsDetailUI:close()
    end
    if ShopMainUI then
        ShopMainUI:close()
    end
    if AdminManageUI then
        AdminManageUI:close()
    end
    if CommentBoardUI then
        CommentBoardUI:close()
    end
    if UserManageUI then
        UserManageUI:close()
    end
    if OrderManageUI then
        OrderManageUI:close()
    end
end

-- apre finestra di vendita pacco
function openGoodEditWindow(items)
    if detailUI then
        detailUI:close()
    end

    -- init finestra
    detailUI = NewUI()
    detailUI:setWidthPercent(0.2)
    detailUI:setTitle(getText("UI_Goods_Edit"))
    addLine(detailUI)

    -- testo titolo
    detailUI:addText("", getText("UI_Goods_Edit_Title"), "Large", _)

    -- combo box per selezionare la categoria
    detailUI:addComboBox("GoodsCategory", GoodsTypeGroup)
    detailUI["GoodsCategory"]:setMarginHorizontal(10)
    detailUI:nextLine()

    -- testo per inserire il titolo
    detailUI:addEntry("GoodsTitle", "")
    detailUI:addEmpty()
    detailUI:nextLine()
    addLine(detailUI)

    -- testo per inserire il prezzo
    detailUI:addText("", getText("UI_Goods_Edit_Price"), "Large", _)
    detailUI:nextLine()
    detailUI:addEntry("GoodsPrice", "", true)
    detailUI["GoodsPrice"]:setOnlyNumbers(true)
    detailUI:addEmpty()
    detailUI:nextLine()
    addLine(detailUI)

    -- testo per inserire la descrizione
    detailUI:addText("", getText("UI_Goods_Edit_Desc"), "Large", _)
    detailUI:nextLine()
    detailUI:setLineHeightPercent(0.2)

    -- entry descrizione
    detailUI:addEntry("GoodsDesc", "")
    detailUI["GoodsDesc"]:setMultipleLine(true)
    detailUI["GoodsDesc"]:setMaxLines(12)
    detailUI:nextLine()
    addLine(detailUI)

    -- testo per inserire gli oggetti
    detailUI:addText("", getText("UI_Goods_Edit_Items"), "Large", _)
    detailUI:nextLine()

    local temp, itemList = getSelectItems(items)

    -- lista oggetti
    detailUI:addScrollList("ItemList", itemList)
    detailUI:nextLine()

    -- pulsante per vendere pacco 
    detailUI:addButton("btnAdd", getText("UI_Goods_Add"), function()

        if PlayerInventory.players[getPlayerId(getPlayer())].banned then
            doSystemHint("Banned Player", false)
        end

        if addPlayerCommodity(getPlayer(), detailUI["GoodsTitle"]:getValue(), GoodsType[detailUI["GoodsCategory"]:getIndex()], detailUI["GoodsPrice"]:getValue(), detailUI["GoodsDesc"]:getValue(), temp) then
            if SandboxVars.LRM.EnableGoodsBroadcast then            
                local broadcastText = getText("UI_Send_Goods_Broadcast", detailUI["GoodsTitle"]:getValue())
                processGeneralMessage(broadcastText)
                sendClientCommand("LRM", "LRMAddComment", { broadcastText })
            end
            detailUI:close()
        end
    end)
    detailUI["btnAdd"]:setMarginHorizontal(30)
    detailUI:setLineHeightPercent(0.05)
    detailUI:nextLine()
    addLine(detailUI)

    detailUI:saveLayout()
end

-- apre lista2? (TODO probabilmente da togliere)
local function openList2()
    if detailUI then
        detailUI:close()
    end

    -- init finestra
    detailUI = NewUI()
    detailUI:isSubUIOf(mainUI)

    local displayName = {}
    for k, v in pairs(CategoryGroupTable[mainUI["category"]:getValue()]) do
        table.insert(displayName, getItemDisplayName(k))
    end
    local displayName = --subUI:open()
    detailUI:addScrollList("goodsList", displayName)
    detailUI:saveLayout()
    --detailUI:setOnMouseDownFunction(_, openList)
    detailUI:setPositionPixel(mainUI:getX() + mainUI:getWidth(), mainUI:getY())
end

-- apre dettaglio item dalla lista pacco
local function openItemDetailWindow(items, _)
    local item = items[goodsDetailUI["GoodsList"]:getSelected()]
    if itemDetailWindow then
        itemDetailWindow:close()
    end

    -- init finestra
    itemDetailWindow = NewUI()
    itemDetailWindow:setTitle(getText("UI_Item_Detail"))
    itemDetailWindow:setWidthPercent(0.15)
    addLine(itemDetailWindow)

    -- testo nome oggetto
    itemDetailWindow:addText("ItemName", item.name, "Title", "Center")
    --itemDetailWindow:setLineHeightPercent(0.04)
    itemDetailWindow:nextLine()
    --addLine(itemDetailWindow)

    -- se c'è aggiunge condizione
    addConditionUI(item, itemDetailWindow, "ItemCondition", "ItemConditionValue")

    -- se c'è aggiunge delta
    addUsedDeltaUI(item, itemDetailWindow, "ItemDelta", "ItemDeltaValue")

    -- se c'è aggiunge età
    addAgeUI(item, itemDetailWindow, "ItemAge", "ItemAgeValue", "ItemAgeProgress")

    -- save layout
    itemDetailWindow:saveLayout()
    itemDetailWindow:setPositionPixel(goodsDetailUI:getX() + goodsDetailUI:getWidth() + 15, goodsDetailUI:getY())
end

-- apre finestra commenti
function openCommentBoardUI()
    if CommentBoardUI then
        CommentBoardUI:close()
    end

    -- init finestra
    CommentBoardUI = NewUI()
    CommentBoardUI:setTitle(getText("UI_Page_CommentBoard"))
    CommentBoardUI:setWidthPercent(0.5)
    addLine(CommentBoardUI)
    CommentBoardUI:setLineHeightPercent(0.7)
    --local commentList = buildCommonList()

    -- lista commenti
    CommentBoardUI:addScrollList("CommentList", {})
    CommentBoardUI:nextLine()
    addLine(CommentBoardUI)
    --CommentBoardUI:setLineHeightPercent(0.04)

    -- entry per inserire commento
    CommentBoardUI:addEntry("InputComment", "")
    CommentBoardUI["InputComment"]:setEnterFunc(function()
        sendClientCommand("LRM", "LRMAddComment", { CommentBoardUI["InputComment"]:getValue() })
        CommentBoardUI["InputComment"]:setValue("")
    end)
    CommentBoardUI:nextLine()
    addLine(CommentBoardUI)

    -- save layout
    CommentBoardUI:saveLayout()
    -- sync commenti
    sendClientCommand("LRM", "RequestCommentBoard", nil)
end

-- apre la finestra di dettaglio  e acquisto del pacco
function openGoodDetailWindow(UI, items)
    if itemDetailWindow then
        itemDetailWindow:close()
    end
    if goodsDetailUI then
        goodsDetailUI:close()
    end

    local index = UI["list"]:getSelected()
    local goodsInfo = items[index]
	local unit = SandboxVars.LRM.ExpressFee
    if goodsInfo.sellerId == getPlayerId(getPlayer()) then
        unit = SandboxVars.LRM.SelfExpressFee
    end

    -- init finestra
    goodsDetailUI = NewUI()
    goodsDetailUI:setWidthPercent(0.2)
    goodsDetailUI:setTitle(getText("UI_Goods_Detail"))
    addLine(goodsDetailUI)
    --goodsDetailUI:nextLine()

    -- testo nome pacco
    goodsDetailUI:addText("GoodsName", goodsInfo.name, "Large", "Center")
	goodsDetailUI:nextLine()
    addLine(goodsDetailUI)
    goodsDetailUI:addEmpty()
    --goodsDetailUI:addEmpty()

    -- testo nome venditore
    goodsDetailUI:addText("SellerName", getText("UI_Seller"), _, "Right")
    goodsDetailUI["SellerName"]:setMarginHorizontal(0)

    -- bottone nome venditore, apre lafinestra express con la lista dei pacchi del venditore
    goodsDetailUI:addButton("btnSeller", goodsInfo.seller, function()
        openPlayerTradeMainUI(goodsInfo.sellerId)
    end)
    goodsDetailUI["btnSeller"]:setMarginHorizontal(10)
    goodsDetailUI:nextLine()
    --addLine(goodsDetailUI)

    -- testo prezzo
    goodsDetailUI:addText("GoodsPrice", getText("UI_Goods_Price")..tostring(math.floor(goodsInfo.price * 100)).."$", "Medium", "Left")
    goodsDetailUI:setLineHeightPercent(0.02)
    goodsDetailUI:nextLine()
	
    -- testo tassa
    goodsDetailUI:addText("", getText("UI_Express_Fee", tostring(math.floor(goodsInfo.weight*unit)), tostring(goodsInfo.weight), tostring(unit)), "Medium", "Left")
	goodsDetailUI:nextLine()
	goodsDetailUI:nextLine()
    addLine(goodsDetailUI)
    goodsDetailUI:setLineHeightPercent(0.03)

    -- testo descrizione pacco
    goodsDetailUI:addText("", getText("UI_Goods_Edit_Desc"), "Medium", "Left")
    goodsDetailUI:nextLine()
    goodsDetailUI:setLineHeightPercent(0.2)

    -- se non c'è una descrizione, mette quella di default
    local goodsDesc = getText("UI_Goods_No_Desc")
    if goodsInfo.desc then
        goodsDesc = goodsInfo.desc
    end

    -- campo di testo descrizione
    goodsDetailUI:addEntry("GoodsDesc", goodsDesc)
    goodsDetailUI["GoodsDesc"]:setMultipleLine(true)
    goodsDetailUI["GoodsDesc"]:setMaxLines(12)
    goodsDetailUI["GoodsDesc"]:setEditable(false)
    goodsDetailUI:nextLine()

    -- testo contenuto pacco
	goodsDetailUI:addText("", "Contenuto Pacco: ", "Medium", "Left")
    goodsDetailUI:setLineHeightPercent(0.04)
    goodsDetailUI:nextLine()
    goodsDetailUI:setLineHeightPercent(0.2)

    -- popola la lista con i nomi del contenuto del pacco
    local itemList = {}
    local localItems = {}
    for _, item in pairs(goodsInfo.items) do

        table.insert(itemList, item.name)
        table.insert(localItems, item)
    end

    -- lista contenuto pacco
    goodsDetailUI:addScrollList("GoodsList", itemList)
    goodsDetailUI["GoodsList"]:setMarginHorizontal(10)
    goodsDetailUI["GoodsList"]:setOnMouseDownFunction(localItems, openItemDetailWindow)
    --goodsDetailUI["GoodsList"]:setWidthPercent(0.1)
    goodsDetailUI:nextLine()
    addLine(goodsDetailUI)

    -- calcola il valore del pacco
    local actGoodsValue = math.floor(goodsInfo.price * 100 + goodsInfo.weight * unit * SandboxVars.LRM.OrderWeightModifier)
    if goodsInfo.sellerId == getPlayerId(getPlayer()) then
        actGoodsValue = math.floor(goodsInfo.weight * unit)
    end

    local orderOutDateTime = SandboxVars.LRM.OrderTimeOutDate
    -- se il pacco è stato ordinato da più del limite di tempo, abilita il bottone per riordinarlo per il proprietario
    if (orderOutDateTime > 0 and goodsInfo.orderTime + orderOutDateTime < getGameTime():getWorldAgeHours() and goodsInfo.sellerId == getPlayerId(getPlayer())) then
        goodsDetailUI:addButton("btnEnable", getText("UI_Enable_Post", tostring(actGoodsValue)), function()
            goodsInfo.orderTime = getGameTime():getWorldAgeHours()
            sendClientCommand("LRM", "AddPlayerCommodity", { goodsInfo })
        end)
        goodsDetailUI["btnEnable"]:setMarginHorizontal(10)
    else
        goodsDetailUI:addEmpty()
    end
    goodsDetailUI:addEmpty()

    -- bottone per comprare il pacco
    goodsDetailUI:addButton("btnBuy", getText("UI_Buy", tostring(actGoodsValue)), function()
        if PlayerInventory.items[goodsInfo.id] == nil or PlayerInventory.items[goodsInfo.id].isFinish then
            getPlayer():Say("UI_Express_Finish")
            return
        end
        if getPlayerAssets(getPlayer()) < actGoodsValue then
            return
        end

        sendClientCommand("LRM", "RequestPlayerCommodity", { getPlayerId(getPlayer()), goodsInfo.id })

        -- TODO: reimplementare il broadcast risolvendo l'overflow dei moddata commenti
        --if SandboxVars.LRM.EnableGoodsBroadcast then
        --    local broadcastText = getText("UI_Send_Buy_Broadcast", goodsInfo.name)
        --    processGeneralMessage(broadcastText)
        --end
        --sendClientCommand("LRM", "LRMAddComment", { broadcastText })

        getPlayer():Say(getText("UI_Buy_Succeed"))
        closeAllUI()
    end)
    goodsDetailUI["btnBuy"]:setMarginHorizontal(10)
    goodsDetailUI:setLineHeightPercent(0.03)
    goodsDetailUI:nextLine()
    addLine(goodsDetailUI)

    -- se non ha abbastanza soldi, disabilita il bottone
    if getPlayerAssets(getPlayer()) < actGoodsValue then
        goodsDetailUI["btnBuy"]:setEnable(false)
    end

    -- se il giocatore è il venditore, il bottone per comprare il pacco diventa "ritira"
    if goodsInfo.sellerId == getPlayerId(getPlayer()) then
        goodsDetailUI["btnBuy"]:setText(getText("UI_Buy_Self", tostring(math.floor(goodsInfo.weight * unit))))
    end

    -- save layout
    goodsDetailUI:saveLayout()
    goodsDetailUI:setPositionPixel(UI:getX() + UI:getWidth() + 15, UI:getY())
end

-- aggiorna la lista da visualizzare in base alla categoria selezionata 
-- o al giocatore che ha messo in vendita i pacchi
function updateItemsByCategory(pId, category)
    local temp = {}
    local items = {}
    local orderOutDateTime = SandboxVars.LRM.OrderTimeOutDate

    for _, v in pairs(PlayerInventory.items) do
        if pId == nil or pId == v.sellerId then
            if (orderOutDateTime == 0 or v.orderTime + orderOutDateTime > getGameTime():getWorldAgeHours() or v.sellerId == getPlayerId(getPlayer())) and not PlayerInventory.players[(v.sellerId)].banned and v.isFinish == false and (category == "All" or v.category == category) then
                table.insert(temp, v.name)
                table.insert(items, v)
            end
        end
    end

    if playerTradeMainUI["list"] then
        playerTradeMainUI["list"]:setItems(temp)
    else
        playerTradeMainUI:addScrollList("list", temp)
    end
    playerTradeMainUI["list"]:setOnMouseDownFunction(items, function(items, _)
        openGoodDetailWindow(playerTradeMainUI, items)
    end)

    return temp, items
end

-- apre finestra express (se c'è pId mostra solo i pacchi di quel player)
function openPlayerTradeMainUI(pId)
    if playerTradeMainUI then
        playerTradeMainUI:close()
    end
    -- init finestra
    playerTradeMainUI = NewUI()
    playerTradeMainUI:setWidthPercent(0.25)
    addLine(playerTradeMainUI)

    -- combobox categorie
    playerTradeMainUI:addComboBox("Category", GoodsTypeGroup)
    playerTradeMainUI["Category"]:setMarginHorizontal(10)
    playerTradeMainUI["Category"]:setOnChange(function()
        updateItemsByCategory(pId, GoodsType[playerTradeMainUI["Category"]:getIndex()])
    end)
   --playerTradeMainUI:addEmpty()

    -- testo bilancio totale
    playerTradeMainUI:addText("YourAssets", getText("UI_Total_Assets", tostring(getPlayerAssets(getPlayer()))), "Large", "Center")
    --playerTradeMainUI:addEmpty()
    playerTradeMainUI:nextLine()
    addLine(playerTradeMainUI)

    -- testo descrizione (TODO: aggiungere stringa localizzata)
    playerTradeMainUI:addText("ListDescription", "Materiali stoccati:", "Small", "Left")
	playerTradeMainUI:nextLine()
    --addLine(playerTradeMainUI)

    -- lista pacchi
    updateItemsByCategory(pId, "All")
    playerTradeMainUI:setLineHeightPercent(0.5)
    playerTradeMainUI:nextLine()
    addLine(playerTradeMainUI)

    -- pulsante aggiorna finestra
    playerTradeMainUI:addButton("UpdateBtn", getText("UI_Update_Page"), function()
        openPlayerTradeMainUI(pId)
    end)
    playerTradeMainUI:setLineHeightPercent(0.05)
    playerTradeMainUI["UpdateBtn"]:setMarginHorizontal(30)
    playerTradeMainUI:nextLine()
    addLine(playerTradeMainUI)

    -- salva layout
    playerTradeMainUI:saveLayout()
    playerTradeMainUI:setPositionPixel(playerTradeMainUI:getX() - playerTradeMainUI:getWidth() / 2, playerTradeMainUI:getY())
end

-- TODO togliere? vecchia funzione che apriva il menu di scelta tra market/express/commenti/admin
function openMainUI()
    if mainUI then
        mainUI:toggle()
        return
    end

    mainUI = NewUI()

    mainUI:setTitle(getText("UI_Kentucky_Shop"))

    addLine(mainUI)
    mainUI:addButton("btn1", getText("UI_Page_Official_Trade"), function()
        mainUI:toggle()
        openShopMainUI(CategoryAll)
    end)
    mainUI:setLineHeightPercent(0.05)
    mainUI["btn1"]:setMarginHorizontal(30)
    mainUI:nextLine()
    addLine(mainUI)

    mainUI:addButton("btn2", getText("UI_Page_Player_Trade"), function()
        mainUI:toggle()
        openPlayerTradeMainUI(nil)
    end)
    mainUI:setLineHeightPercent(0.05)
    mainUI["btn2"]:setMarginHorizontal(30)
    mainUI:nextLine()
    addLine(mainUI)

    mainUI:addButton("btn3", getText("UI_Page_CommentBoard"), function()
        openCommentBoardUI()
    end)
    mainUI:setLineHeightPercent(0.05)
    mainUI["btn3"]:setMarginHorizontal(30)
    mainUI:nextLine()
    addLine(mainUI)

    if isSinglePlayer() or getPlayer():getAccessLevel() ~= "None" then
        mainUI:addButton("btn4", getText("UI_Page_Admin"), function()
            closeAllUI()

            createAdminUI()

            if mainUI then
                mainUI:close()
                return
            end
        end)
        mainUI:setLineHeightPercent(0.05)
        mainUI["btn4"]:setMarginHorizontal(30)
        mainUI:nextLine()
        addLine(mainUI)
    end

    mainUI:saveLayout()
end

function openTradingUI()
    if not isNearLRMObject("Advanced Trading Post") then
        return
    end

    closeAllUI()
    openMainUI()
end

function openCommentUI()
    if not isNearLRMObject("LRMMailbox") then
        return
    end

    closeAllUI()
    openCommentBoardUI()
end

function openMarketUI()
    if not isNearLRMObject("LRMMarket") then
        return
    end

    closeAllUI()
	openShopMainUI(CategoryAll)
end

function openExpressUI()
    if not isNearLRMObject("LRMExpress") then
        return
    end

    closeAllUI()
    openPlayerTradeMainUI(nil)
end

function openAdminUI()
	if not isAdmin() and not getPlayer():getAccessLevel() ~= "None" then
		return
	end

	closeAllUI()
	createAdminUI()
end

-- questa esiste ancora lol (serve solo per la finestra admin :V)
local function OnKeyPressed(key)
    if key == 54 then
        openTradingUI()
    end
    if key == 53 then
        openCommentUI()
    end
    if key == 52 then
        openExpressUI()
    end
    if key == 51 then
        openMarketUI()
    end
    if key == 40 then
		openAdminUI()
    end
end

Events.OnKeyPressed.Add(OnKeyPressed)