function endRound() {
    var allPlayersActed = true;
    var allBetsEqual = true;

    // 是否全部玩家都被轮到
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        if (player.in_game) {
            if (!player.hasActedThisRound) {
                allPlayersActed = false;
                break;
            }
            if (player.current_bet != global.highestBet) {
                allBetsEqual = false;
            }
        }
    }

    // 检查是否只剩下一名玩家未弃牌
	var activePlayerCount = ds_list_size(global.player_list);

    // 如果所有玩家都已响应且赌注平衡，且至少有两名玩家在游戏中，则结束 Preflop
    if (allPlayersActed && allBetsEqual && activePlayerCount > 1) {
        return true; // 结束 Preflop
    } else {
        return false; // 继续 Preflop
    }
}

function startFlop(){
	global.isPreflop = false;
	global.isFlop = true;
	
	global.isBetPlaced = false;
	global.highestBet = 0;
	global.turnPlayerIndex = (global.dealerIndex + 1) % ds_list_size(global.player_list);
	for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
		player.current_bet = 0;
		player.hasActedThisRound = false;
	}	
	//发三张翻牌
	FlopCards();
	var turnPlayer = ds_list_find_value(global.player_list, global.turnPlayerIndex);  
    sendTurnNotification(turnPlayer.socket_id);
	turnPlayer.hasActedThisRound = true;
}

function FlopCards() {
    show_debug_message("Deck at start of FlopCards: " + string(global.deck));
    show_debug_message("Deck size at start of FlopCards: " + string(array_length_1d(global.deck)));
   
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Flop Cards");
    for (var j = 0; j < 3; j++) {  // 发3张牌
        if (array_length_1d(global.deck) > 0) {
            var card = global.deck[0];
			global.publicCard[array_length_1d(global.publicCard)] = card;
            // 调试信息
            show_debug_message("Before deletion: " + string(global.deck));
            // 手动删除第一张牌
			for (var k = 0; k < array_length_1d(global.deck) - 1; k++) {
			    global.deck[k] = global.deck[k + 1]; // 将后续元素前移
			}
			array_resize(global.deck, array_length_1d(global.deck) - 1); // 调整数组大小
				
            show_debug_message("After deletion: " + string(global.deck));
			show_debug_message("Deck size after deletion: " + string(array_length_1d(global.deck)));
            buffer_write(buffer, buffer_string, card);
        } else {
            show_message("Run out of all the cards");
            buffer_delete(buffer);
            return;
        }
    }
    //发送给所有玩家
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
	    var p = ds_list_find_value(global.user_in_room_list, i);
	    network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
	}		
    buffer_delete(buffer); // 清理缓冲区
    show_debug_message("FlopCards succeeded");
}
function startTurn(){
	global.isFlop = false;
	global.isTurn = true;
	
	global.isBetPlaced = false;
	global.highestBet = 0;
	global.turnPlayerIndex = (global.dealerIndex + 1) % ds_list_size(global.player_list);
	for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
		player.current_bet = 0;
		player.hasActedThisRound = false;
	}	
	//发1张转牌
	TurnCards();
	var turnPlayer = ds_list_find_value(global.player_list, global.turnPlayerIndex);  
    sendTurnNotification(turnPlayer.socket_id);
	turnPlayer.hasActedThisRound = true;
}
function TurnCards() {
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "Turn Cards");
    for (var j = 0; j < 1; j++) {  // 发1张牌
        if (array_length_1d(global.deck) > 0) {
            var card = global.deck[0];
			global.publicCard[array_length_1d(global.publicCard)] = card;
            // 调试信息
            show_debug_message("Before deletion: " + string(global.deck));
            // 手动删除第一张牌
			for (var k = 0; k < array_length_1d(global.deck) - 1; k++) {
			    global.deck[k] = global.deck[k + 1]; // 将后续元素前移
			}
			array_resize(global.deck, array_length_1d(global.deck) - 1); // 调整数组大小
				
            show_debug_message("After deletion: " + string(global.deck));
			show_debug_message("Deck size after deletion: " + string(array_length_1d(global.deck)));
            buffer_write(buffer, buffer_string, card);
        } else {
            show_message("Run out of all the cards");
            buffer_delete(buffer);
            return;
        }
    }
    //发送给所有玩家
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
	    var p = ds_list_find_value(global.user_in_room_list, i);
	    network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
	}		
    buffer_delete(buffer); // 清理缓冲区
    show_debug_message("TurnCards succeeded");
}
function startRiver(){
	global.isTurn = false;
	global.isRiver = true;
	
	global.isBetPlaced = false;
	global.highestBet = 0;
	global.turnPlayerIndex = (global.dealerIndex + 1) % ds_list_size(global.player_list);
	for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
		player.current_bet = 0;
		player.hasActedThisRound = false;
	}	
	//发1张转牌
	RiverCards();
	var turnPlayer = ds_list_find_value(global.player_list, global.turnPlayerIndex);  
    sendTurnNotification(turnPlayer.socket_id);
	turnPlayer.hasActedThisRound = true;
}
function RiverCards() {
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(buffer, buffer_string, "River Cards");
    for (var j = 0; j < 1; j++) {  // 发1张牌
        if (array_length_1d(global.deck) > 0) {
            var card = global.deck[0];
			global.publicCard[array_length_1d(global.publicCard)] = card;
            // 调试信息
            show_debug_message("Before deletion: " + string(global.deck));
            // 手动删除第一张牌
			for (var k = 0; k < array_length_1d(global.deck) - 1; k++) {
			    global.deck[k] = global.deck[k + 1]; // 将后续元素前移
			}
			array_resize(global.deck, array_length_1d(global.deck) - 1); // 调整数组大小
				
            show_debug_message("After deletion: " + string(global.deck));
			show_debug_message("Deck size after deletion: " + string(array_length_1d(global.deck)));
            buffer_write(buffer, buffer_string, card);
        } else {
            show_message("Run out of all the cards");
            buffer_delete(buffer);
            return;
        }
    }
    //发送给所有玩家
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
	    var p = ds_list_find_value(global.user_in_room_list, i);
	    network_send_packet(p.socket_id, buffer, buffer_tell(buffer));
	}		
    buffer_delete(buffer); // 清理缓冲区
    show_debug_message("RiverCards succeeded");
}