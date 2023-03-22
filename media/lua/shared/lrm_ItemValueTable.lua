function isModEnabled(modname)

    local actmods = getActivatedMods()
    for i = 0, actmods:size() - 1, 1 do
        if actmods:get(i) == modname then
            return true
        end
    end
    return false
end

if (ItemValueTable == nil) then
    ItemValueTable = {}
end

--- Robe base

ItemValueTable["Base.Money"] = 0.01
ItemValueTable["Base.Pen"] = 0.01
ItemValueTable["Base.Lighter"] = 0.02
ItemValueTable["Base.Battery"] = 0.02
ItemValueTable["Base.HandTorch"] = 0.10


-- Cibo

ItemValueTable["Base.WatermelonSliced"] = 0.04
ItemValueTable["Base.Apple"] = 0.7
ItemValueTable["Base.Yoghurt"] = 0.7
ItemValueTable["Base.Wine2"] = 0.10
ItemValueTable["Base.Burger"] = 0.15
ItemValueTable["Base.Butter"] = 0.35

-- Zaini

ItemValueTable["Base.Bag_Satchel"] = 0.30
ItemValueTable["Base.Bag_NormalHikingBag_Tier2"] = 0.7

-- Armi cc

ItemValueTable["Base.PlankNail"] = 0.03
ItemValueTable["Base.Screwdriver"] = 0.15
ItemValueTable["Base.FlintKnife"] = 0.05
ItemValueTable["Base.HammerStone"] = 0.07
ItemValueTable["HMWeapons.HandmadeBaseballBatNails"] = 0.08
ItemValueTable["Base.WoodenLance"] = 0.09
ItemValueTable["Base.Pan"] = 0.10
ItemValueTable["HMWeapons.StoneHandaxe"] = 0.15
ItemValueTable["Base.HuntingKnife"] = 0.18
ItemValueTable["Base.Hammer"] = 0.20
ItemValueTable["HMWeapons.WoodenSword"] = 0.25
ItemValueTable["Base.Aerosolbomb"] = 0.50
ItemValueTable["Base.Shovel"] = 0.30
ItemValueTable["Base.Crowbar"] = 0.7
ItemValueTable["Base.BaseballBatNails"] = 1.20
ItemValueTable["Base.Axe"] = 3.0
ItemValueTable["Base.Sledgehammer2"] = 10.00
ItemValueTable["Base.Katana"] = 10.00

-- Sopravvivenza


ItemValueTable["Base.Scissors"] = 0.20
ItemValueTable["Base.WeldingRods"] = 0.30
ItemValueTable["Base.EmptyPetrolCan"] = 0.30
ItemValueTable["Base.GardenSaw"] = 0.25
ItemValueTable["Base.Wrench"] = 0.20
ItemValueTable["Base.Twine"] = 0.45
ItemValueTable["Base.NailsBox"] = 0.10
ItemValueTable["Base.PipeWrench"] = 0.30
ItemValueTable["Base.Woodglue"] = 0.55
ItemValueTable["Base.PetrolCan"] = 0.25
ItemValueTable["Base.BarbedWire"] = 0.50
ItemValueTable["Base.BoxOfJars"] = 0.20
ItemValueTable["Base.FishingLine"] = 0.40
ItemValueTable["Base.FishingNet"] = 1.6
ItemValueTable["Base.PotatoBagSeed"] = 3.50
ItemValueTable["Base.BroccoliBagSeed"] = 3.50
ItemValueTable["Base.Generator"] = 5.0


-- Medicina
ItemValueTable["Base.Bleach"] = 0.15
ItemValueTable["Base.Disinfectant"] = 0.20
ItemValueTable["Base.AlcoholWipes"] = 0.20
ItemValueTable["Base.PillsSleepingTablets"] = 0.2
ItemValueTable["Base.SutureNeedle"] = 0.2
ItemValueTable["Base.PillsAntiDep"] = 0.3






-- Meccanica
ItemValueTable["Base.LugWrench"] = 0.25
ItemValueTable["Base.Jack"] = 0.25
ItemValueTable["Base.TirePump"] = 0.25
ItemValueTable["Base.ScrewsBox"] = 0.5
ItemValueTable["Base.CarBattery1"] = 0.4
ItemValueTable["Base.CarBattery2"] = 0.4
ItemValueTable["Base.CarBattery3"] = 0.4
ItemValueTable["Base.CarBatteryCharger"] = 3.0
ItemValueTable["Base.BlowTorch"] = 2.50
ItemValueTable["LabItems.ChSulfuricAcidCan"] = 5.00





