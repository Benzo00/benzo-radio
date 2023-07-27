fx_version 'cerulean'
game 'gta5'

description 'Cool Radio, Edited by Benzo & Mycroft'
version '3.0'
lua54 'yes'

shared_scripts  { '@ox_lib/init.lua', 'config.lua'}

server_script 'server.lua'

client_scripts {'client.lua'}

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/radio.png'}

