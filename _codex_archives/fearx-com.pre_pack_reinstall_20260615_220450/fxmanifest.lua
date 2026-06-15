fx_version 'cerulean'
game 'gta5'

author 'FearX'
description 'FearX Community Service System'
version '1.2.4'

lua54 'yes'

shared_scripts {
    'config/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
    'config/sv_config.lua',
    'config/config.lua'
}

