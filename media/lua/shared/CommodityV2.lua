-- Classe oggetti in vendita al express

-- Categorie express
GoodsType = { 
    "All", 
    "Start", 
    "Mischia", 
    "Fuoco", 
    "Munizioni", 
    "Medicinali", 
    "Cibo", 
    "Vestiti", 
    "Sopravvivenza", 
    "Libri", 
    "Mix", 
    "Altro" 
}

GoodsTypeGroup = {}
for _, v in pairs(GoodsType) do
    table.insert(GoodsTypeGroup, getText("UI_GoodsType_" .. v))
end

-- Definizione pacco express che contiene i vari item
CommodityV2 = {
    id = 0,
    name = "",
    desc = "",
    seller = "",
    sellerId = 0,
    category = "",
    isFinish = false,
    price = 0, 
    items = {}
}

-- Definizione player
PlayerData = {
    playerId = 0,
    score = 0,
    comment = {
        author = "",
        content = "",
    }
}

-- Definizione item contenuto nel pacco express
CommodityItem = {
    type = "",
    fullType = "",
    name = "",
    usedDelta = 1.0, -- per oggetti con delta di usura
    age = 0.0,  -- marciume cibo
    offAge = 0.0,
    offAgeMax = 0.0,
    isBroken = false, -- per armi/strumenti/vestiti
    isRotten = false, -- per cibo
    isBurnt = false, -- per cibo
    condition = 100.0 -- per armi/strumenti/vestiti
}

-- Funzione per aggiungere un pacco express al express
function addPlayerCommodity(player, c_name, c_category, c_price, c_desc, items)

    if c_name == nil or c_name == "" or c_price == nil or c_price < 0 then
        return false
    end

    local commodity = {
        name = c_name,
        seller = player:getUsername(),
        sellerId = getPlayerId(player),
        category = c_category,
        isFinish = false,
        price = c_price / 100.0,
        orderTime = getGameTime():getWorldAgeHours(),
        weight = 0.0,
        items = {}
    }

    if c_desc and c_desc ~= "" then
        commodity.desc = c_desc
    end

    for _, v in pairs(items) do
        if not player:getInventory():containsID(v:getID()) then
            return false
        end

        commodity.weight = commodity.weight + v:getWeight()
        local item = {
            type = v:getType(),
            fullType = v:getFullType(),
            isBroken = v:isBroken(),
            isBurnt = v:isBurnt(), 
            condition = v:getCurrentCondition(),
            cooked = v:isCooked()
        }
        item.name = v:getName()

        if v:getModData() then
            item.modData = v:getModData()
        end

        if instanceof(v, "DrainableComboItem") then
            item.usedDelta = v:getUsedDelta()
        end

        -- aggiunta statistiche cibo
        if instanceof(v, "Food") then
            if v:getPoisonPower() > 0 then
                item.poisonPower = v:getPoisonPower()
                item.poisonDetectionLevel = v:getPoisonDetectionLevel()
                item.poisonLevelForRecipe = v:getPoisonLevelForRecipe()
            end
            item.hungerChange = v:getHungerChange()
            item.thirstChange = v:getThirstChange()
            item.hungChange = v:getHungChange()
        end

        -- aggiunta statistiche vestiti (TODO aggiungere condizione estetica/toppe)
        if instanceof(v, "Clothing") then
            local visual = v:getVisual()
            if visual:getHolesNumber() > 0 then
                item.holes = {}
                local count = 0
                local index = 0
                while (count < visual:getHolesNumber() and index < 18) do
                    if visual:getHole(BloodBodyPartType.FromIndex(index)) > 0.0 then
                        table.insert(item.holes, index)
                        count = count + 1
                    end
                    index = index + 1
                end
            end
        end

        -- aggiunta stato marciume cibo
        if v:getAge() ~= 0 then
            item.age = v:getAge()
            item.offAge = v:getOffAge()
            item.offAgeMax = v:getOffAgeMax()
            item.curAge = getGameTime():getWorldAgeHours()
        end

        table.insert(commodity.items, item)
    end

    if commodity.weight == 0 then
        commodity.weight = 0.01
    end
    commodity.weight = string.format("%1.2f", commodity.weight)

    -- sync
    sendClientCommand(player, "LRM", "AddPlayerCommodity", { commodity })
    player:Say(getText("UI_Upload_Succeed"))

    -- rimozione oggetti dal player
    for _, v in pairs(items) do
        if player:isEquipped(v) then
            player:removeFromHands(v)
        end
        player:getInventory():Remove(v)
    end

    return true
end

-- calcola stato marciume cibo
function getAge(item)
    local stepText = ""
    local ageValue = -1
    local ageProgress = 0
    local ageStep = 0

    if item.age > 0.0 then

        -- variabile sandbox per disabilitare deperimento cibo
        if SandboxVars.LRM.DisableFoodAge then return 0, item.age, getText("UI_item_Unlimited_Age") end

        local lastAge = (item.age + getGameTime():getWorldAgeHours() - item.curAge) / 24.0
        if lastAge < item.offAge then
            ageValue = item.offAge - lastAge
            if ageValue > 100000 then
                ageProgress = 100
                stepText = getText("UI_item_Unlimited_Age")
            else
                ageProgress = math.floor(ageValue / item.offAge * 100)
                stepText = getText("UI_item_NewAge", string.format("%1.1f", ageValue))
            end
        elseif lastAge < item.offAgeMax then
            ageValue = item.offAgeMax - lastAge
            ageProgress = math.floor(ageValue / (item.offAgeMax - item.offAge) * 100)
            ageStep = 1
            stepText = getText("UI_item_OffAge", string.format("%1.1f", ageValue))
        else
            ageValue = 0
            ageProgress = 0
            ageStep = 2
            stepText = getText("UI_item_OffAgeMax")
        end
    end


    return ageStep, ageProgress, stepText
end