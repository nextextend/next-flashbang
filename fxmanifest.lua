fx_version 'cerulean'
game 'gta5'

author 'The Next Team | github.com/next-resources'
description 'The most optimized flashbang system.'
version '1.0.0'
lua54 'yes'

client_scripts {
    --'@ox_lib/init.lua', -- Uncomment if using ox_inventory (Recommended for better client performance). The system will automatically adapt to this change.
    'config.lua',
    'client.lua'
}

server_script 'server.lua'