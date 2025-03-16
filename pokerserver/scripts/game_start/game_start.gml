function check_start_game() {   
    var player_list_size = ds_list_size(global.user_in_room_list);
	
    if (player_list_size >= 2) { //至少几人开玩
		addPlayersToRoom();
        game_start();
    } else {
    }
}

//初始化牌组
function InitializeDeck() {
    global.deck = [];
    var suits = ["Hearts", "Diamonds", "Clubs", "Spades"];
    var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];

    for (var suit = 0; suit < array_length_1d(suits); suit++) {
        for (var rank = 0; rank < array_length_1d(ranks); rank++) {
            var card = suits[suit] + " " + ranks[rank];
            global.deck[array_length_1d(global.deck)] = card;
        }
    }
	show_debug_message("Deck initialized with " + string(array_length_1d(global.deck)) + " cards.");
	ShuffleDeck();
}

//洗牌函数
function ShuffleDeck() {
    for (var i = array_length_1d(global.deck) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = global.deck[i];
        global.deck[i] = global.deck[j];
        global.deck[j] = temp;
    }
}


//游戏开始时给玩家发两张手牌函数
function DealCards() {
    show_debug_message("Deck at start of DealCards: " + string(global.deck));
    show_debug_message("Deck size at start of DealCards: " + string(array_length_1d(global.deck)));

    var player_count = ds_list_size(global.player_list);
	show_debug_message("player_list size when dealcards:" + string(player_count));
    for (var i = 0; i < player_count; i++) {
        var current_player = ds_list_find_value(global.player_list, i);
        var target_client_socket = current_player.socket_id;
        current_player.hand = [];  // 清空手牌
        
        var buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(buffer, buffer_string, "Deal Cards");

        for (var j = 0; j < 2; j++) {  // 每个玩家发两张牌
            if (array_length_1d(global.deck) > 0) {
                var card = global.deck[0];
                current_player.hand[array_length_1d(current_player.hand)] = card;

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
        network_send_packet(target_client_socket, buffer, buffer_tell(buffer));
        buffer_delete(buffer); // 清理缓冲区
    }
    show_debug_message("DealCards succeeded");
}
//拉玩家入房间
function addPlayersToRoom(){
	broadcastUserInRoomList();
	for (var j = 0; j < ds_list_size(global.user_in_room_list); j++) {
	    var current_player = ds_list_find_value(global.user_in_room_list, j);
                        
	    if (!current_player.in_game) {               
	        current_player.in_game = true;
	        var target_client_socket = current_player.socket_id;                               
	        var buffer = buffer_create(256, buffer_fixed, 1);
	        buffer_write(buffer, buffer_string, "Game Start");
                               
			// 假设每个玩家的位置已经预先确定
			var positions = [{ x: 317, y: 156 }, { x: 1276, y: 156 }]; //needs to update positions
			for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
				var player_data = ds_list_find_value(global.user_in_room_list, i);
				buffer_write(buffer, buffer_u32, positions[i].x);
				buffer_write(buffer, buffer_u32, positions[i].y);
			}				
	        var send_length = buffer_tell(buffer);                
	        network_send_packet(target_client_socket, buffer, send_length);                
	        buffer_delete(buffer); 
			sendUserIndex(target_client_socket);
			sendPotUpdate(target_client_socket, global.pot);
			sendChipsUpdate(target_client_socket, current_player.chips);			
	    }
	}
}

function game_start(){ //如果有新玩家中途加入不调用此函数，只调用“拉玩家入局”部分代码就可;每局游戏开始前调用此函数
	global.publicCard = [];
	global.isPreflop = true;
	global.player_list = global.user_in_room_list; //每局开始前都更新player_list
	global.isBetPlaced = true;
	global.pot = 0;  //初始化底池金额
	for (var i = 0; i < ds_list_size(global.player_list); i++) {
	    var player = ds_list_find_value(global.player_list, i);
		player.hasActedThisRound = false;
		sendPotUpdate(player.socket_id, global.pot);
	}

	randomize();
	InitializeDeck();
	DealCards();
	updateDealerPosition();
	blindsSetting_12();
	//initialize玩家轮次管理
	global.turnPlayerIndex = (global.dealerIndex + 3) % (ds_list_size(global.player_list));
    // 下注逻辑
	show_debug_message("player_list size when turn player index:" + string(ds_list_size(global.player_list)));
	// 向当前玩家发送轮次开始的通知
	var turnPlayer = ds_list_find_value(global.player_list, global.turnPlayerIndex);  
    sendTurnNotification(turnPlayer.socket_id);
	turnPlayer.hasActedThisRound = true;
}

function broadcastUserInRoomList(){
	var buffer = buffer_create(1024, buffer_grow, 1); // 创建一个足够大的缓冲区
	buffer_write(buffer, buffer_string, "Player List"); 
	buffer_write(buffer, buffer_u32, ds_list_size(global.user_in_room_list)); // 首先写入玩家数量
	show_debug_message("player_list_size:" + string(ds_list_size(global.user_in_room_list)));
	
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
		var player = ds_list_find_value(global.user_in_room_list, i);
        buffer_write(buffer, buffer_u32, player.socket_id); // 写入socket_id
    }
	
	for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
        var player = ds_list_find_value(global.user_in_room_list, i);
        network_send_packet(player.socket_id, buffer, buffer_tell(buffer));
    }
	buffer_delete(buffer);
}
function gameEnd(){
	//1.计算赢家
    var winners = [];
    var highest_strength = -1;
	if(ds_list_size(global.player_list) <= 1){
		var player = ds_list_find_value(global.player_list, 0);
		//winners = player.socket_id
		array_push(winners, player.socket_id);
	}else{
		for (var i = 0; i < ds_list_size(global.player_list); i++) {   
		    var player = ds_list_find_value(global.player_list, i);
		    var strength = evaluate_hand(player.hand, global.publicCard);			
			show_debug_message("player" + string(player.socket_id) + "strength" + string(strength));
		    if (strength > highest_strength) {
		        highest_strength = strength;
		        winners = [player.socket_id]; // 重新初始化 winners 数组
		    } else if (strength == highest_strength) {
		        array_push(winners, player.socket_id); // 使用 array_push 将 i 添加到 winners 数组中
		    }
		}
	}
	show_debug_message("winner is : player" + string(winners[0]) + " pot :" + string(global.pot));//改为通知user_in_room_list
	//2.通知user_in_room_list，player1 win pot：50
	broadcastWinNotification(winners);
	//3.更新玩家chips状态
	distributePot(winners);
	//4.game_start()
	inst_6FC3F374.alarm[0] = 120; 
}

function distributePot(winners) {
    if (array_length(winners) == 0) {
        show_debug_message("没有赢家，不进行分发");
        return;
    }
    var chipsPerWinner = global.pot / array_length(winners);
    for (var i = 0; i < array_length(winners); i++) {
        var winnerSocketId = winners[i];
		for (var i = 0; i < ds_list_size(global.player_list); i++) {   
		    var player = ds_list_find_value(global.player_list, i);
			if (player.socket_id == winnerSocketId){
				player.chips += chipsPerWinner;
				sendChipsUpdate(player.socket_id, player.chips);
			}else{
				show_debug_message("falied to find winner");
			}
		}
	}
}