local ClosestCokePlant = nil
local inMission = false
local lastZone = false
local shown = false
local blips = {}
local veh = nil
local packages = 0
local delivered = 0
local onRoute = false
local spawnedPlants = false

Citizen.CreateThread(function()
    local wait = 1000
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehicleCoords = GetEntityCoords(veh)
        local inRange = false
        local inZone = false

        if not spawnedPlants then
            if #(pedCoords - Config.CokePlantZone) < 500 then
                CreateCokePlants()
                spawnedPlants = true
            end
        end

        for k, v in pairs(Config.CokePlants) do
            if #(pedCoords - v.coords) < 2 then
                inRange = true
                if v.prop ~= nil then
                    DrawText3Ds(vector3(v.coords.x, v.coords.y, v.coords.z + 1), _U('collect'))
                    if IsControlJustPressed(0, 38) then
                        FarmCokePlant()
                    end
                end 
            end 
        end

        for k, v in pairs(Config.Locations) do
            if v.show then
                if #(pedCoords - v.coords) < v.distance then
                    inRange = true

                    DrawText3Ds(vector3(v.coords.x, v.coords.y, v.coords.z), v.text1)
                    DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, v.marker.r, v.marker.g, v.marker.b, 222, false, false, false, true, false, false, false)
                    if IsControlJustPressed(0, v.key) then
                        ManageAction(k)
                    end 
                end 
            end
        end

        if inMission then
            for k, v in pairs(Config.DeliveryLocations) do
                if v.show then
                    if #(pedCoords - v.coords) < 600 then
                        inRange = true
                        inZone = true
                        if veh ~= nil then
                            DrawMarker(1, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 80.0, 80.0, 30.0, 200, 0, 0, 50, false, false, false, true, false, false, false)
                            if IsControlJustPressed(0, 38) then
                                if #(pedCoords - v.coords) < 80 then
                                    v.show = false
                                    RemoveBlip(v.blip)
                                    RemoveBlip(v.radius)
                                    DeliveryCoca()
                                else
                                    exports['t-notify']:Custom({
                                        style  =  'error',
                                        duration = 3000,
                                        message  =  _U('too_far'),
                                    })
                                end
                            end
                        end
                    end 
                end
            end

            if lastZone ~= inZone then
                lastZone = inZone
                shown = false
            end

            if inZone and not shown then
                shown = true
                exports['t-notify']:Custom({
                    style  =  'info',
                    duration = 7000,
                    message  =  _U('help_text_1'),
                    sound = true,
                })
            end
        end

        if veh ~= nil then
            if packages == 0 and not onRoute then
                if #(pedCoords - vehicleCoords) < 7 then
                    inRange = true
                    DrawText3Ds(vector3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z), _U('store_coca'))
                    if IsControlJustPressed(0, 38) then
                        SetDeliveryLocations()
                    end                        
                end
            end
        end

        if inRange then
            wait = 3
        else
            wait = 1000
        end

        Citizen.Wait(wait)
    end
end)

function DeliveryCoca()
    packages = packages - 1
    delivered = delivered + 1
    exports['t-notify']:Custom({
        style  =  'success',
        duration = 4000,
        message  =  _U('delivered'),
    })
    local pedCoords = GetEntityCoords(PlayerPedId())
    local prop = CreateObject(GetHashKey('prop_mp_drug_pack_red'), pedCoords.x, pedCoords.y, pedCoords.z - 1, true, false)
    Citizen.Wait(10000)
    DeleteObject(prop)
    if packages == 0 then
        exports['t-notify']:Custom({
            style  =  'info',
            duration = 10000,
            message  =  _U('return_plane'),
            sound = true,
        })
        local blip = AddBlipForCoord(Config.Locations["store_vehicle"].coords)
        blips[blip] = {}
        SetBlipRoute(blip, true)
    end
end

