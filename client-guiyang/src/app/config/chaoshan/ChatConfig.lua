--------------------- 
-- 语音配置文件
-- 多语言
---------------------
local ns = namespace("config")
-- 获得对应方言的方言文字
local Constants = require("app.gameMode.mahjong.core.Constants")

local ChatConfig = class("ChatConfig")
ns.ChatConfig = ChatConfig;

--[[ 方言类型  NORMAL与LOCAL不用动，其他的自己随意配置
 * 当只有一门方言的时候，是LOCAL，两门级以上，自己定义，LOCAL就用不到了,但是不要删除
 * 如果没有方言，则CONST为1，其他情况，CONST都为2
 * 扩展的话，在NORMAL 跟 COUNT 之间插入就可以，记得改COUNT 值
--]]
ChatConfig.DialectType = {
	NORMAL 		= 0,
	JIEYANG 	= 1,
	CHAOZHOU 	= 2,
	SHANTOU 	= 3,
	SHANWEI 	= 4,
	PUNING 		= 5,
	HUILAI 		= 6,
	JIEXI 		= 7,
	COUNT 		= 8,
	ZHENGSHANGYOU = 9,
}

--[[
 * 说明：
 * soundPath：当前单效路径，不要直接使用SFX
 * textArray：常用语的文字，显示在界面上可以选择的显示，现在textArray可以直接复制，同一地区的
 * voiceArray：常用语的语音，对应在播放文字的时候播放的语音
 * notice：textArray，voiceArray数目要一致
 * 这里配置的是闲话的显示，其它碰杠信息，以及牌值，没有在这里配置
 * 具体在Constants.ts中，不建议去改，最后是同名放置就可以了
--]]
local config = {}
-- 普通话
-- 现在资源路径已经删除，用着的时候，自己配置
config[ChatConfig.DialectType.NORMAL] = {
	name = "普通话",

	soundPath = {
		[Constants.GenderType.Male] = "sound/SFX_ChaoShan_PuTong/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_PuTong/Woman/chat/",
	},

	sfxPath = "sound/SFX_ChaoShan_PuTong/",

	textArray = {
		"快点出牌啦", "快点啦，用不用我帮你打？", "打张牌给我碰嘛", "唉，这手气也是没谁了", "套路好深呐！", "给我来张好牌", "等我一下，马上回来", "你的牌也太好了吧"
	},

	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}
-- 本条目结束，到这里是完整一个地区的配置

-- 揭阳话
config[ChatConfig.DialectType.JIEYANG] = {
	name = "揭阳话",

	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_JieYang/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_JieYang/Woman/chat/",
	},

	sfxPath = "sound/SFX_ChaoShan_JieYang/",

	textArray = {
		"猛者，着去拜下老爷咩？", "啊你踏卡车是浪险死是咩", "恁有听够钱声咧咧叫有无", "副牌摸起来到甜甜", "我打局派派个客宁看呐", "牌照凹，矮卖个拿错恁个", "嗒做个客宁酸米参宁酸哪", "停下停下，马上回来"
	},

	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  潮州话
