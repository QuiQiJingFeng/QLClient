-- 使用namespace，在globalrequire里只require一次，防止有些可能的问题出现
local MultiArea = namespace("MultiArea")

local RoomSetting = config.GlobalConfig.getRoomSetting()
local Constants	= require("app.gameMode.mahjong.core.Constants")
local areas = config.GlobalConfig.AREAS

local _areaconfig = {}
local _registCommandFuns = {}
local _registReplayCommandFuns = {}
local _registRuleTypeFuns = {}
local _registForbidPlayFuns = {}
local _getGameUICfg = {}

for i, area in ipairs(areas) do
    local id = area.id
    local name = area.name
    local config = require("app.gameMode.mahjong.region.config." .. name)
    _areaconfig[id] = config.gameType
    _registCommandFuns[id] = config.registCommands
    _registReplayCommandFuns[id] = config.registReplayCommands
    _registRuleTypeFuns[id] = config.registRuleType
    _registForbidPlayFuns[id] = config.registForbidPlay
    _getGameUICfg[id] = config.getGameUI
    -- 添加roomsetting
    for j, setting in ipairs(config.roomSettings) do
        table.insert( RoomSetting.GAME_TYPE_SETTING, setting )
    end
    -- 添加ui
    if config.UIConfig then
        local UI_CONFIG = require("app.define.UIConfig")
        table.merge(UI_CONFIG,config.UIConfig)
    end
    --添加CommonEvents
    Constants.CommonEvents[area.id] = config.commonEvents
end

------------- functions ----------------
-- 获取对应地区的分享文字
local _getShareMessage = function(areaId)
	local shareMessage = {}
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.shareMsg
		end
	end
	return ""
end

-- 获取对应地区战绩分享开关
local _getShareRecord = function(areaId)
	local shareMessage = {}
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.shareRecord
		end
	end
	return ""
end

-- 获取对应地区的CLUB帮助信息
local _getClubHelpTxt = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.clubHelpTxt
		end
	end
	return ""
end

