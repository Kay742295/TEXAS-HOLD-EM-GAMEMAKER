function evaluate_hand(player_hand, public_cards){
	var point = 0;
	var cardArray = array_concat(player_hand, public_cards);
	show_debug_message("cardArray " + string(cardArray));
	
	var suitArray = array_create(array_length(cardArray)); // 存储花色部分
	var original_valueArray = array_create(array_length(cardArray)); 
	for (var i = 0; i < array_length(cardArray); i++) {
	    var parts = string_split(cardArray[i], " "); // 按空格分割
	    suitArray[i] = parts[0]; // 提取花色部分	
	    original_valueArray[i] = parts[1]; // 提取数值部分
	}

	//valueArray数组值替换
	for (var i = 0; i < array_length(original_valueArray); i++) {
	    switch (original_valueArray[i]) {
	        case "2": original_valueArray[i] = 2; break;
	        case "3": original_valueArray[i] = 3; break;
	        case "4": original_valueArray[i] = 4; break;
	        case "5": original_valueArray[i] = 5; break;
	        case "6": original_valueArray[i] = 6; break;
	        case "7": original_valueArray[i] = 7; break;
	        case "8": original_valueArray[i] = 8; break;
	        case "9": original_valueArray[i] = 9; break;
	        case "10": original_valueArray[i] = 10; break;
	        case "J": original_valueArray[i] = 11; break;
	        case "Q": original_valueArray[i] = 12; break;
	        case "K": original_valueArray[i] = 13; break;
	        case "A": original_valueArray[i] = 14; break;
	        default: original_valueArray[i] = 0; break;
	    }
	}
	
	//valueArray数组降序
	var valueArray = array_create(array_length(original_valueArray));
	array_copy(valueArray, 0, original_valueArray, 0, array_length(original_valueArray));
	array_sort(valueArray, false);
	
	
	var triplets = findTriplets(valueArray); //是降序
	var pairs = findPairs(valueArray); //是降序
	var maxStraight = findMaxStraight(findStraight(valueArray));
	var maxFourOfAKind = findFourOfAKind(valueArray);
	
	
	//判定牌型：
	if (isSameSuit(suitArray)){
		if (array_length(maxStraight) != 0){
			var flush =  findFlush(suitArray, original_valueArray);
			var straightFlush = findMaxStraight(findStraight(flush));
			if (straightFlush[0] == 14 && straightFlush[1] == 5){
				var kicker = straightFlush[1];
			}else{
				var kicker = straightFlush[0];
			}
			point = 90000000000 + kicker;			
			show_debug_message("牌型最终为同花顺");
		}else{
			var flush = findFlush(suitArray, original_valueArray);
			var kicker1 = flush[0];
			var kicker2 = flush[1]; 
			var kicker3 = flush[2];
			var kicker4 = flush[3];
			var kicker5 = flush[4];
			point = 60000000000 + 100000000*kicker1 + 1000000*kicker2 + 10000*kicker3 + 100*kicker4 + kicker5;			
			show_debug_message("flush:" + string(flush));
			show_debug_message("牌型最终为同花");
		}
	}else{
		if (array_length(maxFourOfAKind) != 0){
			var mainPart = maxFourOfAKind[0];
			var kicker = maxFourOfAKind[4];			
			point = 80000000000 + 100*mainPart + kicker;
			show_debug_message("牌型最终为四条");
		}else if (array_length(triplets) > 1){
			var mainPart = triplets[0];
			var kicker = triplets[1];
			point = 70000000000 + 100*mainPart + kicker;
			show_debug_message("牌型最终为葫芦");
		}else if (array_length(triplets) == 1 && array_length(pairs) >= 1){
			var mainPart = triplets[0];
			var kicker = pairs[0];
			point = 70000000000 + 100*mainPart + kicker;
			show_debug_message("牌型最终为葫芦");
		}else if(array_length(maxStraight) != 0){
			if (maxStraight[0] == 14 && maxStraight[1] == 5){
				var kicker = maxStraight[1];
			}else{
				var kicker = maxStraight[0];
			}
			point = 50000000000 + kicker;
			show_debug_message("牌型最终为顺子");
		}else if(array_length(triplets) == 1 && array_length(pairs) == 0){
			var threeOfAKind = findThreeOfAKind(valueArray, triplets);
			var mainPart = threeOfAKind[0];
			var kicker1 = threeOfAKind[3];
			var kicker2 = threeOfAKind[4];
			point = 40000000000 + 10000*mainPart + 100*kicker1 + kicker2;
			show_debug_message("3 of a kind:" + string(threeOfAKind));
			show_debug_message("牌型最终为三条");
		}else if(array_length(pairs) > 1){
			var twoPairs = findTwoPairs(valueArray, pairs);
			var mainPart1 = twoPairs[0];
			var mainPart2 = twoPairs[2];
			var kicker = twoPairs[4];
			point = 30000000000 + 10000*mainPart1 + 100*mainPart2 + kicker;
			show_debug_message("牌型最终为两对");
		}else if(array_length(pairs) == 1){
			var onePair = findOnePair(valueArray, pairs);
			var mainPart = onePair[0];
			var kicker1 = onePair[2];
			var kicker2 = onePair[3];
			var kicker3 = onePair[4];
			point = 20000000000 + 1000000*mainPart + 10000*kicker1 + 100*kicker2 + kicker3;
			show_debug_message("牌型最终为一对");
		}else{
			var kicker1 = valueArray[0];
			var kicker2 = valueArray[1]; 
			var kicker3 = valueArray[2];
			var kicker4 = valueArray[3];
			var kicker5 = valueArray[4];
			point = 10000000000 + 100000000*kicker1 + 1000000*kicker2 + 10000*kicker3 + 100*kicker4 + kicker5;
			show_debug_message("牌型最终为高牌");
		}
	}
	return point;
}

