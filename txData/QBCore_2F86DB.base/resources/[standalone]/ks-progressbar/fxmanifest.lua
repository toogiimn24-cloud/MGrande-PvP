fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'KS Scripts'
description 'Standalone Progress Bar'
version '1.5'

escrow_ignore {
    'config.lua',
    'INSTALL/ox_lib/interface/client/progress.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/assets/*.js',
    'web/assets/*.css',
    'web/vite.svg'
}
shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua' 	


export 'start'
export 'cancelprogress'
dependency '/assetpacks'