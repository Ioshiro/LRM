AdminManageUI, UserManageUI, OrderManageUI, ItemManageUI = nil
local subManageUI = nil

local function openUserManageUI()

    if UserManageUI then
        UserManageUI:close()
    end

    if OrderManageUI then
        OrderManageUI:close()
    end

    if ItemManageUI then
        ItemManageUI:close()
    end

    if subManageUI then
        subManageUI:close()
    end

    UserManageUI = NewISUserManageUI()
    UserManageUI:isSubUIOf(AdminManageUI)

    if AdminManageUI then
        UserManageUI:setPositionPixel(AdminManageUI:getX() + AdminManageUI:getWidth() + 15, AdminManageUI:getY())
    end
end

local function openOrderEditUI(goodInfo)

    if goodInfo == nil then
        return
    end

    if subManageUI then
        subManageUI:close()
    end

    subManageUI = NewUI()
    subManageUI:isSubUIOf(OrderManageUI)

    subManageUI:addText("", getText("UI_Goods_Edit_Title"))
    subManageUI:addEntry("EditTitle", goodInfo.name)
    subManageUI:nextLine()
    subManageUI:addText("", getText("UI_Goods_Edit_Price"))
    subManageUI:addEntry("EditPrice", tostring(math.floor(goodInfo.price * 100)), true)
    subManageUI:nextLine()
    subManageUI:addText("", getText("UI_Goods_Edit_Finished"))
    subManageUI:addTickBox("EditFinished")
    subManageUI["EditFinished"]:setValue(goodInfo.isFinish)
    subManageUI:nextLine()

    local isEnable = SandboxVars.LRM.OrderTimeOutDate == 0 or
        goodInfo.orderTime + SandboxVars.LRM.OrderTimeOutDate > getGameTime():getWorldAgeHours()

    subManageUI:addText("", getText("UI_Enable_Post"))
    subManageUI:addTickBox("EditEnable")
    subManageUI["EditEnable"]:setValue(isEnable)

    subManageUI:nextLine()

    subManageUI:addButton("SaveBtn", "Save", function()
        goodInfo.name = subManageUI["EditTitle"]:getValue()
        goodInfo.price = subManageUI["EditPrice"]:getValue() / 100.0
        goodInfo.isFinish = subManageUI["EditFinished"]:getValue()

        if isEnable ~= subManageUI["EditEnable"]:getValue() then
            if subManageUI["EditEnable"]:getValue() == true then
                goodInfo.orderTime = getGameTime():getWorldAgeHours()
            else
                goodInfo.orderTime = 0.0
            end
        end

        sendClientCommand(player, "LRM", "AddPlayerCommodity", { goodInfo })
        getPlayer():Say("Update Succeed")
    end)
    subManageUI["SaveBtn"]:setMarginHorizontal(10)

    subManageUI:nextLine()
    addLine(subManageUI)

    subManageUI:saveLayout()
    if OrderManageUI then
        subManageUI:setPositionPixel(OrderManageUI:getX() + OrderManageUI:getWidth() + 15, OrderManageUI:getY())
    end


end

local function openOrderManageUI()

    if UserManageUI then
        UserManageUI:close()
    end

    if OrderManageUI then
        OrderManageUI:close()
    end

    if ItemManageUI then
        ItemManageUI:close()
    end

    if subManageUI then
        subManageUI:close()
    end

    OrderManageUI = NewUI()
    OrderManageUI:setTitle(getText("UI_Page_Order"))
    OrderManageUI:isSubUIOf(AdminManageUI)

    OrderManageUI:setWidthPercent(0.15)

    addLine(OrderManageUI)

    local playerList = table.shallow_copy(PlayerInventory)

    local goodsName = {}
    local goodsList = {}

    for _, v in pairs(playerList.items) do
        table.insert(goodsName, v.name)
        table.insert(goodsList, v)

    end

    OrderManageUI:addScrollList("OrderList", goodsName)
    OrderManageUI:setLineHeightPercent(0.3)
    OrderManageUI["OrderList"]:setOnMouseDownFunction(goodsList, function(items, _)
        local goodsInfo = items[OrderManageUI["OrderList"]:getSelected()]
        openOrderEditUI(goodsInfo)
    end)

    OrderManageUI:nextLine()
    addLine(OrderManageUI)

    OrderManageUI:saveLayout()
    if AdminManageUI then
        OrderManageUI:setPositionPixel(AdminManageUI:getX() + AdminManageUI:getWidth() + 15, AdminManageUI:getY())
    end
end