function isSameSuit(suitArray){
	for (var i = 0; i < array_length(suitArray); i++) {
	    var currentSuit = suitArray[i];
	    var count = 0;

	    // 统计当前花色出现的次数
	    for (var j = 0; j < array_length(suitArray); j++) {
	        if (suitArray[j] == currentSuit) {
	            count++;
	        }
	    }
	    if (count >= 5) {
	        return true;
	    }
	}
	return false;
}
function findFlush(suitArray, original_valueArray) {
    // 统计每种花色的牌
    var flushMap = ds_map_create();
    for (var i = 0; i < array_length(suitArray); i++) {
        var suit = suitArray[i];
        var value = original_valueArray[i];

        if (ds_map_exists(flushMap, suit)) {
            var cards = ds_map_find_value(flushMap, suit);
            array_push(cards, value);
            ds_map_set(flushMap, suit, cards);
        } else {
            ds_map_set(flushMap, suit, [value]);
        }
    }

    // 找到至少 5 张同一花色的牌
    var flushCards = [];
    var key = ds_map_find_first(flushMap);
    while (key != undefined) {
        var cards = ds_map_find_value(flushMap, key);
        if (array_length(cards) >= 5) {
            // 提取所有同花牌
            for (var i = 0; i < array_length(cards); i++) {
                array_push(flushCards, cards[i]);
            }
            break; // 找到第一个满足条件的同花后退出循环
        }
        key = ds_map_find_next(flushMap, key);
    }
    ds_map_destroy(flushMap);
	array_sort(flushCards, false);
    return flushCards;
}

function findOnePair(valueArray, pairs) {
    var mainPart = pairs[0]; // 一对的主要部分

    // 找到三张 kicker（不能与一对的牌相同）
    var kickers = [];
    for (var i = 0; i < array_length(valueArray); i++) {
        if (valueArray[i] != mainPart) { // 排除一对的牌
            array_push(kickers, valueArray[i]);
            if (array_length(kickers) == 3) { // 找到三张 kicker 后退出循环
                break;
            }
        }
    }
    // 返回一对和 kicker
    return array_concat([mainPart, mainPart], kickers);
}
function findTwoPairs(valueArray, pairs) {
    // 选择最大的两对
    var firstPair = pairs[0]; // 第一对
    var secondPair = pairs[1]; // 第二对

    // 找到 kicker（不能与两对的牌相同）
    var kicker = 0;
    for (var i = 0; i < array_length(valueArray); i++) {
        if (valueArray[i] != firstPair && valueArray[i] != secondPair) { // 排除两对的牌
            kicker = valueArray[i];
            break; // 因为数组已经降序排列，第一个不等于两对的值就是最大的 kicker
        }
    }
    // 返回两对和 kicker
    return array_concat([firstPair, firstPair, secondPair, secondPair], [kicker]);
}
function findThreeOfAKind(valueArray, triplets) {
    var mainPart = triplets[0]; // 三条的主要部分

    // 找到两张 kicker（不能与三条的牌相同）
    var kickers = [];
    for (var i = 0; i < array_length(valueArray); i++) {
        if (valueArray[i] != mainPart) { // 排除三条的牌
            array_push(kickers, valueArray[i]);
            if (array_length(kickers) == 2) { // 找到两张 kicker 后退出循环
                break;
            }
        }
    }
    return array_concat([mainPart, mainPart, mainPart], kickers);
}

