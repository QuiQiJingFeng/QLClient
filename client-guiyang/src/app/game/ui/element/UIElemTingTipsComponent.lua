--[[
    听牌提示/自动胡牌按钮组件
]]
local CD_TIME = 1

local csbPath = "ui/csb/ui_component/TingTipsBtnComponent.csb"
local UIElemTingTipsComponent = class("UIElemTingTipsComponent", function() return kod.LoadCSBNode(csbPath) end)
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local RoomSetting = config.GlobalConfig.getRoomSetting()

function UIElemTingTipsComponent:ctor(root)
    root:addChild(self)
    self._animAction = nil

    -- 关闭计时器
	if self._timerTask ~= nil then
		unscheduleOnce(self._timerTask);
    end
    self._timerTask = nil;
    self._isInCd = false

    self:setScale(1.3)

    self._btnAutoDiscard = seekNodeByName(self, "Button_AutoDiscard", "ccui.Button")
    self._btnCancleAuto = seekNodeByName(self, "Button_AutoCancle", "ccui.Button")
    self._btnDisplayTing = seekNodeByName(self, "Button_cardTips", "ccui.Button")

    game.service.RoomService.getInstance():addEventListener("DISPLAY_TING_HELP_BTN",    handler(self, self._setDisplay), self)
    game.service.RoomService.getInstance():addEventListener("ENTER_TIANTING_STATUS",    handler(self, self.disableAutoBtn), self)
    game.service.RoomService.getInstance():addEventListener("ENTER_STOP_ROBOT",    handler(self, self._onStopRobot), self)
    game.service.RoomService.getInstance():addEventListener("TING_DISABLE_ALL",    handler(self, self.disableAll), self)
    bindEventCallBack(self._btnDisplayTing, handler(self, self._onClickBtnDisplayTing), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnAutoDiscard, handler(self, self._onClickAutoDiscard), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnCancleAuto, handler(self, self._onClickCancleAuto), ccui.TouchEventType.ended);

    self:setAutoDiscard(false)

    self:setVisible(false)    

    -- 有些玩法需要关闭
    self._cantOpenRobot = false
    if game.service.RoomService:getInstance() ~= nil then
        local rules = game.service.RoomService:getInstance():getGamePlays()
        table.foreach(rules,function (k,v)
            if v == RoomSetting.GamePlay.GAMEPLAY_MENHU then
                self._cantOpenRobot = true
            end
        end)
    end
end

function UIElemTingTipsComponent:dispose()
    	-- 关闭计时器
	if self._timerTask ~= nil then
		unscheduleOnce(self._timerTask);
		self._timerTask = nil;
    end
    self:setVisible(false)
    game.service.RoomService.getInstance():removeEventListenersByTag(self)
end

-- 自动胡牌开/关
function UIElemTingTipsComponent:setAutoDiscard(tf)
    if tolua.isnull(self) then 
        return 
    end

    if tf == true then
        self._animAction = cc.CSLoader:createTimeline(csbPath)
        self:runAction(self._animAction)
        self._animAction:play("animation0",true)
    end
    -- self._btnCancleAuto:setVisible(tf)
    -- self._btnAutoDiscard:setVisible(not tf)
    self._btnCancleAuto:setVisible(false)
    self._btnAutoDiscard:setVisible(false)
end

function UIElemTingTipsComponent:_onStopRobot()
    self._btnCancleAuto:setVisible(false)
    -- self._btnAutoDiscard:setVisible(true)
end

-- 关闭自动胡牌开关
function UIElemTingTipsComponent:disableAutoBtn()
    if tolua.isnull(self) then 
        return 
    end

    self._btnCancleAuto:setVisible(false)
    self._btnAutoDiscard:setVisible(false)
end

function UIElemTingTipsComponent:disableAll()
    -- 断线重连的时候，插件会释放掉，添加判定处理下
    if tolua.isnull(self) then 
        return 
    end 
    self:dispose()
end 

function UIElemTingTipsComponent:_setDisplay(event)
    -- 断线重连的时候，插件会释放掉，添加判定处理下
    if tolua.isnull(self) then 
        return 
    end 

    local playerProcessor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(CardDefines.Chair.Down)
    if playerProcessor == nil then 
        self:setVisible(false)
        return 
    end
    if event.display == true then
        if playerProcessor:getPlayerFsm():isState("PlayerState_TianTing") then
            self:disableAutoBtn()
        else
            self:setAutoDiscard(playerProcessor:getPlayerFsm():isState("PlayerState_AutoDiscard"))
        end
        self:setVisible(true)
    elseif playerProcessor:getPlayerFsm():isState("PlayerState_AutoDiscard") then
        self:setVisible(true)
        return
    else
        self:setVisible(false)
    end
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() or
        game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold or self._cantOpenRobot then
            self:disableAutoBtn()
    end
end

function UIElemTingTipsComponent:_onClickBtnDisplayTing()
    if tolua.isnull(self) then 
        return 
    end

    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local playerProcessor = gameService:getPlayerProcessorByChair(CardDefines.Chair.Down)
	
	if playerProcessor ~= nil then
		if playerProcessor:getSeatUI():switchCacheTips() == true then
			playerProcessor:getSeatUI():displayTingCards()
            gameService:getRoomUI():hideDiscardedCardIndicator()
            -- 统计点击听牌的次数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.OnClick_TingTipsBtn_new);				
		else
			gameService:getRoomUI():markDiscardedCardIndicator()
		end
    end
end

function UIElemTingTipsComponent:_onClickAutoDiscard()
    if tolua.isnull(self) then 
        return 
    end
    
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local playerProcessor = gameService:getPlayerProcessorByChair(CardDefines.Chair.Down)

    -- 如果是天听就关闭自己
    if playerProcessor:getPlayerFsm():isState("PlayerState_TianTing") then
        self:disableAutoBtn()
        return
    end

    if self._isInCd == true  then
        return 
    end
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if playerProcessor ~= nil then
        playerProcessor:getPlayerFsm():enterState("PlayerState_AutoDiscard")
        self:setAutoDiscard(true)
    end
    gameService:queryBOpenAutoHu(true)

    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Button_Auto_Hu_Click_new);
end

function UIElemTingTipsComponent:_onClickCancleAuto()
    if self._isInCd == true then
        return 
    end
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local playerProcessor = gameService:getPlayerProcessorByChair(CardDefines.Chair.Down)
    if playerProcessor ~= nil then
        playerProcessor:getPlayerFsm():enterState("PlayerState_Normal")
        self:setAutoDiscard(false)
    end
    gameService:queryBOpenAutoHu(false)

    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Button_Auto_Hu_Cancle_new);
end

function UIElemTingTipsComponent:_createCd()
    self._isInCd = true   
    self._timerTask = scheduleOnce(function ()
        self._isInCd = false     
    end,CD_TIME)
end

return UIElemTingTipsComponent