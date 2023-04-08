-- Apertura pacco express e inserimento delle statistiche nei vari item contenuti nel pacco
function OpenExpressBox(_, item)

    local expressData = item:getModData().ExpressData
    if expressData == nil then
        getPlayer():Say(getText("UI_Express_No_Player"))
        return
    end

    if getPlayerId(getPlayer()) ~= expressData.recipient then
        getPlayer():Say(getText("UI_Express_Wrong_Player"))
        return
    end

    local items = expressData.expressContent
    for _, goods in pairs(items) do
        local inventoryItem = instanceItem(goods.fullType)
        if inventoryItem then
            inventoryItem:setCondition(math.floor(goods.condition / 100 * inventoryItem:getConditionMax()))
            inventoryItem:setBroken(goods.isBroken)
            inventoryItem:setBurnt(goods.isBurnt)
            inventoryItem:setCooked(goods.cooked)

            if instanceof(inventoryItem, "Food") then
                if  goods.hungChange then
                    inventoryItem:setHungChange(goods.hungChange)
                    inventoryItem:setThirstChange(goods.thirstChange)
                end

                if goods.poisonPower then
                    inventoryItem:setPoisonPower(goods.poisonPower)
                    inventoryItem:setPoisonDetectionLevel(goods.poisonDetectionLevel)
                    inventoryItem:setPoisonLevelForRecipe(goods.poisonLevelForRecipe)
                end
            else
                inventoryItem:setName(goods.name)
            end

            if goods.age then
                inventoryItem:setOffAge(goods.offAge)
                inventoryItem:setOffAgeMax(goods.offAgeMax)
                inventoryItem:setAge(goods.age + getGameTime():getWorldAgeHours() - goods.curAge)
                inventoryItem:update()
                inventoryItem:setAutoAge()
            end

            if goods.usedDelta then
                inventoryItem:setDelta(goods.usedDelta)
            end

            if goods.holes then
                for i = 1, #goods.holes do
                    inventoryItem:getVisual():setHole(BloodBodyPartType.FromIndex(goods.holes[i]))
                end
            end

            if goods.modData then
                inventoryItem:copyModData(goods.modData)
            end

            getPlayer():getInventory():AddItem(inventoryItem)
        end
    end
    getPlayer():getInventory():Remove(item)
end