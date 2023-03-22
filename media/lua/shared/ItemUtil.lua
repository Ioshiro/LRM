

--require "Commodity"

---@return InventoryItem
function getParentContainer(container)
    return container:getContainer():getContainingItem()
end

---@return ArrayList|InventoryItem
function getContainerItems(container)
    return container:getItemContainer():getItems()
end

function isSinglePlayer()
    return getOnlinePlayers() == nil
end

function getPlayerId(player)
    if isSinglePlayer() then
        return 0
        --elseif player:getSteamID() ~= nil then
        --    return player:getSteamID()
    else
        --return getSteamIDFromUsername(player:getUsername())
        return player:getSteamID()
        --return player:getUsername()
    end
end

function getPlayerIdFromUsername(username)
    local player = getPlayerFromUsername(username)
    if player then
        return getPlayerId(player)
    else
        return nil
    end
end




function getPlayerAssets(player)
    if PlayerInventory == nil then
        return 0
    end

    local pId = getPlayerId(player)
    return math.floor(PlayerInventory.players[pId].score * 100)
    --local score =
    --commodities.players[pId].score = score + args[1]


    --playerInventory
end

function getSyncContainer()

    return SyncContainer
end

function syncPlayerCommodity(inventory)
    PlayerInventory = inventory
end

function initSycContainer(newTable)
    SyncContainer = newTable
end

function SyncItemTable(newTable)
    ItemValueTable = newTable
    InitLRMTables()
end

function SyncCommentBoard(newTable)
    RawCommentTable = newTable
end

function CreateOrResetDepository(_, container)


    local itemContainer = container:getItemContainer()

    itemContainer:removeAllItems()

    local shop_item;
    for k, v in pairs(ItemValueTable) do
        --local itemType = k;
        local cat = ItemCategoryTable[k];

        if (v > 0.0) and (cat ~= nil) and (cat == "Money") then

            for i = 0, 15 do
                shop_item = instanceItem(k);
                itemContainer:addItemOnServer(shop_item);
                itemContainer:AddItem(shop_item);
            end
        elseif (v > 0.0) and (ZombRand(v) < 10) and (cat ~= nil) then

            if (CategoryGroupTable[cat] == nil) then
                print("CategoryGroupTable[cat] is nil when cat is [" .. tostring(cat) .. "]");
            end
            local ts = CategoryTotals[cat];
            local uts = (ts / 45);

            if (uts < 2) then
                uts = 2
            end
            --elseif(uts> 15) then uts = 15 end
            if (ZombRand(1, uts) == 1) then

                local randomAmount = ZombRand(15 + 1 - math.floor(v / 3));
                if (randomAmount > 0) then
                    for i = 0, randomAmount do
                        shop_item = instanceItem(k);
                        itemContainer:addItemOnServer(shop_item);
                        itemContainer:AddItem(shop_item);
                    end
                end

            end

        elseif (v > 0) and (ZombRand(v) < 10) and (cat == "Food") and (ZombRand(1, 4) == 1) then

        end
    end

    --print(tostring(CategoryTotals["Item"]));

end

function ChangeDepository(_, container)
    local worldItem = container:getWorldItem()

    if worldItem == nil then
        getPlayer():Say(getText("UI_NEED_OnGround"))
        return
    end

    --local newTable = requestResetInventory(container)
    local newTable = doCheckInventory(container)
    requestSavePost(newTable)
end

function getItemDisplayName(itemType)
    return getScriptManager():getItem(itemType):getDisplayName()
    --local itemObj = instanceItem(itemType);
    --if (itemObj ~= nil) then
    --    return itemObj:getDisplayName()
    --end
    --return "";
end

function AbsoluteValue(value)
    if (value >= 0) then
        return value;
    else
        return (value * -1);
    end
end

