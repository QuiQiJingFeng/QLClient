--[[
本地玩家数据存储模块
EVENT : {name = "TABLE_BACKGROUND_CHANGED", value = ""}
EVENT : {name = "CARD_BACKGROUND_CHANGED", value = ""}
--]]
local ns = namespace("game.service")

local BaseLocalData = require("app.kod.data.BaseLocalData")

local PlayerSettingVersion = 1
local PlayerSetting = class("PlayerSetting", BaseLocalData)
function PlayerSetting:ctor()
    BaseLocalData:ctor()
    self.tableBackgound = 1
    
	-- 牌面选择
    self.card_BG_index = 1
    self.effectTable = {
        -- 碰杠提示
        effect_PengGangTiShi = false,
        -- 出牌提示
        effect_ChuPaiTiShi = false,
        -- 出牌停留
        effect_ChuPaiTingLiu = false,
        -- 斜插牌
        effect_XieChaPai = false,
        -- 魔法表情开关
        effect_Expression = true,
        -- 俱乐部离线推送
        effect_ClubPush = false,
        -- 推送开关
	    -- effect_TuiSongKaiGuan = false -- 该信息存储在 PushService中
    }

    -- 多地方使用，数字定义吧 1 基本的双击出牌 2 单击出牌
    self.clickType = 1

    -- 魔法表情提示
    self.isExpression = false
end

function PlayerSetting:upgrade()
    self.__ver = PlayerSettingVersion
    self.tableBackgound = 1
	-- 牌面选择
    self.card_BG_index = 1
end

-- 处理玩家数据相关逻辑
local LocalPlayerSettingService = class("LocalPlayerSettingService")
ns.LocalPlayerSettingService = LocalPlayerSettingService

-- 单例支持
-- @return LoginService
function LocalPlayerSettingService:getInstance()
    return game.service.LocalPlayerService.getInstance():getLocalPlayerSettingService()
end

function LocalPlayerSettingService:ctor()
    cc.bind(self, "event");    
    self._playerSetting = nil
end

function LocalPlayerSettingService:initialize()
    -- self:loadLocalStorage()
end

function LocalPlayerSettingService:dispose()
    cc.unbind(self, "event");
end

function LocalPlayerSettingService:loadLocalStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    self._playerSetting = manager.LocalStorage.getUserDataWithVersion(roleId, "LocalPlayerSetting", PlayerSetting, PlayerSettingVersion);
end

function LocalPlayerSettingService:_saveLocalStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    manager.LocalStorage.setUserData(roleId, "LocalPlayerSetting", self._playerSetting);
end

-- 各项设置打点
function LocalPlayerSettingService:_updateDataEye()
    -- 统计玩家是否开了出牌放大
	local effectChuPaiFangDaTriggle = self:getEffectValues().effect_ChuPaiTingLiu
	if effectChuPaiFangDaTriggle then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.discard_stay_on);
	else
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.discard_stay_off);
    end
    
    -- 统计单击出牌
    if self._playerSetting.clickType == 2 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_discard_on);
    else
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_discard_off);
    end

    -- 统计桌布
    local desktop = self:getTableBackgound() 
    if desktop == 1 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.desktop_classical);
    elseif desktop == 2 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.desktop_eyeProtectionGreen);
    else
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.desktop_bluenavy);
    end

    local cardBg = self:getCardBackgound()
    if cardBg == 1 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_cardblue);
    elseif cardBg == 2 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_cardgreen);
    elseif cardBg == 3 then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_cardbrown);
    end

    local is3D = game.service.GlobalSetting.getInstance().is3D
    if is3D then 
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_is3D_on);
    else
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_is3D_off);
    end

    local isClassic = game.service.GlobalSetting.getInstance().isClassic
    if isClassic then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_classic_on);
    else
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.setting_classic_off);
    end
    --更多分享
    if game.service.GlobalSetting.getInstance().enableMoreShare then
        game.service.DataEyeService.getInstance():onEvent("MoreShareSettingClick_on")
    else
        game.service.DataEyeService.getInstance():onEvent("MoreShareSettingClick_off")
    end
    -- 互动表情
    if self:getEffectValues().effect_Expression then
        game.service.DataEyeService.getInstance():onEvent("ExpressionSettingClick_on")
    else
        game.service.DataEyeService.getInstance():onEvent("ExpressionSettingClick_off")
    end
    -- 俱乐部离线推送
    if self:getEffectValues().effect_ClubPush then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.clubPushSettingClick_on)
    else
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.clubPushSettingClick_off)
    end
end

-- 获取自定义桌布
function LocalPlayerSettingService:getTableBackgound()
    return self._playerSetting.tableBackgound;
end

function LocalPlayerSettingService:getCardBackgound()
    return self._playerSetting.card_BG_index;
end

-- 设置自定义桌布
function LocalPlayerSettingService:setTableBackgound(value)
    if Macro.assertTrue(value == nil) then return end
    
    if self._playerSetting.tableBackgound == value then
        -- 不用重复设置
        return
    end

    self._playerSetting.tableBackgound = value;
    self:_saveLocalStorage();

    self:dispatchEvent({name = "TABLE_BACKGROUND_CHANGED", value = value}); -- 这个event并没有人监听

    game.service.DataEyeService.getInstance():onStatusEvent("CustomTable", "CustomTable_"..value)
end

-- 获取自定义桌布
function LocalPlayerSettingService:getClickType()
    return self._playerSetting.clickType;
end

-- 设置自定义桌布
function LocalPlayerSettingService:setClickType(value)
    if Macro.assertTrue(value == nil) then return end
    
    if self._playerSetting.clickType == value then
        -- 不用重复设置
        return
    end

    self._playerSetting.clickType = value;
    self:_saveLocalStorage();
    self:dispatchEvent({name = "GAME_CLICK_TYPE_CHANGED", value = value})
    game.service.DataEyeService.getInstance():onStatusEvent("ClickType", "ClickType_"..value)
end

function LocalPlayerSettingService:setCardBackgound(value)
    if Macro.assertTrue(value == nil) then return end
    if self._playerSetting.card_BG_index == value then
        -- 不用重复设置
        return
    end

    self._playerSetting.card_BG_index = value;
    self:_saveLocalStorage();
    CardFactory:getInstance():setCardStyle(value)
    -- self:dispatchEvent({name = "CARD_BACKGROUND_CHANGED", value = value})
    game.service.DataEyeService.getInstance():onStatusEvent("CustomCard", "CustomCard_"..value)
end

function LocalPlayerSettingService:getEffectValues()
    return self._playerSetting.effectTable
end

-- @param t:table 要修改的effect数据组成的表
-- 如果t中的键在effectTable中不存在的话会报错
function LocalPlayerSettingService:setEffectValues(t)
    local effectTable = self._playerSetting.effectTable
    for k, v in pairs(t) do
        effectTable[k] = t[k]
        if k == "effect_ClubPush" then
            -- 发给服务器俱乐部离线推送状态
            game.service.club.ClubService.getInstance():getClubRoomService():sendCCLUpdateOfflineInvitedSwitchREQ(t[k] and 1 or 0)
        end
    end
end

function LocalPlayerSettingService:getIsExpression()
    return self._playerSetting.isExpression
end

function LocalPlayerSettingService:setIsExpression(tf)
    self._playerSetting.isExpression = tf
end

-- 难道重复设置会影响性能？
function LocalPlayerSettingService:saveSetting()
    self:_saveLocalStorage()
end