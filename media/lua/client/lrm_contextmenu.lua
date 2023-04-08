require "TimedActions/ISBaseTimedAction"
require "ItemUtil"
require "LRMSyncManager"
require "UI/LRMMainUI"

LRM = {};

MaxStock = 999;
SelectedContainer = nil;
LRM.ShowWares = function(_, tp)

    if tp == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    local out = "";
    --local tempTable = {};

    --local ic = getContainerItems(tp)
    --for i = 0, ic:size() - 1 do
    --    if (tempTable[ic:get(i):getFullType()] == nil) then
    --        tempTable[ic:get(i):getFullType()] = 1;
    --    else
    --        tempTable[ic:get(i):getFullType()] = tempTable[ic:get(i):getFullType()] + 1
    --    end
    --
    --end
    local itemInfo
    for k, v in pairs(tp) do

        itemInfo = instanceCommodity(k);
        if itemInfo ~= nil then
            out = out .. getText("UI_text1", tostring(v), itemInfo.displayName, itemInfo.displayPrice, itemInfo.displayInflation) .. "\n";
        end

    end

    out = out .. "\n";

    LRMWindow:setText(out);
    LRMWindow:setVisible(true);

end

function makeToolTip(option, name, desc)
    local toolTip = ISToolTip:new();
    toolTip:initialise();
    toolTip:setVisible(false);
    -- add it to our current option
    option.toolTip = toolTip;
    toolTip:setName(name);
    toolTip.description = desc .. " <LINE> ";
    --toolTip:setTexture("crafted_01_16");

    --toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> More Desc" ;
    --option.notAvailable = true;
    return toolTip;
end

local function showTotalValue(items)

    --local items = getContainerItems(container)
    --local items = container:getItems()
    local totalValue = 0.00;
    local totalValueString = getText("UI_Appraisal_Breakdown") .. "\n\n";
    local type;
    local item

    local tempOfferGroupTable = {};

    for _, v in ipairs(items) do
            if not instanceof(v, "InventoryItem") then
                item = v.items[1]
                type = v.items[1]:getFullType()
            else
                item = v
                type = v:getFullType()
            end
            --if type ~= "LRM.AdvancedTradingPostInv" then
            if ItemValueTable[type] ~= nil and ItemValueTable[type] > 0.0 then
                if not checkItemUseful(item) then
                    totalValueString = totalValueString .. getItemUselessText(item) .. "\n\n";

                    --local text = getItemUselessText(items:get(i))
                else
                    local itemInfo = instanceCommodity(type);

                    if itemInfo and itemInfo.price then
                        totalValue = totalValue + itemInfo.price;
                        --if (tempOfferGroupTable[type] == nil) then
                        --local itemCount = getInStockCount(container, type);
                        tempOfferGroupTable[type] = true;
                        totalValueString = totalValueString .. getText("UI_View_Wares_desc", itemInfo.displayName, itemInfo.displayPrice, itemInfo.displayInflation) .. "\n\n";
                    end

                end

                --end
            else

                --end
            end
    end
    local TPUsageTax = (totalValue * SandboxVars.LRM.SellHandlingFee / 100);
    totalValue = totalValue - TPUsageTax;
    totalValueString = totalValueString .. getText("UI_Trading_Tax", tostring(SandboxVars.LRM.SellHandlingFee)) .. " (" .. tostring(math.floor(TPUsageTax * 100)) .. ") \n " .. getText("UI_Totaled_to") .. tostring(math.floor(totalValue * 100));
    print("total value calc: " .. tostring(totalValue));

    return totalValue, totalValueString


end

local function showTotalDeposit(items, fromStack)

    local totalValue = 0.00;
    local totalValueString = getText("UI_Appraisal_Breakdown") .. "\n\n";
    local type;
    local item
	local stackValue = 0.00;
    for _, v in ipairs(items) do
            if not instanceof(v, "InventoryItem") then
                item = v.items[1]
                type = v.items[1]:getFullType()
            else
                item = v
                type = v:getFullType()
            end
            if type == "Base.Money" then
				totalValue = totalValue + 0.01;
				stackValue = 0.01
			elseif type == "MoneyToXP.XPMoneyStack" then
				totalValue = totalValue + 1
				stackValue = 1.0
            end
    end
	if fromStack then totalValue = totalValue - stackValue end
    totalValueString = totalValueString .. getText("UI_Totaled_to") .. tostring(math.floor(totalValue * 100));
    print("total value calc: " .. tostring(totalValue));

    return totalValue, totalValueString


