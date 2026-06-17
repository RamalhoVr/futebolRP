fx_version 'cerulean'
game 'gta5'

shared_script 'shared/config.lua'

client_scripts {
    'client/cl_main.lua',
    'client/cl_input_controller.lua',
    'client/cl_movement_controller.lua',
    'client/cl_camera_controller.lua',
    'client/cl_hud.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_database.lua',
    'server/sv_ball_physics.lua',
    'server/sv_player_state.lua',
    'server/sv_match_manager.lua',
    'server/sv_referee.lua',
    'server/sv_career.lua'
}

ui_page 'html/hud.html'

files {
    'html/hud.html',
    'html/hud.css',
    'html/hud.js'
}

dependencies {
    'es_extended',
    'oxmysql'
}