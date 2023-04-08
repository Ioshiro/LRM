-- Classe helper per comprare un oggetto, probabilmente non viene usata (TODO da verificare/togliere)
function DoBuyOperation(items, value)
    local syncContainer = getSyncContainer()
    if syncContainer == nil then
        return
    end

    local player = getPlayer()
    local yourItemsValue = getPlayerAssets()
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
end