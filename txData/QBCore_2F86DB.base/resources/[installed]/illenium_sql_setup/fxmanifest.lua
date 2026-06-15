fx_version 'cerulean'
game 'gta5'

description 'Creates illenium-appearance database tables'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependency 'oxmysql'
