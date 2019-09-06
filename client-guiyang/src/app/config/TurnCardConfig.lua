local ns = namespace("config")

local TurnCardConfig = class("TurnCardConfig")
ns.TurnCardConfig = TurnCardConfig;

TurnCardConfig.itemIds = {
	0x06000016,
	0x04000004,
	0x0F000002,
	0x0F000005,

	0x0F000003,
	0x0F000004,
	0x04000005,
	0x0F000007,
}

TurnCardConfig.itemConfig = {
	[1001] = {'iPhoneX', 'art/function/icon_iphoneX.png', 0},
	[2001] = {'小米电视', 'art/function/icon_tv.png', 0.21},
	[3001] = {'格力空调', 'art/function/icon_gl.png', 0.61},
	[4000] = {'现金红包', 'art/function/icon_xjhb.png', 0.76},
	[4001] = {'5元红包', 'art/function/icon_5yhb.png', 0.91},
	[4002] = {'2元红包', 'art/function/icon_2yhb.png', 0.94},
	[4003] = {'1元红包', 'art/function/icon_1yhb.png', 0.97},
	[5000] = {'房卡', 'art/function/icon_fk.png', 0.97},
	[5001] = {'房卡*1', 'art/function/icon_fkx1.png', 0.97},
	[6000] = {'礼券', 'art/function/icon_lq0.png', 1},
	[6001] = {'礼券*10', 'art/function/icon_lq10.png', 1},
	[6002] = {'礼券*50', 'art/function/icon_lq50.png', 1},
	[7000] = {'参赛券', 'art/function/icon_sq0.png', 1},
	[7001] = {'参赛券*1', 'art/function/icon_sqX1.png', 1},
	[8000] = {'金币', 'art/function/icon_gold.png', 0.76},
	[8001] = {'3000金币', 'art/function/icon_gold3000.png', 0.91},
	[8002] = {'1000金币', 'art/function/icon_gold1000.png', 0.94},
	[8003] = {'2000金币', 'art/function/icon_gold2000.png', 0.94},
}
TurnCardConfig.YearItem = {
	[1] = {"iPhone XS", 0.0002},
	[2] = {"小米电视", 0.0012},
	[3] = {"288元红包", 0.05},
	[4] = {"188元红包", 0.15},
	[5] = {"100元红包", 0.30},
	[6] = {"88元红包", 0.65},
	[7] = {"50元红包", 1.0}
}
--昵称
TurnCardConfig.names = {
	"悦葶", "蓓俪芙", "小贝壳。", "陶陶陶艺", "小八", "Lu", "甜",  "以麻为主", "BEESpring rainWSC", "、浮华沧桑", "家有娇妻", "郭超", "冯桂圆",  "血月", "守护心",  "Misx",  "露露", "雨雨妹",  "L", "彭彭", "Murphy.", "嗯", "方", "~阿虎", "徐抱抱",  "A-di", "李桃", "下",  "王霞", "默然", "tqing ai", "荣", "陸", "Jack Sparrow", "梦梦", "未来有晚", "蜕变 *", "风铃", "周浪", "刘刘", "前任", "宸洛", "总有刁民想害爱妃",  "胖猪", "远帆", "二少", "冷女", "冷暖自知", "_嘟嘟~", "a", "Marcello", "北北北北北", "team", "子龙千金", "迷路的小孩", "几木", "杨陶", "玲玲", "つ微凉徒眸意浅挚半", "橙橙好", "Alary", "简芳", "周西亮－一面湖水", "风雨同舟", "电风扇", "阿尔泰.小贱", "卖洋芋的格格巫", "老公", "张骏", "蟑螂叫小强。", "wly", "无法模仿的伤", "小李飞刀", "欢欢", "杨大侠", "瀿澕荿僦奢澕", "Fjgbkgvkkj", "筱頗絯", "〈语过添情〉", "忠华", "十指紧扣...", "李代群", "LS", "回忆", "杰", "胡涂",  "巧乐滋", "守护的狼", "指尖上的幸福", "飞人", "瞎胡闹", "何去何从", "wind", "惠惠", "蔣先生", "实现", "一个梦一个人", "寒寒", "伝辰", "迷！",  "久久", "采生人", "荟", "秀", "苦笑", "不戒", "华哥依旧", "嗯哼jiao香姐", "老陈", "甜甜圈", "勿忘", "但是我没有8", "苦行僧", "默然", "周诗锜", "比尔盖天*", "默念", "hf", "娜", "幸福人", "z", "biu！", "平平淡淡", "女丑", "娜", "MISS", "一帘幽梦", "追梦无悔", "保持沉默", "听风", "wpy",  "u", "jiangli", "Saint", "浅色！！！", "levo", "无所谓", "刘梨", "会", "小飞哥", "阿亮",  "雨溪", "久久", "绝处逢身", "姚小姐", "郎慧", "hsl", "Zz煜", "故事里的事",  "^_^0^_^", "权", "飞飞", "找回自我", "姚赖赖", "彩虹", "有你就好",
	"红鹦鹉",  "Ai这么远那么近", "九哥", "既然青春留不住", "翟礼长", "Mary", "阿欣护肤品专卖", "Javin Yang", "张红", "龙继忠", "丰息", "不败便好", "彤彤",  "HSG", "Marlboro冰", "钟娟", "天道酬勤", "无敌小银锤", "末", "77777777", "何骏", "诗诺璇", "加油o(^_^)o朋友", "敏敏", "黔龙", "刘兰", "春芳",  "骑驴找马追鹿鹿.", "桐桐", "乡下仔", "健康快乐毎一天", "koala", "红", "小华", "Y~JH",  "米虫", "怡然", "EFM", "胡", "yuxi", "茶飘香", "悦己小泡泡", "静若繁花*", "仅此", "站在墙头等红颜", "忘",  "无奈的人生", "支丹", "西井。", "biubiubiu～",   "卢梦君", "罗可萱", "微微", "媳妇别闹", "微笑 感染嘴角的苦涩", "闹够了没有", "风停了，云知道", "南呱呱", "金秀", "meng", "贝贝", "日久生情", "张坤", "恋恋不舍", "Zhang y", "梦想",  "黑匣子", "小喜歌",   "～倩～", "目标导向",  "叶祥胜", "祥子", "珍惜", "还爱", "123", "阿杜", "小马哥13--1--1", "老酒与老友。", "昱晓",  "找", "小情绪", "三三", "猫吃鱼，一场游戏一个梦", "擁有的幸福誰都代替不了", "啊丹", "磊子",  "相知相惜", "曾锋", "哟嘿",   "Me",  "半睡半醒半朦胧", "嫄儿", "海海海", "平", "全部都是套路", "w、x、g",  "柠檬",  "lina", "佳慧", "任欣欣", "沫然", "天下", "大了蕊", "阿健", "Y", "furong", "hi朱小妹", "回忆虽美，终究是梦。", "阳光宝贝 丽莎",  "雪花满天飞", "Song TY.", "赵锐", "人生ン如茶灬", "惠子", "六马村", "玉凤", "潘国霞", "燕子",  "嚎", "实实",  "zhang渐渐", "东方", "Little lucky", "初夏", "怀亦", "乐双", "红枼", "乘风", "我我我","Dear_", "阿楠", "小黑", "二零幺九", "whlanuo", "Mr.杨", "ss", "II Mostra", "落尘", "龙龙", "Ernest_Q", "Ninlgde", "胖毅毅", "良木", "八千里云与月", "久伴", "落", "dust", "金鱼怪", "森哥", "金下卫", "LBJ", "输掉链子的狗", "咔~咔", "Jarrod", "余生", "风魔", "大象", "fairy强"
}
--奖品
TurnCardConfig.prizes = {
	"iPhoneX", "小米电视", "288元红包", "88元红包", "88元红包", "格力空调", "188元红包", "88元红包", "格力空调", "88元红包", "88元红包", "小米电视", "288元红包", "格力空调", "88元红包", "88元红包", "188元红包", "88元红包", "小米电视", "88元红包", "88元红包", "288元红包", "格力空调", "88元红包", "小米电视", "288元红包", "88元红包", "小米电视", "88元红包", "188元红包", "88元红包", "格力空调", "88元红包", "iPhoneX", "88元红包", "小米电视", "288元红包", "88元红包", "88元红包", "88元红包", "188元红包", "88元红包", "小米电视", "格力空调", "88元红包", "288元红包", "格力空调", "88元红包", "小米电视", "288元红包", "88元红包", "小米电视", "格力空调", "188元红包", "88元红包", "88元红包", "88元红包", "iPhoneX", "88元红包", "小米电视", "288元红包", "格力空调", "88元红包", "88元红包", "188元红包", "88元红包", "88元红包", "格力空调", "88元红包", "288元红包", "88元红包", "88元红包", "小米电视", "288元红包", "88元红包", "小米电视", "88元红包", "188元红包", "88元红包", "格力空调", "88元红包", "iPhoneX", "88元红包", "88元红包", "288元红包", "格力空调", "88元红包", "188元红包", "88元红包", "88元红包", "格力空调", "88元红包", "288元红包", "iPhoneX", "格力空调", "88元红包", "小米电视", "288元红包", "88元红包", "88元红包", "格力空调", "188元红包", "88元红包", "格力空调", "88元红包", "88元红包", "小米电视", "288元红包", "88元红包", "格力空调", "88元红包", "188元红包", "88元红包", "88元红包", "格力空调", "88元红包", "288元红包", "iPhoneX", "88元红包", "88元红包", "小米电视", "288元红包", "88元红包", "88元红包", "88元红包", "188元红包", "88元红包"
}

