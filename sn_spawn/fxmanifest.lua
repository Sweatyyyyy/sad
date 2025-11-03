fx_version 'cerulean'
game "gta5"
lua54 'yes'

author 'SkeletonNetworks'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
    'client_open.lua',
}

files {
    'build/**',
}

escrow_ignore {
    'client_open.lua',
    'server.lua',
    'config.lua'
}

dependency '/assetpacks'