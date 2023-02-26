--!strict

-- if _G.TradingApi then
--     return _G.TradingApi
-- end

local Signal: {new : () -> RBXScriptSignal | RBXScriptConnection} = loadstring(game:GetObjects("rbxassetid://6654965987")[1].Source)()
local tson = loadstring(game:HttpGet("https://pastebin.com/raw/9Tt6Ug7e"))()

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"
type AnalyzeResult = {Result : number,Reason : string}
type Trade = {You : {}, Them : {}}

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local SkinValues = ReplicatedStorage.Values

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UI = Player.PlayerGui.UI


local InventoryEvent:RemoteFunction = Remotes.Inventory
local TradeEvent: RemoteEvent = Remotes.Trade

local TradingApi:{
	GotTrade : RBXScriptSignal | {Destroy : () -> ()},
	GetTradeRequests : () -> (TradeList),
	Skins : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status : Trade_Status, PlayerName : string) -> (),
	TradeAnalyzer : (Trade2 : TradeList, Trade1 : TradeList?) -> (AnalyzeResult),
	GetTrade : () -> ()
} = {}

local function ExtractDataFromTemplate(Template)
	local TextLabel = (Template::Frame):FindFirstChildOfClass("TextLabel")
	local Find = {TextLabel.Text:find(".*'s")}
	return {
		Player = TextLabel.Name == "You" and Player or Players:FindFirstChild(TextLabel.Text:sub(Find[1],Find[2]-2)),
		Offer = (function()
			local a = {}
			for i,v in pairs(Template.Offer:GetChildren()) do
				if v.ClassName~="UIGridLayout" then
					a[v.NameLabel.Text] = tostring(v.Amount.Text:gsub("x",""))
				end
			end
			return a
		end)()
	}
end

function TradingApi.GetTrade() : Trade
	local TradeTemplate = UI:FindFirstChild("TradeTemplate")
	return TradeTemplate and {You = ExtractDataFromTemplate(TradeTemplate.You), Them = ExtractDataFromTemplate(TradeTemplate.Them) } or false
end

TradingApi.GotTrade = Signal.new()

TradeEvent.OnClientEvent:Connect(function(Trade_Status : Trade_Status, PlayerName : string)
    if Trade_Status == "GotTrade" and TradingApi.GotTrade then
        TradingApi.GotTrade:Fire(Players[PlayerName])
    end
end)

function TradingApi.GetTradeRequests() : TradeList
	return {}
end

TradingApi.SkinsList = (function(List : Folder)
	local Skins = {}
	for _,SkinValue in pairs(List:GetChildren()) do
		Skins[SkinValue.Name] = (SkinValue::IntValue).Value
	end
	return Skins
end)(SkinValues)

function TradingApi.Inventory(Player) : Inventory
	return InventoryEvent:InvokeServer(Player)
end
function TradingApi.Trade(Player,Trade_Status)
	return TradeEvent:FireServer(Players:FindFirstChild(tostring(Player)),Trade_Status)
end

TradingApi.tson = tson
_G.TradingApi = TradingApi

return TradingApi