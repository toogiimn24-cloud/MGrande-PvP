Config = {}

Config.Zones = {
    Redzone = {
        center = vector3(-1474.455, -2716.211, 13.944),
        radius = 100.0,
        marker = {type=1, height=2.0, r=200, g=30, b=30, a=120},
        weapon = 'WEAPON_COMBATPISTOL',
        blip = {
            enabled = true,
            sprite = 161,     -- Skull
            color = 1,        -- Red
            scale = 1.2,
            label = "Redzone"
        },
        radiusBlip = {
            enabled = true,
            color = 1,        -- Red
            alpha = 100       -- Transparency
        }
    }
}

Config.UseBucket = true
Config.RedzoneBucket = 5001
Config.KillReward = 50
Config.RespawnTime = 5
Config.ChatPrefix = "[Redzone] "
Config.KillstreakAnnounce = {5, 10, 15, 20, 25, 30, 40, 50}
Config.RespawnPoints = {
    vector3(-1411.407, -2806.361, 13.944),
    vector3(-1380.159, -2765.143, 13.944)
}
