function DealCardsReceive(cards){
	//show player1's hand
	var positions = [ {x: 831, y: 960},{x: 901, y: 960} ]; // player1手牌的位置(will be deleted)
	global.playerHand = [];
	for (var j = 0; j < array_length_1d(cards); j++) {
		var card_obj = instance_create_layer(positions[j].x, positions[j].y, "Instances", obj_card);
		var img_index = ds_map_find_value(global.cardIndexMap, cards[j]);
		card_obj.image_index = img_index; 
		array_push(global.playerHand, card_obj);
	}
}

function FlopCardsReceive(cards){
	var positions = [ {x: 576, y: 450},{x: 656, y: 450},{x : 736, y: 450}]; //3张翻牌的位置
	for (var j = 0; j < array_length_1d(cards); j++) {
		var card_obj = instance_create_layer(positions[j].x, positions[j].y, "Instances", obj_card);
		var img_index = ds_map_find_value(global.cardIndexMap, cards[j]);
		card_obj.image_index = img_index; 
		array_push(global.publicHand, card_obj);
	}	
}
function TurnCardsReceive(cards){
	var positions = [ {x: 816, y: 450}]; 
	for (var j = 0; j < array_length_1d(cards); j++) {
		var card_obj = instance_create_layer(positions[j].x, positions[j].y, "Instances", obj_card);
		var img_index = ds_map_find_value(global.cardIndexMap, cards[j]);
		card_obj.image_index = img_index; 
		array_push(global.publicHand, card_obj);
	}	
}
function RiverCardsReceive(cards){
	var positions = [ {x: 896, y: 450}]; 
	for (var j = 0; j < array_length_1d(cards); j++) {
		var card_obj = instance_create_layer(positions[j].x, positions[j].y, "Instances", obj_card);
		var img_index = ds_map_find_value(global.cardIndexMap, cards[j]);
		card_obj.image_index = img_index; 
		array_push(global.publicHand, card_obj);
	}	
}
// 卡牌image和卡牌索引的对应关系
function InitCardMappings() {
    global.cardIndexMap = ds_map_create();

    var suits = ["Spades", "Hearts", "Clubs", "Diamonds"];
    var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];
    var index = 0;

    for (var i = 0; i < array_length_1d(suits); i++) {
        for (var j = 0; j < array_length_1d(ranks); j++) {
            var key = suits[i] + " " + ranks[j]; // Creates a key like "Spades A"
            ds_map_add(global.cardIndexMap, key, index);
            index++;
        }
    }
}

function TurnStart(isBetPlaced, betAmount){
	global.isMyTurn = true;
	if (!isBetPlaced){
		with (inst_B9D8168) {
			visible = true;
			enabled = true;
		}
		with (inst_3FBD08B8) {
			visible = true;
			enabled = true;
		}
	}else{
		with (inst_25288B7B) {
			betAmountBefore = betAmount;
			visible = true;
			enabled = true;
			if (betAmountBefore == global.currentBet){
				sprite_index = spr_check; 
				show_debug_message("sprite turned to check")
			} else{show_debug_message("sprite not turned to check")}
		}
		with (inst_E9FDC33) {
			visible = true;
			enabled = true;
			betAmountBefore = betAmount;
		}
		with (inst_6805F40E) {
			betAmountBefore = betAmount;
			if (betAmountBefore != global.currentBet){
				visible = true;
				enabled = true;	
			}
		}	
	}
}
function TurnEnd(){
	global.isMyTurn = false;
	with (inst_B9D8168) {
			visible = false;
			enabled = false;
		}
	with (inst_3FBD08B8) {
			visible = false;
			enabled = false;
		}
	with (inst_25288B7B) {
			visible = false;
			enabled = false;
			betAmountBefore = 0;
			sprite_index = spr_call;
		}
	with (inst_E9FDC33) {
			visible = false;
			enabled = false;
			betAmountBefore = 0;
		}
	with (inst_6805F40E) {
			visible = false;
			enabled = false;
			betAmountBefore = 0;
		}
}

function updateAction(action, player, betAmount){
    var positionX = player.position.x;
    var positionY = player.position.y - 30;      
    var inst = instance_position(positionX, positionY, text_playerAction);
    if (inst != noone) {  // 如果找到了实例，则摧毁它
        instance_destroy(inst);		
    }else{		
	}
    
    var actionText = ""; // 用于存储根据行动确定的文本
    switch (action) {
        case "call":
            actionText = "Call";
            break;
        case "check":
            actionText = "Check";
            break;
        case "bet":
            actionText = "Bet: " + string(betAmount);
            break;
        case "raise":
            actionText = "Raise to: " + string(betAmount);
            break;
        case "fold":
            actionText = "Fold";
            break;
    }
    var obj_text = instance_create_layer(positionX, positionY, "Instances", text_playerAction);
    obj_text.text = actionText;
}
