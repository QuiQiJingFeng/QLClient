local ns = namespace("config")
local propConfig = require("app.config.PropConfig")
local LuckyDrawConfig = class("LuckyDrawConfig")
ns.LuckyDrawConfig = LuckyDrawConfig;
LuckyDrawConfig.soundConfig = {
	Sound_Begin = "sound/SFX/Choujiang/run_begin.mp3",
	Sound_End = "sound/SFX/Choujiang/run_over.mp3",
	Sound_Run1 = "sound/SFX/Choujiang/run1.mp3",
	Sound_Run2 = "sound/SFX/Choujiang/run2.mp3",
	Sound_GetItem = "sound/SFX/Choujiang/getitem.mp3",
	Sound_TenEnd = "sound/SFX/Choujiang/victory.mp3",
}
LuckyDrawConfig.moneyConfig = {
	[251658241] = {"金豆", "art/menu/icon_Bean.png"},
	[251658242] = {"房卡", "art/menu/img_34.png"},
	[251658243] = {"金币", "art/gold/icon_1.png.png"},
}
LuckyDrawConfig.itemConfig = {
	{'iPhoneX','art/function/icon_iphoneX.png',0},
	{'小米电视','art/function/icon_tv.png', 0.21},
	{'金条','art/function/icon_pieceofgold.png', 0.21},
	{'888元红包','art/function/icon_888yhb.png', 0.76},
	{'20元红包','art/function/icon_20yhb.png', 0.76},
	{'10元红包','art/function/icon_10yhb.png', 0.76},
	{'8元红包','art/function/icon_8yhb.png', 0.76},
	{'5元红包','art/function/icon_5yhb.png', 0.76},
	{'2元红包','art/function/icon_2yhb.png', 0.76},
	{'1元红包','art/function/icon_1yhb.png', 0.76},
	{'666张房卡','art/function/icon_fk666.png', 0.76},
	{'20张房卡','art/function/icon_fk20.png', 0.76},
	{'10张房卡','art/function/icon_fk10.png', 0.76},
	{'5张房卡','art/function/icon_fk5.png', 0.76},
	{'2张房卡','art/function/icon_fk2.png', 0.76},
	{'1张房卡','art/function/icon_fk1.png', 0.76},
	{'10张参赛券','art/function/icon_sqX10.png', 0.76},
	{'2张参赛券','art/function/icon_sqX2.png', 0.76},
	{'1张参赛券','art/function/icon_sqX1.png', 0.76},
	{'1000张礼券','art/function/icon_lq1000.png', 0.76},
	{'600礼券','art/function/icon_lq600.png', 0.76},
	{'100礼券','art/function/icon_lq100.png', 0.76},
	{'20礼券','art/function/icon_lq20.png', 0.76},
	{'10张礼券','art/function/icon_lq10.png', 0.76},
	{'头像框','art/function/icon_frameicon.png', 0.76},
	{'头像框1','art/function/icon_frameicon.png', 0.76},
	{'头像框2','art/function/icon_frameicon.png', 0.76},
	{'38888金币','art/function/icon_38888.png', 0.76},
	{'28888金币','art/function/icon_28888.png', 0.76},
	{'18888金币','art/function/icon_18888.png', 0.76},
	{'8888金币','art/function/icon_8888.png', 0.76},
	{'5000金币','art/function/icon_gold5000.png', 0.76},
	{'2000金币','art/function/icon_gold2000.png', 0.76},
	{'1000金币','art/function/icon_1000.png', 0.76},		
}

