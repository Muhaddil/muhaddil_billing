fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'FiveM script that allows players to send and manage invoices within the game'
version 'v1.0.3'

client_script 'client.lua'
ui_page 'html/ui.html'

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
    '@ox_lib/init.lua'
}

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