function SetDeliveryLocations()
    onRoute = true
    ESX.TriggerServerCallback('vrs_drugs:server:checkamount', function(amount)
        if amount > 0 then
            if amount > Config.MaxDeliveryLocations then
                amount = Config.MaxDeliveryLocations
            end

            TriggerServerEvent('vrs_drugs:server:removeitem', "coca", amount)
            packages = amount

            ExecuteCommand("e mechanic")
            ESX.Game.Utils.Progressbar("store_coca", _U('storing_coca'), packages * 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                for i = 1, packages, 1 do
                    local randomLocation = GetRandomLocation()
                    local blip = AddBlipForCoord(Config.DeliveryLocations[randomLocation].coords.x, Config.DeliveryLocations[randomLocation].coords.y, Config.DeliveryLocations[randomLocation].coords.z)
                    local radius = AddBlipForRadius(Config.DeliveryLocations[randomLocation].coords.x, Config.DeliveryLocations[randomLocation].coords.y, Config.DeliveryLocations[randomLocation].coords.z, 150.0)
                    
                    Config.DeliveryLocations[randomLocation].show = true

                    SetBlipAlpha(radius, 80) -- Change opacity here
                    SetBlipColour(radius, 1) -- Change blip colour here
    
                    SetBlipSprite(blip, 501)
                    SetBlipColour(blip, 1)
                    SetBlipScale(blip, 0.8)
                
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(_U('delivery_blip'))
                    EndTextCommandSetBlipName(blip)
    
                    blips[blip] = {}
                    blips[radius] = {}

                    Config.DeliveryLocations[randomLocation].blip = blip
                    Config.DeliveryLocations[randomLocation].radius = radius
                end
                ExecuteCommand("e c")
                exports['t-notify']:Custom({
                    style  =  'info',
                    duration = 8000,
                    message  =  _U('mission_text_2'),
                })
            end, function()
                ExecuteCommand("e c")
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('cancelled'),
                })
            end)
        else

        end
    end, "coca")
end