end

local function addSellMenu(context, items)

    --if not isAdmin() and not getPlayer():getAccessLevel() ~= "None" then
	--	return
	--end
    local totalValue, totalValueString = showTotalValue(items)

    local TradeForOption = context:addOption(getText("UI_Sell_Contents"), nil, LRM.DoSell, items);
    makeToolTip(TradeForOption, getText("UI_View_Wares_name", tostring(math.floor(totalValue * 100))), totalValueString);

end

local function addDepositMenu(context, items, fromStack)

	local totalValue, totalValueString = showTotalDeposit(items, fromStack)
	local DepositOption = context:addOption(getText("UI_Deposit_Money"), nil, LRM.DoDeposit, items, fromStack);
	makeToolTip(DepositOption, getText("UI_View_Deposit_Total", tostring(math.floor(totalValue * 100))), "");
end	


local function OnFillInventoryObjectContextMenu(player, context, items)

    local tradePostItem;
    local hasSellOption = false
	local hasDepositOption = false
    local temp, itemList = getSelectItems(items)

    for _, v in ipairs(items) do


        if not instanceof(v, "InventoryItem") then
            tradePostItem = v.items[1];
        else
            tradePostItem = v
        end

        --print("Trade post item: "..tradePostItem:getType())

        if (tradePostItem ~= nil) then

            local tempContainer = getSyncContainer()

            local selectedContainer

            if tradePostItem:getName() == "LRMMarket" then
                selectedContainer = tradePostItem:getContainer()
            elseif getParentContainer(tradePostItem) ~= nil and getParentContainer(tradePostItem):getName() == "LRMMarket" then
                selectedContainer = tradePostItem:getContainer()
			elseif isNearLRMObject("LRMMailbox") or isNearLRMObject("location_business_bank_01_64") or isNearLRMObject("location_business_bank_01_65") or isNearLRMObject("location_business_bank_01_66")or isNearLRMObject("location_business_bank_01_67") or isNearLRMObject("LRMMarket") then
				selectedContainer = tradePostItem:getContainer()
				SelectedContainer = tradePostItem:getContainer()
			end
			if
                selectedContainer and not hasDepositOption and (tradePostItem:getFullType() == "Base.Money" or tradePostItem:getFullType() == "MoneyToXP.XPMoneyStack") then
                hasSellOption = true
				hasDepositOption = true
				if not instanceof(v, "InventoryItem") then
					addDepositMenu(context,items[1].items, true)

				else
					addDepositMenu(context,items, false)
				end

			end
			
            if selectedContainer and not hasSellOption then
                hasSellOption = true
                addSellMenu(context, items)
            end
        end

    end


end

LRM.UpdateOnServer = function(modifyTable)
    modifySyncContainer(modifyTable)
end