function getDistanceBetween(z1, z2)
    if (z1 == nil) or (z2 == nil) then
        return -1
    end

    local z1x = z1:getX();
    local z1y = z1:getY();
    local z2x = z2:getX();
    local z2y = z2:getY();
    return (AbsoluteValue(z1x - z2x) + (AbsoluteValue(z1y - z2y)) / 2);

end

--function getShortTypeName(fullType)
--    local item = instanceItem(fullType);
--    return item:getType();
--end

function getInStockCount(fullType)

    if SyncContainer == nil or SyncContainer[fullType] == nil then
        return 0
    end

    return SyncContainer[fullType]
end

function instanceCommodity(fullType)
    --if not getSyncContainer() then
    --    return nil
    --end

    return Commodity:instance(fullType)
end

function getItemUselessText(inventoryItem)
    local item = inventoryItem:getScriptItem()
    if inventoryItem:isBroken() then
        return getText("UI_Useless_1", inventoryItem:getDisplayName())
    end

    if instanceof(inventoryItem, "Clothing") and inventoryItem:getVisual():getHolesNumber() > 0 then
        return getText("UI_Useless_1", inventoryItem:getDisplayName())
    end

    if inventoryItem:IsRotten() then
        return getText("UI_Useless_2", inventoryItem:getDisplayName())
    end

    if inventoryItem:getCurrentCondition() < 60.0 then
        return getText("UI_Useless_3", inventoryItem:getDisplayName())
    end

    if inventoryItem:isBurnt() then
        return getText("UI_Useless_4", inventoryItem:getDisplayName())
    end

    if instanceof(inventoryItem, "DrainableComboItem") and inventoryItem:getUsedDelta() < 0.6 then
        return getText("UI_Useless_5", inventoryItem:getDisplayName())
    end

    return ""
end

function checkItemUseful(inventoryItem)
    local item = inventoryItem:getScriptItem()
    --local condition = inventoryItem:getCurrentCondition()
    local getOffAgeMax = inventoryItem:getOffAgeMax() -- 腐败时间
    local getOffAge = inventoryItem:getOffAge() -- 不新鲜时间

    --if instanceof(inventoryItem, "Food") then
    --    inventoryItem:getHungChange() -- 获取饱食度值
    --    inventoryItem:getThirstChange() -- 口渴
    --end

    --if instanceof(inventoryItem, "Food") then
    --    inventoryItem:getUsedDelta() -- 剩余量
    --end


    if inventoryItem:isBroken() then
        return false
    end

    if inventoryItem:IsRotten() then
        return false
    end

    if inventoryItem:isBurnt() then
        return false
    end

    if inventoryItem:getCurrentCondition() < 60.0 then
        return false
    end

    if instanceof(inventoryItem, "DrainableComboItem") and inventoryItem:getUsedDelta() < 0.6 then
        return false
    end

    if instanceof(inventoryItem, "Clothing") and inventoryItem:getVisual():getHolesNumber() > 0 then
        return false
    end

    return true
end


function calItemPrice(item)
    if checkItemUseful(item) then

    end
    if item:isBroken() then

    end

end

function getSelectItems(items)
    if items == nil then
        return nil, nil
    end

    local temp = {}
    local itemList = {}
    for i = 1, #items do
        if not instanceof(items[i], "InventoryItem") then

            for j = 2, #items[i].items do

                table.insert(temp, items[i].items[j])
                table.insert(itemList, items[i].items[j]:getName())
            end
        else
            table.insert(temp, items[i])
            table.insert(itemList, items[i]:getName())
        end
    end

    return temp, itemList
end

function table_length(t)
    local leng = 0
    for k, v in pairs(t) do
        leng = leng + 1
    end
    return leng;
end

