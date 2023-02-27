rconsoleclose()
local TradingPlaceId = 5325113759

if game.PlaceId ~= TradingPlaceId then return warn("Game isnt a CB Trading") end

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"
type AnalyzeResult = {Result : number,Reason : string}

local Players = game:GetService("Players")
local TradingApi:{
	GotTrade : RBXScriptSignal | {Destroy : () -> ()},
	GetTradeRequests : () -> (TradeList),
	Skins : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : "Create" | "DeclineTrade" | "SendTrade" | "GotTrade", Player : Player) -> (),
	TradeAnalyzer : (Trade2 : TradeList, Trade1 : TradeList?) -> (AnalyzeResult),
	GetTrade : () -> (),
	tson : (obj : any) -> ()
} = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()

local n = "BTrade 1.0"

local lib = loadstring(game:HttpGet("https://pastebin.com/raw/eZHeDLKM"))()
local StarterGui = game:GetService("StarterGui")
local notify = function(data)
	data.Title = data.Title or n
	print(TradingApi.tson(data))
	return StarterGui:SetCore("SendNotification",data)
end
local win = lib:AddWindow(n,{
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(500, 600),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
})

local main = win:AddTab("Trading")

local Settings = {
	AutoTradeAccept = false
}

local function change(n)
	return function(v)
		Settings[n]=v
	end
end

-- elements
do
	--[[
	1 Trade analyzer:
		• Check if player is currently trading if not. Tell player he isnt trading
		• Get AnalyzeResult from TradeAnalyzer
			• Get Trade data -> { You , Them }

			• How trade can be "positive":
				• We get +value from trade, factors:
					• Skin base value (not accurate)
					• Skin demandw 

			• Return a calculated Result 
		• Tell Player AnalyzeResult
	2. TradeAll: 
		• Sends Trade requests to all players
	3. AutoTradeAccept		
	]]

	local AnalyzerBtn = main:AddButton("Trade Analyzer",function()
		local Trade = TradingApi.GetTrade()
		if not Trade then return notify({Text = "You have to be in a trade!"}) end
		local AnalyzeResult = TradingApi:TradeAnalyzer()
		notify({Text = AnalyzeResult.Reason:format(AnalyzeResult.Result)})
	end)

	local TradeAll = main:AddButton("Trade all",function()
		for i,v in pairs(Players:GetPlayers()) do
			if v==Players.LocalPlayer then continue end
			TradingApi.Trade("SendTrade",v.Name)
			--print("SendTrade to",v.Name)
		end
	end)

	local AutoTradeAccept = main:AddSwitch("Auto Trade accept",change("AutoTradeAccept"))
end

TradingApi.GotTrade:Connect(function(plr)
	if Settings.AutoTradeAccept then
		TradingApi.Trade("Create",plr.Name)
	end
end)