LuckyDrawConfig.imageMoneyConfig ={
	[1] = 'art/clubDesc/ckfk2.png',
	[2] = 'art/clubDesc/ckfk1.png'
}
LuckyDrawConfig.rule = '1. 消耗5张房卡或25金豆即可摇奖一次，消耗45张房卡或225金豆即可进行十连摇；\n2. 连续进行十次摇奖，抽中奖品可在抽奖框中出现；\n3. 抽中虚拟货币类奖品（例如金币、房卡等）时，奖品自动发放至个人账户；\n4. 抽中红包类奖品，可在官方微信myqhd2017中查看领取；\n5. 抽中实物类大奖时，需要您填写个人信息和收货地址，我们会根据地址为您发放奖品；\n6. 消耗的房卡和金豆不可退回，请各位用户知晓。'

LuckyDrawConfig.strTeachBefore = '欢迎光临摇奖大世界~我是聚友小助手，期待您来很久了，现送上免费抽奖一次，试试点击“摇一摇”按钮，看看有什么惊喜发生吧！'

LuckyDrawConfig.strTeachAfter = '恭喜你！你获得了%s！奖品会发送至您的账户，悄悄告诉您，奖品发放途径可以通过右上角“活动说明”查看哦，现在开始游戏吧！'
--昵称
LuckyDrawConfig.names = {
	"尹。潇","梁正","刘元香","红颜为君醉","悦葶","蓓俪芙","小贝壳。","陶陶陶艺","小八","Lu","甜","红尘中遇见你","以麻为主","BEESpring rainWSC","、浮华沧桑","家有娇妻","郭超","wy","YYY","患难见真情","熊林","冯桂圆","淼","血月","守护心","启发18685316648","AAA希望明天会更好","Misx","wyx","露露","过客","雨雨妹","A贵州金源顺达工程有限公司","郑艳眉眼唇中草药美容","L","彭彭","Murphy.","嗯","方","~阿虎","徐抱抱","专业汽车贷款18212929916","A-di","李桃","下","发条青蛙","王霞","默然","▲tqing ai","荣","陸","Jack Sparrow","梦梦","未来有晚","蜕变 *","风铃","周浪","刘刘","前任","宸洛","总有刁民想害爱妃","小毅哥","胖猪","远帆","二少","冷女","冷暖自知","_嘟嘟~","a","Marcello","北北北北北 ì","team","子龙千金","迷路的小孩","几木","杨陶","玲玲","つ微凉徒眸意浅挚半","橙橙好","Alary","简芳","周西亮－一面湖水","风雨同舟","电风扇","阿尔泰.小贱","卖洋芋的格格巫","老公","张骏","蟑螂叫小强。","wly","无法模仿的伤","小李飞刀","欢欢","杨大侠","瀿澕荿僦奢澕","Fjgbkgvkkj","筱頗絯","〈语过添情〉","忠华","十指紧扣...","李代群","LS","回忆","杰","胡涂","baby","巧乐滋","守护的狼","指尖上的幸福","飞人","瞎胡闹","何去何从","wind","惠惠","蔣先生","实现","一个梦一个人","寒寒","伝辰","迷！","某某某","期刊论文发表-刘伟","久久","采生人","荟","秀","苦笑","不戒","华哥依旧","嗯哼jiao香姐","老陈","甜甜圈","勿忘","但是我没有8","苦行僧","默然","周诗锜","比尔盖天*","默念","hf","娜","幸福人","z","biu！","平平淡淡","女丑","娜","MISS","一帘幽梦","追梦无悔","保持沉默","听风","wpy","洋洋","u","jiangli","Saint","浅色！！！","levo","无所谓","刘梨","会","小飞哥","阿亮","金太子造型","雨溪","久久","绝处逢身","姚小姐","郎慧","hsl","Zz煜","故事里的事","A-金六福珠宝 张素","^_^0^_^","权","飞飞","找回自我","姚赖赖","彩虹","有你就好",
	"红鹦鹉","@来自何方情归何处","Ai这么远那么近","九哥","既然青春留不住","翟礼长","Mary","阿欣护肤品专卖","Javin Yang","张红","龙继忠","丰息","王先森","不败便好","彤彤","尚瑞家居装饰","HSG","Marlboro冰","钟娟","天道酬勤","无敌小银锤","末","77777777","何骏","诗诺璇","加油o(^_^)o朋友","敏敏","黔龙","办理资格证18608586789","刘兰","春芳","白天不懂夜的黑","骑驴找马追鹿鹿.","桐桐-","乡下仔","健康快乐毎一天","koala","红","小华","Y~JH","谢安娜13595005609","米虫","怡．然","EFM","胡","yuxi","茶飘香","悦己·小泡泡","静若繁花*","仅此","站在墙头等红颜","忘","许三多","无奈的人生","支丹","西井。","biubiubiu～","A-贵州高速广告","A毕节汽车电子电路维修","卢梦君","罗可萱","微微","媳妇别闹","微笑 感染嘴角的苦涩","闹够了没有","风停了，云知道","南呱呱","金秀","meng","贝贝","日久生情","张坤","恋恋不舍","Zhang y","梦想","A_丫头","黑匣子","小喜歌","北方的狼","红玫瑰","ALOONG雷龙","～倩～","目标导向","伊人","叶祥胜","祥子","珍惜","还爱","123","阿杜","小马哥13--1--1","老酒与老友。","昱晓","AAA为人民服务","找","小情绪","三三","猫吃鱼，一场游戏一个梦","雪儿，擁有的幸福誰都代替不了","啊丹","磊子","Z先生","杨","相知相惜","曾锋","哟嘿","安德露青蛙","A三生三世，十里桃花","Me","Faker","半睡丶半醒丶半朦胧","嫄儿","海海海","平","全部都是套路","w、x、g","纳呢","柠檬","杨丽金典女装零售批发，招代理","lina","佳慧","任欣欣","沫然","天下","大了蕊","阿健","Y","furong","hi朱小妹、","回忆虽美，终究是梦。","阳光宝贝 丽莎","A雪雪雪","雪花满天飞","Song TY.","赵锐","人生ン如茶灬","惠子","六马村","玉凤","潘国霞","燕子","Baby.","嚎","实实","沫小鹏.","Y_Y","第三者的第三者","zhang渐渐","东方","Little lucky"}
