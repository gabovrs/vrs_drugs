RegisterServerEvent('vrs_drugs:server:give:coca_leaf')
AddEventHandler('vrs_drugs:server:give:coca_leaf', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.addInventoryItem("coca_leaf", 1)

end)

RegisterServerEvent('vrs_drugs:server:give:ground_coca')
AddEventHandler('vrs_drugs:server:give:ground_coca', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.removeInventoryItem("coca_leaf", 2)
	xPlayer.addInventoryItem("ground_coca", 1)

end)

RegisterServerEvent('vrs_drugs:server:give:queroseno')
AddEventHandler('vrs_drugs:server:give:queroseno', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.removeInventoryItem("water", 1)
	xPlayer.removeInventoryItem("ground_coca", 1)
	xPlayer.addInventoryItem("queroseno", 1)

end)

RegisterServerEvent('vrs_drugs:server:give:coca_paste')
AddEventHandler('vrs_drugs:server:give:coca_paste', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.removeInventoryItem("sulfuric_acid", 1)
	xPlayer.removeInventoryItem("queroseno", 1)
	xPlayer.addInventoryItem("coca_paste", 1)

end)

RegisterServerEvent('vrs_drugs:server:give:coca')
AddEventHandler('vrs_drugs:server:give:coca', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.removeInventoryItem("coca_paste", 1)
	xPlayer.addInventoryItem("coca", 1)

end)


ESX.RegisterServerCallback('vrs_drugs:server:checkspace', function(source, cb, itemName, itemCount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.canCarryItem(itemName, itemCount) then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('vrs_drugs:server:checkitem', function(source, cb, itemName, itemCount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(itemName).count >= itemCount then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('vrs_drugs:server:checkamount', function(source, cb, itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.getInventoryItem(itemName).count)
end)


ESX.RegisterServerCallback('vrs_drugs:server:checkcops', function(source, cb)
	local xPlayers = ESX.GetPlayers()
	local cops = 0
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'pdi' then
			cops = cops + 1
		end
	end
	cb(cops)
end)

RegisterServerEvent('vrs_drugs:server:removeitem')
AddEventHandler('vrs_drugs:server:removeitem', function(itemName, itemCount)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	xPlayer.removeInventoryItem(itemName, itemCount)
end)

RegisterServerEvent('vrs_drugs:server:pay')
AddEventHandler('vrs_drugs:server:pay', function(amount)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local pay = 0
	if amount <= Config.MaxDeliveryLocations then
		pay = amount * Config.CocaSellPrice
		xPlayer.addAccountMoney('black_money', pay)
	else
		print(GetPlayerName(src, "HACKEANDO TRIGGER DE VRS_DRUGS CON MONTO", amount))
	end
end)