function GetRandomLocation()
    local location = nil
    while location == nil do
        local random = math.random(#Config.DeliveryLocations)

        if not Config.DeliveryLocations[random].selected then
            Config.DeliveryLocations[random].selected = true       
            location = random
        end
        Citizen.Wait(0) 
    end
    return location
end

function StartMission()
    inMission = true
    local blip = AddBlipForCoord(Config.Locations["garage"].coords)
    blips[blip] = {}
    SetBlipRoute(blip, true)

    Config.Locations["garage"].show = true

    exports['t-notify']:Custom({
        style  =  'success',
        duration = 3000,
        message  =  _U('mission_text_1'),
    })
end

function ManageAction(action)
    if action == "triturate" then
        ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
            if haveItem then
                ESX.TriggerServerCallback('vrs_drugs:server:checkspace', function(hasSpace)
                    if hasSpace then
                        local SucceededAttempts = 0
                        local NeededAttempts = 4
                        local ped = PlayerPedId()
                        local Skillbar = exports['cl_skillbar']:GetSkillbarObject()
                    
                        FreezeEntityPosition(ped, true)
                
                        ExecuteCommand("e parkingmeter")
                        Skillbar.Start({
                            duration = math.random(2500, 3500),
                            pos = math.random(10, 30),
                            width = math.random(10, 15),
                        }, function()
                            if SucceededAttempts + 1 >= NeededAttempts then
                                -- Finish
                                FreezeEntityPosition(ped, false)
                                ExecuteCommand("e c")
                                ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
                                    if haveItem then
                                        TriggerServerEvent('vrs_drugs:server:give:ground_coca')
                                    else
                                        exports['t-notify']:Custom({
                                            style  =  'error',
                                            duration = 3000,
                                            message  =  _U('item_not_found', "Hoja de coca"),
                                        })
                                    end
                                end, "coca_leaf", 2)
                            else
                                -- Repeat
                                Skillbar.Repeat({ 
                                    duration = math.random(1000, 2000),
                                    pos = math.random(10, 30),
                                    width = math.random(7, 10),
                                })
                                SucceededAttempts = SucceededAttempts + 1
                            end
                        end, function()
                            -- Fail
                            FreezeEntityPosition(ped, false)
                            exports['t-notify']:Custom({
                                style  =  'error',
                                duration = 3000,
                                message  =  _U('fail'),
                            })
                            ExecuteCommand("e c")
                        end) 
                    else
                        exports['t-notify']:Custom({
                            style  =  'error',
                            duration = 3000,
                            message  =  _U('not_enough_space'),
                        })
                    end
                end, "ground_coca", 1)
            else
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('item_not_found', "Hoja de coca"),
                })
            end
        end, "coca_leaf", 2)
    


    elseif action == "mix_water" then
        ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
            if haveItem then
                ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
                    if haveItem then
                        ESX.TriggerServerCallback('vrs_drugs:server:checkspace', function(hasSpace)
                            if hasSpace then
                                ExecuteCommand("e mechanic")
                                ESX.Game.Utils.Progressbar("mix_water", _U('mixing'), Config.MixDuration, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    TriggerServerEvent('vrs_drugs:server:give:queroseno')
                                    ExecuteCommand("e c")
                                end, function()
                                    ExecuteCommand("e c")
                                    exports['t-notify']:Custom({
                                        style  =  'error',
                                        duration = 3000,
                                        message  =  _U('cancelled'),
                                    })
                                end)
                            else
                                exports['t-notify']:Custom({
                                    style  =  'error',
                                    duration = 3000,
                                    message  =  _U('not_enough_space'),
                                })
                            end
                        end, "queroseno", 1)
                    else
                        exports['t-notify']:Custom({
                            style  =  'error',
                            duration = 3000,
                            message  =  _U('item_not_found', "Hoja de coca molida"),
                        })
                    end
                end, "ground_coca", 1)
            else
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('item_not_found', "Agua"),
                })
            end
        end, "water", 1)



    elseif action == "mix_acid" then
        ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
            if haveItem then
                ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
                    if haveItem then
                        ESX.TriggerServerCallback('vrs_drugs:server:checkspace', function(hasSpace)
                            if hasSpace then
                                ExecuteCommand("e mechanic")
                                ESX.Game.Utils.Progressbar("mix_water", _U('mixing'), Config.MixDuration, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    TriggerServerEvent('vrs_drugs:server:give:coca_paste')
                                    ExecuteCommand("e c")
                                end, function()
                                    ExecuteCommand("e c")
                                    exports['t-notify']:Custom({
                                        style  =  'error',
                                        duration = 3000,
                                        message  =  _U('cancelled'),
                                    })
                                end)
                            else
                                exports['t-notify']:Custom({
                                    style  =  'error',
                                    duration = 3000,
                                    message  =  _U('not_enough_space'),
                                })
                            end
                        end, "coca_paste", 1)
                    else
                        exports['t-notify']:Custom({
                            style  =  'error',
                            duration = 3000,
                            message  =  _U('item_not_found', "Queroseno"),
                        })
                    end
                end, "queroseno", 1)
            else
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('item_not_found', "Acido sulfurico"),
                })
            end
        end, "sulfuric_acid", 1)

        

    elseif action == "triturate_coca_paste" then
        ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
            if haveItem then
                ESX.TriggerServerCallback('vrs_drugs:server:checkspace', function(hasSpace)
                    if hasSpace then
                        local SucceededAttempts = 0
                        local NeededAttempts = 4
                        local ped = PlayerPedId()
                        local Skillbar = exports['cl_skillbar']:GetSkillbarObject()
                    
                        FreezeEntityPosition(ped, true)
                
                        ExecuteCommand("e parkingmeter")
                        Skillbar.Start({
                            duration = math.random(2500, 3500),
                            pos = math.random(10, 30),
                            width = math.random(10, 15),
                        }, function()
                            if SucceededAttempts + 1 >= NeededAttempts then
                                -- Finish
                                FreezeEntityPosition(ped, false)
                                ExecuteCommand("e c")
                                ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
                                    if haveItem then
                                        TriggerServerEvent('vrs_drugs:server:give:coca')
                                    else
                                        exports['t-notify']:Custom({
                                            style  =  'error',
                                            duration = 3000,
                                            message  =  _U('item_not_found', "Pasta de coca"),
                                        })
                                    end
                                end, "coca_paste", 1)
                            else
                                -- Repeat
                                Skillbar.Repeat({ 
                                    duration = math.random(1000, 2000),
                                    pos = math.random(10, 30),
                                    width = math.random(7, 10),
                                })
                                SucceededAttempts = SucceededAttempts + 1
                            end
                        end, function()
                            -- Fail
                            FreezeEntityPosition(ped, false)
                            exports['t-notify']:Custom({
                                style  =  'error',
                                duration = 3000,
                                message  =  _U('fail'),
                            })
                            ExecuteCommand("e c")
                        end) 
                    else
                        exports['t-notify']:Custom({
                            style  =  'error',
                            duration = 3000,
                            message  =  _U('not_enough_space'),
                        })
                    end
                end, "coca", 1)
            else
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('item_not_found', "Pasta de coca"),
                })
            end
        end, "coca_paste", 1)



    elseif action == "start_mission" then
        local job = ESX.GetPlayerData().job.name
        if job == "mafiaone" or job == "mafiatwo" or job == "mafiathree" or job == "mafiafour" or job == "mafiafive" or job == "mafiasix" or job == "mafiaseven" or job == "mafiaeight" or job == "mafianine" then
            --chekear cooldown y items
            ESX.TriggerServerCallback('vrs_drugs:server:checkcops', function(cops)
                if cops >= Config.MinCops then
                    ESX.TriggerServerCallback('vrs_drugs:server:checkitem', function(haveItem)
                        if haveItem then
                            StartMission()
                            Config.Locations["start_mission"].show = false
                            Config.Locations["stop_mission"].show = true
                        else
                            exports['t-notify']:Custom({
                                style  =  'error',
                                duration = 3000,
                                message  =  _U('item_not_found', "Cocaina"),
                            })
                        end
                    end, "coca", 1)  
                else
                    exports['t-notify']:Custom({
                        style  =  'error',
                        duration = 3000,
                        message  =  _U('not_cops'),
                    })
                end
            end)   
        else
            exports['t-notify']:Custom({
                style  =  'error',
                duration = 3000,
                message  =  _U('not_authorized'),
            })
        end
    elseif action == "stop_mission" then
        Config.Locations["stop_mission"].show = false
        if delivered > 0 then
            TriggerServerEvent("vrs_drugs:server:pay", delivered)
            exports['t-notify']:Custom({
                style  =  'success',
                duration = 8000,
                message  =  _U('mission_text_3', delivered * Config.CocaSellPrice),
                sound = true,
            }) 
        end
    
        if veh ~= nil then
            ESX.Game.DeleteVehicle(veh)
        end
        onRoute = false
        packages = 0
        delivered = 0
        inMission = false
        for k, v in pairs(blips) do
            RemoveBlip(k)
        end
        Citizen.Wait(500)
        Config.Locations["start_mission"].show = true
    elseif action == "garage" then
        Config.Locations["garage"].show = false
        Config.Locations["store_vehicle"].show = true
        for k, v in pairs(blips) do
            RemoveBlip(k)
        end
        DoScreenFadeOut(500)
        Citizen.Wait(1000)
        ESX.Game.SpawnVehicle(Config.VehicleMission, Config.Locations["spawn_vehicle"].coords, Config.Locations["spawn_vehicle"].heading, function(vehicle) 
            veh = vehicle
        end)
        DoScreenFadeIn(500)
        Citizen.Wait(1000) 
    elseif action == "store_vehicle" then
        Config.Locations["store_vehicle"].show = false
        if delivered > 0 then
            exports['t-notify']:Custom({
                style  =  'info',
                duration = 6000,
                message  =  _U('mission_text_4'),
                sound = true,
            })
            for k, v in pairs(blips) do
                RemoveBlip(k)
            end
            local blip = AddBlipForCoord(Config.Locations["stop_mission"].coords)
            blips[blip] = {}
            SetBlipRoute(blip, true)
        end
        ESX.Game.DeleteVehicle(veh)
        veh = nil
        Citizen.Wait(500)
        Config.Locations["garage"].show = true
    end
