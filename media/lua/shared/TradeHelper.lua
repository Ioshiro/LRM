


function DoBuyOperation(items, value)

    local syncContainer = getSyncContainer()

    if syncContainer == nil then
        return
    end

    local player = getPlayer()

    --if (getDistanceBetween(getPlayer(), TP:getWorldItem():getSquare()) > 3) then
    --    return false
    --end

    --if (total == nil) then
    --    print("error total given is nil");
    --    return false;
    --end

    local yourItemsValue = getPlayerAssets()

    --local parent = TP:getItemContainer();
    --local parentItems = parent:getItems();
    --local fakeContainer = parent:FindAndReturn("AdvancedTradingPostInv")
    --local shopContainer = syncContainer:getItemContainer();

    local ItemsToRemoveTable = {};

    local inventory = player:getInventory()
    for _, item in pairs(items) do
        inventory:AddItem(item)
        if ItemsToRemoveTable[item] == nil then
            ItemsToRemoveTable[item] = 0
        end
        ItemsToRemoveTable[item] = ItemsToRemoveTable[item] - 1
    end

    yourItemsValue = yourItemsValue - value

    player:Say(getText("UI_Thanks"))
    LRM.UpdateOnServer(ItemsToRemoveTable)





    --for i = 0, parentItems:size() - 1 do
    --    item = parentItems:get(i);
    --    if item ~= nil and checkItemUseful(item) and item ~= fakeContainer then
    --        local fullType = item:getFullType();
    --        if ItemValueTable[fullType] ~= nil and ItemValueTable[fullType] > 0.0 then
    --            local itemInfo = instanceCommodity(syncContainer, fullType)
    --
    --            if itemInfo ~= nil then
    --                yourItemsValue = yourItemsValue - itemInfo.price;
    --                table.insert(ItemsToRemoveTable, getShortTypeName(fullType));
    --            end
    --        end
    --
    --    end
    --
    --    if (yourItemsValue <= 0) then
    --        break
    --    end
    --end

    --if (yourItemsValue > 0) then
    --    return false
    --end -- someone is trying to cheat

    --local count = 1;

    --local tradeTable = {}
    --while (ItemsToRemoveTable[count]) do
    --    item = parent:FindAndReturn(ItemsToRemoveTable[count]);
    --
    --    local category = item:getDisplayCategory();
    --    if (category == nil) then
    --        category = item:getCategory();
    --    end
    --    ItemCategoryTable[item] = category;
    --    if (not has_value(CategoryList, category)) then
    --        table.insert(CategoryList, category)
    --    end
    --
    --    --print("removing " .. itype .. " valued at " .. tostring(getThePrice(TP, itype)));
    --    shopContainer:addItemOnServer(item);
    --    shopContainer:AddItem(item);
    --    if tradeTable[ItemsToRemoveTable[count]] == nil then
    --        tradeTable[ItemsToRemoveTable[count]] = 0
    --    end
    --    tradeTable[ItemsToRemoveTable[count]] = tradeTable[ItemsToRemoveTable[count]] + 1
    --
    --    parent:removeItemOnServer(item);
    --    parent:DoRemoveItem(item);
    --
    --    count = count + 1;
    --end

    --if (fakeContainer) then
    --local itemToTransfer;

    --for i = 0, amount - 1 do
    --    itemToTransfer = shopContainer:FindAndReturn(getShortTypeName(type));
    --    if (itemToTransfer ~= nil) then
    --        shopContainer:removeItemOnServer(itemToTransfer);
    --        shopContainer:DoRemoveItem(itemToTransfer);
    --        if tradeTable[type] == nil then
    --            tradeTable[type] = 0
    --        end
    --        tradeTable[type] = tradeTable[type] - 1
    --
    --        parent:addItemOnServer(itemToTransfer);
    --        parent:AddItem(itemToTransfer);
    --    else
    --        print("error finding item to transfer in inner container from type " .. type);
    --    end
    --end
    --else
    --    print("error could not get inner container in TradeForFunction");
    --end

    --SyncContainer(syncContainer)
    --getGameTime():getModData().syncContainer[1] = syncContainer

    --if (LRMWindow:isVisible()) then
    --    LRM.ShowWares(nil, syncContainer, getSpecificPlayer(0));
    --end
    --getSpecificPlayer(0):Say(getText("UI_Thanks"));
    --LRM.UpdateOnServer(tradeTable);
end