
GoodsType = { "All", "Start", "Mischia", "Fuoco", "Munizioni", "Medicinali", "Cibo", "Vestiti", "Sopravvivenza", "Libri", "Mix", "Altro" }
--GoodsType.All = "All"
--GoodsType.Base = "Base"
--GoodsType.Weapon = "Weapon"
--GoodsType.Food = "Food"
--GoodsType.Material = "Material"
--GoodsType.Mix = "Mix"
--GoodsType.Other = "Other"

GoodsTypeGroup = {}
for _, v in pairs(GoodsType) do
    table.insert(GoodsTypeGroup, getText("UI_GoodsType_" .. v))
end

CommodityV2 = {
    id = 0,
    name = "",
    desc = "",
    seller = "",
    sellerId = 0,
    category = "",
    --newDegree = 10, -- 几成新
    isFinish = false,
    price = 0, -- 价格
    --comment = {}, -- 玩家评论
    items = {}
}

PlayerData = {
    playerId = 0,
    score = 0,
    comment = {
        author = "",
        content = "",
    }
}

CommodityItem = {
    type = "",
    fullType = "",
    name = "",
    usedDelta = 1.0, -- 剩余量
    age = 0.0, -- 物品时间
    offAge = 0.0,
    offAgeMax = 0.0,
    isBroken = false, -- 是否损坏
    isRotten = false, -- 是否腐败
    isBurnt = false, -- 是否烧焦
    condition = 100.0 -- 当前耐久度
}

function addPlayerCommodity(player, c_name, c_category, c_price, c_desc, items)

    if c_name == nil or c_name == "" or c_price == nil or c_price < 0 then
        return false
    end

    local commodity = {
        name = c_name,
        seller = player:getUsername(),
        sellerId = getPlayerId(player),
        category = c_category,
        --newDegree = c_newDegree,
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
        --local v= instanceItem("")
        local item = {
            type = v:getType(),
            fullType = v:getFullType(),
            --name = v:getDisplayName(),
            --usedDelta = -1.0, -- 剩余量

            --age = v:getAge(), -- 物品时间
            --offAge = 0.0,
            --offAgeMax = 0.0,
            --curAge = getGameTime():getWorldAgeHours(),
            --hungChange = 0.0,
            --thirstChange = 0.0,

            isBroken = v:isBroken(), -- 是否损坏
            --isRotten = v:IsRotten(), -- 是否腐败
            isBurnt = v:isBurnt(), -- 是否烧焦
            condition = v:getCurrentCondition(), -- 当前耐久度
            cooked = v:isCooked()
        }

        --if getScriptManager():getItem(v:getFullType()):getDisplayName() ~= v:getName() then
        item.name = v:getName()
        --end

        if v:getModData() then
            item.modData = v:getModData()
        end

        if instanceof(v, "DrainableComboItem") then
            item.usedDelta = v:getUsedDelta()
        end

        if instanceof(v, "Food") then
            if v:getPoisonPower() > 0 then
                item.poisonPower = v:getPoisonPower()
                item.poisonDetectionLevel = v:getPoisonDetectionLevel()
                item.poisonLevelForRecipe = v:getPoisonLevelForRecipe()
            end

            item.hungerChange = v:getHungerChange() -- 用于显示
            item.thirstChange = v:getThirstChange() -- 用于赋值
            item.hungChange = v:getHungChange()
        end

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
            --item.usedDelta = v:getVisual()
        end

        if v:getAge() ~= 0 then
            item.age = v:getAge() -- 物品时间
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

    sendClientCommand(player, "LRM", "AddPlayerCommodity", { commodity })
    player:Say(getText("UI_Upload_Succeed"))

    for _, v in pairs(items) do
        if player:isEquipped(v) then
            player:removeFromHands(v)
        end
        player:getInventory():Remove(v)
    end

    --return commodity
    return true
end

function getAge(item)
    local stepText = ""
    local ageValue = -1
    local ageProgress = 0
    local ageStep = 0

    if item.age > 0.0 then
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