fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'qb-inventory'
description 'Compatibility wrapper for QBCore scripts using ox_inventory'

dependency 'ox_inventory'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
