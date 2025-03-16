for (var i =0; i < array_length(global.playerHand); i++){
	instance_destroy(global.playerHand[i]);
}
for (var j =0; j < array_length(global.publicHand); j++){
	instance_destroy(global.publicHand[j]);
}
for (var k =0; k < array_length(global.dealer); k++){
	instance_destroy(global.dealer[k]);
}
global.playerHand = [];
global.publicHand = [];
global.currentBet = 0;
global.dealer = [];