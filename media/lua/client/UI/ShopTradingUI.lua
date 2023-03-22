

ShopMainUI = nil
local selectedItemName
local shoppingList = {}
local actShoppingList = {}
local displayName = {}

local firstItemCount = nil
local totalValue = 0

local tempShopInventory

local function updateBuyBtn()
    if ShopMainUI and ShopMainUI["BtnBuy"] then
        ShopMainUI["BtnBuy"]:setText(getText("UI_Buy", tostring(totalValue)))

        if getPlayerAssets(getPlayer()) < totalValue then
            ShopMainUI["BtnBuy"]:setEnable(false)
            ShopMainUI["BtnBuy"].textColor = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }

        else
            ShopMainUI["BtnBuy"]:setEnable(true)
            ShopMainUI["BtnBuy"].textColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

        end

    end
end

local function doAddShoppingList(button, args)
	if not displayName[selectedItemName] then return end
    if displayName[selectedItemName][2] == 0 then
        return
    end

    if not ShopMainUI or not ShopMainUI["ShoppingList"] then
        return
    end
    table.insert(shoppingList, selectedItemName)
    table.insert(actShoppingList, displayName[selectedItemName][1])
    --local temp = shoppingList
    ShopMainUI["ShoppingList"]:setItems(shoppingList)
	
	if displayName[selectedItemName][1] ~= "Base.Money" and displayName[selectedItemName][1] ~= "MoneyToXP.XPMoneyStack" then
		displayName[selectedItemName][2] = displayName[selectedItemName][2] - 1
	end
    tempShopInventory[displayName[selectedItemName][1]] = displayName[selectedItemName][2]
    totalValue = totalValue + getThePrice(displayName[selectedItemName][1])

    ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    updateBuyBtn()
    --ShopMainUI["BtnBuy"]:setText(getText("UI_Buy", tostring(totalValue)))


end

local function doRemoveShoppingList(_, _)
    if not ShopMainUI or not ShopMainUI["ShoppingList"] then
        return
    end
    local index = ShopMainUI["ShoppingList"]:getSelected()
    local selectedItemName = shoppingList[index]
    --print(tostring(index))
    table.remove(shoppingList, index)
    table.remove(actShoppingList, index)

    ShopMainUI["ShoppingList"]:setItems(shoppingList)

	if displayName[selectedItemName][1] ~= "Base.Money" and displayName[selectedItemName][1] ~= "MoneyToXP.XPMoneyStack" then
		displayName[selectedItemName][2] = displayName[selectedItemName][2] + 1
	end
    tempShopInventory[displayName[selectedItemName][1]] = displayName[selectedItemName][2]
    totalValue = totalValue - getThePrice(displayName[selectedItemName][1])

    ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    --ShopMainUI["BtnBuy"]:setText(getText("UI_Buy", tostring(totalValue)))
    updateBuyBtn()

end

local function doBuy(button, args)
    --local temp = actShoppingList
    doBuyTradingItem(actShoppingList, totalValue)
    getPlayer():Say(getText("UI_Buy_Succeed"))

    if ShopMainUI then
        ShopMainUI:close()
    end
end

local function getItemsByCategory(category)
    displayName = {}

    firstItemCount = nil
    for k, v in pairs(tempShopInventory) do
        if v > 0 and (ItemValueTable[k] and ItemValueTable[k] > 0.0 and (category == "All" or CategoryGroupTable[category][k] ~= nil)) then
            --local temp = {}
            --temp[k] = v
            if firstItemCount == nil then
                firstItemCount = { k, v }
                selectedItemName = getItemDisplayName(k)
            end
            displayName[getItemDisplayName(k) .. "[" .. k .. "]"] = { k, v }
        end
        --table.insert(displayName, getItemDisplayName(k))
    end

    --if ShopMainUI["AddShoppingList"] and firstItemCount then
     --   ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(firstItemCount[1]), tostring(firstItemCount[2])))
    --end
    return displayName
    --ShopMainUI["ShopInventory"]:setItems(displayName)
end

function toggleItemManageUI(shopMainUI, editable)
	if ItemManageUI then 
		ItemManageUI:close()
		ItemManageUI = nil
	else 
		openItemManageUI(ShopMainUI, false) 
	end
