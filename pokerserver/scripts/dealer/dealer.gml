


// 庄家位置更新函数
function updateDealerPosition() {
    global.dealerIndex = (global.dealerIndex + 1) % ds_list_size(global.player_list);
	broadcastDealerNotification();
}
function broadcastDealerNotification(){
	var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Dealer Notification");
    buffer_write(buffer, buffer_u32, global.dealerIndex);
    for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
        var p = ds_list_find_value(global.user_in_room_list, i);
        network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
    }
    buffer_delete(buffer);
}
//轮次更新函数
function turnMove() {
	totalPlayers = ds_list_size(global.player_list); 
    // 更新当前玩家索引
    global.turnPlayerIndex = (global.turnPlayerIndex + 1) % totalPlayers;
    // 获取当前玩家
    var turnPlayer = ds_list_find_value(global.player_list, global.turnPlayerIndex);
    // 向当前玩家发送轮次开始的通知
    sendTurnNotification(turnPlayer.socket_id);
	turnPlayer.hasActedThisRound = true;
}

function sendTurnNotification(socket_id) {
    var buffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Turn Start");

	buffer_write(buffer, buffer_bool, global.isBetPlaced);
	buffer_write(buffer, buffer_f32, global.highestBet);
    network_send_packet(socket_id, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
	show_debug_message("turn notification sent to player");
	show_debug_message("betAmount: " + string(global.highestBet));
}
