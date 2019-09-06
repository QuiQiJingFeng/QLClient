--[[    各种常量配置
]]
local ns_constants = namespace("share.constants")

local help_key = "Show_Share_Help"
ns_constants.HELP_KEY = help_key



local enters = {                -- 分享入口
	HALL					= "HALL",                   -- 大厅分享
	ROOM_INFO			= "ROOM_INFO",              -- 房间信息
	CLUB_ROOM_INFO		= "CLUB_ROOM_INFO",			--俱乐部房间信息
	FINAL_REPORT			= "FINAL_REPORT",           -- 总结算
	TIMEOUT				= "TIMEOUT",                -- 超时
	REPLAY				= "REPLAY",                 -- 回放
	CAMPAIGN				= "CAMPAIGN",               -- 比赛相关
	CLUB_RED_ACTIVITY	= "CLUB_RED_ACTIVITY",      -- 俱乐部红包分享
	CLUB_REWARD_ACTIVITY	= "CLUB_REWARD_ACTIVITY",   -- 俱乐部获奖分享
	SHARE_RECALL			= "SHARE_RECALL",           -- 分享送红包
	MONEY_TREE			= "MONEY_TREE",             -- 摇钱树
	DAILY_SHARE			= "DAILY_SHARE",            -- 每日分享
	TURN_CARD_SHARE		= "TURN_CARD_SHARE",        -- 翻牌活动分享
	TURN_CARD_ITEM_SHARE	= "TURN_CARD_ITEM_SHARE",   -- 翻牌中奖分享
	SHARE_GET_GOLD_ANDROID = "SHARE_GET_GOLD_ANDROID",-- share node by system only
	SHARE_GET_GOLD_IOS = "SHARE_GET_GOLD_IOS",-- share url by wechat friends only
	SHARE_PULLNEW = "SHARE_PULLNEW", -- 拉新分享
	SYSTEM_SCREEN_SHOT	= "SYSTEM_SCREEN_SHOT", -- 统一的 SYSTEM_SCREEN_SHOT 分享 
	WEEK_SIGN			= "WEEK_SIGN",          --七日登录
	NEW_SHARE_FRIEND		= "NEW_SHARE_FRIEND",   -- 新邀请到好友
	NEW_SHARE_CIRCLE		= "NEW_SHARE_CIRCLE",   -- 新邀请到好友圈
    CLUB_INVITED_FRIENDS    = "CLUB_INVITED_FRIENDS", -- 俱乐部微信邀请好友
	CLUB_INVITED_MOMENTS    = "CLUB_INVITED_MOMENTS", -- 俱乐部朋友圈邀请好友
    LEADER_BOARD_SHARE    = "LEADER_BOARD_SHARE", -- 俱乐部排行榜
	COMEBACK = "COMEBACK", -- 回流邀请用户
	ACTIVITY_FOR_SCREEN_SHOT = "ACTIVITY_FOR_SCREEN_SHOT", 	--截图活动分享
    OPEN_REDPACKAGE         = "OPEN_REDPACKAGE",         --拆红包活动
	SPRING_INVITED          = "SPRING_INVITED",          -- 春节邀新活动
	SHARE_COLLECTION		= "SHARE_COLLECTION",		-- 春节集赞活动
	COLLECT_CODE            = "COLLECT_CODE",            -- 集码活动
	NIAN_BAO				= "NIAN_BAO",
	OFFLINE_ROOM_INFO		= "OFFLINE_ROOM_INFO", -- 离线邀请
}
ns_constants.ENTER = enters

local channels = {                      -- 分享渠道(出口)
	FRIENDS	= "FRIENDS",         -- 好友
	MOMENTS	= "MOMENTS",         -- 票圈
	SYSTEM	= "SYSTEM",         -- 系统分享    
	DINGDING	= "DINGDING",        -- 钉钉分享
	SYSTEM_FRIENDCIRCLE = "SYSTEM_FRIENDCIRCLE",    --系统分享直接到好友圈
	SYSTEM_TOFRIENDS = "SYSTEM_TOFRIENDS",      --系统分享直接到好友
}
ns_constants.CHANNEL = channels

local channelIdxs = {                   -- 渠道index
	FRIENDS	= 1,        -- 好友
	MOMENTS	= 2,        -- 票圈
	SYSTEM	= 3,        -- 系统分享
	DINGDING	= 4,         -- 钉钉分享
	SYSTEM_FRIENDCIRCLE = 5,    --系统分享到好友圈
	SYSTEM_TOFRIENDS = 6,       --系统分享
}
ns_constants.CHANNELIDX = channelIdxs

local imgHelp = {
    android = {
        [1] = "art/img/img_jiaocheng1.png"
    },
    ios = {
        [1] = "art/img/img_jiaocheng2.png",
        [2] = "art/img/img_jiaocheng3.png",
        [3] = "art/img/img_jiaocheng4.png",
    }
    
}
ns_constants.imgHelp = imgHelp

