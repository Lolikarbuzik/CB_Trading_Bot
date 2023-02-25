type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"

local TradingApi:{
	GotTrade : RBXScriptSignal,
	GetTradeRequests : () -> (TradeList),
	SkinsList : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : Trade_Status, PlayerName : string) -> ()
} = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()


TradingApi.GotTrade:Connect(function(plr)
    print(plr)
end)