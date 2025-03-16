function checkPressed(socket_id){
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
	buffer_write(buffer, buffer_string, "Check Pressed");
	
	var isBet = false; //决定了server中的isBetPlaced，只有check是false，其他操作都是true
	var betAmount = 0;
	buffer_write(buffer, buffer_bool, isBet);
	buffer_write(buffer, buffer_f32, betAmount);
	buffer_write(buffer, buffer_f32, global.currentBet);
	buffer_write(buffer, buffer_string, "check");
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("check button pressed");

	TurnEnd();
}
function callPressed(socket_id, betAmountBefore){
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
	buffer_write(buffer, buffer_string, "Call Pressed");
	
	var isBet = true; 
	var betAmount = betAmountBefore - global.currentBet;
	global.currentBet = betAmountBefore; 

	buffer_write(buffer, buffer_bool, isBet);
	buffer_write(buffer, buffer_f32, betAmount); //补进底池的数；server用这个处理bet
	buffer_write(buffer, buffer_f32, global.currentBet); //该轮一共投入底池的数；server用这个赋值global.highestBet等
	buffer_write(buffer, buffer_string, "call");
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("call button pressed");

	TurnEnd();
}

function betPressed(socket_id){
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
	buffer_write(buffer, buffer_string, "Bet Pressed");
	
	var isBet = true;
	
	var betAmount = -1;  // 设置为-1以启动循环
	// 使用循环来确保用户输入有效的投注金额
	while (betAmount < 0) {
	    betAmount = get_integer("Enter bet amount:", "");

	    // 检查输入是否有效
	    if (betAmount < 0) {
	        show_message("Wrong bet. Please enter a number that is over 0.");
	    }
	}
	global.currentBet = betAmount;
	buffer_write(buffer, buffer_bool, isBet);
	buffer_write(buffer, buffer_f32, betAmount);
	buffer_write(buffer, buffer_f32, global.currentBet);
	buffer_write(buffer, buffer_string, "bet");
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("bet button pressed");

	TurnEnd();
}

function raisePressed(socket_id, betAmountBefore){
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
	buffer_write(buffer, buffer_string, "Raise Pressed");
	
	var isBet = true;
	var raiseAmount = -1;  // 设置为-1以启动循环
	// 使用循环来确保用户输入有效的投注金额
	while (raiseAmount < 2*betAmountBefore) {
	    raiseAmount = get_integer("Enter bet amount:", "");

	    // 检查输入是否有效
	    if (raiseAmount < 2*betAmountBefore) {
	        show_message("Wrong bet. Please enter a number that is 2x over previous player's bet.");
	    }
	}
	var betAmount = raiseAmount - global.currentBet;
	global.currentBet = raiseAmount;
	buffer_write(buffer, buffer_bool, isBet);
	buffer_write(buffer, buffer_f32, betAmount);
	buffer_write(buffer, buffer_f32, global.currentBet);
	buffer_write(buffer, buffer_string, "raise");
	network_send_packet(socket_id, buffer, buffer_tell(buffer));  
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("raise button pressed");

	TurnEnd();
}
function foldPressed(socket_id, betAmountBefore){
	var buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);         // 定位到缓冲区起始位置
	buffer_write(buffer, buffer_string, "Fold Pressed");
	
	var isBet = true; //决定了server中的isBetPlaced，只有check是false，其他操作都是true
	var betAmount = 0;
	buffer_write(buffer, buffer_bool, isBet);
	buffer_write(buffer, buffer_f32, betAmount);
	buffer_write(buffer, buffer_f32, global.currentBet);
	buffer_write(buffer, buffer_string, "fold");
	network_send_packet(socket_id, buffer, buffer_tell(buffer)); 
	buffer_delete(buffer); // 清理缓冲区
	show_debug_message("fold button pressed");
	TurnEnd();
	//fold之后的效果，player_list移除，牌消失
    var darkenColor = make_color_rgb(150, 150, 150); // 创建一个较暗的颜色
    for (var i = 0; i < array_length_1d(global.playerHand); i++) {
        var card = global.playerHand[i];
        card.image_blend = darkenColor; // 应用暗色混合
        card.image_alpha = 0.5; // 可选：降低透明度使效果更明显
    }	
}