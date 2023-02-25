type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"

local TradingApi:{
	GotTrade : RBXScriptSignal | {Destroy : () -> ()},
	GetTraDeRequests : () -> (TradeList),
	SkinsList : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : Trade_Status, PlayerName : string) -> ()
} = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()

print("Trading Bot started",TradingApi)

TradingApi.GotTrade:Connect(function(plr)
    print("Got Trade from",plr.Name)
end)