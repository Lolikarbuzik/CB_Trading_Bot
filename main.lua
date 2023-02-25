type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"

local TradingApi:{
	GotTrade : RBXScriptSignal,
	GetTradeRequests : () -> (TradeList),
	SkinsList : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Player,Trade_Status ) -> ()
} = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()
print(TradingApi)