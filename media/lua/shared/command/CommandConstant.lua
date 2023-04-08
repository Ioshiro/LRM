 -- Costanti per i comandi client/server (non credo siano utilizzate)
Command = {}
Command.Client = {}
Command.Server = {}
-- Comandi client
Command.Client.ResetInventory = "ResetInventory"
Command.Client.ModifyInventory = "ModifyInventory"
Command.Client.UpdatePlayerScore = "UpdatePlayerScore"
Command.Client.UpdatePlayerData = "UpdatePlayerData"
Command.Client.AddPlayerCommodity = "AddPlayerCommodity"
Command.Client.RequestPlayerCommodity = "RequestPlayerCommodity"
Command.Client.RequestInitData = "RequestInitData"
-- Comandi server
Command.Server.SyncInventory = "SyncInventory"
Command.Server.SyncPlayerInventory = "SyncPlayerInventory"
Command.Server.InitTradingData = "InitTradingData"
Command.Server.SendPlayerCommodity = "SendPlayerCommodity"