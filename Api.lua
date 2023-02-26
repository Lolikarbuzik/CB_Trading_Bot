--!strict

-- if _G.TradingApi then
--     return _G.TradingApi
-- end

local Signal: {new : () -> ()} = loadstring(game:GetObjects("rbxassetid://6654965987")[1].Source)()

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
	return {
		Player = Template:FindFirstChild("Them") and Players[Template:FindFirstChild("Them").Text] or Player,
		Offer = (function()
			local a = {}
			for i,v in pairs(Template.Offers:GetChildren()) do
				if v.ClassName~="UIGridLayout" then
					a[v.NameLabel.Text] = tostring(v.Amount.Value:gsub("x",""))
				end
			end
			return a
		end)()
	}
end

function TradingApi.GetTrade() : Trade
	local TradeTemplate = UI:FindFirstChild("TradeTemplate")
	return TradeTemplate and {You = ExtractDataFromTemplate(TradeTemplate.You), Them = ExtractDataFromTemplate(TradeTemplate.Them) } or nil
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
	return TradeEvent:FireServer(Player,Trade_Status)
end

_G.TradingApi = TradingApi

return TradingApi