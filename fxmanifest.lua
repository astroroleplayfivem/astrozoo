fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'astro-zoo'
author 'Opie Winters'
description 'Astro Zoo - immersive animal viewing zoo with ticketed entry, multi-framework, multi-inventory, and multi-target support.'
version '2.1.0'

ui_page 'html/index.html'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'README.md',
    'sql/astro_zoo.sql',
    'peds.meta',
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

data_file 'PED_METADATA_FILE' 'peds.meta'