--奖品
TurnCardConfig.prizes2 = {
	"20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "小米电视", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "iPhoneX", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包", "20元红包"
}
--砸蛋音效
TurnCardConfig.sound = "sound/SFX/Egg/sui.mp3"
local prizeStr = {}
local idx = 1
function TurnCardConfig.getImagePath(nId)
	if TurnCardConfig.itemConfig[nId] then
		return TurnCardConfig.itemConfig[nId] [2]
	end
	return ""
end

function TurnCardConfig.getPrizeStr()
	local j = math.ceil(#TurnCardConfig.prizes * math.random())
	while #prizeStr < 5 do
		local i = math.ceil(#TurnCardConfig.names * math.random())		
		local n =(j + #prizeStr) %(#TurnCardConfig.prizes) + 1
		-- local str = "恭喜"..TurnCardConfig.names[i].."获得"..TurnCardConfig.prizes[n]
		local obj = {name = TurnCardConfig.names[i], prize = TurnCardConfig.prizes[n]}
		table.insert(prizeStr, obj)
	end
	local n = idx
	idx = idx >= 5 and 1 or idx + 1
	return prizeStr[n]

end


function TurnCardConfig.getPrizeStr2()
	local j = math.ceil(#TurnCardConfig.prizes2 * math.random())
	while #prizeStr < 100 do
		local i = math.ceil(#TurnCardConfig.names * math.random())		
		local n =(j + #prizeStr) %(#TurnCardConfig.prizes2) + 1
		-- local str = "恭喜"..TurnCardConfig.names[i].."获得"..TurnCardConfig.prizes[n]
		local obj = {name = TurnCardConfig.names[i], prize = TurnCardConfig.prizes2[n]}
		table.insert(prizeStr, obj)
	end
	local n = idx
	idx = idx >= 100 and 1 or idx + 1
	return prizeStr[n]
end 


function TurnCardConfig:getYearStr()

	local ran = math.random()
	local name,prize
	name = TurnCardConfig.names[math.ceil(#TurnCardConfig.names * ran)]
	for i = 1,#TurnCardConfig.YearItem do
		if TurnCardConfig.YearItem[i][2] > ran then
			prize = TurnCardConfig.YearItem[i][1]
			break
		end
	end
	return {name = name , prize = prize}
end 

local nameidx = -1
function TurnCardConfig.getOneName()
	if nameidx == -1 then
		nameidx = math.ceil( #TurnCardConfig.names * math.random() )
	end
	nameidx = nameidx == #TurnCardConfig.names and 1 or nameidx+1
	return TurnCardConfig.names[nameidx]
end