local function openItemEditUI(itemId, itemPrice)
    if subManageUI then
        subManageUI:close()
    end

    subManageUI = NewUI()
    subManageUI:setWidthPercent(0.15)
    subManageUI:setTitle(getText("UI_Add_Custom_Item"))

    if ItemManageUI then
        subManageUI:isSubUIOf(ItemManageUI)
    end

    addLine(subManageUI)
    subManageUI:addText("", getText("UI_Add_Custom_Item_Id"))
    subManageUI:addEntry("ItemId", itemId)
    subManageUI:setLineHeightPercent(0.025)
    subManageUI:nextLine()

    subManageUI:addText("", getText("UI_Add_Custom_Item_Price"))
    subManageUI:addEntry("ItemPrice", tostring(itemPrice), true)
    subManageUI:setLineHeightPercent(0.025)
    subManageUI:nextLine()
    addLine(subManageUI)

    subManageUI:addButton("AddBtn", getText("UI_Mod_Custom_Item"), function()

        local id = subManageUI["ItemId"]:getValue()
        local price = subManageUI["ItemPrice"]:getValue()

        if id == nil or price == nil or price < 0.0 then
            return
        end

        if getScriptManager():getItem(id) == nil then
            doSystemHint(getText("UI_Valid_Item_Id"), false)
            return
        end
        doSystemHint(getText("UI_Add_Item_Succeed"), true)
        sendClientCommand("LRM", "UpdateItemTable", { id, price })
    end)
    subManageUI:setLineHeightPercent(0.03)
    subManageUI["AddBtn"]:setMarginHorizontal(100)
    subManageUI:nextLine()
    addLine(subManageUI)

    subManageUI:saveLayout()
    subManageUI:setPositionPixel(ItemManageUI:getX() + ItemManageUI:getWidth() + 15, ItemManageUI:getY())

end

function openItemManageUI(parentUI, editable)

    if UserManageUI then
        UserManageUI:close()
    end

    if OrderManageUI then
        OrderManageUI:close()
    end

    if ItemManageUI then
        ItemManageUI:close()
    end

    if subManageUI then
        subManageUI:close()
    end

    ItemManageUI = NewISItemManageUI()
    ItemManageUI:isSubUIOf(parentUI)
    ItemManageUI:setTitle(getText("UI_Page_Item"))

    addLine(ItemManageUI)

    ItemManageUI:setWidthPercent(0.23)
    ItemManageUI:setLineHeightPercent(0.6)
    local itemNames, itemList = ItemManageUI:buildItemNameList(ItemValueTable, "", editable)
    ItemManageUI:addText("", "filter:")
    ItemManageUI:addEntry("FilterItems", "")
    ItemManageUI:setLineHeightPercent(0.025)
    ItemManageUI:nextLine()
    ItemManageUI:setLineHeightPercent(0.01)
    ItemManageUI:nextLine()

    ItemManageUI:addScrollList("ItemList", itemNames)
    ItemManageUI:setLineHeightPercent(0.6)
    if editable then
        ItemManageUI["ItemList"]:setOnMouseDownFunction(itemList, function(items, _)
            local itemInfo = items[ItemManageUI["ItemList"]:getSelected()]
            openItemEditUI(itemInfo[1], itemInfo[2])
        end)

        ItemManageUI:nextLine()
        addLine(ItemManageUI)

        ItemManageUI:setLineHeightPercent(0.04)
        ItemManageUI:addButton("AddBtn", getText("UI_Add_Custom_Item"), function()
            openItemEditUI("", "")
        end)
        ItemManageUI["AddBtn"]:setMarginHorizontal(30)

    end

    ItemManageUI:nextLine()
    addLine(ItemManageUI)

    ItemManageUI:saveLayout()
    if parentUI then
        ItemManageUI:setPositionPixel(parentUI:getX() + parentUI:getWidth() + 15, parentUI:getY())

    end

end

function createAdminUI()

    if AdminManageUI then
        AdminManageUI:close()
    end

    AdminManageUI = NewUI()

    AdminManageUI:setTitle(getText("UI_Page_Admin"))

    addLine(AdminManageUI)
    AdminManageUI:addButton("btn1", getText("UI_Page_User"), openUserManageUI)
    AdminManageUI:setLineHeightPercent(0.05)
    AdminManageUI["btn1"]:setMarginHorizontal(30)
    AdminManageUI:nextLine()
    addLine(AdminManageUI)

    AdminManageUI:addButton("btn2", getText("UI_Page_Order"), openOrderManageUI)
    AdminManageUI:setLineHeightPercent(0.05)
    AdminManageUI["btn2"]:setMarginHorizontal(30)
    AdminManageUI:nextLine()
    addLine(AdminManageUI)

    AdminManageUI:addButton("btn3", getText("UI_Page_Item"), function()
        openItemManageUI(AdminManageUI, true)
    end)
    AdminManageUI:setLineHeightPercent(0.05)
    AdminManageUI["btn3"]:setMarginHorizontal(30)
    AdminManageUI:nextLine()
    addLine(AdminManageUI)

    AdminManageUI:addButton("btn4", getText("UI_Page_Backup"), function()
        sendClientCommand("LRM", "RequestBackLRMItemConfig", nil)
    end)
    AdminManageUI:setLineHeightPercent(0.05)
    AdminManageUI["btn4"]:setMarginHorizontal(30)
    AdminManageUI:nextLine()
    addLine(AdminManageUI)

    if SandboxVars.LRM.EnableRestore then
        AdminManageUI:setLineHeightPercent(0.05)

        AdminManageUI:addButton("btn5", getText("UI_Page_Restore"), function()
            sendClientCommand("LRM", "RequestRestoreLRMItemConfig", nil)
        end)
        AdminManageUI["btn5"]:setMarginHorizontal(5)

        AdminManageUI:addButton("btn6", getText("UI_Page_Reset"), function()
            sendClientCommand("LRM", "RequestResetLRMItemConfig", nil)
        end)
        AdminManageUI["btn6"]:setMarginHorizontal(5)

        AdminManageUI:nextLine()
        addLine(AdminManageUI)
    end

    AdminManageUI:saveLayout()


end
