local TradingPlaceId = 5325113759

if game.PlaceId ~= TradingPlaceId then return warn("Game isnt a CB Trading") end

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"
type AnalyzeResult = {Result : number,Reason : string}
local Tson = loadstring(game:HttpGet("https://pastebin.com/raw/9Tt6Ug7e"))()

local TradingApi:{
	GotTrade : RBXScriptSignal | {Destroy : () -> ()},
	GetTradeRequests : () -> (TradeList),
	Skins : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : Trade_Status, PlayerName : string) -> (),
	TradeAnalyzer : (Trade2 : TradeList, Trade1 : TradeList?) -> (AnalyzeResult),
	GetTrade : () -> ()
} = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()

local lib = loadstring(game:HttpGet("https://pastebin.com/raw/dm6dfm15"))()
local win = lib:AddWindow("BTrade 1.0",{
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(500, 600),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
})

local main = win:AddTab("Trading")

-- elements
do
	--[[
	1 Trade analyzer:
		• Check if player is currently trading if not. Tell player he isnt trading
		• Get AnalyzeResult from TradeAnalyzer
		• Tell Player AnalyzeResult
	2. 
	]]

	local AnalyzerBtn = win:AddButton("Trade Analyzer",function()
		if not TradingApi.GetTrade() then return end
		local AnalyzeResult = TradingApi:TradeAnalyzer()
	end)
end

TradingApi.GotTrade:Connect(function()
	
end)

print(Tson(TradingApi.Skins))