end

function FarmCokePlant()
    ESX.TriggerServerCallback('vrs_drugs:server:checkspace', function(hasSpace)
        if hasSpace then
            ExecuteCommand("e mechanic")
            ESX.Game.Utils.Progressbar("repair_part", _U('collecting'), Config.CollectDuration, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                TriggerServerEvent('vrs_drugs:server:give:coca_leaf')
                GetClosestCokePlant()
                DeleteCokePlant()
                SpawnNewCokePlant()
                ExecuteCommand("e c")
            end, function()
                ExecuteCommand("e c")
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('cancelled'),
                })
            end)
        else
            exports['t-notify']:Custom({
                style  =  'error',
                duration = 3000,
                message  =  _U('not_enough_space'),
            })
        end
    end, "coca_leaf", 1)
end

function DeleteCokePlant()
    DeleteEntity(Config.CokePlants[ClosestCokePlant].prop)
    Config.CokePlants[ClosestCokePlant].prop = nil
end

function SpawnNewCokePlant()

    while Config.CokePlants[ClosestCokePlant].timer > 0 do
        Config.CokePlants[ClosestCokePlant].timer = Config.CokePlants[ClosestCokePlant].timer - 1
        Citizen.Wait(1000)
    end

    local coords = vector3(Config.CokePlantZone.x + math.random(Config.MinPlantSpawnRadius, Config.MaxPlantSpawnRadius), Config.CokePlantZone.y + math.random(Config.MinPlantSpawnRadius, Config.MaxPlantSpawnRadius), Config.CokePlantZone.z -1.2)
    local prop = CreateObject(GetHashKey(Config.CokePlant), coords.x, coords.y, coords.z, true, false)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)
    coords = GetEntityCoords(prop)

    --assignment

    Config.CokePlants[ClosestCokePlant].timer = Config.PlantSpawnCoolDown
    Config.CokePlants[ClosestCokePlant].prop = prop
    Config.CokePlants[ClosestCokePlant].coords = coords
