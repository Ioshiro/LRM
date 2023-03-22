require "ISUI/ISItemManageUI"

ISUserManageUI = ISItemManageUI:derive("ISUserManageUI");
local subManageUI = nil

function ISUserManageUI:openPlayerEditUI(playerInfo)
    if playerInfo == nil then
        return
    end

    if subManageUI then
        subManageUI:close()
    end

    subManageUI = NewUI()
    subManageUI:isSubUIOf(UserManageUI)

    subManageUI:addText("", getText("UI_Edit_Player_Assets"))
    subManageUI:addEntry("EditAssets", tostring(math.floor(playerInfo.score * 100)), true)
    subManageUI:nextLine()
    subManageUI:addText("", getText("UI_Edit_Player_Banned"))
    subManageUI:addTickBox("EditBanner")
    subManageUI["EditBanner"]:setValue(playerInfo.banned)

    subManageUI:nextLine()

    subManageUI:addButton("SaveBtn", "Save", function()
        playerInfo.score = subManageUI["EditAssets"]:getValue() / 100.0
        playerInfo.banned = subManageUI["EditBanner"]:getValue()
        sendClientCommand("LRM", "UpdatePlayerData", { playerInfo })
        getPlayer():Say("Update Succeed")
    end)

    subManageUI["SaveBtn"]:setMarginHorizontal(10)

    subManageUI:nextLine()
    addLine(subManageUI)

    subManageUI:saveLayout()
    if UserManageUI then
        subManageUI:setPositionPixel(UserManageUI:getX() + UserManageUI:getWidth() + 15, UserManageUI:getY())
    end

end

function ISUserManageUI:buildPlayerNameList(players, filter)
    local playerNames = {}
    local playerList = {}
    for k, v in pairs(players) do
        if v.username then
            if filter == "" then
                table.insert(playerNames, v.username)
                table.insert(playerList, v)
            elseif filter and string.contains(string.lower(v.username), string.lower(filter)) then
                table.insert(playerNames, v.username)
                table.insert(playerList, v)
            end
        end
    end
    return playerNames, playerList
end

function ISUserManageUI:filter()
    local filterText = string.trim(self["FilterPlayers"]:getInternalText())
    local playerNames, playerList = self:buildPlayerNameList(table.shallow_copy(PlayerInventory).players, filterText)
    if self["PlayerList"] then
        print("filter: " .. filterText)
        self["PlayerList"]:setItems(playerNames)
        self["PlayerList"]:setOnMouseDownFunction(playerList, function(items, _)
            local playerInfo = items[self["PlayerList"]:getSelected()]
            ISUserManageUI:openPlayerEditUI(playerInfo)
        end)
    end
end

function ISUserManageUI:update()
    if self["FilterPlayers"] ~= nil then
        local text = string.trim(self["FilterPlayers"]:getInternalText())
        if text ~= self.lastText then
            self:filter()
            self.lastText = text
        end
    end
end

function NewISUserManageUI()
    local ui = ISUserManageUI:new(0.4, 0.4, 0.2)
    ui:initialise();
    ui:instantiate();
    ui:setTitle(getText("UI_Page_User"))
    ui:setWidthPercent(0.15)
    addLine(ui)
    local playerData = table.shallow_copy(PlayerInventory)
    local playerNames, playerList = ui:buildPlayerNameList(playerData.players, "")
    ui:addText("", "filter:")
    ui:addEntry("FilterPlayers", "")
    ui:nextLine()
    ui:addScrollList("PlayerList", playerNames)
    ui:setLineHeightPercent(0.3)
    ui["PlayerList"]:setOnMouseDownFunction(playerList, function(items, _)
        local playerInfo = items[ui["PlayerList"]:getSelected()]
        ISUserManageUI:openPlayerEditUI(playerInfo)
    end)
    ui:nextLine()
    addLine(ui)
    ui:saveLayout()
    return ui
end
