fx_version 'cerulean'
game 'gta5'
lua54 'true'

author 'Fearx'
description 'FearX-Looting - Enhanced Looting System with Playtime & Item Protection'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/version.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/playtime.lua',
    'server/main.lua',
    'server/version.lua',
    'server/updater.lua'
}

dependencies {
    'ox_inventory',
    'ox_lib',
    'oxmysql'
}

escrow_ignore {
    'config.lua'
}

dependency '/assetpacks'