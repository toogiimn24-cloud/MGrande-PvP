Config = {}

Config.Color = "#3498db"

Config.Locale = {
    settings_label = "Position Settings",
    settings_sublabel = "Drag to move. Press ESC to exit.",
    settings_help_text = "Use [+]/[-] to resize. Hold [SHIFT] + Drag to rotate.",
    test_label = "Cracking a safe",
    test_sublabel = "Finding the combination..."
}

-- Commands
Config.CommandPlayerSettings = "progresssettings" -- For players (Local changes)
Config.CommandAdminDefaults = "progressdefaults"  -- For admins (Global changes)

-- Player Permissions
-- If false, players cannot open the settings menu at all to move/rotate
-- If true, they can open the menu and adjust locally
Config.AllowPlayerMove = true
Config.AllowPlayerRotate = true
Config.AllowPlayerScale = true
Config.AllowPlayerColors = true

-- Admin List (License)
Config.Admins = {
    "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
}