--奖品
LuckyDrawConfig.prizes = {
	"iPhoneX","小米电视","288元红包","88元红包","小米电视","格力空调","188元红包","88元红包","格力空调","88元红包","iPhoneX","88元红包","小米电视","288元红包","格力空调","格力空调","88元红包","188元红包","88元红包","小米电视","格力空调","88元红包","288元红包","iPhoneX","格力空调","88元红包","小米电视","288元红包","88元红包","小米电视","格力空调","188元红包","88元红包","格力空调","88元红包","iPhoneX","88元红包","小米电视","288元红包","格力空调","格力空调","88元红包","188元红包","88元红包","小米电视","格力空调","88元红包"
}
local prizeStr = {}
local idx = 1
function LuckyDrawConfig.getImagePath(name)
	for _,item in pairs(LuckyDrawConfig.itemConfig) do
		if item[1] == name then
			return item[2]
		end
	end
	return "art/function/icon_xjhb.png"
end

function LuckyDrawConfig.getPrizeStr()
	local j = math.ceil(#LuckyDrawConfig.prizes * math.random())
	while #prizeStr < 5 do
		local i = math.ceil(#LuckyDrawConfig.names * math.random())		
		local n = (j+#prizeStr)%(#LuckyDrawConfig.prizes) + 1
		-- local str = "恭喜"..LuckyDrawConfig.names[i].."获得"..LuckyDrawConfig.prizes[n]
		local obj = {name = LuckyDrawConfig.names[i], prize = LuckyDrawConfig.prizes[n]}
		table.insert(prizeStr, obj)
	end
	local n = idx
	idx = idx >= 5 and 1 or idx+1
	return prizeStr[n]
end

function LuckyDrawConfig.getItemById(id)
	for _,t in pairs(propConfig) do
		if tonumber(t.id) == id then
			return t
		end
	end
end