fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'MGrande PvP core: safe zone, BlueZone, duel, airdrop, hub, shops'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory',
}
