fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Configurable QBCore Redzone Script (FFA) with NUI Kill Counter'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
