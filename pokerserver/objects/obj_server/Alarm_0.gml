var player_list_size = ds_list_size(global.user_in_room_list);
if (player_list_size >= 2) { //至少几人开玩
    game_start();
} else {
}