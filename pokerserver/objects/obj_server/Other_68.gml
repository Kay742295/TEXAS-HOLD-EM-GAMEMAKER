
var type = async_load[? "type"];
switch (type) {
    case network_type_connect:
        var socket_id = async_load[? "socket"];
		
		var player_info = {
            "socket_id": socket_id,			
            "in_game": false,
			"chips": 1000,  // 初始筹码设置为1000,后续会更改为实时chips amount
			"current_bet": 0,
			"hasActedThisRound": false,
			"last_action": "",
			"hand": [],
        };
        ds_list_add(global.user_in_room_list, player_info);
		
        show_debug_message("New client connected: ID = " + string(socket_id));
		
		// 可以在这里初始化与客户端相关的更多数据
		
		check_start_game();
		//show_debug_message("check_start_game() function called.");
        
        break;

    case network_type_data:
	    var client_socket = async_load[? "id"];
	    var buffer_id = async_load[? "buffer"];
		var message = buffer_read(buffer_id, buffer_string);
		
		if (message == "Check Pressed") {
			show_debug_message("Check Pressed received");
			
		    for (var i = 0; i < ds_list_size(global.player_list); i++) {
		        var player = ds_list_find_value(global.player_list, i);
		        if (player.socket_id == client_socket) {
										
					global.isBetPlaced = buffer_read(buffer_id, buffer_bool);
					show_debug_message("isBetPlaced: " + string(global.isBetPlaced));
					var betAmount = buffer_read(buffer_id, buffer_f32);
					var currentBet = buffer_read(buffer_id, buffer_f32);
					var action_type = buffer_read(buffer_id, buffer_string);
					
					processPlayerAction(i, action_type, betAmount, currentBet);				
					break;
				}
			}
		}
		else if (message == "Call Pressed") {
			show_debug_message("Call Pressed received");
			
		    for (var i = 0; i < ds_list_size(global.player_list); i++) {
		        var player = ds_list_find_value(global.player_list, i);
		        if (player.socket_id == client_socket) {
										
					global.isBetPlaced = buffer_read(buffer_id, buffer_bool);
					show_debug_message("isBetPlaced: " + string(global.isBetPlaced));
					var betAmount = buffer_read(buffer_id, buffer_f32);
					var currentBet = buffer_read(buffer_id, buffer_f32);
					var action_type = buffer_read(buffer_id, buffer_string);
					
					processPlayerAction(i, action_type, betAmount, currentBet);			
					break;
				}
			}
		}
		else if (message == "Bet Pressed") {
			show_debug_message("Bet Pressed received");
			
		    for (var i = 0; i < ds_list_size(global.player_list); i++) {
		        var player = ds_list_find_value(global.player_list, i);
		        if (player.socket_id == client_socket) {
										
					global.isBetPlaced = buffer_read(buffer_id, buffer_bool);
					show_debug_message("isBetPlaced: " + string(global.isBetPlaced));
					var betAmount = buffer_read(buffer_id, buffer_f32);
					//...
					var currentBet = buffer_read(buffer_id, buffer_f32);
					var action_type = buffer_read(buffer_id, buffer_string);
					
					processPlayerAction(i, action_type, betAmount, currentBet);				
					break;
				}
			}
		}
		else if (message == "Raise Pressed") {
			show_debug_message("Raise Pressed received");
			
		    for (var i = 0; i < ds_list_size(global.player_list); i++) {
		        var player = ds_list_find_value(global.player_list, i);
		        if (player.socket_id == client_socket) {
										
					global.isBetPlaced = buffer_read(buffer_id, buffer_bool);
					show_debug_message("isBetPlaced: " + string(global.isBetPlaced));
					var betAmount = buffer_read(buffer_id, buffer_f32);
					var currentBet = buffer_read(buffer_id, buffer_f32);
					var action_type = buffer_read(buffer_id, buffer_string);
					
					processPlayerAction(i, action_type, betAmount, currentBet);					
					break;
				}
			}
		}		
		else if (message == "Fold Pressed") {
			show_debug_message("Fold Pressed received");
			for (var i = 0; i < ds_list_size(global.player_list); i++) {
	            var player = ds_list_find_value(global.player_list, i);
	            if (player.socket_id == client_socket) {
					global.isBetPlaced = buffer_read(buffer_id, buffer_bool);
					var betAmount = buffer_read(buffer_id, buffer_f32);
					var currentBet = buffer_read(buffer_id, buffer_f32);
					var action_type = buffer_read(buffer_id, buffer_string);	

					processPlayerAction(i, action_type, betAmount, currentBet);					
					show_debug_message("player_list size after fold:" + string(ds_list_size(global.player_list)));
					break;
				}
			}
		}
	    buffer_delete(buffer_id);
	    break;

    case network_type_disconnect:
        var client_socket = async_load[? "socket"];

        // 遍历global.player_list寻找并移除对应的客户端信息
        for (var i = 0; i < ds_list_size(global.user_in_room_list); i++) {
            var player = ds_list_find_value(global.user_in_room_list, i);
            if (player.socket_id == client_socket) {
                ds_list_delete(global.user_in_room_list, i);
                show_debug_message("Client removed from player list: ID = " + string(client_socket));
                break;
            }
        }
		break;
}
