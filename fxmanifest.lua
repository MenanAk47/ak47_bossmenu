fx_version 'cerulean'
game 'gta5'
description 'Ak47 Boss Menu'
version '1.0.0'
author 'MenanAk47'
lua54 'yes'

--ui_page 'web/index.html'
ui_page 'http://localhost:5173'

files {
    'web/**/*',
}

shared_scripts {
    '@ak47_lib/init.lua',
    'config.lua',
    'locales/locale.lua',
    'locales/en.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'webhooks.lua',
    'api/server/*.lua',
    'modules/**/server/*.lua',
    'compat/server/*.lua',
    'custom/server/*.lua',
}

client_scripts {
    'api/client/*.lua',
    'modules/**/client/*.lua',
    'compat/client/*.lua',
    'custom/client/*.lua',
}

dependencies {
    'ak47_lib',
}

provides {
    'esx_society',
    'qb-management',
    'qbx_management',
    'qb-bossmenu',
}
