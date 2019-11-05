﻿return {
GAME_TYPE_R_TONGREN = {
{ title = "(一) 牌型：" },
{ content = "1. 平胡，1分。", cards = {2,2,2,7,8,9,17,18,18,18,19,25,26,0,24}, space = 15},
{ content = "2. 大对子，5分。", cards = {2,2,2,7,7,7,14,14,14,23,23,23,29,0,29}, space = 15 },
{ content = "3. 七对，10分。", cards = {1,1,4,4,7,16,16,18,18,24,24,27,27,0,7}, space = 15 },
{ content = "4. 清一色，10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ content = "5. 清大对，15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ content = "6. 龙七对，20分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "7. 地龙，20分。", cards = {1,1,1,0,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "8. 清地龙，30分。", cards = {1,1,1,0,2,2,4,4,6,6,8,8,9,9,0,1}, space = 15 },
{ content = "9. 清七对，20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ content = "10. 清龙背，30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },
{ title = "(二) 特殊规则如下："},
{ content = [[1.自摸平胡时，一扣二每家收2分，一扣三每家收3分。
2.杠开（杠上开花），杠牌玩家额外收取其他玩家1分。
3.热炮（杠上炮）,无豆平胡可胡。烧鸡烧豆时杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效。
4.抢杠，无豆平胡可胡。烧鸡烧豆时杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效。
5.报听胡牌：摸到第一张牌后听牌，结算时每家额外收取10分。
6.一炮多响：当多个玩家可和同一张牌时，此时根据玩家的选择胡牌。点炮玩家要按照对应的牌型进行赔付，每个牌型各自计算分数。
7.过胡，若玩家在可以吃胡其他玩家时选择放弃，在其下一次出牌前，不能再吃胡其他玩家的牌。软报过吃胡后，只能自摸胡牌。
8.天胡，庄家开局即自摸胡牌，每家收10分。
9.地胡：闲家在第一轮接炮胡牌，可无豆平胡，计10分。
10.包鸡包豆，牌局中，有其中一玩家胡牌后，其他玩家打出去的鸡（幺鸡、乌骨鸡）不听牌或者碰了不叫牌时，需要支付给叫牌和胡牌玩家鸡和豆的分值。若碰幺鸡或八筒未听牌，需要赔付听牌玩家打冲锋鸡或打冲锋乌骨鸡一方5分（若碰的不是冲锋，则赔付3分），赔付其他听牌玩家3分；若明杠幺鸡或八筒未听牌，需要赔付听牌玩家打冲锋鸡或打冲锋乌骨鸡一方9分，赔付其他听牌玩家4分；若闷豆幺鸡或八筒未听牌，需要赔付听牌玩家7分。若转弯豆幺鸡或八筒未听牌，需要赔付听牌玩家打冲锋鸡或打乌骨鸡一方9分，赔付其他听牌玩家7分。]]},
{ title = "(三) 关于“豆”"},
{ content = [[1. 闷豆
玩家摸到4张一样的牌并杠出，为闷豆。结算时，其他玩家每人付3分，可叠加。
2. 转弯豆
碰牌后，再摸到最后一张牌杠出，为转弯豆。结算时，其他玩家每人付3分，可叠加。
3. 点明豆、明豆
某玩家打出一张牌，被其他玩家用3张相同的牌杠走，为点豆。结算时，点豆者向接豆者付3分，可叠加。]]},
{ title = "(四) 关于鸡" },
{ content = [[1.幺鸡：幺鸡，叫牌时每张计1分；未叫牌时，打出或碰杠的幺鸡需赔付叫牌玩家。（责任鸡作为持有者的普通鸡结算分数）
2.冲锋鸡：在起牌后，所有玩家打出的第一张幺鸡为冲锋鸡，计3分。若翻牌鸡为幺鸡，则此冲锋金鸡结算时为6分。
3.责任鸡：摸牌后，若玩家打出去的第一张幺鸡被其他玩家碰或杠走，则该鸡为责任鸡，计3分，未叫牌反赔。
4.翻牌鸡：玩家胡牌后，翻开第1张未摸的牌，根据这张牌的数值，顺位+1的牌为鸡，计1分（翻开的是5万，6万为鸡；若翻开的是9条，则幺鸡为金鸡，计2分）。
5.本鸡：翻牌鸡翻开的那张牌也是鸡，计1分。
6.摇摆鸡：翻牌的顺位+1和-1的两张牌都为鸡。
7.乌骨鸡：默认八筒为乌骨鸡，相关分数为与幺鸡相同。
8.满堂鸡：所有打出的鸡和手中的鸡都参与最终结算。
9.两房：在贵阳捉鸡规则基础上去掉万，只有“条”和“筒”共72张牌，胡牌更迅速，紧张刺激！！！]]},
{ title = "(五) 黄庄查叫" },
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，部分玩家叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数。]]}
},