-- 获取对应地区的分享图片
local _getShareImg = function (areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.shareImg
		end
	end

	-- 如果没有配默认分享贵阳的
	return "art/guiyang"
end

-- 获取对应地区的分享图片
local _getBusinessUrl = function (areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.businessUrl
		end
	end

	-- 如果没有配默认分享贵阳的
	return ""
end

-- 获取对应地区的game types
local _getGameTypeKeys = function(areaId)
	local gametypes = {}
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			for i, tv in ipairs(v.gameTypes) do
				gametypes[#gametypes + 1] = tv.id
			end
		end
	end
	return gametypes
end

-- 获取对应地图的gameType配置
-- return map 字典，键值为gameType
local _getGameTypeMap = function(areaId)
	local map = {}
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			for i, tv in ipairs(v.gameTypes) do
				map[tv.id] = tv
			end
		end
	end
	return map
end

-- 检查当前areaid是否显示
local _checkAreaId = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return true
		end
	end
	return false
end

-- 获取地区玩法
local _getRuleType = function(areaId)
	local ruleTypes = {}
	for k, v in pairs(_registRuleTypeFuns) do
		if k == areaId then
			table.insert(ruleTypes, v)
		end
	end
	return ruleTypes
end

-- 获取地区亲友圈禁用玩法
local _getForbidPlay = function(areaId)
	local forbidPlay = {}
	for k, v in pairs(_registForbidPlayFuns) do
		if k == areaId then
			table.insert(forbidPlay, v)
		end
	end
	
	return forbidPlay
end

-- 获取地区微信号
local _getWeChat = function(areaId)
	local shareMessage = {}
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.weChat
		end
	end
	return ""
end

-- 获取地区公众号
local _getNoPublic = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.noPublic
		end
	end
	return ""
end

-- 获取某个ui的name
-- uiType定义在constants.lua里
local _getGameUI = function(areaId, gamePlay, uiType)
	for k, v in pairs(_getGameUICfg) do
		if k == areaId then
			return v and v(gamePlay, uiType) or nil
		end
	end
	return nil
end

local _getZhuoJiCatcherCost = function(areaId)
	local areaConfig = _areaconfig[areaId]
	if areaConfig then
		local catcherCost = areaConfig.catcherCost
		if catcherCost then
			return catcherCost
		end
	end
	return 1
end

--获取主界面UI
local _getMainUI = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.mainButtons
		end
	end
	return require("app.gameMode.mahjong.region.config.guizhou.guiyang").gameType.mainButtons
end

-- 获取解散房间原因列表配置
local _getReasonForm = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.reasonForm
		end
	end

	return {}
end

MultiArea.getReasonForm = _getReasonForm

MultiArea.getGameUI = _getGameUI

MultiArea.getWeChat = _getWeChat

MultiArea.getNoPublic = _getNoPublic

MultiArea.getForbidPlay = _getForbidPlay

MultiArea.getRuleType = _getRuleType

MultiArea.getGameTypeKeys = _getGameTypeKeys

MultiArea.getShareMessage = _getShareMessage

MultiArea.getGameTypeMap = _getGameTypeMap

MultiArea.getClubHelpTxt = _getClubHelpTxt

MultiArea.checkAreaId = _checkAreaId

MultiArea.getShareRecord = _getShareRecord

MultiArea.getZhuoJiCatcherCost = _getZhuoJiCatcherCost

MultiArea.getShareImg = _getShareImg

MultiArea.getBusinessUrl = _getBusinessUrl

MultiArea.getMainUI = _getMainUI

-- 注册命令
local _registCommands = function(areaId, gamePlay)
	Macro.assertTrue(gamePlay == nil or gamePlay == "")
	return _registCommandFuns[areaId](gamePlay)
end

MultiArea.registCommands = _registCommands

-- 注册回放命令
local _registReplayCommands = function(areaId, gamePlay)
	Macro.assertTrue(gamePlay == nil or gamePlay == "")
	return _registReplayCommandFuns[areaId](gamePlay)
end

MultiArea.registReplayCommands = _registReplayCommands

-- 获取地区分享短链
local _getShareShortUrl = function(areaId)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v.shareShortUrl
		end
	end

	-- 如果没有配默认分享贵阳的
	return _areaconfig[10002].shareShortUrl
end

MultiArea.getShareShortUrl = _getShareShortUrl

--新增
--地区配置里面的_gameType经常被获取,单独提出一个函数
local function getGameTypeConfig(areaId , id)
	for k, v in pairs(_areaconfig) do
		if k == areaId then
			return v[id]
		end
	end
	return require("app.gameMode.mahjong.region.config.guizhou.guiyang").gameType[id] -- 找不到就返回贵阳的
end

local _getRoundType = function ( areaId )
	return getGameTypeConfig(areaId , "roundType")
end

local _getRoomCost = function ( areaId )
	return getGameTypeConfig(areaId , "roomCost")
end

local _getIsShowRuleBox = function ( areaId )
	return getGameTypeConfig(areaId , "isShowRuleBox")
end

local _getPlayerSceneBgImg = function ( areaId )
	return getGameTypeConfig(areaId , "playerSceneBgImg")
end

local _getSafeNotices = function ( areaId )
	return getGameTypeConfig(areaId , "safeNotices")
end

local _getHuAnis = function ( areaId )
	return getGameTypeConfig(areaId , "HuAnis")
end

MultiArea.getRoundType = _getRoundType
MultiArea.getRoomCost = _getRoomCost
MultiArea.getIsShowRuleBox = _getIsShowRuleBox
MultiArea.getPlayerSceneBgImg = _getPlayerSceneBgImg
MultiArea.getSafeNotices = _getSafeNotices
MultiArea.getHuAnis = _getHuAnis
MultiArea.getConfigByKey = function(key)
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    if Macro.assertFalse(type(areaId) == 'number' and type(key) == 'string' and key ~= "", string.format('error areaId or key, areaId:[%s] key:[%s]', areaId, key))then
        local _config = getGameTypeConfig(areaId, key)
        if Macro.assertFalse(_config, string.format('get config by areaId failed, AreaId:[%s], key:[%s]', tostring(areaId), tostring(key))) then
            return _config
        end
    end
end

return MultiArea
