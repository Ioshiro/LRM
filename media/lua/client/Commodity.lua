
Commodity = {
    fullType = "",
    stock = 0,
    inflation = 1.0,
    displayInflation = "",
    rawPrice = 0.0,
    price = 0.0,
    displayPrice = "",
    displayName = "",
    bugCountLimit = 0, -- 购买数量限制，0表示不限量
    bugLimitfullType = 0
}

local function getInflation(stock)
    if not SandboxVars.LRM.EnableInflation then
        return 1.0
    end
	
    local inflation = (1 + (((stock - ((MaxStock + 1) / 2)) / 20) * -1));
	--print("STOCK: "..stock..", MAXSTOCK:"..MaxStock..", INFLATION: "..inflation)
    if (inflation < 0.5) then
        inflation = 0.5;
    elseif (inflation > 1.5) then
        inflation = 1.5;
    end
    return inflation;
end

function Commodity:instance(fullfullType)

    --print("Commodity:fullType:" .. fullfullType)

    if ItemCategoryTable[fullfullType] == nil then
        return nil
    end

    if ItemValueTable[fullfullType] == 0.0 then
        return nil
    end

    self.stock = getInStockCount(fullfullType);
    self.inflation = getInflation(self.stock);
    self.displayInflation = tostring(math.floor(self.inflation * 100)) .. "%";
    self.rawPrice = ItemValueTable[fullfullType];
    self.price = self.inflation * self.rawPrice;
    self.displayPrice = math.floor(self.price * 100);
    self.displayName = getItemDisplayName(fullfullType);

    return self


end

function getTheInflation(fullType)
    if (ItemCategoryTable[fullType] ~= nil) and (fullType == "Base.Money") then
        return 1.0
    end
    local stock = getInStockCount(fullType);
    return (getInflation(stock));
end
function getThePrice(fullType)
    if (ItemValueTable[fullType] == nil) then
        return 0
    end
    local result = (getTheInflation(fullType) * ItemValueTable[fullType]);
    return math.floor(result * 100) ;
end