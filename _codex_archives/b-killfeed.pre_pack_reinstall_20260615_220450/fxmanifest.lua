fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'b-dev.eu @ https://discord.gg/b-dev'
shared_scripts {
    "shared/config.lua",
    "shared/framework.lua",
}
server_scripts {
    'server/**/*.lua',
    'public/server/**/*.lua'
}
client_scripts {
    'client/**/*.lua',
    'public/client/**/*.lua'
}

files {
    'web/*.*',
    'web/**/*.*',
    'web/**/**/*.*',
    'web/**/**/**/*.*'
}

escrow_ignore {
    "shared/config.lua",
    "shared/framework.lua",
}

ui_page 'web/index.html'
