

local function doSell(_, items)
    openGoodEditWindow(items)
    --showSellWindow(item)
end

local function OnFillInventoryObjectContextMenu(player, context, items)
    local item = items[1];
    if not instanceof(items[1], "InventoryItem") then
        item = items[1].items[1];
    end
    if not getPlayer():getInventory():contains(item) then
        return
    end

    if isNearLRMObject("LRMExpress") then
        context:addOption(getText("UI_Goods_Sell"), nil, doSell, items)
    end

    if item:getType() == "ExpressBox" then
        context:addOption(getText("UI_Open_Express"), nil, OpenExpressBox, item)
    end

    --if instanceof(item, "Clothing") then
    --
    --    context:addOption("Add Hole", nil, function(_, item)
    --        item:getVisual():setHole(BloodBodyPartType.FromIndex(ZombRand(18)))
    --    end, item)
    --end


end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)

--local function openTradingUI(_)
--    if not isNearAdvancedTradingPost() then
--        return
--    end
--
--    closeAllUI()
--    openMainUI()
--end
--[[
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
	if isNearLRMObject("LRMMarket") then
		context:addOption(getText("UI_Open_Trade_UI"), nil, openTradingUI)
		return
	end
end
--]]

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)