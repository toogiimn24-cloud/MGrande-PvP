Config = {}

Config.Framework = 'QB'

Config.ESX = {
    enabled = false,
    sharedObject = 'esx:getSharedObject'
}

Config.QB = {
    enabled = true,
    coreObject = 'qb-core'
}

Config.CheckForUpdates = true

Config.AdminGroups = {
    'admin',
    'superadmin',
    'mod'
}

Config.AdminIdentifiers = {
    'license:your_license_here',
    'steam:your_steam_hex_here',
    'discord:your_discord_id_here',
}

Config.ComServLocation = vector3(3084.375488, -4719.055176, 15.262276)

Config.ComServZoneRadius = 40.0

Config.EscapePenalty = 10

Config.MarkerLocations = {
    vector3(3079.334961, -4734.686523, 15.262367),
    vector3(3072.769531, -4722.313477, 15.262246),
    vector3(3063.713867, -4735.427734, 15.261639),
    vector3(3082.999756, -4728.151367, 15.262296),
    vector3(3078.020508, -4708.569824, 15.262259)
}

Config.MarkerSettings = {
    type = 1,
    size = {x = 1.5, y = 1.5, z = 1.0},
    color = {r = 255, g = 165, b = 0, a = 200},
    bob = true
}

Config.AnimDict = 'anim@amb@drug_field_workers@rake@male_a@base'
Config.AnimName = 'base'

Config.ProgressBarTime = 10000

Config.WasabiAmbulance = false

Config.Notifications = {
    title = 'Community Service',
    success = 'success',
    error = 'error',
    info = 'info'
}

Config.ShowZoneOnMap = false
Config.ZoneBlipSprite = 9
Config.ZoneBlipColor = 5
Config.ZoneBlipScale = 1.0
Config.ZoneBlipName = 'Community Service Zone'

Config.ZoneRadiusBlipSprite = 1
Config.ZoneRadiusBlipColor = 5
Config.ZoneRadiusBlipAlpha = 128

Config.DisableCombatInZone = true
Config.AutoReviveInZone = true
