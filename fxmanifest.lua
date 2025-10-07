fx_version 'cerulean'
game 'gta5'
provide 'lib'
description 'CX Speed Cameras (Qbox)'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

lua54 'yes'

dependencies {
    'qbx_core',
    'ox_lib' 
}