GAME_TYPE_R_LIANG_FANG = {
{ title = "(一) 牌型：" },
{ content = "1. 平胡，1分。", cards = {12,12,12,17,18,19,25,26,27,28,28,28,29,0,24}, space = 15},
{ content = "2. 大对子，5分。", cards = {12,12,12,13,13,13,14,14,14,23,23,23,29,0,29}, space = 15 },
{ content = "3. 单吊，10分。", cards = {12,12,12,0,13,13,13,0,14,14,14,0,23,23,23,0,29,0,29}, space = 15 },
{ content = "4. 清单吊，20分。", cards = {12,12,12,0,13,13,13,0,15,15,15,0,17,17,17,0,19,0,19}, space = 15 },
{ content = "5. 七对，10分。", cards = {11,11,12,12,13,16,16,18,18,24,24,27,27,0,13}, space = 15 },
{ content = "6. 清一色，10分。", cards = {11,11,11,12,13,14,15,16,17,18,19,19,19,0,18}, space = 15 },
{ content = "7. 清大对，15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ content = "8. 龙七对，20分。", cards = {11,11,11,12,12,14,14,21,21,22,22,24,24,0,11}, space = 15 },
{ content = "9. 地龙，10分。", cards = {11,11,11,0,12,12,14,14,21,21,22,22,24,24,0,11}, space = 15 },
{ content = "10. 清地龙，20分。", cards = {11,11,11,0,12,12,14,14,16,16,18,18,19,19,0,11}, space = 15 },
{ content = "11. 清七对，20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ content = "12. 清龙背，30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },
{ title = "(二) 特殊规则如下："},
{ content = [[1.自摸加1分。
2.杠开（杠上开花），杠牌玩家额外收取其他玩家3分。
3.热炮（杠上炮），在胡牌牌形基础上加3分，杠牌后打出一张牌给其他玩家点炮，无豆平胡可胡。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.抢杠，杠牌玩家额外赔付胡牌者9分，（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效），无豆平胡可胡。
5.报听胡牌：分为硬报和软报两种。摸到第一张牌就自摸，此为硬报，结算时每家额外收取20分；摸到第一张牌后听牌（接下来不能换牌、杠牌），此为软报，结算时每家额外收取10分。
6.一炮多响：当多个玩家可和同一张牌时，此时根据玩家的选择胡牌。点炮玩家要按照对应的牌型进行赔付，每个牌型各自计算分数。
7.过胡：若玩家在可以吃胡其他玩家时选择放弃，在其下一次出牌前，不能再吃胡其他玩家的牌。软报过吃胡后，只能自摸胡牌。
8.地胡：闲家在第一轮接炮胡牌，可无豆平胡，计10分. ]]},
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
10.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。
11.首圈鸡：同一个玩家第二次出牌前打出的幺鸡为首圈鸡，计3分。若该玩家未上听，则赔付上听玩家3分。责任鸡分数不变。（首圈鸡是特殊情况的冲锋鸡）
12.银鸡：拿到一筒或一万时，计2分（注：如果选择翻牌鸡，则是抓到牌为九筒或九万，翻牌鸡为一筒或一万时为银鸡；如果是摇摆鸡，则抓到九筒或九万或二筒或二万时，摇摆鸡为一筒或一万时为银鸡；如果选择是本鸡，则是翻牌鸡或摇摆鸡抓到一筒或一万，为银鸡]]},
{ title = "(五) 黄庄查叫" },
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，部分玩家叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数。]]},
{ title = "(六) 通三" },
{ content = [[胡牌规则与贵阳捉鸡一致，自摸无加分，分数如下：
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
},

GAME_TYPE_R_GUIYANG = {
{ title = "(一) 牌型：" },
{ content = "1. 平胡，1分。", cards = {2,2,2,7,8,9,17,18,18,18,19,25,26,0,24}, space = 15},
{ content = "2. 大对子，5分。", cards = {2,2,2,7,7,7,14,14,14,23,23,23,29,0,29}, space = 15 },
{ content = "3. 单吊，10分。", cards = {2,2,2,0,7,7,7,0,14,14,14,0,23,23,23,0,29,0,29}, space = 15 },
{ content = "4. 清单吊，20分。", cards = {2,2,2,0,3,3,3,0,5,5,5,0,7,7,7,0,9,0,9}, space = 15 },
{ content = "5. 七对，10分。", cards = {1,1,4,4,7,16,16,18,18,24,24,27,27,0,7}, space = 15 },
{ content = "6. 清一色，10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ content = "7. 清大对，15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ content = "8. 龙七对，20分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "9. 地龙，10分。", cards = {1,1,1,0,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "10. 清地龙，20分。", cards = {1,1,1,0,2,2,4,4,6,6,8,8,9,9,0,1}, space = 15 },
{ content = "11. 清七对，20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ content = "12. 清龙背，30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },
{ title = "(二) 特殊规则如下："},
{ content = [[1.自摸加1分。
2.杠开（杠上开花），杠牌玩家额外收取其他玩家3分。
3.热炮（杠上炮），在胡牌牌形基础上加3分，杠牌后打出一张牌给其他玩家点炮，无豆平胡可胡。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.抢杠，杠牌玩家额外赔付胡牌者9分，（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效），无豆平胡可胡。
5.报听胡牌：分为硬报和软报两种。摸到第一张牌就自摸，此为硬报，结算时每家额外收取20分，不计牌型番数以及自摸番数；摸到第一张牌后听牌（接下来不能换牌、杠牌），此为软报，结算时每家额外收取10分。
6.一炮多响：当多个玩家可和同一张牌时，此时根据玩家的选择胡牌。点炮玩家要按照对应的牌型进行赔付，每个牌型各自计算分数。
7.过胡：若玩家在可以吃胡其他玩家时选择放弃，在其下一次出牌前，不能再吃胡其他玩家的牌。软报过吃胡后，只能自摸胡牌。
8.地胡：闲家在第一轮接炮胡牌，可无豆平胡，计10分。
9.估卖：每局开始前，每位玩家都可以设置估卖分，如果本局结束时玩家之间有牌型分收付的过程，则计算时需要额外加上双方的估卖分。 ]]},
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
10.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。
11.首圈鸡：同一个玩家第二次出牌前打出的幺鸡为首圈鸡，计3分。若该玩家未上听，则赔付上听玩家3分。责任鸡分数不变。（首圈鸡是特殊情况的冲锋鸡）
12.银鸡：拿到一筒或一万时，计2分（注：如果选择翻牌鸡，则是抓到牌为九筒或九万，翻牌鸡为一筒或一万时为银鸡；如果是摇摆鸡，则抓到九筒或九万或二筒或二万时，摇摆鸡为一筒或一万时为银鸡；如果选择是本鸡，则是翻牌鸡或摇摆鸡抓到一筒或一万，为银鸡]]},
{ title = "(五) 黄庄查叫" },
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，部分玩家叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数。]]},
{ title = "(六) 通三" },
{ content = [[胡牌规则与贵阳捉鸡一致，自摸无加分，分数如下：
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
{ content = [[在贵阳捉鸡规则基础上去掉万，只有“条”和“筒”共72张牌，胡牌更迅速，紧张刺激！！！]]}
},

GAME_TYPE_R_ANLONG = {
{ title = "(一) 开局规则:"},
{ content = [[1.游戏人数：4人、3人（3丁拐）、2人（2丁拐）。
2.牌：两人、三人局没有万，只有条和筒，四人局有万、条、筒、红中112张牌。 
3.排座：创建房间者默认方位为东风位，其他玩家按进入房间的顺序以东、南、西、北的（逆）顺序排座，牌局开始后玩家位置不会改变。]]},
{ title = "(二) 游戏规则:"},
{ subTitle = "抓牌:"},
{ content = [[1.牌局开始时，庄家抓14张牌，闲家抓13张牌。
2.抓牌顺序默认为逆时针按座次依次抓牌。
3.碰牌、杠牌和和牌会改变抓牌顺序。]]},
{ subTitle = "出牌:"},
{ content = [[1.庄家起手14张牌，直接出牌（或者直接天和）。
2.按照逆时针顺序，上家出牌后，下家再抓牌，出牌。
3.碰、杠会改变出牌顺序。]]},
{ subTitle = "碰牌:"},
{ content = [[1.玩家手中有两张牌与其他玩家打出的牌相同，即可选择碰牌。
2.其它三家出的牌，都可以碰。
3.碰完牌，需要再出一张牌。]]},
{ subTitle = "杠牌:"},
{ content = [[1.明杠：分为点杠和梭杠。
2.点杠：手里有三张一样的牌，别人再打出一张相同的牌，提示杠牌。
3.选择杠牌，不考虑手牌中的已经存在的暗杠。杠牌后抓一张牌
4.选择"过"，不需要出牌
5.梭杠：抓到一张牌和以前碰的三张牌相同。
6.暗杠：手里有四张一样的牌。 
7.明杠、梭杠、暗杠漏杠（摸到杠牌的第一轮未选择杠）后，再杠不算分，但可作为胡牌通行证，杠上炮和杠上胡不受影响。
8.结算时，若玩家未叫牌（听牌），杠不参与结算。黄庄时不计算所有杠的分数。]]},
{ subTitle = "鸡牌:"},
{ content = [[1.冲锋鸡 2.责任鸡 3.普通鸡 4.乌骨鸡 5.翻牌鸡 6.本鸡]]},
{ subTitle = "和牌和黄庄:"},
{ content = [[1.可和牌方式：点和、自摸、抢杠。
2.自己抓到的牌导致和牌时，称为自摸。自摸的玩家向其他所有未和牌的玩家收取自己牌型应获取番数的积分。
3.由其他玩家打出的牌和牌时，称为点和，该玩家称为点炮。点和玩家向点炮玩家收取自己牌型应获取番数的积分。
4.抢杠胡:当其他玩家梭杠时，若有玩家胡这张牌，可以抢杠胡，按照抢杠玩家自摸计算，所有玩家应付分数由被抢杠玩家承担，同时被抢杠玩家烧掉所有鸡和杠。抢杠胡不能闷胡。
5.一炮多响/截和：当多个玩家可和同一张牌时，此时根据玩家的选择胡牌。点炮玩家要按照对应的牌型进行赔付，每个牌型各自计算番数。
6.游戏结束：有一个玩家和牌或黄庄。
7.黄庄：所有牌摸完、打完， 无人胡牌为黄庄。（不再计算杠、鸡）
8.无人叫牌或全部叫牌，无输赢
9.有人叫牌，有人没叫牌。这种情况未叫牌的玩家需分别赔付所有叫牌玩家的最大可能牌形的分数。
10.闲家报听时可以杀报，且其他玩家每次闷胡都要算杀报分数。开局庄家可以天胡，不能报听，闲家可以报听，即闲家若想报听必须开局手牌就有听。如果胡的是平胡则算胡清一色，如果胡的是其他牌型则在原牌型的基础上再加清一色的分数。]]},
{ subTitle = "特殊规则:"},
{ content = [[闷胡:
A.当自己可以接炮胡牌（有杠）或者自摸的时候可以选择1、胡牌 2、闷起。1、选择胡牌则倒牌结束牌局 2、选择闷起也分为两种，一种是自摸闷起,牌不可见。另一种是捡别人的牌闷胡，正面向上。
B.如果最后都没有人倒牌结束牌局则算作流局，未叫牌玩家需要赔付闷胡玩家所有闷胡分，若无闷胡则赔付正常叫牌分。
C.选择闷牌后自动打牌，遇到能胡的牌必须选择闷起或者倒牌，不能过胡，也不能碰杠。
D.第一次自摸闷胡可作为通行证，即之后平胡也可接炮
E.一炮多响不能闷胡，可以选择倒牌胡或者过胡。抢杠胡必须胡，不能过胡或闷胡，热炮可以闷胡，天胡不能闷胡
F.闷胡以后不可以杠
G.连胡玩法下，闷胡不改变摸牌顺序]]},
{ title = "(三) 计分规则:"},
{ subTitle = "基础牌型:"},
{ content = [[1.平和:1分。自摸2分。
2.大对子:5分。自摸10分。
3.七对:5分。自摸10分。
4.清一色:10分。自摸20分。
5.龙七对:10分。自摸20分。
6.地龙七对:10分。自摸20分。
7.清大对:15分。自摸30分。
8.清七对:15分。自摸30分。
9.青龙背:20分。自摸40分。]]},
{ subTitle = "特殊加分项:"},
{ content = [[1.自摸:牌型分翻倍
2.连庄：每连庄一次:+1分
3.杠上花:1分。（杠牌后补牌成和）]]},
{ subTitle = "杠牌与鸡牌:"},
{ content = [[1.点杠，点杠者给被点杠者3分，可叠加。
2.梭杠，其他3个玩家每人给梭杠者3分，可叠加。
3.暗杠，其余玩家每人给暗杠者3分，可叠加。
4.鸡牌。
5.冲锋鸡:2分。
6.责任鸡:1分。
7.普通鸡:1分。
8.乌骨鸡:2分。
9.翻牌鸡:1分。
10.金鸡:2分。
11.摇摆鸡:1分。
12.本鸡:1分。
13.红中:1分。]]},
},

GAME_TYPE_R_ZUNYI = {
{ title = "(一) 牌型："},
{ content = "1. 平胡   2分。", cards = {2,2,2,7,8,9,25,26,27,28,28,28,29,0,24}, space = 15 },
{ content = "2. 边卡吊  3分。"},
{ content = "边：", cards = {1,2,3,7,8,9,21,22,23,26,26,28,29,0,27}, space = 15 },
{ content = "卡：", cards = {1,2,3,7,8,9,21,22,23,26,26,27,29,0,28}, space = 15 },
{content = "吊：", cards = {1,2,3,7,8,9,21,22,23,24,25,26,28,0,28}, space = 15 },
{ content = "3. 大宽张  4分。", cards = {1,2,3,7,8,9,11,11,13,14,15,16,17,0,12}, space = 15 },
{ content = "4. 大对子   4分。", cards = {2,2,2,7,7,7,23,23,23,25,25,25,29,0,29}, space = 15 },
{ content = "5. 七对  7分。", cards = {1,1,4,4,7,14,14,16,16,17,17,18,18,0,7}, space = 15 },
{ content = "6. 龙七对  10分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "7. 清一色   10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ content = "8. 清大对  10分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ content = "9. 清七对  20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ content = "10. 清龙七对  20分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },
{ title = "(二) 特殊规则如下："},
{ content = [[1.杠开（杠上开花），杠牌后补牌直接胡牌，按清一色自摸计算，收取其他3个玩家对应分数。
2.热炮（杠上炮），杠牌后打出的第一张牌被其他玩家胡牌。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
3.抢杠胡，有玩家在成转弯豆时，其他玩家如果叫这张牌，可直接胡牌。此时成豆玩家转弯豆不计分，胡牌玩家按清一色计分，由转弯豆玩家赔付。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.天缺，玩家起牌缺一门，牌局结束每家收取2分。（无论是否听牌）
5.天听，庄家起牌打掉一张牌后立即叫牌，可以报听；闲家起牌后第一轮打牌后立即叫牌，可以报听。此时不能换牌、不能碰牌也不能杠牌，直到此局结束。平胡直接按10分结算，其他牌型再牌型分值上+10分结算。
6.天胡，庄家起牌后直接胡牌，计分规则同天听。
7.地胡，闲家起牌后第一轮接炮或自摸胡牌，计分规则同天听。
8.一炮多响，玩家打出一张牌，被多个玩家同时胡牌，玩家需要按胡牌玩家牌型分别赔付。]]},
{ title = "(三) 关于“豆”"},
{ content = [[遵义麻将中的“杠”即为“豆”。
1. 闷豆
玩家摸到4张一样的牌并杠出，为闷豆。结算时，其他玩家每人付2分，可叠加。
2. 转弯豆
碰牌后，再摸到最后一张牌杠出，为转弯豆。结算时，其他玩家每人付2分，可叠加。
3. 点豆、接豆
某玩家打出一张牌，被其他玩家用3张相同牌的杠走，为点豆。结算时，点豆者向接豆者付2分，可叠加。]]},
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
{ title = "(五) 黄庄查叫"},
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，有玩家叫牌，有玩家不叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数，未叫牌且未缺门的玩家每张缺牌都需要赔给叫牌玩家1分，有多家叫牌的每家均需支付。]]},
{ title = "(六) 胡牌查缺" },
{ content = "有玩家胡牌后，需要所有玩家开牌确定定缺情况，如果有玩家还有缺门牌，每张牌都需要赔给胡牌人1分。"}
},

