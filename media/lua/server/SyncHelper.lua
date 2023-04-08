-- classe di supporto per sync delle table
-- 

-- modifica ShopInventory con la table passata come parametro
function DoModifyInventory(newTable)
    if newTable == nil then
        return
    end

    local temp = getGameTime():getModData().ShopInventory
    for key, value in pairs(newTable) do
        if temp[key] == nil then
            temp[key] = 0
        end
        temp[key] = temp[key] + value
        if temp[key] < 0 then
            temp[key] = 0
        end
    end
    getGameTime():getModData().ShopInventory = temp
end

-- rifa la table creando una nuova table e reinserendo i dati(serve per resettare il contenitore?)
function doCheckInventory(container)
    local itemTable = {}
    local items = container:getItemContainer():getItems()
    for i = 0, items:size() - 1 do
        local type = items:get(i):getFullType()
        if itemTable[type] == nil then
            itemTable[type] = 0
        end
        itemTable[type] = itemTable[type] + 1
    end
    return itemTable
end

-- Crea l'item pacco e lo inserisce nell'inventario del player
function doPackExpressBox(goodsInfo)
    local item = getScriptManager():getItem("Base.ExpressBox")
    item:getCategories()
    if goodsInfo.weight then
        item:DoParam("Weight = " .. tostring(goodsInfo.weight + 1.0))
    end

    local expressBox = instanceItem("Base.ExpressBox")
    expressBox:getModData().ExpressData = {}
    expressBox:setName(getText("UI_ExpressBox", getPlayer():getUsername()))
    expressBox:setTooltip(getText("UI_ExpressBox_Tooltip", goodsInfo.name))
    expressBox:getModData().ExpressData.recipient = getPlayerId(getPlayer())
    expressBox:getModData().ExpressData.expressContent = goodsInfo.items
    expressBox:setWeight(goodsInfo.weight + 1.0)
    expressBox:setActualWeight(goodsInfo.weight + 1.0)
    expressBox:setCustomWeight(true)

    getPlayer():getInventory():AddItem(expressBox)

    item:DoParam("Weight = 10")
end
