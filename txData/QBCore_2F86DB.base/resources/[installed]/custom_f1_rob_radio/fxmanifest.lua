fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Custom F1 rob radial, reload, and player death appearance fixes'

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
