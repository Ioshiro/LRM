-- Classe UI del market

ShopMainUI = nil
local selectedItemName
local shoppingList = {}
local actShoppingList = {}
local displayName = {}
local firstItemCount = nil
local totalValue = 0
local tempShopInventory

-- aggiorna il valore totale della spesa visualizzato sul bottone acquista
local function updateBuyBtn()
    if ShopMainUI and ShopMainUI["BtnBuy"] then
        ShopMainUI["BtnBuy"]:setText(getText("UI_Buy", tostring(totalValue)))

        -- se non ha abbastanza soldi disabilita il bottone
        if getPlayerAssets(getPlayer()) < totalValue then
            ShopMainUI["BtnBuy"]:setEnable(false)
            ShopMainUI["BtnBuy"].textColor = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
        else
            ShopMainUI["BtnBuy"]:setEnable(true)
            ShopMainUI["BtnBuy"].textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
        end
    end
end

-- aggiunge un oggetto alla lista della spesa
local function doAddShoppingList(button, args)
	if not displayName[selectedItemName] then return end
    if displayName[selectedItemName][2] == 0 then return end
    if not ShopMainUI or not ShopMainUI["ShoppingList"] then return end

    -- aggiunge item alla table e alla lista ui
    table.insert(shoppingList, selectedItemName)
    table.insert(actShoppingList, displayName[selectedItemName][1])
    ShopMainUI["ShoppingList"]:setItems(shoppingList)
	
    -- se sono soldi o mazzetta non decrementa il contatore nella lista ui
	if displayName[selectedItemName][1] ~= "Base.Money" and displayName[selectedItemName][1] ~= "MoneyToXP.XPMoneyStack" then
		displayName[selectedItemName][2] = displayName[selectedItemName][2] - 1
	end
    tempShopInventory[displayName[selectedItemName][1]] = displayName[selectedItemName][2]

    -- aggiorna tasto aggiungi alla lista spesa con nome item e prezzo
    ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    
    -- aggiorna il valore totale della spesa
    totalValue = totalValue + getThePrice(displayName[selectedItemName][1])
    updateBuyBtn()
end

-- rimuove un oggetto dalla lista della spesa
local function doRemoveShoppingList(_, _)
    if not ShopMainUI or not ShopMainUI["ShoppingList"] then return end

    local index = ShopMainUI["ShoppingList"]:getSelected()
    local selectedItemName = shoppingList[index]

    -- rimuove item dalla table e dalla lista ui
    table.remove(shoppingList, index)
    table.remove(actShoppingList, index)
    ShopMainUI["ShoppingList"]:setItems(shoppingList)

    -- se sono soldi o mazzetta non incrementa il contatore nella lista ui
	if displayName[selectedItemName][1] ~= "Base.Money" and displayName[selectedItemName][1] ~= "MoneyToXP.XPMoneyStack" then
		displayName[selectedItemName][2] = displayName[selectedItemName][2] + 1
	end
    tempShopInventory[displayName[selectedItemName][1]] = displayName[selectedItemName][2]

    -- aggiorna tasto aggiungi alla lista spesa con nome item e prezzo
    ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    
    -- aggiorna il valore totale della spesa
    totalValue = totalValue - getThePrice(displayName[selectedItemName][1])
    updateBuyBtn()
end

-- hook per comprare la lista della spesa
local function doBuy(button, args)
    doBuyTradingItem(actShoppingList, totalValue)
    getPlayer():Say(getText("UI_Buy_Succeed"))
    if ShopMainUI then
        ShopMainUI:close()
    end
end

-- filtro oggeti per categoria
local function getItemsByCategory(category)
    displayName = {}

    firstItemCount = nil
    for k, v in pairs(tempShopInventory) do
        if v > 0 and (ItemValueTable[k] and ItemValueTable[k] > 0.0 and (category == "All" or CategoryGroupTable[category][k] ~= nil)) then
            if firstItemCount == nil then
                firstItemCount = { k, v }
                selectedItemName = getItemDisplayName(k)
            end
            displayName[getItemDisplayName(k) .. "[" .. k .. "]"] = { k, v }
        end
    end

    return displayName
