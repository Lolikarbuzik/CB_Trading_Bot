rconsoleclose()
local TradingPlaceId = 5325113759

if game.PlaceId ~= TradingPlaceId then return warn("Game isnt a CB Trading") end

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"
type AnalyzeResult = {Result : number,Reason : string}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local TradingApi:{
	GotTrade : RBXScriptSignal | {Destroy : () -> ()},
	GetTradeRequests : () -> (TradeList),
	Skins : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : "Create" | "DeclineTrade" | "SendTrade" | "GotTrade", Player : Player) -> (),
	TradeAnalyzer : (Trade2 : TradeList, Trade1 : TradeList?) -> (AnalyzeResult),
	GetTrade : () -> (),
	tson : (obj : any) -> ()
} = _G.TradingApi or loadstring(game:HttpGet("https://raw.githubusercontent.com/Lolikarbuzik/CB_Trading_Bot/main/Api.lua"))()

local n = "BTrade 1.0"

local lib = loadstring(game:HttpGet("https://pastebin.com/raw/eZHeDLKM"))()
local StarterGui = game:GetService("StarterGui")
local notify = function(data)
	data.Title = data.Title or n
	return StarterGui:SetCore("SendNotification",data)
end
local win = lib:AddWindow(n,{
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(500, 600),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
})

local main = win:AddTab("Trading")
main:Show()

local Settings = {
	AutoTradeAccept = false,
	TradeBot = false,
	TradeFriends = false,
	LFriendJoin = false
}

local function change(n,callbacks)
	callbacks = setmetatable(callbacks or {},{
		__index = function()
			return function() end
		end
	})
	return function(v)
		Settings[n]=v
		callbacks[v]()
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
					• Skin base value (not accurate) or demand

			• Return a calculated Result 
		• Tell Player AnalyzeResult
	2. TradeAll: 
		• Sends Trade requests to all players
	3. AutoTradeAccept
	4. Trade bot:
		• Skins to get to filter out from all players to get players what we can trade
		• Do we trade friends?
		• Skins we cant trade or are blocked
		• Start trading via Switch
		• When set to true call "callback"
	]]
	local AnalyzerBtn = main:AddButton("Trade Analyzer",function()
		local Trade = TradingApi.GetTrade()
		if not Trade then return notify({Text = "You have to be in a trade!"}) end
		local AnalyzeResult = TradingApi.TradeAnalyzer()
		notify({Text = AnalyzeResult.Reason:format(AnalyzeResult.Result)})
	end)

	local TradeAll = main:AddButton("Trade all",function()
		for i,v in pairs(Players:GetPlayers()) do
			if v==Players.LocalPlayer then continue end
			TradingApi.Trade("SendTrade",v)
			--print("SendTrade to",v.Name)
		end
	end)

	local AutoDecline = main:AddSwitch("Auto Decline (Code below)",change("AutoDecline"))
	local ADCode = main:AddConsole({
		["y"] = 200,
		["source"] = "Lua",
	})
	ADCode:Set("local Trade = true\nreturn Trade and \"Create\" or \"DeclineTrade\" ")

	local function consoleAD(code,env)
		local func = loadstring(code)
		local env = env or getfenv(0)
		env.RequestData = {
			Player = LP,
			Inventory = TradingApi.Inventory(LP)
		}
		env.TradingApi = TradingApi
		setfenv(func,env)
		return func()
	end

	local ExecPreview = main:AddButton("Execute Preview",function()
		consoleAD(ADCode:Get())
	end)

	local AutoTradeAccept = main:AddSwitch("Auto Trade accept",change("AutoTradeAccept"))
	local TradeBotFolder = main:AddFolder("Trade Bot")
	local TradeFriends = TradeBotFolder:AddSwitch("Trade friends (not recommended)",change("TradeFriends"))
	local LeaveFriendJoin = TradeBotFolder:AddSwitch("Leave when friend joins",change("LFriendJoin"))
	local TradingSwitch = TradeBotFolder:AddSwitch("Trading Bot",function(v)
		change("TradeBot")(v)
		while Settings.TradeBot do
			break
		end
	end)

	-- events
	TradingApi.GotTrade:Connect(function(plr)
		local res = consoleAD(ADCode:Get())
		if Settings.AutoTradeAccept then
			TradingApi.Trade("Create",plr.Name)
		end
	end)

	Players.PlayerAdded:Connect(function(plr)
		if plr:IsFriendsWith(LP.UserId) and Settings.LFriendJoin then
			game:GetService("TeleportService"):Teleport(TradingPlaceId,LP)
		end
	end)
end