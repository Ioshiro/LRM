require "TimedActions/ISBaseTimedAction"
require "ItemUtil"
require "LRMSyncManager"
require "UI/LRMMainUI"

-- classe principale di creazione opzioni nel menu contestuale e gestione delle azioni

LRM = {};
MaxStock = 999;
SelectedContainer = nil;

-- calcola il valore totale di un insieme di oggetti
local function showTotalValue(items)
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

        if ItemValueTable[type] ~= nil and ItemValueTable[type] > 0.0 then
            if not checkItemUseful(item) then
                totalValueString = totalValueString .. getItemUselessText(item) .. "\n\n"
            else
                local itemInfo = instanceCommodity(type);
                if itemInfo and itemInfo.price then
                    totalValue = totalValue + itemInfo.price
                    tempOfferGroupTable[type] = true;
                    totalValueString = totalValueString .. getText("UI_View_Wares_desc", itemInfo.displayName, itemInfo.displayPrice, itemInfo.displayInflation) .. "\n\n";
                end
            end
        end
    end

    local TPUsageTax = (totalValue * SandboxVars.LRM.SellHandlingFee / 100);
    totalValue = totalValue - TPUsageTax;
    totalValueString = totalValueString .. getText("UI_Trading_Tax", tostring(SandboxVars.LRM.SellHandlingFee)) .. " (" .. tostring(math.floor(TPUsageTax * 100)) .. ") \n " .. getText("UI_Totaled_to") .. tostring(math.floor(totalValue * 100));
    print("total value calc: " .. tostring(totalValue));

    return totalValue, totalValueString
end

-- calcola valore soldi depositati 
-- (flag fromStack controlla se gli item sono dentro uno stack che genera un item virtuale in più)
local function showTotalDeposit(items, fromStack)
    local totalValue = 0.00
    local totalValueString = getText("UI_Appraisal_Breakdown") .. "\n\n"
    local type
    local item
	local stackValue = 0.00

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
    -- se è un stack di soldi, togliamo il valore di un singolo soldo
	if fromStack then totalValue = totalValue - stackValue end

    totalValueString = totalValueString .. getText("UI_Totaled_to") .. tostring(math.floor(totalValue * 100));
    print("total value calc: " .. tostring(totalValue));

    return totalValue, totalValueString
end

-- aggiunge opzione di vendita al menu contestuale
local function addSellMenu(context, items)
    --if not isAdmin() and not getPlayer():getAccessLevel() ~= "None" then
	--	return
	--end

    local totalValue, totalValueString = showTotalValue(items)

    local TradeForOption = context:addOption(getText("UI_Sell_Contents"), nil, LRM.DoSell, items);
    makeToolTip(TradeForOption, getText("UI_View_Wares_name", tostring(math.floor(totalValue * 100))), totalValueString);
end

-- aggiunge opzione di deposito al menu contestuale
local function addDepositMenu(context, items, fromStack)
	local totalValue, totalValueString = showTotalDeposit(items, fromStack)
	local DepositOption = context:addOption(getText("UI_Deposit_Money"), nil, LRM.DoDeposit, items, fromStack);
	makeToolTip(DepositOption, getText("UI_View_Deposit_Total", tostring(math.floor(totalValue * 100))), "");
end	

-- check per l'aggiunta dell'opzione di prelievo e vendita al menu contestuale
-- controlla la distanza dalla mailbox, atm o market
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

        if (tradePostItem ~= nil) then
            local tempContainer = getSyncContainer()
            local selectedContainer

            if getParentContainer(tradePostItem) ~= nil and getParentContainer(tradePostItem):getName() == "LRMMarket" then
                selectedContainer = tradePostItem:getContainer()
			elseif isNearLRMObject("LRMMailbox") or
                   isNearLRMObject("LRMMarket") or
                   isNearLRMObject("LRMMarketMoney") then
				selectedContainer = tradePostItem:getContainer()
                -- attenzione questo è l'oggetto globale
                 --  isNearLRMObject("location_business_bank_01_64") or
                 --  isNearLRMObject("location_business_bank_01_65") or
                --   isNearLRMObject("location_business_bank_01_66")or
                 --  isNearLRMObject("location_business_bank_01_67") or
                SelectedContainer = tradePostItem:getContainer()
			end

			if selectedContainer and not hasDepositOption and (tradePostItem:getFullType() == "Base.Money" or tradePostItem:getFullType() == "MoneyToXP.XPMoneyStack") then
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

-- sync table con il server
LRM.UpdateOnServer = function(modifyTable)
    modifySyncContainer(modifyTable)
end

-- logica principale di vendita nel market
LRM.DoSell = function(_, items)
    if PlayerInventory.players[getPlayerId(getPlayer())].banned then
        doSystemHint("Player blacklisted", false)
        return
    end

    local syncContainer = getSyncContainer()

    if syncContainer == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    local tempTable = {}
    local ItemsToRemoveTable = {};
    local item
    local type 
    local totalValue, _ = showTotalValue(items)
    sendClientCommand("LRM", "UpdatePlayerScore", { getPlayerId(getPlayer()), totalValue })

    for _, v in ipairs(items) do
        if not instanceof(v, "InventoryItem") then
            item = v.items[1]
            type = v.items[1]:getFullType()
        else
            item = v
            type = v:getFullType()
        end

        if ItemValueTable[type] ~= nil and ItemValueTable[type] > 0.0 and checkItemUseful(item) then
            table.insert(ItemsToRemoveTable, item);
            if tempTable[type] == nil then
                tempTable[type] = 0
            end
            tempTable[type] = tempTable[type] + 1
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
    LRM.UpdateOnServer(tempTable);