config[ChatConfig.DialectType.CHAOZHOU] = {
	name = "潮州话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_ChaoZhou/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_ChaoZhou/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_ChaoZhou/",
	textArray = {
		"好猛么，你么稳过载卵？", "猛哇，粥熟哇？", "通街市想无", "尚，过尚", "兴到爱输哈无变啊", "唔知做尼拍", "短涨，副牌么过奥", "且慢，我速速住来"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  汕头话
config[ChatConfig.DialectType.SHANTOU] = {
	name = "汕头话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_ShanTou/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_ShanTou/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_ShanTou/",
	textArray = {
		"猛呐，咔着去问下老爷", "猛哇，无踢你去老人组哇", "块牌过优秀", "哇，这牌好漂亮", "这副牌就够烈啊", "副牌好做作十三幺佬", "全看无花字个", "等我一下，即时回来"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  汕尾话
config[ChatConfig.DialectType.SHANWEI] = {
	name = "汕尾话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_ShanWei/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_ShanWei/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_ShanWei/",
	textArray = {
		"快点啊，我还要回去煮饭", "快点行不行，我老婆喊我回去洗衣服呢", "钱都送到我手上来了", "这副牌也太好了", "我打盘好牌给你们看", "这牌都可以丢掉了", "不跟你们玩了，我去睡觉了。", "等我一下，马上回来。"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  普宁话
config[ChatConfig.DialectType.PUNING] = {
	name = "普宁话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_PuNing/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_PuNing/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_PuNing/",
	textArray = {
		"猛下，用去拜下伯公用免", "啊你搭卡车是浪险是啊", "恁有听够钱声咧咧叫有无", "副牌摸起来耍卖莫", "我物局如个客恁看", "副香凹，个矮拿混啊卖", "担做趟下挂掂多掺恁刀热", "停下哈，既时返来"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  惠来话
config[ChatConfig.DialectType.HUILAI] = {
	name = "惠来话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_HuiLai/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_HuiLai/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_HuiLai/",
	textArray = {
		"担猛呐，着去拜下老爷是咩？", "啊你踏卡车是浪险死是咩", "宁有听着钱声咧咧叫无", "副牌摸起来到甜甜", "我物局派派个客宁看呐", "副牌照臭，是米客恁拟混去？", "嗒今日是个该恁挼有挼无个住着啊", "停下停下，马上回来"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

--  揭西话
config[ChatConfig.DialectType.JIEXI] = {
	name = "揭西话",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_ChaoShan_JieXi/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_ChaoShan_JieXi/Woman/chat/",
	},
	sfxPath = "sound/SFX_ChaoShan_JieXi/",
	textArray = {
		"赶紧出牌啊", "等你出牌公鸡都叫了", "这副牌好正", "等着钱来了", "出牌小心点，这牌太好了", "哎，牌这么差，要怎么打？", "哎，牌差到都不想看了", "等等，马上回来继续"
	},
	voiceArray = {
		"xianhua1.mp3", "xianhua2.mp3", "xianhua3.mp3", "xianhua4.mp3", "xianhua5.mp3", "xianhua6.mp3", "xianhua7.mp3", "xianhua8.mp3"
	},
}

-- 争上游
config[ChatConfig.DialectType.ZHENGSHANGYOU] = {
	name = "争上游",
	soundPath = {
		[Constants.GenderType.Male]	  = "sound/SFX_Paodekuai/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_Paodekuai/Woman/chat/",
	},
	sfxPath = "sound/SFX_Paodekuai/",
	textArray = {
		"合作愉快", "您的牌打得也忒好了", "后见，有要紧事要离开一下", "不好意思，网络太差了~", "你再不快点，花都谢了"
	},
	voiceArray = {
		"gladCooperate.mp3", "goodJob.mp3", "littleLeave.mp3", "netBad.mp3", "quick.mp3"
	},
}


-- 当前地区的默认选择语言
ChatConfig.defaultDialect = ChatConfig.DialectType.NORMAL

-- @param dialect: number
-- @return string[]
ChatConfig.getTextArray = function(dialect)
	-- 争上游是特有的语言，其他麻将不能通用，因此这边对争上游特殊处理
	local gameType = Constants.SpecialEvents.gameType
	if gameType ~= "GAME_TYPE_ZHENGSHANGYOU" and dialect == ChatConfig.DialectType.ZHENGSHANGYOU then
		dialect = ChatConfig.DialectType.NORMAL
	end
	return config[dialect].textArray;
end

-- @param dialect: number
-- @return string
ChatConfig.getPath = function(dialect, gender)
	if gender == Constants.GenderType.InValid then
		-- 检查gender参数
		Logger.error("Invalid gender type:,%d",gender);
		gender = Constants.GenderType.Male;
	end

	return config[dialect].soundPath[gender];
end

-- 获取特效文件所在路径（打牌的声效文件）
-- @param dialect: number
-- @return string
ChatConfig.getSFXPath = function(dialect)
	return config[dialect].sfxPath;
end

-- @param dialect: number
-- @return string
ChatConfig.getVoiceArray = function(dialect)
	return config[dialect].voiceArray;
end

-- 获得对应方言的方言文字
-- @param index: number
-- @return string
ChatConfig.getLocalTextList = function(index)
	return localTextList[index];
end

-- 获取当前方言的所有地区名字，以及对应的变量
ChatConfig.getLocalNames = function()
	local names = {}
	local enums = {}
	-- 从第一个方言可始遍历，将方言的名字生成一个列表，返回
	for i=ChatConfig.DialectType.NORMAL+1,ChatConfig.DialectType.COUNT-1 do
		if config[i].name ~= nil then
			table.insert(names, config[i].name)
			table.insert(enums, i)
		end
	end

	return names, enums
end

-- 获取当前对应方言的所有配置
ChatConfig.getLocalConfig = function(dialect)
	return config[dialect]
end