GAME_TYPE_R_ANSHUN_GUIYANG = {
{ title = "(一) 牌型：" },
{ content = "1. 平胡   1分。", cards = {2,2,2,7,8,9,17,18,18,18,19,25,26,0,24}, space = 15 },
{ content = "2. 大对子   5分。", cards = {2,2,2,7,7,7,14,14,14,23,23,23,29,0,29}, space = 15 },
{ content = "3. 七对  10分。", cards = {1,1,4,4,7,16,16,18,18,24,24,27,27,0,7}, space = 15 },
{ content = "4. 清一色   10分。", cards = {1,1,1,2,3,4,5,6,7,8,9,9,9,0,8}, space = 15 },
{ content = "5. 清大对   15分。", cards = {21,21,21,22,22,22,23,23,23,25,26,26,26,0,25}, space = 15 },
{ content = "6. 龙七对  20分。", cards = {1,1,1,2,2,4,4,21,21,22,22,24,24,0,1}, space = 15 },
{ content = "7. 清七对  20分。", cards = {11,11,13,13,14,14,16,16,17,17,18,19,19,0,18}, space = 15 },
{ content = "8. 清龙七对  30分。", cards = {21,21,24,24,25,25,26,26,28,28,29,29,29,0,29}, space = 15 },

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
8.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。
11.首圈鸡：同一个玩家第二次出牌前打出的幺鸡为首圈鸡，计3分。若该玩家未上听，则赔付上听玩家3分。责任鸡分数不变。（首圈鸡是特殊情况的冲锋鸡）
12.银鸡：抓到一筒或一万时，计2分（注：如果选择翻牌鸡，则是翻到牌为九筒或九万，翻牌鸡为一筒或一万时为银鸡；如果是摇摆鸡，则翻到九筒或九万或二筒或二万时，摇摆鸡为一筒或一万时为银鸡；如果选择是本鸡，则是翻牌鸡或摇摆鸡抓到一筒或一万，为银鸡]]},

