Config = {}

Config.Locale = "es"

Config.CokePlant = 'prop_plant_01a'

Config.VehicleMission = 'cuban800'

Config.CocaSellPrice = 1000000

Config.MinCops = 0

Config.CollectDuration = math.random(6000, 8000)

Config.MixDuration = math.random(7000, 9000)

Config.CokePlantZone = vector3(2814.801, -1491.409, 11.62096)

Config.MaxDeliveryLocations = 10

Config.CokeMaxPlants = 30

Config.PlantSpawnCoolDown = 5

Config.MaxPlantSpawnRadius = 20

Config.MinPlantSpawnRadius = -20

Config.CokePlants = {}

Config.Locations = {
    ["triturate"] = {coords = vector3(1975.482, 3818.685, 33.43629), marker = {r = 200, g = 0, b = 0}, distance = 7.0, text1 = _U('triturate'), show = true, key = 47},
    ["mix_water"] = {coords = vector3(1392.015, 3605.795, 38.94193), marker = {r = 130, g = 220, b = 250}, distance = 7.0, text1 = _U('mix_water'), show = true, key = 38},
    ["mix_acid"] = {coords = vector3(1365.923, 4358.083, 44.50055), marker = {r = 255, g = 255, b = 255}, distance = 7.0, text1 = _U('mix_acid'), show = true, key = 38},
    ["triturate_coca_paste"] = {coords = vector3(1904.54, 4924.141, 48.88424), marker = {r = 240, g = 215, b = 179}, distance = 7.0, text1 = _U('triturate_coca_paste'), show = true, key = 47},
    ["start_mission"] = {coords = vector3(1861.859, 3857.027, 36.27161), marker = {r = 200, g = 0, b = 0}, distance = 7.0, text1 = _U('start_mission'), show = true, key = 38},
    ["stop_mission"] = {coords = vector3(1861.859, 3857.027, 36.27161), marker = {r = 200, g = 0, b = 0}, distance = 7.0, text1 = _U('stop_mission'), show = false, key = 38},
    ["garage"] = {coords = vector3(2134.061, 4782.55, 40.97032), marker = {r = 200, g = 0, b = 0}, distance = 7.0, text1 = _U('take_vehicle'), show = false, key = 38},
    ["store_vehicle"] = {coords = vector3(2134.061, 4782.55, 40.97032), marker = {r = 200, g = 0, b = 0}, distance = 7.0, text1 = _U('store_vehicle'), show = false, key = 38},
    ["spawn_vehicle"] = {coords = vector3(2123.463, 4802.473, 41.09784), heading = 113.0, show = false, key = 38}
}

Config.DeliveryLocations = {
    [1] = {coords = vector3(-1869.346, 5240.271, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [2] = {coords = vector3(-1176.47, 5779.227, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [3] = {coords = vector3(-672.3224, 6834.427, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [4] = {coords = vector3(315.5794, 7203.788, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [5] = {coords = vector3(1045.713, 7134.688, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [6] = {coords = vector3(2145.985, 6936.219, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [7] = {coords = vector3(3381.922, 6317.003, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [8] = {coords = vector3(3692.727, 5282.537, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [9] = {coords = vector3(3891.397, 4575.002, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [10] = {coords = vector3(3902.818, 3840.887, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [11] = {coords = vector3(3669.78, 2744.24, 0.0), selected = false, show = false, blip = nil, radius = nil},
    [12] = {coords = vector3(3007.987, 1550.853, 0.0), selected = false, show = false, blip = nil, radius = nil}
}