end

-- toggle finestra listino prezzi
function toggleItemManageUI(shopMainUI, editable)
	if ItemManageUI then 
		ItemManageUI:close()
		ItemManageUI = nil
	else 
		openItemManageUI(ShopMainUI, false) 
	end
end

-- apre la finestra principale del market
function openShopMainUI(categories)
    if ShopMainUI then
        ShopMainUI:close()
    end

    tempShopInventory = table.shallow_copy(SyncContainer)
    shoppingList = {}
    actShoppingList = {}
    firstItemCount = nil
    totalValue = 0

    -- init finestra
    ShopMainUI = NewUI()
    ShopMainUI:setWidthPercent(0.25)
    ShopMainUI:setTitle(getText("UI_Kentucky_Shop"))
    addLine(ShopMainUI)

    -- combo box per selezionare la categoria
    ShopMainUI:addComboBox("Category", categories)
    ShopMainUI["Category"]:setMarginHorizontal(10)

    -- testo bilancio
    ShopMainUI:addText("YourAssets", getText("UI_Total_Assets", tostring(getPlayerAssets(getPlayer()))), "Large", "Center")
    ShopMainUI:nextLine()
    addLine(ShopMainUI)
    ShopMainUI:addEmpty()
    ShopMainUI:addEmpty()

    -- bottone listino prezzi
    ShopMainUI:addButton("BtnPriceTable", getText("UI_Price_Table"), function()
		toggleItemManageUI(shopMainUI, false)
    end)
    ShopMainUI["BtnPriceTable"]:setMarginHorizontal(20)
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- testo item disponibili e carrello (TODO aggiungere stringa localizzata)
    ShopMainUI:addText("TableDescription", "Item disponibili:", "Small", "Left")
    ShopMainUI:addText("TableDescription2", "Carrello:", "Small", "Left")
	ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- lista item disponibili, selezionarli modifica il bottone aggiungi alla lista spesa
    ShopMainUI:addScrollList("ShopInventory", getItemsByCategory("All"))
    ShopMainUI["ShopInventory"]:setOnMouseDownFunction(_, function(_, item)
        local value, it = ShopMainUI["ShopInventory"]:getValue()
        selectedItemName = value
        ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    end)
    ShopMainUI:setLineHeightPercent(0.3)

    -- lista item nella lista spesa, selezionarli elimina l'item dalla lista
    ShopMainUI:addScrollList("ShoppingList", {})
    ShopMainUI["ShoppingList"]:setOnMouseDownFunction(shoppingList, doRemoveShoppingList)
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- al cambio categoria aggiorna la lista item disponibili
    ShopMainUI["Category"]:setOnChange(function()
		local cat = ShopMainUI["Category"]:getValue()
		openShopMainUI(categories)
		ShopMainUI["Category"]:select(cat)
        ShopMainUI["ShopInventory"]:setItems(getItemsByCategory(cat))
    end)
    ShopMainUI:addText("GoodsName", "", "Large", "Center")
    ShopMainUI:addText("GoodsPrice", "", "Large", "Center")
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- bottone aggiungi a lista della spesa TODO aggiungere stringa localizzata
    ShopMainUI:addButton("AddShoppingList", "Seleziona Item da aggiungere al carrello", doAddShoppingList)
    ShopMainUI["AddShoppingList"]:setMarginHorizontal(30)
    ShopMainUI:setLineHeightPercent(0.05)
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- bottone acquista lista spesa
    ShopMainUI:addButton("BtnBuy", getText("UI_Buy", "0"), doBuy)
    updateBuyBtn()
    ShopMainUI["BtnBuy"]:setMarginHorizontal(30)
    ShopMainUI:setLineHeightPercent(0.05)
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    -- save layout
    ShopMainUI:saveLayout()
	toggleItemManageUI(shopMainUI, false)
end