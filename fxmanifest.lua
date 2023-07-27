fx_version 'cerulean'
game 'gta5'

description 'Cool Radio for ESX, Coverted By Benzo & Mycroft'
version '3.0'
lua54 'yes'

shared_scripts  {'@es_extended/imports.lua',     '@ox_lib/init.lua', 'config.lua'}

server_script 'server.lua'

client_scripts {'client.lua'}

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/radio.png'}

