global.client_socket = network_create_socket(network_socket_tcp);
global.server_ip = "127.0.0.1"; // 服务器IP地址
global.server_port = get_integer("type in server's port", 50000);

global.isMyTurn = false; //貌似没用，可删
// 尝试连接到服务器
var connection = network_connect(global.client_socket, global.server_ip, global.server_port);
if (connection < 0) {
    show_debug_message("Failed to connect to server.");
} else {
    show_debug_message("Connected to server11.");
}

global.player_list = ds_list_create(); //貌似没用
global.user_in_room_list = ds_list_create();
global.currentBet = 0;//在新的轮次开始时将其设置为0
global.publicHand = [];
global.playerPositions = [];
global.dealer = [];