{ title = "(五) 黄庄查叫"},
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，有玩家叫牌，有玩家不叫牌。不叫牌玩家需要给叫牌玩家按牌型分别支付分值。]]
}},

GAME_TYPE_PAODEKUAI = {
{ title = "(一) 基本规则："},
{ content = [[1.游戏人数：2-3人。
2.所有玩家自成一组，首先将手牌出完者获胜。
3.牌数：一副牌的游戏去掉大小王，3个2,1个A后，发48张牌，每人16张，2人局只发32张。
4.本游戏的牌点由大到小排列为：2、A、K、Q、J、10、9、8、7、6、5、4、3；
5.出牌过程：先手方首先出牌，玩家可以出一张牌，也可以出几张牌，只要是正确的牌型就可以了；游戏者依次轮流出牌，后一家打出的牌必须比前一家打出的牌大，如没有可以选择不要；直到一方出完为止。]]},

{ title = "(二) 特殊规则"},
{ content = [[1.全关加倍：如果有人出去时，输家一张牌都没出，要输手中剩余牌数16*2分。
2.有牌必压：能管上必须管，操作中只有提示和出牌，不能选择不要。
3.报单必顶：有人报单，上家如出单牌必须出最大的牌，不能选择不要。]]},

{ title = "(三) 牌形介绍"},
{ content = [[单张：可以是手中的任意一张牌；
对子：两张牌点相同的牌，两张牌的花色可以不同；
连对：两对或两对以上相连的牌，如：33 44，99 88；
三同张，三张牌点相同的牌，三张牌的花色可以不同；
三带一：三张相同点数的牌带一张点数不同的单牌，如：QQQ5
三代二：三张相同点数的牌，带两张点数相同的牌，如：QQQ55
顺子：五张或五张以上牌点连续的牌，花色不限。例如：3、4、5、6、7、8、9、10、J、Q、K等。注意：A、2在构成顺子时，可以A、2、3、4、5或9、10、J、Q、K、A，而不能组成J、Q、K、A、2、3这样的顺子；
飞机：两顺或以上+相同数量的对牌或单张或不加牌]]},

{ title = "(四) 结算"},
{ content = [[当有一名玩家出完牌后牌局结束。
1.手中仅剩一张牌的牌数分不出不进，但炸弹依旧会算分。
2.赢家：赢所有输家的分
3.输家：剩余牌数
4.全关：剩余牌数*2
5.炸弹：10分/个]]},
},

