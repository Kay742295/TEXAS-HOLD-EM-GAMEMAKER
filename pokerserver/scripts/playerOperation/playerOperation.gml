function blindsSetting_12() { //盲注大小为1，2的盲注设置函数
    var smallBlindAmount = 1;  // 设置小盲注金额
    var bigBlindAmount = 2;   // 设置大盲注金额
	
	var numPlayers = ds_list_size(global.player_list);
    var smallBlindIndex = (global.dealerIndex + 1) % numPlayers;
    var bigBlindIndex = (global.dealerIndex + 2) % numPlayers;

	var smallBlindPlayer = ds_list_find_value(global.player_list, smallBlindIndex);
	var bigBlindPlayer = ds_list_find_value(global.player_list, bigBlindIndex);
    // 下注逻辑
	smallBlindPlayer.last_action = "bet";
	smallBlindPlayer.current_bet = smallBlindAmount;
	bigBlindPlayer.last_action = "bet";
	bigBlindPlayer.current_bet = bigBlindAmount;
	global.highestBet = bigBlindAmount;
	bet(smallBlindPlayer, smallBlindAmount, smallBlindPlayer.socket_id);
	bet(bigBlindPlayer, bigBlindAmount, bigBlindPlayer.socket_id);
	broadcastPlayerAction(smallBlindPlayer.socket_id, "bet", smallBlindAmount);
	broadcastPlayerAction(bigBlindPlayer.socket_id, "bet", bigBlindAmount);
	
	sendBlindAmount(smallBlindPlayer, bigBlindPlayer, smallBlindAmount, bigBlindAmount);
}

function bet(player, amount, socket_id) {
	//player类型：var player = ds_list_find_value(global.player_list, i);
    if (player.chips >= amount) {
        player.chips -= amount;  // 从玩家筹码中扣除下注金额
        global.pot += amount;    // 将下注金额加到底池
		sendChipsUpdate(socket_id, player.chips); //bet之后自动向client发送buffer        
    } else {
        // 玩家筹码不足，处理筹码不足的情况
        show_debug_message("Player does not have enough chips to bet " + string(amount));        
    }
}

function sendChipsUpdate(socket_id, chips) {
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
    buffer_write(buffer, buffer_string, "Chip Update");
	
	buffer_write(buffer, buffer_f32, chips);
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("client ID = " + string(socket_id) + ", chips amount: " + string_format(chips, 0, 0));

}
function sendPotUpdate(socket_id, currentPot) {
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
    buffer_write(buffer, buffer_string, "Pot Update");
	
	buffer_write(buffer, buffer_f32, currentPot);
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("pot amount: " + string_format(currentPot, 0, 0));

}
function sendUserIndex(socket_id){
	var buffer = buffer_create(256, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0); 
	buffer_write(buffer, buffer_string, "User Index");
	buffer_write(buffer, buffer_u32, socket_id);
	network_send_packet(socket_id, buffer, buffer_tell(buffer)); 
	buffer_delete(buffer); // 清理缓冲区
}
function processPlayerAction(current_player_id, action_type, betAmount, currentBet) {
    var current_player = ds_list_find_value(global.player_list, current_player_id); //player_id is an index
    current_player.last_action = action_type;
	current_player.current_bet = currentBet;
	current_player.hasActedThisRound = true;
	if (currentBet > global.highestBet){
		global.highestBet = currentBet;
	}
	bet(current_player, betAmount, current_player.socket_id);
	if (action_type == "fold"){
		ds_list_delete(global.player_list, current_player_id);
	}				
	if (endRound()) {
		show_debug_message("this round ended");
		for (var j = 0; j < ds_list_size(global.user_in_room_list); j++) {
			var player = ds_list_find_value(global.user_in_room_list, j);
			sendPotUpdate(player.socket_id, global.pot);
		}
		if(global.isPreflop == true){
			startFlop();
		}else if(global.isFlop == true){
			startTurn();
		}else if(global.isTurn == true){
			startRiver();
		}else if(global.isRiver == true){
			gameEnd();	
		}
	}else if(ds_list_size(global.player_list) <= 1){
		for (var j = 0; j < ds_list_size(global.user_in_room_list); j++) {
			var player = ds_list_find_value(global.user_in_room_list, j);
			sendPotUpdate(player.socket_id, global.pot);
		}
		gameEnd();
	}else{	
		turnMove();
	}
    // 发送更新给所有客户端
    broadcastPlayerAction(current_player.socket_id, action_type, currentBet);
}

function broadcastPlayerAction(socket_id, action_type, betAmount) {
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Update Action");
    buffer_write(buffer, buffer_u32, socket_id);
    buffer_write(buffer, buffer_string, action_type);
    buffer_write(buffer, buffer_f32, betAmount);

    for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
        var p = ds_list_find_value(global.user_in_room_list, i);
        network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
    }
    buffer_delete(buffer);
}
function broadcastWinNotification(array){
	var text = "winner is: ";
	for (var i = 0; i < array_length_1d(array); i++) {
	    text += "player" + string(array[i]);
	    if (i < array_length_1d(array) - 1) {
	        text += ", ";  // 在每个赢家之间添加逗号
	    }
	}
	text += " pot: " + string(global.pot);
	var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Win Notification");
	buffer_write(buffer, buffer_string, text);
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
        var p = ds_list_find_value(global.user_in_room_list, i);
        network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
    }
    buffer_delete(buffer);	
}
function sendBlindAmount(smallBlindPlayer, bigBlindPlayer, smallBlindAmount, bigBlindAmount){
	var buffer_s = buffer_create(256, buffer_grow, 1);
	buffer_write(buffer_s, buffer_string, "Blind Amount");
	buffer_write(buffer_s, buffer_u32, smallBlindAmount);
	network_send_packet(smallBlindPlayer.socket_id, buffer_s, buffer_tell(buffer_s));
	buffer_delete(buffer_s);
	
	var buffer_b = buffer_create(256, buffer_grow, 1);
	buffer_write(buffer_b, buffer_string, "Blind Amount");
	buffer_write(buffer_b, buffer_u32, bigBlindAmount);
	network_send_packet(bigBlindPlayer.socket_id, buffer_b, buffer_tell(buffer_b));
	buffer_delete(buffer_b);	
}