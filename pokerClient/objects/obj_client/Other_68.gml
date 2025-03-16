
global.server_socket_id = async_load[? "id"];
var type = async_load[? "type"];

switch (type) {
    case network_type_data:
        var buffer_id = async_load[? "buffer"];
        var message = buffer_read(buffer_id, buffer_string);		

        if (message == "Game Start") {
            show_debug_message("Game is starting...");
			InitCardMappings();
			var player_count = ds_list_size(global.user_in_room_list);
			show_debug_message("player_count = " + string(player_count));
			for (var i = 0; i < player_count; i++) {
				var player = ds_list_find_value(global.user_in_room_list, i);
				player.position.x = buffer_read(buffer_id, buffer_u32);
				player.position.y = buffer_read(buffer_id, buffer_u32);
				var position = {
			        x: player.position.x,
			        y: player.position.y
			    };
			    array_push(global.playerPositions, position);
				
			}
			if (player_count == 2){
				var player1 =  ds_list_find_value(global.user_in_room_list, 0);
				var player2 =  ds_list_find_value(global.user_in_room_list, 1);
				instance_create_layer(player1.position.x, player1.position.y, "Instances", obj_player1);
				instance_create_layer(player2.position.x, player2.position.y, "Instances", obj_player2);
				show_debug_message("Players created at position");
			}
            global.player_list = global.user_in_room_list;
        }
		else if (message == "Dealer Notification") {
			var dealerIndex = buffer_read(buffer_id, buffer_u32);
			var dealerPosition = global.playerPositions[dealerIndex];
			var dealer_obj = instance_create_layer(dealerPosition.x, dealerPosition.y + 100, "Instances", obj_dealer);
			array_push(global.dealer, dealer_obj);	
		}
		else if (message == "Deal Cards") {
            show_debug_message("Deal Cards received");
			var cards = [];
			// 读取每张卡
		    for (var i = 0; i < 2; i++) {
		        var card = buffer_read(buffer_id, buffer_string);
		        cards[i] = card;
		        show_debug_message("Received card: " + card);
		    }
			DealCardsReceive(cards);
        }
		else if (message == "Chip Update"){
			show_debug_message("Chip Update received");
			var chip = buffer_read(buffer_id, buffer_f32);
			with (inst_553C1D1A) {
		        chips_amount = chip;
		    }			
		}
		else if (message == "Pot Update"){
			show_debug_message("Pot Update received");
			var pot = buffer_read(buffer_id, buffer_f32);
			with (inst_2747CDC6) {
		        pot_amount = pot;
		    }			
		}
		else if (message == "Turn Start"){
			show_debug_message("Turn Start received");
			var isBetPlaced = buffer_read(buffer_id, buffer_bool);
			var betAmount = buffer_read(buffer_id, buffer_f32);
			TurnStart(isBetPlaced, betAmount);
		}
		else if (message == "Update Action"){
			show_debug_message("Update Action received");
			var client_socket = buffer_read(buffer_id, buffer_u32);
		    var action = buffer_read(buffer_id, buffer_string);
		    var amount = buffer_read(buffer_id, buffer_f32);
	        for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
	            var player = ds_list_find_value(global.user_in_room_list, i);
	            if (player.socket_id == client_socket) {
					updateAction(action, player, amount);
				}
			}			
		}
		else if (message == "Player List"){
			show_debug_message("Player List received");
			var player_count = buffer_read(buffer_id, buffer_u32); // 读取玩家数量
		    for (var i = 0; i < player_count; i++) {
		        var socket_id = buffer_read(buffer_id, buffer_u32); // 读取每个玩家的socket_id
		        var player_info = { 
					"socket_id": socket_id,
					"position": { "x": x, "y": y }, 
				};
		        ds_list_add(global.user_in_room_list, player_info); // 将玩家信息添加到本地列表
		    }			
		}
		else if (message == "Blind Amount"){
			global.currentBet = buffer_read(buffer_id, buffer_u32);
			show_debug_message("totalAmount:" + string(global.currentBet));
		}
		else if (message == "Flop Cards"){
			show_debug_message("Flop Cards received");
			global.currentBet = 0;
			var cards = [];		
			// 读取每张卡
		    for (var i = 0; i < 3; i++) {
		        var card = buffer_read(buffer_id, buffer_string);
		        cards[i] = card;
		        show_debug_message("Received card: " + card);
		    }
			FlopCardsReceive(cards);
		}
		else if (message == "Turn Cards"){
			show_debug_message("Turn Cards received");
			global.currentBet = 0;
			var cards = [];		
			// 读取每张卡
		    for (var i = 0; i < 1; i++) {
		        var card = buffer_read(buffer_id, buffer_string);
		        cards[i] = card;
		        show_debug_message("Received card: " + card);
		    }
			TurnCardsReceive(cards);
		}
		else if (message == "River Cards"){
			show_debug_message("River Cards received");
			global.currentBet = 0;
			var cards = [];		
			// 读取每张卡
		    for (var i = 0; i < 1; i++) {
		        var card = buffer_read(buffer_id, buffer_string);
		        cards[i] = card;
		        show_debug_message("Received card: " + card);
		    }
			RiverCardsReceive(cards);
		}
		else if (message == "User Index"){
			var index = buffer_read(buffer_id, buffer_u32);	
			with (inst_5D19174) {
		        user_index = index;
		    }				
		}
		else if (message == "Win Notification"){
			var text = buffer_read(buffer_id, buffer_string);
			var ins = instance_create_layer(800, 35, "Instances", text_winNotification);
			ins.text = text;
			ins.alarm[0] = 120;
			//删除所有桌上的牌
			alarm[0] = 120;
		}
        buffer_delete(buffer_id);
        break;
}
