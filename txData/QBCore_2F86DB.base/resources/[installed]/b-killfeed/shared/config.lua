BDEV = {
    Framework = "qbcore",
}

BDEV.Killfeed = {
    --[[
        type: string
        @GLOBAL: The killfeed will be displayed to all players
        @LOCAL: The killfeed will only be displayed to the player who killed the target
        @NEARBY: The killfeed will be displayed to all players within a certain radius of the kill
    ]]
    type = "GLOBAL", 
    NearbyDistance = 100, -- The distance in which the killfeed will be displayed to other players
    enableJobsColor = true, -- Enable job colors in the killfeed
    jobs = {
        ["police"] = "#0000FF",
        ["ambulance"] = "#FF0000"
    }
}

--@Debug
BDEV.DEBUG = false -- Set to false to disable debug messages

--[[
    Exports:
    exports["b-killfeed"]:CreateKillfeed({
                                            killer: "Player 2",
                                            killerColor: "#730FFF",
                                            victimColor: "#0FFF9F",
                                            victimName: "Player 1",
                                            distance: 1000,
                                            streak: "2",
                                        })
]]
