--[[ NOT WORKING 
-> GotTrade

]]

local TradingApi = {
	GotTrade = {
		Connect = function(Func) : RBXScriptConnection
			local event
			event = TradeEvent.OnClientEvent:Connect(function(Trade_Status : Trade_Status, Player : Player)
				if Trade_Status == "GotTrade" then
					Func(Player)
				end
			end)
			return event
		end,
		Once = function(Func)
			local Event
			Event = TradingApi.GotTrade.Connect(function(...)
				Event:Disconnect()
				return Func(...)
			end)
		end,
	},
	GetTradeRequests = function() : TradeList
		return {}
	end,
	SkinsList = (function(List : Folder) : Skins_Demands
		local Skins = {}
		for _,SkinValue  in List:GetChildren() do
			Skins[SkinValue.Name] = (SkinValue::IntValue).Value
		end
		return Skins
	end)(SkinValues),
	Inventory = function(Player)
		return InventoryEvent:InvokeServer(Player)
	end,
	Trade = function(Player,Trade_Status)
		return TradeEvent:FireServer(Player,Trade_Status)
	end,
}