-- Armi da fuoco e Munizioni

ItemValueTable["Base.Molotov"] = 0.15
ItemValueTable["Base.Bullets9mmBox"] = 0.40
ItemValueTable["Base.Bullets44Box"] = 0.40
ItemValueTable["Base.Bullets45Box"] = 0.40
ItemValueTable["Base.223Box"] = 0.50
ItemValueTable["Base.308Box"] = 0.50
ItemValueTable["Base.PipeBomb"] = 0.50
ItemValueTable["Base.ShotgunShellsBox"] = 0.50
ItemValueTable["Base.556Box"] = 0.5
ItemValueTable["Base.x2Scope"] = 1.5
ItemValueTable["Base.x4Scope"] = 3.0
ItemValueTable["Base.x8Scope"] = 6.0

-- Libri

ItemValueTable["Base.BookCarpentry1"] = 0.05
ItemValueTable["Base.BookCooking1"] = 0.05
ItemValueTable["Base.BookFirstAid1"] = 0.05
ItemValueTable["Base.BookFarming1"] = 0.05
ItemValueTable["Base.BookFishing1"] = 0.05
ItemValueTable["Base.BookForaging1"] = 0.05
ItemValueTable["Base.BookElectrician1"] = 0.05
ItemValueTable["Base.BookMetalWelding1"] = 0.05
ItemValueTable["Base.BookFishing1"] = 0.05

ItemValueTable["Base.BookCarpentry2"] = 0.07
ItemValueTable["Base.BookElectrician2"] = 0.07
ItemValueTable["Base.BookFarming2"] = 0.07
ItemValueTable["Base.BookFishing2"] = 0.07
ItemValueTable["Base.BookForaging2"] = 0.07
ItemValueTable["Base.BookMetalWelding2"] = 0.07


ItemValueTable["Base.BookCarpentry3"] = 0.15
ItemValueTable["Base.BookCooking3"] = 0.15
ItemValueTable["Base.BookElectrician3"] = 0.15
ItemValueTable["Base.BookFarming3"] = 0.15
ItemValueTable["Base.BookFishing3"] = 0.15
ItemValueTable["Base.BookForaging3"] = 0.15
ItemValueTable["Base.BookMetalWelding3"] = 0.15
ItemValueTable["Base.BookTrapping3"] = 0.15

ItemValueTable["Base.BookCarpentry4"] = 0.30
ItemValueTable["Base.BookCooking4"] = 0.30
ItemValueTable["Base.BookElectrician4"] = 0.30
ItemValueTable["Base.BookFarming4"] = 0.30
ItemValueTable["Base.BookFishing4"] = 0.30
ItemValueTable["Base.BookForaging4"] = 0.30
ItemValueTable["Base.BookMetalWelding4"] = 0.30
ItemValueTable["Base.BookTrapping4"] = 0.30


ItemValueTable["Base.BookCarpentry5"] = 0.60
ItemValueTable["Base.BookCooking5"] = 0.60
ItemValueTable["Base.BookElectrician5"] = 0.60
ItemValueTable["Base.BookFarming5"] = 0.60
ItemValueTable["Base.BookFishing5"] = 0.60
ItemValueTable["Base.BookForaging5"] = 0.60
ItemValueTable["Base.BookMetalWelding5"] = 0.60
ItemValueTable["Base.BookTrapping5"] = 0.60

-- riviste

ItemValueTable["Base.MechanicMag1"] = 0.2
ItemValueTable["Base.MechanicMag2"] = 0.2
ItemValueTable["Base.MechanicMag3"] = 0.2
ItemValueTable["Base.MetalworkMag1"] = 0.2
ItemValueTable["Base.MetalworkMag2"] = 0.2
ItemValueTable["Base.MetalworkMag3"] = 0.2
ItemValueTable["Base.MetalworkMag4"] = 0.2
ItemValueTable["Base.ElectronicsMag4"] = 0.2
ItemValueTable["Base.FishingMag1"] = 0.3
ItemValueTable["Base.FishingMag2"] = 0.3
ItemValueTable["Base.HuntingMag1"] = 0.3
ItemValueTable["Base.HuntingMag2"] = 0.3
ItemValueTable["Base.HuntingMag3"] = 0.3
ItemValueTable["Base.CookingMag1"] = 0.3
ItemValueTable["Base.HerbalistMag"] = 0.8
ItemValueTable["Base.CookingMag2"] = 0.25
ItemValueTable["LabBooks.BkChemistryCourse"] = 15
ItemValueTable["LabBooks.BkLaboratoryEquipment1"] = 15
ItemValueTable["LabBooks.BkVirologyCourses1"] = 20