end

-- logica principale di deposito nel market
LRM.DoDeposit = function(_, items, fromStack)
    local syncContainer = getSyncContainer()

    if syncContainer == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    local ItemsToRemoveTable = {};
    local item
    local type 
    local totalValue, _ = showTotalDeposit(items, fromStack)
    sendClientCommand("LRM", "UpdatePlayerScore", { getPlayerId(getPlayer()), totalValue })

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

-- rimozione item dal server
LRM.RemoveItem = function(_, container)
    local wi = container:getWorldItem();
    if wi ~= nil then
        local sq = wi:getSquare();
        sq:transmitRemoveItemFromSquare(wi);
        wi:removeFromSquare();
    else
        container:getContainer():DoRemoveItem(container)
        --container:getContainer():removeItemOnServer(container);
    end
end

-- printa lista item nella finestra lrm
LRM.ShowWares = function(_, tp)
    if tp == nil then
        getPlayer():Say(getText("UI_Shop_Maintaining"))
        return
    end

    local out = "";
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

-- crea tooltip per l'opzione
function makeToolTip(option, name, desc)
    local toolTip = ISToolTip:new();
    toolTip:initialise();
    toolTip:setVisible(false);
    -- add it to our current option
    option.toolTip = toolTip;
    toolTip:setName(name);
    toolTip.description = desc .. " <LINE> ";
    return toolTip;
end

-- funzione che aggiunge le opzioni nel menu contestuale
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
	if isNearLRMObject("LRMExpress") then
		context:addOption("Apri Express", thump, LRM.openExpressUI, player)
	elseif isNearLRMObject("LRMMarket") then
		context:addOption("Apri Market", thump, LRM.openMarketUI, player)
	elseif isNearLRMObject("LRMMailbox") then
		context:addOption("Apri Mailbox", thump, LRM.openCommentUI, player)
    elseif isNearLRMObject("LRMMarketMedical") then
        context:addOption("Accedi a Farmacia", thump, LRM.openMarketMedicalUI, player)
    elseif isNearLRMObject("LRMMarketMoney") then
        context:addOption("Accedi a Bancomat", thump, LRM.openMarketMoneyUI, player)
    elseif isNearLRMObject("LRMMarketAmmo") then
        context:addOption("Accedi a Polveriera", thump, LRM.openMarketAmmoUI, player)
    elseif isNearLRMObject("LRMMarketSurvival") then
        context:addOption("Accedi a Centro Sopravvivenza", thump, LRM.openMarketSurvivalUI, player)
    elseif isNearLRMObject("LRMMarketWeapon") then
        context:addOption("Accedi ad Armeria", thump, LRM.openMarketWeaponUI, player)
    elseif isNearLRMObject("LRMMarketClothing") then
        context:addOption("Accedi a Spaccio Vestiti", thump, LRM.openMarketClothingUI, player)
    elseif isNearLRMObject("LRMMarketFood") then
        context:addOption("Accedi a Rosticceria (Brace Accesa)", thump, LRM.openMarketFoodUI, player)
    elseif isNearLRMObject("LRMMarketBook") then
        context:addOption("Accedi a Libreria", thump, LRM.openMarketBookUI, player)
    elseif isNearLRMObject("LRMMarketCar") then
        context:addOption("Accedi a Officina", thump, LRM.openMarketCarUI, player)
    end
end

function LRM.openExpressUI()
    closeAllUI()
    openPlayerTradeMainUI(nil)
end

function LRM.openMarketUI()
    closeAllUI()
	openShopMainUI(CategoryAll)
end

function LRM.openMarketMedicalUI()
    closeAllUI()
    openShopMainUI(CategoryMedical)
end

function LRM.openMarketMoneyUI()
    closeAllUI()
    openShopMainUI(CategoryMoney)
end

function LRM.openMarketAmmoUI()
    closeAllUI()
    openShopMainUI(CategoryAmmo)
end

function LRM.openMarketSurvivalUI()
    closeAllUI()
    openShopMainUI(CategorySurvival)
end

function LRM.openMarketWeaponUI()
    closeAllUI()
    openShopMainUI(CategoryWeapon)
end

function LRM.openMarketClothingUI()
    closeAllUI()
    openShopMainUI(CategoryClothing)
end

function LRM.openMarketFoodUI()
    closeAllUI()
    openShopMainUI(CategoryFood)
end

function LRM.openMarketBookUI()
    closeAllUI()
    openShopMainUI(CategoryBook)
end

function LRM.openMarketCarUI()
    closeAllUI()
    openShopMainUI(CategoryCar)
end

function LRM.openCommentUI()
    closeAllUI()
    openCommentBoardUI()
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu);
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)