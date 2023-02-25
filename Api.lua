--!strict

local Signal: {new : () -> ()} = loadstring(game:GetObjects("rbxassetid://6654965987")[1].Source)()

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local SkinValues = ReplicatedStorage.Values

local Players = game:GetService("Players")

local InventoryEvent:RemoteFunction = Remotes.Inventory
local TradeEvent: RemoteEvent = Remotes.Trade

local TradingApi:{
	GotTrade : RBXScriptConnection,
	GetTradeRequests : () -> (TradeList),
	SkinsList : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Trade_Status,Player ) -> ()
} = {}
TradingApi.GotTrade = {}

TradingApi.GotTrade = Signal.new()

TradeEvent.OnClientEvent:Connect(function(Trade_Status : Trade_Status, PlayerName : string)
    if Trade_Status == "GotTrade" and TradingApi.GotTrade then
        TradingApi.GotTrade:Fire(Players[PlayerName])
    end
end)

function TradingApi:GetTradeRequests() : TradeList
	return {}
end

TradingApi.SkinsList = (function(List : Folder)
	local Skins = {}
	for _,SkinValue  in List:GetChildren() do
		Skins[SkinValue.Name] = (SkinValue::IntValue).Value
	end
	return Skins
end)(SkinValues)

function TradingApi:Inventory(Player) : Inventory
	return InventoryEvent:InvokeServer(Player)
end
function TradingApi:Trade(Player,Trade_Status)
	return TradeEvent:FireServer(Player,Trade_Status)
end

_G.TradingApi = TradingApi

return TradingApi