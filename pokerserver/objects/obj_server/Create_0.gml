socket = -1;
port = 50000;
max_attempts = 100;  // 尝试次数限制
attempts = 0;

global.user_in_room_list = ds_list_create(); //房间中的所有玩家
global.player_list = ds_list_create(); //没弃牌还在玩的玩家
// 初始化游戏时随机设置庄家位置
//global.dealerIndex = irandom(array_length_1d(global.player_list) - 1);
global.dealerIndex = 0;

global.isBetPlaced = true; //初始化是否之前有人下注，在轮次结束后更新为false,游戏开始后更新为true
global.highestBet = 0;
global.pot = 0;

global.isPreflop = false;
global.isFlop = false;
global.isTurn = false;
global.isRiver = false;