ItemCategoryTable = {}
CategoryList = { "All" }

function has_value (tab, val)
    if (tab ~= nil) and (val ~= nil) then
        for _, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
    end
    return false
end

--function StrReplace(thisString, findThis, replaceWithThis)
--    return string.gsub(thisString, "(" .. findThis .. ")", replaceWithThis)
--end
--function TableSize(a)
--    if (not a) then
--        return 0
--    end
--    local i = 1
--    for k, v in pairs(a) do
--        i = i + 1
--    end
--    return i
--end

--function IsIn(big, small)
--    local temp = StrReplace(big, small, "")
--    if (temp == big) then
--        return false
--    else
--        return true
--    end
--end
CategoryGroupTable = {}
CategoryTotals = {}
BackupOfItemValueTable = copyTable(ItemValueTable)
--isEnhancedMapShareEnabled = false

local function resetTable()
    ItemCategoryTable = {}
    CategoryList = { "All" }
    CategoryGroupTable = {}
    CategoryTotals = {}
end

function InitLRMTables()

    if ItemValueTable == nil then
        return
    end

    print("starting init")
    --isEnhancedMapShareEnabled = isModEnabled("amhghk")
    resetTable()


    --for k, v in pairs(ItemValueTable) do
    --    BackupOfItemValueTable[k] = v
    --end

    for k, v in pairs(ItemValueTable) do
        --if(v > 0) then
        local tempItem = getScriptManager():getItem(k)
        if (tempItem ~= nil) then
            local category = tempItem:getDisplayCategory()
            if (category == nil) then
                category = instanceItem(k):getCategory()
            end

            --if not (v > 0) then
            --    if (thecat == "Weapon") and (tempItem:getModule() == "ORGM") and (not IsIn(tempItem:getDisplayName(), "(")) then
            --        ItemValueTable[k] = 4.0
            --        v = 4.0
            --        --elseif(thecat == "Food") and tempItem:getFoodType()~= nil and (tostring(tempItem:getFoodType()) == "NoExplicit") then
            --        --	tempresult = 0
            --        --
            --        --	print(tempItem:getDisplayName()..": ".. tostring(tempItem:getFoodType()))
            --        --	tempresult = tempresult - (tempItem:getHungerChange())
            --        --	print("getHungerChange: "..tostring(tempItem:getHungerChange()) )
            --        --	tempresult = tempresult - (tempItem:getStressChange()/10)
            --        --	print("getStressChange: "..tostring(tempItem:getStressChange()) )
            --        --	tempresult = tempresult - (tempItem:getUnhappyChange()/10)
            --        --	print("getUnhappyChange: "..tostring(tempItem:getUnhappyChange()) )
            --        --	tempresult = tempresult - (tempItem:getBoredomChange()/10)
            --        --	print("getBoredomChange: "..tostring(tempItem:getBoredomChange()) )
            --        --
            --        --	if(tempresult < 0) then tempresult = 0.00 end
            --        --
            --        --	print("result value:"..tostring(tempresult))
            --        --	ItemValueTable[k] = tempresult
            --        --	v = tempresult
            --    elseif (thecat == "WeaponPart") then
            --        ItemValueTable[k] = 0.25
            --        v = 0.25
            --    end
            --end

            ItemCategoryTable[k] = category
            if (not has_value(CategoryList, category)) and category ~= "Key" then
                table.insert(CategoryList, category)
            end

            if (not CategoryGroupTable[category]) then
                CategoryGroupTable[category] = {}
                CategoryTotals[category] = 0
            end
            CategoryGroupTable[category][k] = v
            if (v > 0) then
                CategoryTotals[category] = CategoryTotals[category] + 1
            end

            --print(tostring(k) .. " added to category " .. tostring(thecat))
        else
            print("error loading item: " .. k)
        end
        --else
        --	ItemValueTable[k] = nil
        --	end
    end

    --BackupOfItemValueTable = nil
    --LRMInitDone = true
    print("finished init")

end

--Events.OnPreGameStart.Add(InitLRMTables)
--Events.OnGameStart.Add(InitLRMTables)