function findPairs(valueArray) {
    var pairs = []; // 用于存储所有对子的牌值

    // 遍历数组，找到所有对子
    for (var i = 0; i < array_length(valueArray) - 1; i++) {
        // 检查当前元素与下一个元素是否相同，并确保这对不是更大组合的一部分
        if (valueArray[i] == valueArray[i + 1]) {
            if ((i == 0 || valueArray[i] != valueArray[i - 1]) &&  // 确保前一个元素不同
                (i + 2 >= array_length(valueArray) || valueArray[i] != valueArray[i + 2])) {  // 确保后面第二个元素不同
                array_push(pairs, valueArray[i]); // 将对子的牌值添加到数组中
                i += 1;  // 跳过下一个已经配对的元素
            }
        }
    }
    return pairs;
}
function findTriplets(valueArray) {
    var triplets = []; // 用于存储所有三条的牌值

    // 遍历数组，找到所有三条
    for (var i = 0; i < array_length(valueArray) - 2; i++) {
        // 检查当前元素与接下来的两个元素是否相同，并确保这三个不是更大组合的一部分
        if (valueArray[i] == valueArray[i + 1] && valueArray[i] == valueArray[i + 2]) {
            if ((i == 0 || valueArray[i] != valueArray[i - 1]) &&  // 确保前一个元素不同
                (i + 3 >= array_length(valueArray) || valueArray[i] != valueArray[i + 3])) {  // 确保后面第四个元素不同
                array_push(triplets, valueArray[i]); // 将三条的牌值添加到数组中
                i += 2;  // 跳过接下来的两个已经计算过的元素
            }
        }
    }
    return triplets;
}
function findMaxStraight(straights) {
    if (array_length(straights) == 0) {
        return []; // 如果没有顺子，返回空数组
    }

    var maxStraight = straights[0]; // 假设第一个顺子是最大的
    var maxValue = maxStraight[0]; // 第一个顺子的最大牌

    // 遍历所有顺子，找到最大牌力的顺子
    for (var i = 1; i < array_length(straights); i++) {
        var currentStraight = straights[i];
        var currentMaxValue = currentStraight[0]; // 当前顺子的最大牌

        // 特殊处理 A-2-3-4-5 顺子
        if (currentStraight[0] == 14 && currentStraight[1] == 5) {
            currentMaxValue = 5; // A-2-3-4-5 顺子的牌力视为 5
        }

        // 如果当前顺子的最大牌更大，更新结果
        if (currentMaxValue > maxValue) {
            maxStraight = currentStraight;
            maxValue = currentMaxValue;
        }
    }

    return maxStraight;
}
function findStraight(valueArray) {
    var uniqueArray = []; // 用于存储去重后的数组
    var straights = []; // 用于存储所有满足条件的顺子

    // 去掉多余的重复值
    for (var i = 0; i < array_length(valueArray); i++) {
        var isDuplicate = false;
        for (var j = 0; j < array_length(uniqueArray); j++) {
            if (valueArray[i] == uniqueArray[j]) {
                isDuplicate = true;
                break;
            }
        }
        if (!isDuplicate) {
            array_push(uniqueArray, valueArray[i]);
        }
    }
    // 如果去重后的数组长度小于 5，直接返回空数组
    if (array_length(uniqueArray) < 5) {
        return straights;
    }

    // 检查普通顺子
    for (var i = 0; i <= array_length(uniqueArray) - 5; i++) {
        var isConsecutive = true;

        // 检查当前元素及其后 4 个元素是否连续
        for (var j = i; j < i + 4; j++) {
            if (uniqueArray[j] - uniqueArray[j + 1] != 1) {
                isConsecutive = false;
                break;
            }
        }

        // 如果找到连续序列，手动提取连续 5 张牌
        if (isConsecutive) {
            var straight = [];
            for (var k = i; k < i + 5; k++) {
                array_push(straight, uniqueArray[k]);
            }
            array_push(straights, straight);
        }
    }

	// 检查 A-2-3-4-5 顺子
	if (uniqueArray[0] == 14 && 
	    uniqueArray[array_length(uniqueArray) - 4] == 5 && 
	    uniqueArray[array_length(uniqueArray) - 3] == 4 && 
	    uniqueArray[array_length(uniqueArray) - 2] == 3 && 
	    uniqueArray[array_length(uniqueArray) - 1] == 2) {
	    var straight = [14, 5, 4, 3, 2]; // 直接构造 A-2-3-4-5 顺子
	    array_push(straights, straight);
	}

    return straights;
}
function findFourOfAKind(valueArray) {
    // 遍历数组，找到四张相同的牌
    for (var i = 0; i <= array_length(valueArray) - 4; i++) {
        if (valueArray[i] == valueArray[i + 1] &&
            valueArray[i] == valueArray[i + 2] &&
            valueArray[i] == valueArray[i + 3]) {
            var fourOfAKind = [valueArray[i], valueArray[i + 1], valueArray[i + 2], valueArray[i + 3]]; 
            var kicker = 0;
            for (var j = 0; j < array_length(valueArray); j++) {
                if (valueArray[j] != valueArray[i]) { // 排除四条的牌
                    kicker = valueArray[j];
                    break; // 因为数组已经降序排列，第一个不等于四条的值就是最大的 kicker
                }
            }
            // 返回四条和 kicker
            return array_concat(fourOfAKind, [kicker]);
        }
    }
    return [];
}