local forms = {              -- 形式
	--[[        连接形式
        需要传入的数据: data = {
            url = 分享出去的东西,
            shareInfo = 分享标题,(非必须)
            shareContent = 分享内容,(非必须)
            shareIcon = 分享icon(非必须)
        }
    ]]
	URL					= "URL",
	--[[        大厅特殊连接
        需要传入的数据: data = {
            enter = 入口--根据配置生成短链,
            shareInfo = 分享标题,(非必须)
            shareContent = 分享内容,(非必须)
            shareIcon = 分享icon(非必须)
        }
    ]]
	SPECIAL_URL			= "SPECIAL_URL",
	--[[        配置好的短链
        需要传入的数据: data = {
            enter = 入口--根据配置生成短链,
            shareInfo = 分享标题,(非必须)
            shareContent = 分享内容,(非必须)
            shareIcon = 分享icon(非必须)
        }
    ]]
	SHORT_URL			= "SHORT_URL",
	--[[        截图
        需要传入的数据: data = {
            shareInfo = 分享标题,(非必须)
        }
    ]]
	SCREEN_SHOT			= "SCREEN_SHOT",
	--[[        带logo的截图
        需要传入的数据: data = {
            shareInfo = 分享标题,(非必须)
        }
    ]]
	SCREEN_SHOT_WITH_LOGO = "SCREEN_SHOT_WITH_LOGO",
	--[[        某个node
        需要传入的数据: data = {
            shareInfo = 分享标题,(非必须)
            其他的就很灵活了，根据要创建的node所需传
        }
    ]]
	NODE					= "NODE"
}
ns_constants.FORM = forms

--[[    分享配置，从/res/config/shareConfig.l里读取
]]
local ns_config = namespace("share.config")
ns_config.url_QRCode ={
  other = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/other.png",
  room = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/room.png",
  activity = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/activity.png",
  campaign = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/campaign.png",
  hall = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/hall.png",
  gold = "http://share-image.qcloud.cdn.majiang01.com/qrcode/tr/20190731/gold.png"
}
local str = json.encode(ns_config.url_QRCode)

local t = cc.FileUtils:getInstance():getStringFromFile("config/shareConfig.l")
local lconfig = loadstring(t)()

--[[    这个是每个地区的分享行为的配置
        第一级是地区，有个default默认
            第二级是入口，哪里调起的分享
                第三季是行为数组，告诉在这个入口里，包含几个分享行为
                每个行为是由渠道+形式组成的
]]
local behavior = lconfig.behavior

-- 特殊行动进行拆分判断
local function removeUnConditonalBehavior(result)
	--如果没有绑定钉钉则去掉钉钉分享
	if not game.service.LocalPlayerService:getInstance():getIsBindDingTalk() then
		table.arrayFilter(result, function(v)
			return not string.find(v, "DINGDING")
		end)
	end
end

-- 根据入口判断分享的具体行为
ns_config.getBehavior = function(enter, default)
	if Macro.assertTrue(table.keyof(enters, enter) == nil) then
		-- 入口没找到分享个寂寞
		return nil
	end
	-- 获取地区id，有些奇奇怪怪的地区总喜欢干奇奇怪怪的事情！！！！！
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	
	-- 先找到对应的cfg，找不到就10002
	-- local _cfg = behavior['10002']
	-- if not default then
	--     _cfg = behavior['' .. areaId] ~= nil and behavior["".. areaId] or behavior['10002']
	-- end
	local _cfg =(not default and behavior["" .. areaId]) and behavior["" .. areaId] or behavior["10002"]
	
	-- 再找具体行为，如果在自己的地区找不到，就去10002里找
	local result = clone(_cfg[enter] or behavior['10002'] [enter])
	removeUnConditonalBehavior(result)
	
	return result
end




-- 短链配置
local shortUrls = lconfig.shortUrls

ns_config.getShortUrl = function(enter, channel)
	if Macro.assertTrue(table.keyof(enters, enter) == nil) then
		-- 入口没找到分享个寂寞(默认)
		return shortUrls['10002'] ['default']
	end
	local name = string.format("%s_%s", enter, channel);
	-- 获取地区id，有些奇奇怪怪的地区总喜欢干奇奇怪怪的事情！！！！！
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	
	-- 先找到对应的cfg，找不到就用贵阳的
	local _cfg = shortUrls[areaId] or shortUrls['10002']
	
	-- 再找具体url，如果在自己的地区找不到，就去default里找
	local result = _cfg[name] or shortUrls['10002'] [name]
	
	-- 如果这也找不到，就用默认的(大厅票圈)
	result = result or shortUrls['10002'] ['default']
	
	return result
end


-- 各种图片配置
local shareImagesPath = lconfig.shareImagesPath

