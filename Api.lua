--!strict

local Signal: {new : () -> ()} = loadstring(game:GetObjects("rbxassetid://6654965987")[1].Source)()

type TradeList = {Player}
type Skins_Demands = { string : number }
type Inventory = {}
type Trade_Status = "Create" | "DeclineTrade" | "SendTrade" | "GotTrade"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local SkinValues = ReplicatedStorage.Values

local InventoryEvent:RemoteFunction = Remotes.Inventory
local TradeEvent: RemoteEvent = Remotes.Trade

local TradingApi:{
	GotTrade : RBXScriptSignal,
	GetTradeRequests : () -> (TradeList),
	SkinsList : Skins_Demands,
	Inventory : (Player?) -> Inventory,
	Trade : (Player,Trade_Status ) -> ()
} = {}
TradingApi.GotTrade = {}

TradingApi.GotTrade = Signal.new()

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

return TradingApi