function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function doBuyTradingItem(items, value)
    if items == nil or getPlayerAssets(getPlayer()) < value then
        return
    end
    local tradingItem = {}
    for i, v in pairs(items) do
        if tradingItem[v] == nil then
            tradingItem[v] = 0
        end
        getPlayer():getInventory():AddItem(v)
		if v ~= "Base.Money" and v ~= "MoneyToXP.XPMoneyStack" then
			tradingItem[v] = tradingItem[v] - 1
		end
    end

    sendClientCommand("LRM", "UpdatePlayerScore", { getPlayerId(getPlayer()), -(value / 100.0) })

    LRM.UpdateOnServer(tradingItem)


    --return tradingItem

end

function doSystemHint(text, isSucceed)
    if text == nil or isSucceed == nil then
        return
    end

    if isSinglePlayer() then
        getPlayer():Say(text)
    else
        local rgb = { 0.6, 0.6, 0.6 }
        if isSucceed ~= nil then
            if isSucceed == true then
                rgb = { 0.0, 1.0, 0.0 }
            else
                rgb = { 1.0, 0.0, 0.0 }
            end
        end
        getPlayer():SayRadio(text, rgb[1], rgb[2], rgb[3], nil, 100.0, 0, "radio")
    end
end

function isNearLRMObject(objName)
    local square = getPlayer():getCurrentSquare()
    local px = square:getX();
    local py = square:getY();
    local pz = square:getZ();
    local isFound = false
    local hasPower = getGameTime():getNightsSurvived() < getSandboxOptions():getElecShutModifier()
    if isAdmin() or getPlayer():getAccessLevel() ~= "None" then
        hasPower = true
    end

    for y = py - 1, py + 1 do
        for x = px - 1, px + 1 do
            local squareTest = getCell():getGridSquare(x, y, pz);
            if squareTest then
                local objects = squareTest:getObjects();
                for i = 0, objects:size()-1 do
                    local obj = objects:get(i)
                    if obj then
						--print("found object: "..(obj:getName() or "error"))
                        if(obj:getSprite()) then
                            local sp = obj:getSprite():getProperties();
                            if sp:Is("GroupName") and sp:Is("CustomName") and sp:Val("GroupName")..sp:Val("CustomName") == objName then
                                isFound = true
                            end
                            if obj:getSprite():getName() == objName then
                                isFound = true
                            end
                            if not hasPower and (not SandboxVars.LRM.NeedElectricity or squareTest:haveElectricity()) then
                                hasPower = true
                            end
                            if isFound and hasPower then

                                return true
                            end
                        end

                    end
                end
            end
        end
    end

    if isFound and not hasPower then
        doSystemHint(getText("UI_LRM_NO_Electricity" .. tostring(ZombRandBetween(1, 4))), false)
    end

    return false;
end



local struct = {
    author = "",
    time = "",
    content = "",
}

local function getCurTime()

    getTimestamp()
end

local tempUI
function buildCommonList(commentTable)

    if CommentBoardUI and CommentBoardUI:isVisible() then
        local commentList = {}
        local timeList = {}
        for _, v in pairs(commentTable) do

            if v.visible == nil or v.visible == true then
                table.insert(commentList, getText("UI_Comment_Author", v.author, v.time))
                table.insert(commentList, v.content)
                table.insert(timeList, v.time)
            end
        end

        CommentBoardUI["CommentList"]:setItems(commentList)

        if isSinglePlayer() or getPlayer():getAccessLevel() ~= "None" then
            CommentBoardUI["CommentList"]:setOnMouseDownFunction(_, function(_, _)
                local time = timeList[math.floor((CommentBoardUI["CommentList"]:getSelected() + 1) / 2.0)]
                if tempUI then
                    tempUI:close()
                end

                tempUI = NewUI()
                tempUI:isSubUIOf(CommentBoardUI)
                tempUI:setWidthPercent(0.05)
                tempUI:addButton("", "Remove", function()
                    sendClientCommand("LRM", "LRMAddComment", { nil, time })
                end)

                tempUI:saveLayout()
                tempUI:setPositionPixel(CommentBoardUI:getX() + CommentBoardUI:getWidth() + 15, CommentBoardUI:getY())

            end)
        end



    end


end