ns_config.getShareImg = function(enter, ext, channel)
	if Macro.assertTrue(table.keyof(enters, enter) == nil) then
		-- 入口没找到分享个寂寞
		return nil
	end
	channel = channel or "common"
	channel = string.lower(channel)
	-- 获取地区id，有些奇奇怪怪的地区总喜欢干奇奇怪怪的事情！！！！！
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	
	-- 先找到对应的path，找不到就用贵阳的
	local path = shareImagesPath[tostring(areaId)] or shareImagesPath['10002']
	
	local filePath = string.format("%s/%s/%s.%s", path, enter, channel, ext)
	
	return filePath
end



ns_config.getQRCodeUrl = function(str)
	return ns_config.url_QRCode[str] or ""
end 

ns_config.getAllQRCodeImages = function()
	for _, v in pairs(ns_config.url_QRCode) do
		manager.RemoteFileManager.getInstance():getRemoteFile("playericon", v, function() end)
	end
end

local mode = {
	Normal = 'normal',  --以前的模式，体验模式
	Safe = 'safe',      --安全模式
}
-- 根据版本号和设备号获取分享方法
local currentMode = mode.Normal

local function getCurrentMode()
	-- return currentModelocal v = game.service.LocalPlayerService.getInstance():getBtnValue()
	local btnValue = game.service.LocalPlayerService.getInstance():getBtnValue()
	local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst

	-- self:_changeButtonVisibleState(self._btnNianbao, bit.band(v, buttonConst.NIAN_BAO) ~= 0) 
	local v = bit.band(btnValue, buttonConst.SHARE_TYPE)
	if v == 0 then
		return mode.Normal
	else
		return mode.Safe
	end
end

local function getEnableMoreShare()
	return game.service.GlobalSetting.getInstance().enableMoreShare
end
--安卓分享到好友
local function getAndroidShareFriends()
	if getCurrentMode() == mode.Normal then
		--休闲模式，直接拉起原本的微信分享
		return channels.FRIENDS
	elseif kod.VersionHelper.smallerThanVersion("4.4.1") then
		--4.4以下版本
		return channels.FRIENDS
	elseif kod.VersionHelper.smallerThanVersion("4.6.0") then
		--4.4< v <=4.6,调系统手动
		return channels.SYSTEM
	else
		-- >4.6,调系统指定到好友
		return channels.SYSTEM_TOFRIENDS
	end		
end
--安卓分享到朋友圈
local function getAndroidShareMoments()
	if kod.VersionHelper.smallerThanVersion("4.6.0") then
		return channels.SYSTEM
	else
		return channels.SYSTEM_FRIENDCIRCLE
	end
end
--ios分享到好友
local function getIOSShareFriends()
	if getCurrentMode() == mode.Normal or kod.VersionHelper.smallerThanVersion("4.4.0") then
		return channels.FRIENDS
	else
		return channels.SYSTEM
	end
end
--ios分享到好友圈
local function getIOSShareMoments()
	return channels.SYSTEM
end

local function getIOSShareSystem(...)
	if kod.VersionHelper.smallerThanVersion("4.4.1") then
		--4.4以下版本
		return channels.FRIENDS
	else
		if getEnableMoreShare() == true then
			-- 开启更多分享开关则用系统分享
			return channels.SYSTEM
		elseif getCurrentMode() == mode.Normal then
			return channels.FRIENDS
		else
			return channels.SYSTEM
		end
	end
end

-- 安卓牌桌内分享
local function getAndroidShareSystem(...)
	if kod.VersionHelper.smallerThanVersion("4.4.1") then
		--4.4以下版本
		return channels.FRIENDS
	elseif kod.VersionHelper.smallerThanVersion("4.6.0") then
		if getEnableMoreShare() == true then
			-- 开启更多分享开关则用系统分享
			return channels.SYSTEM
		elseif getCurrentMode() == mode.Normal then
			return channels.FRIENDS
		else
			return channels.SYSTEM
		end
	else
		-- >4.6,调系统指定到好友
		if getEnableMoreShare() == true then
			-- 开启更多分享开关则用系统分享
			return channels.SYSTEM
		else
			return channels.SYSTEM_TOFRIENDS
		end
	end		
end

ns_constants.getShareChannel = function(channel)
	-- if device.platform == "windows" then
	-- 	return channel
	-- end
	if channel ~= channels.FRIENDS and channel ~= channels.MOMENTS and channel ~= channels.SYSTEM then
		return channel
	end
	if device.platform == "ios" then
		if channel == channels.FRIENDS then
			return getIOSShareFriends()
		elseif channel == channels.MOMENTS then
			return getIOSShareMoments()
		else
			return getIOSShareSystem()
		end		
	else
		if channel == channels.FRIENDS then
			return getAndroidShareFriends()
		elseif channel == channels.MOMENTS then
			return getAndroidShareMoments()
		else
			return getAndroidShareSystem()
		end
	end
end 
