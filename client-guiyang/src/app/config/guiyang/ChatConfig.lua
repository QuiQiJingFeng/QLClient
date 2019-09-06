local ns = namespace("config")
local Constants = require("app.gameMode.mahjong.core.Constants")

local ChatConfig = class("ChatConfig")
ns.ChatConfig = ChatConfig;

--[[ 方言类型  NORMAL与LOCAL不用动，其他的自己随意配置
 * 当只有一门方言的时候，是LOCAL，两门级以上，自己定义，LOCAL就用不到了,但是不要删除
 * 如果没有方言，则CONST为1，其他情况，CONST都为2
 * 扩展的话，在NORMAL 跟 COUNT 之间插入就可以，记得改COUNT 值
--]]
ChatConfig.DialectType = {
	NORMAL = 0,
	LOCAL_GUIYANG = 1,
	PAODEKUAI = 2,
	COUNT = 3 -- 用不上，忽略他
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
		[Constants.GenderType.Male] = "sound/SFX/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX/Woman/chat/",
	},

	sfxPath = "sound/SFX/",

	textArray = {
		"打张牌给我碰嘛",
		"我这个牌硬是闯到鬼了",
		"麻将有首歌，上碰下自摸",
		"你弹簧手是不？快点出~",
		"菩萨菩萨，给我摸个咔咔",
		"想哭都哭不出来",
		"必须点个赞",
		-- "你的牌也太好了吧！", -- 贵阳没有这句话
		"套路好深哦",
	},

	voiceArray = {
		"xianhua1.mp3",
		"xianhua2.mp3",
		"xianhua3.mp3",
		"xianhua4.mp3",
		"xianhua5.mp3",
		"xianhua6.mp3",
		"xianhua7.mp3",
		"xianhua8.mp3",
	},
}
-- 本条目结束，到这里是完整一个地区的配置

-- 贵阳话
-- 现在只有特效不同，闲话的话，还是用原来的
config[ChatConfig.DialectType.LOCAL_GUIYANG] = {
	name = "贵阳话",

	soundPath = {
		[Constants.GenderType.Male] = "sound/SFX/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX/Woman/chat/",
	},

	sfxPath = "sound/SFX/",

	textArray = {
		"打张牌给我碰嘛",
		"我这个牌硬是闯到鬼了",
		"麻将有首歌，上碰下自摸",
		"你弹簧手是不？快点出~",
		"菩萨菩萨，给我摸个咔咔",
		"想哭都哭不出来",
		"必须点个赞",
		-- "你的牌也太好了吧！", -- 贵阳没有这句话
		"套路好深哦",
	},

	voiceArray = {
		"xianhua1.mp3",
		"xianhua2.mp3",
		"xianhua3.mp3",
		"xianhua4.mp3",
		"xianhua5.mp3",
		"xianhua6.mp3",
		"xianhua7.mp3",
		"xianhua8.mp3",
	},
}

config[ChatConfig.DialectType.PAODEKUAI] = {
	name = "内置-跑得快",
	soundPath = {
		[Constants.GenderType.Male] = "sound/SFX_Paodekuai/Man/chat/",
		[Constants.GenderType.Female] = "sound/SFX_Paodekuai/Woman/chat/",
	},

	-- sfxPath = "sound/SFX/",

	textArray = {
		"合作愉快",
		"您的牌打得也忒好了",
		"后见，有要紧事要离开下",
		"不好意思，网络太差了~",
		"你再不快点，花都谢了",
	},

	voiceArray = {
		"gladCooperate.mp3",
		"goodJob.mp3",
		"littleLeave.mp3",
		"netBad.mp3",
		"quick.mp3",
	},
}

-- 当前地区的默认选择语言
ChatConfig.defaultDialect = ChatConfig.DialectType.LOCAL_GUIYANG

-- @param dialect: number
-- @return string[]
ChatConfig.getTextArray = function(dialect)
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