end

function openShopMainUI()
    if ShopMainUI then
        ShopMainUI:close()
    end

    tempShopInventory = table.shallow_copy(SyncContainer)
    shoppingList = {}
    actShoppingList = {}
    firstItemCount = nil
    totalValue = 0

    ShopMainUI = NewUI()
    ShopMainUI:setWidthPercent(0.25)
    ShopMainUI:setTitle(getText("UI_Kentucky_Shop"))

    addLine(ShopMainUI)

    ShopMainUI:addComboBox("Category", CategoryList)
    ShopMainUI["Category"]:setMarginHorizontal(10)

    ShopMainUI:addText("YourAssets", getText("UI_Total_Assets", tostring(getPlayerAssets(getPlayer()))), "Large", "Center")
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    ShopMainUI:addEmpty()
    ShopMainUI:addEmpty()
    ShopMainUI:addButton("BtnPriceTable", getText("UI_Price_Table"), function()
        --openItemManageUI(ShopMainUI, false)
		toggleItemManageUI(shopMainUI, false)
    end)
    ShopMainUI["BtnPriceTable"]:setMarginHorizontal(20)

    ShopMainUI:nextLine()
    addLine(ShopMainUI)
    ShopMainUI:addText("TableDescription", "Item disponibili:", "Small", "Left")

    ShopMainUI:addText("TableDescription2", "Carrello:", "Small", "Left")
	ShopMainUI:nextLine()
    addLine(ShopMainUI)
    ShopMainUI:addScrollList("ShopInventory", getItemsByCategory("All"))
    ShopMainUI["ShopInventory"]:setOnMouseDownFunction(_, function(_, item)
		
        local value, it = ShopMainUI["ShopInventory"]:getValue()
        selectedItemName = value
        ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", getThePrice(displayName[selectedItemName][1]), tostring(displayName[selectedItemName][2])))
    end)
    ShopMainUI:setLineHeightPercent(0.3)
    --ShopMainUI["ShopInventory"]:setBorder(true)

    ShopMainUI:addScrollList("ShoppingList", {})
    ShopMainUI["ShoppingList"]:setOnMouseDownFunction(shoppingList, doRemoveShoppingList)

    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    ShopMainUI["Category"]:setOnChange(function()
		--if shoppingList then table.remove(shoppingList) end
		--if actShoppingList then table.remove(actShoppingList) end
		--ShopMainUI["ShoppingList"]:setItems({})
		local cat = ShopMainUI["Category"]:getValue()
		openShopMainUI()
		ShopMainUI["Category"]:select(cat)
        ShopMainUI["ShopInventory"]:setItems(getItemsByCategory(cat))

    end)

    --ShopMainUI:nextColumn()


    ShopMainUI:addText("GoodsName", "", "Large", "Center")
    ShopMainUI:addText("GoodsPrice", "", "Large", "Center")
    ShopMainUI:nextLine()
    addLine(ShopMainUI)

  --  if firstItemCount then
  --      ShopMainUI:addButton("AddShoppingList", getText("UI_Add_Shopping_List", getThePrice(firstItemCount[1]), tostring(firstItemCount[2])), doAddShoppingList)
  --  else
        ShopMainUI:addButton("AddShoppingList", "Seleziona Item da aggiungere al carrello", doAddShoppingList)
  --  end
    --ShopMainUI["AddShoppingList"]:setText(getText("UI_Add_Shopping_List", tostring(firstItemCount)))
    --ShopMainUI:setWidthPercent(0.1)
    ShopMainUI["AddShoppingList"]:setMarginHorizontal(30)
    ShopMainUI:setLineHeightPercent(0.05)

    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    ShopMainUI:addButton("BtnBuy", getText("UI_Buy", "0"), doBuy)
    updateBuyBtn()
    ShopMainUI["BtnBuy"]:setMarginHorizontal(30)
    ShopMainUI:setLineHeightPercent(0.05)

    ShopMainUI:nextLine()
    addLine(ShopMainUI)

    ShopMainUI:saveLayout()
	toggleItemManageUI(shopMainUI, false)
    --ShopMainUI["AddShoppingList"]:setWidthPercent(0.1)
end