end

function GetClosestCokePlant()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = nil
    for k, v in pairs(Config.CokePlants) do

        if current == nil then
            dist = #(playerCoords - v.coords)
            current = k
        else
            if #(playerCoords - v.coords) < dist then
                dist = #(playerCoords - v.coords)
                current = k
            end
        end
    end
    ClosestCokePlant = current
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        for k, v in pairs(Config.CokePlants) do
            DeleteEntity(v.prop)
        end

        for k, v in pairs(blips) do
            RemoveBlip(k)
        end
        
        ESX.Game.DeleteVehicle(veh)
	end
end)

function CreateCokePlants()
    for i = 1, Config.CokeMaxPlants, 1 do
        local coords = vector3(Config.CokePlantZone.x + math.random(Config.MinPlantSpawnRadius, Config.MaxPlantSpawnRadius), Config.CokePlantZone.y + math.random(Config.MinPlantSpawnRadius, Config.MaxPlantSpawnRadius), Config.CokePlantZone.z)
        local prop = CreateObject(GetHashKey(Config.CokePlant), coords.x, coords.y, coords.z, true, false)
        PlaceObjectOnGroundProperly(prop)
        coords = GetEntityCoords(prop)
        FreezeEntityPosition(prop, true)
        table.insert(Config.CokePlants, {coords = coords, prop = prop, timer = Config.PlantSpawnCoolDown})
    end
end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(coords.x, coords.y, coords.z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end