GAME_TYPE_R_LIANGDING = {
{ title = " 两丁一房" },
{ content = [[在贵阳捉鸡规则基础上去掉万和筒，只有“条”共36张牌，起手庄家八张牌，闲家7张牌，胡牌更迅速，紧张刺激！！！]]},

{ title = "(一) 牌型：" },
{ content = "1. 平胡，1分。", cards = {17,18,18,18,19,25,26,0,24}, space = 15},

{ title = "(二) 特殊规则如下："},
{ content = [[1.自摸加1分。
2.杠开（杠上开花），杠牌玩家额外收取其他玩家3分。
3.热炮（杠上炮），在胡牌牌形基础上加3分，杠牌后打出一张牌给其他玩家点炮，无豆平胡可胡。（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效）
4.抢杠，杠牌玩家额外赔付胡牌者9分，（杠牌者手中加分的鸡和豆全部烧掉，要赔付的仍然生效），无豆平胡可胡。
5.报听胡牌：分为硬报和软报两种。摸到第一张牌就自摸，此为硬报，结算时每家额外收取20分，不计牌型番数以及自摸番数；摸到第一张牌后听牌（接下来不能换牌、杠牌），此为软报，结算时每家额外收取10分。
6.过胡：若玩家在可以吃胡其他玩家时选择放弃，在其下一次出牌前，不能再吃胡其他玩家的牌。软报过吃胡后，只能自摸胡牌。
7.地胡：闲家在第一轮接炮胡牌，可无豆平胡，计10分. ]]},

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
7.摇摆鸡：翻牌的顺位+1和-1的两张牌都为鸡。
8.满堂鸡：所有打出的鸡和手中的鸡都参与最终结算。
9.吹风鸡：翻鸡翻开的是5筒时为吹风机，此局所有玩家的鸡全部作废。
10.星期鸡：当天的星期数（1至7）对应数字的万条筒（1至7）的牌也为鸡。
11.首圈鸡：同一个玩家第二次出牌前打出的幺鸡为首圈鸡，计3分。若该玩家未上听，则赔付上听玩家3分。责任鸡分数不变。（首圈鸡是特殊情况的冲锋鸡）
12.银鸡：拿到一筒或一万时，计2分（注：如果选择翻牌鸡，则是抓到牌为九筒或九万，翻牌鸡为一筒或一万时为银鸡；如果是摇摆鸡，则抓到九筒或九万或二筒或二万时，摇摆鸡为一筒或一万时为银鸡；如果选择是本鸡，则是翻牌鸡或摇摆鸡抓到一筒或一万，为银鸡]]},

{ title = "(五) 黄庄查叫" },
{ content = [[所有牌都被摸完之后，没有玩家胡牌为“黄庄”。黄庄后所有的豆、鸡都不计分。此时需要所有玩家开牌确定叫牌情况。
查牌后，无人叫牌或所有玩家都叫牌，则各家无输赢，庄家连庄。
查牌后，部分玩家叫牌。未叫牌玩家需要赔付给叫牌玩家牌型对应的分数。]]},

{ title = "(六) 通三" },
{ content = [[胡牌规则与贵阳捉鸡一致，自摸无加分，分数如下：
1. 平胡/自摸	3分
关于“豆”的规则与贵阳捉鸡一致，分值如下：
1. 闷豆		3分
2. 明豆		3分
3. 转弯豆		3分
关于“鸡”的规则与贵阳捉鸡一致，分值如下：
1. 普通鸡		1分
2. 金鸡			2分
3. 冲锋鸡		3分
4. 冲锋乌骨		4分
5. 冲锋金鸡		6分
6. 责任鸡		1分]]},
},

}