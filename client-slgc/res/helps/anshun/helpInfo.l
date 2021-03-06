﻿return {
GAME_TYPE_R_GUIYANG = {
{ title = "(一) 牌型：" },
{ subTitle = "1. 平胡，1分。", cards = {2,2,2,7,8,9,17,18,18,18,19,25,26,0,24}, space = 15},
{ subTitle = "2. 大对子，5分。", cards = {2,2,2,7,7,7,14,14,14,23,23,23,29,0,29}, space = 15 },
{ subTitle = "3. 单吊，10分。", cards = {2,2,2,0,7,7,7,0,14,14,14,0,23,23,23,0,29,0,29}, space = 15 },
{ subTitle = "4. 清单吊，20分。", cards = {2,2,2,0,3,3,3,0,5,5,5,0,7,7,7,0,9,0,9}, space = 15 },
{ subTitle = "5. 七对，10分。", cards = {1,1,4,4,7,16,16,18,18,24,24,27,27,0,7}, space = 15 },
{ subTitle = "6. 清一色，10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ subTitle = "7. 清大对，15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ subTitle = "8. 龙七对，20分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ subTitle = "9. 地龙，10分。", cards = {1,1,1,0,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ subTitle = "10. 清地龙，20分。", cards = {1,1,1,0,2,2,4,4,6,6,8,8,9,9,0,1}, space = 15 },
{ subTitle = "11. 清七对，20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ subTitle = "12. 清龙背，30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },
{ title = "(二) 特殊规则如下："},
{ content = [[1.自摸加1分。
2.杠开（杠上开花），杠牌玩家额外收取其他玩家3分。
3.热炮（杠上炮），在胡牌牌形基础上加3分，杠牌后打出一张牌给其他玩家点炮，无豆平胡可胡。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.抢杠，杠牌玩家额外赔付胡牌者9分，（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效），无豆平胡可胡。
5.报听胡牌：分为硬报和软报两种。摸到第一张牌就自摸，此为硬报，结算时每家额外收取20分；摸到第一张牌后听牌（接下来不能换牌、杠牌），此为软报，结算时每家额外收取10分。
6.一炮多响：当多个玩家可和同一张牌时，此时根据玩家的选择胡牌。点炮玩家要按照对应的牌型进行赔付，每个牌型各自计算分数。
7.过胡：若玩家在可以吃胡其他玩家时选择放弃，在其下一次出牌前，不能再吃胡其他玩家的牌。软报过吃胡后，只能自摸胡牌。
8.地胡：闲家在第一轮接炮胡牌，可无豆平胡，计10分]]},
{ title = "(三) 关于“豆”"},
{ content = [[1. 闷豆
　　玩家摸到4张一样的牌并杠出，为闷豆。结算时，其他玩家每人付3分，可叠加。
2. 转弯豆
　　碰牌后，再摸到最后一张牌杠出，为转弯豆。结算时，其他玩家每人付3分，可叠加。
3. 点明豆、明豆
　　某玩家打出一张牌，被其他玩家用3张相同的牌杠走，为点豆。结算时，点豆者向接豆者付3分，可叠加。]]},
{ title = "(四) 关于鸡" },
{ content = [[1.普通鸡：幺鸡，叫牌时每张计1分；未叫牌时，打出或碰杠的幺鸡需赔付叫牌玩家。（责任鸡作为持有者的普通鸡结算分数）
2.冲锋鸡：在起牌后，所有玩家打出的第一张幺鸡为冲锋鸡，计2分。若翻牌鸡为幺鸡，则此冲锋金鸡结算时为4分。
3.责任鸡：摸牌后，若玩家打出去的第一张幺鸡被其他玩家碰或杠走，则该鸡为责任鸡，计1分，未叫牌反赔。
4.翻牌鸡：玩家胡牌后，翻开第1张未摸的牌，根据这张牌的数值，顺位+1的牌为鸡，计1分（翻开的是5万，6万为鸡；若翻开的是9条，则幺鸡为金鸡，计2分）。
5.本鸡：翻牌鸡翻开的那张牌也是鸡，计1分。
6.乌骨鸡：默认八筒为乌骨鸡，相关分数为幺鸡的2倍。
7.摇摆鸡：翻牌的顺位+1和-1的两张牌都为鸡。
8.满堂鸡：所有打出的鸡和手中的鸡都参与最终结算。
9.吹风鸡：翻鸡翻开的是5筒时为吹风机，此局所有玩家的鸡全部作废。
10.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。]]},
{ title = "(五) 黄庄查叫" },
{ content = [[　　所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
　　查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
　　查牌后，部分玩家叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数。]]},
{ title = "(六) 通三" },
{ content = [[　　胡牌规则与贵阳捉鸡一致，自摸无加分，分数如下：
1. 平胡/自摸	3分
2. 大对子		8分
3. 七对		13分
4. 清一色		13分
5. 清大对		18分
6. 龙七对		23分
7. 清七对		23分
8. 清龙背		30分

　　关于“豆”的规则与贵阳捉鸡一致，分值如下：
1. 闷豆		3分
2. 明豆		3分
3. 转弯豆		3分

　　关于“鸡”的规则与贵阳捉鸡一致，分值如下：
1. 普通鸡		1分
2. 乌骨鸡		2分
3. 金鸡			2分
4. 金乌骨		4分
5. 冲锋鸡		3分
6. 冲锋乌骨		4分
7. 冲锋金鸡		6分
8. 冲锋金乌骨		8分
9. 责任鸡		1分
10. 责任乌骨		2分]]},
{ title = "(七) 两房" },
{ content = [[　　在贵阳捉鸡规则基础上去掉万，只有“条”和“筒”共72张牌，胡牌更迅速，紧张刺激！！！]]}
},

GAME_TYPE_R_ANSHUN = {
{ title = "(一) 牌型：" },
{ subTitle = "1. 平胡   1分。", cards = {2,2,2,7,8,9,17,18,18,18,19,25,26,0,24}, space = 15 },
{ subTitle = "2. 大对子   5分。", cards = {2,2,2,7,7,7,14,14,14,23,23,23,29,0,29}, space = 15 },
{ subTitle = "3. 七对  10分。", cards = {1,1,4,4,7,16,16,18,18,24,24,27,27,0,7}, space = 15 },
{ subTitle = "4. 清一色   10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ subTitle = "5. 清大对   15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ subTitle = "6. 龙七对  20分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ subTitle = "7. 清七对  20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ subTitle = "8. 清龙七对  30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },

{ title = "(二) 特殊规则如下："},
{ content = [[1.杠开（杠上开花），杠牌后补牌直接胡牌，额外收取其他玩家3分。
2.热炮（杠上炮），杠牌后打出的第一张牌被其他玩家胡牌，胡牌者额外加1分，（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）。
3.抢杠，有玩家在成转弯豆时，其他玩家如果叫这张牌，可直接胡牌。此时成豆玩家转弯豆不计分，额外赔付9分，无豆平胡可胡。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.天听，庄家起牌打掉一张牌后立即叫牌，可以报听；闲家起牌后第一轮打牌后立即叫牌，可以报听。此时不能换牌、不能碰牌也不能杠牌，直到此局结束。平胡直接按10分结算，其他牌型再牌型分值上+10分结算，自摸翻倍。
5.天胡，庄家起牌后直接胡牌，计分规则同天听。
6.地胡，闲家起牌后第一轮接炮或自摸胡牌，计分规则同天听。
7.一炮多响，玩家打出一张牌，被多个玩家同时胡牌，玩家需要按胡牌玩家牌型分别赔付。]]},

{ title = "(三) 关于“豆”"},
{ content = [[1. 闷豆
　　玩家摸到4张一样的牌并杠出，为闷豆。结算时，其他玩家每人付3分，可叠加。
2. 转弯豆
　　碰牌后，再摸到最后一张牌杠出，为转弯豆。结算时，其他玩家每人付3分，可叠加。
3. 点豆、接豆
　　某玩家打出一张牌，被其他玩家用3张相同牌的杠走，为点豆。结算时，点豆者向接豆	者付3分，可叠加。]]},

{ title = "(四) 关于鸡"},
{ content = [[1.普通鸡：幺鸡，叫牌时每张计1分；未叫牌时，打出或碰杠的幺鸡需赔付叫牌玩家。
2.冲锋鸡：在起牌后，所有玩家打出的第一张幺鸡为冲锋鸡，计2分。若翻牌鸡为幺鸡，则此冲锋金鸡结算时为4分。
3.翻牌鸡：玩家胡牌后，翻开第1张未摸的牌，根据这张牌的数值，顺位+1的牌为鸡，计1分（翻开的是5万，6万为鸡；若翻开的是9条，则幺鸡为金鸡，计2分）。
4.本鸡：翻牌鸡翻开的那张牌也是鸡，计1分。
5.乌骨鸡：默认八筒为乌骨鸡，相关分数为幺鸡的2倍。
6.摇摆鸡：翻牌的顺位+1和-1的两张牌都为鸡。
7.吹风鸡：翻鸡翻开的是5筒时为吹风机，此局所有玩家的鸡全部作废。
8.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。]]},

{ title = "(五) 黄庄查叫"},
{ content = [[　　所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
　　查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
　　查牌后，有玩家叫牌，有玩家不叫牌。不叫牌玩家需要给叫牌玩家按牌型分别支付分值。]]
}
}

}