LRM.DoSell = function(_, items)

    if PlayerInventory.players[getPlayerId(getPlayer())].banned then
        doSystemHint("Banner Player", false)
        return
    end


    local syncContainer = getSyncContainer()

    if syncContainer == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    --local items = itemContainer:getItems()

    local ItemsToRemoveTable = {};

    local totalValue, _ = showTotalValue(items)
    sendClientCommand("LRM", "UpdatePlayerScore", { getPlayerId(getPlayer()), totalValue })

    local tempTable = {}
    local item
    local type 

    for _, v in ipairs(items) do
        if not instanceof(v, "InventoryItem") then
            item = v.items[1]
            type = v.items[1]:getFullType()
        else
            item = v
            type = v:getFullType()
        end
        --if (item ~= nil) and (item ~= fakeContainer) then
        if ItemValueTable[type] ~= nil and ItemValueTable[type] > 0.0 and checkItemUseful(item) then

            table.insert(ItemsToRemoveTable, item);
            if tempTable[type] == nil then
                tempTable[type] = 0
            end
            tempTable[type] = tempTable[type] + 1



		--end
        end

    end

    for k,i in pairs(ItemsToRemoveTable) do
        --print("CONTAINER:: "..(SelectedContainer:getType() or "nil"))
        --SelectedContainer:removeItemOnServer(i);
        local wi = i:getWorldItem()
        if wi ~= nil then
            local sq = wi:getSquare();
            sq:transmitRemoveItemFromSquare(wi);
            wi:removeFromSquare();
        end
        SelectedContainer:DoRemoveItem(i)

    end


    --local count = 1;
    --local container = syncContainer:getItemContainer()
    --local tempTable = {}

    --while (ItemsToRemoveTable[count]) do
    --    item = postContainer:FindAndReturn(ItemsToRemoveTable[count]);
    --    if (item ~= nil) then
    --
    --        local category = item:getDisplayCategory();
    --        if (category == nil) then
    --            category = item:getCategory();
    --        end
    --        ItemCategoryTable[item] = category;
    --        if (not has_value(CategoryList, category)) then
    --            table.insert(CategoryList, category)
    --        end
    --
    --        --print("removing " .. itype .. " donated");
    --
    --        if tempTable[item:getFullType()] == nil then
    --            tempTable[item:getFullType()] = 0
    --        end
    --
    --        tempTable[item:getFullType()] = tempTable[item:getFullType()] + 1
    --
    --        container:addItemOnServer(item);
    --        container:AddItem(item);
    --        --table.insert(addOption, { workingitem, 1 })
    --
    --        postContainer:removeItemOnServer(item);
    --        postContainer:DoRemoveItem(item);
    --    end
    --
    --    count = count + 1;
    --end

    if (LRMWindow:isVisible()) then
        LRM.ShowWares(nil, syncContainer);
    end

    getSpecificPlayer(0):Say(getText("UI_Thanks"));
    LRM.UpdateOnServer(tempTable);
end

LRM.DoDeposit = function(_, items, fromStack)

    local syncContainer = getSyncContainer()

    if syncContainer == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    local ItemsToRemoveTable = {};

    local totalValue, _ = showTotalDeposit(items, fromStack)
    sendClientCommand("LRM", "UpdatePlayerScore", { getPlayerId(getPlayer()), totalValue })

    local tempTable = {}
    local item
    local type 

    for _, v in ipairs(items) do
        if not instanceof(v, "InventoryItem") then
            item = v.items[1]
            type = v.items[1]:getFullType()
        else
            item = v
            type = v:getFullType()
        end
        if type == "Base.Money" or type == "MoneyToXP.XPMoneyStack" then
            table.insert(ItemsToRemoveTable, item);
        end

    end

    for k,i in pairs(ItemsToRemoveTable) do
        local wi = i:getWorldItem()
        if wi ~= nil then
            local sq = wi:getSquare();
            sq:transmitRemoveItemFromSquare(wi);
            wi:removeFromSquare();
        end
        SelectedContainer:DoRemoveItem(i)
        
    end

    if (LRMWindow:isVisible()) then
        LRM.ShowWares(nil, syncContainer);
    end
    getSpecificPlayer(0):Say(getText("UI_Thanks"));
end

--LRM.ForceDrop = function(_, player, item)
--
--    initTP(item);
--    player:getCurrentSquare():AddWorldInventoryItem(item, 0.0, 0.0, 0.0, true);
--    player:getInventory():Remove(item);
--
--end

LRM.RemoveItem = function(_, container)

    getPlayer()

    local wi = container:getWorldItem();
    if wi ~= nil then
        local sq = wi:getSquare();
        sq:transmitRemoveItemFromSquare(wi);
        wi:removeFromSquare();
    else
        container:getContainer():DoRemoveItem(container)
        --container:getContainer():removeItemOnServer(container);
    end


    --item:get

    --
    --initTP(item);
    --player:getCurrentSquare():AddWorldInventoryItem(item, 0.0, 0.0, 0.0, true);
    --player:getInventory():Remove(item);

end

function LRM.openExpressUI()
    closeAllUI()
    openPlayerTradeMainUI(nil)
end

function LRM.openMarketUI()
    closeAllUI()
	openShopMainUI()
end

function LRM.openCommentUI()
    closeAllUI()
    openCommentBoardUI()
end

local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
	if isNearLRMObject("LRMExpress") then
		context:addOption("Apri Express", thump, LRM.openExpressUI, player)
	elseif isNearLRMObject("LRMMarket") then
		context:addOption("Apri Market", thump, LRM.openMarketUI, player)
	elseif isNearLRMObject("LRMMailbox") then
		context:addOption("Apri Mailbox", thump, LRM.openCommentUI, player)
	end
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu);
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)