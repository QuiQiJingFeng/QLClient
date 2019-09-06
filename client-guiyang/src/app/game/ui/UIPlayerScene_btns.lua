local csbPath = "ui/csb/UIPlayerScene_btns.csb"
local super = require("app.game.ui.UIBase")
local UIRTVoiceComponent = require("app.game.ui.element.UIRTVoiceComponent")
local UIRuleboxComponent = require("app.game.ui.element.UIRuleBoxComponent")
local UIElemTingTipsComponent = require("app.game.ui.element.UIElemTingTipsComponent")
local UI_ANIM = require("app.manager.UIAnimManager")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local UIPlayerScene_btns = class("UIPlayerScene_btns", super, function() return kod.LoadCSBNode(csbPath) end)

function UIPlayerScene_btns:ctor()
	self._btnSetting = seekNodeByName(self, "Button_setting_Scene2", "ccui.Button");
	self._btnMessage = seekNodeByName(self, "Button_message_Scene2", "ccui.Button");
	self._btnTalk	= seekNodeByName(self, "Button_talk_Scene2", "ccui.Button");
	self._btnGiveup = seekNodeByName(self, "Button_Exit", "ccui.Button")
	
	self._checking		= seekNodeByName(self, "Button_1_2_Scene2",	"ccui.Button");
	self._danger		= seekNodeByName(self, "Button_2_2_Scene2",	"ccui.Button");
	self._safe			= seekNodeByName(self, "Button_3_2_Scene2",	"ccui.Button");
	self._Gps_Bay		= seekNodeByName(self, "Panel_2_Scene2",		"ccui.Layout");
	self._timeDelay		= seekNodeByName(self, "Button_yc_Scene",		"ccui.Button");
	self._campaignDetail = seekNodeByName(self, "Button_xq_Scene",		"ccui.Button");
	
	self._btnRedPacket = seekNodeByName(self, "Button_qhb",			"ccui.Button");
	self._particleRedPacket = seekNodeByName(self, "Particle_1",		"cc.ParticleSystemQuad")
	
	-- 金币场打牌送礼卷显示的面板
	self._panelGift = seekNodeByName(self, "panelGift", "ccui.Layout")
	self._bmTextGift1 = seekNodeByName(self, "bmTextGift1", "ccui.TextBMFont")
	self._bmTextGift2 = seekNodeByName(self, "bmTextGift2", "ccui.TextBMFont")

	-- 魔法表情提示
	self._imgExpressionTips = seekNodeByName(self, "Panel_qp", "ccui.Layout")
	self._imgExpressionTips:setVisible(false)
	
	-------------------------------------------------------------
	bindEventCallBack(self._btnSetting, handler(self, self._onClickSettingButton), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnMessage, handler(self, self._onClickMessageButton), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnTalk,	handler(self, self._btnSpeakClick))
	
	bindEventCallBack(self._checking,	handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);
	bindEventCallBack(self._safe,		handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);
	bindEventCallBack(self._danger,		handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);
	bindEventCallBack(self._timeDelay,	handler(self, self._onClickTimeDelay),	ccui.TouchEventType.ended);
	bindEventCallBack(self._campaignDetail,	handler(self, self._onClickCampaignDetail),	ccui.TouchEventType.ended);
	bindEventCallBack(self._btnGiveup,	handler(self, self._onClickGiveupCampaign),	ccui.TouchEventType.ended);
	
	bindEventCallBack(self._btnRedPacket,	handler(self, self._onClickRedPacket),	ccui.TouchEventType.ended);
	
	self._mousePositionY = 0
	self._imRecordCanceled = false;
	self._checkingAniPlaying = false;
	self._dangerAniPlaying = false;
end

function UIPlayerScene_btns:onShow(...)
	local args = {...};
	
	-- TODO:现在UI的生命周期要长于Service，所以提前创建，其相关的变化全部由自身来处理
	-- add component
	self._uiRTVoiceCmp = UIRTVoiceComponent.new(seekNodeByName(self, "Node_rt_voice", "cc.Node"));
	self._uiRuleBoxCmp = UIRuleboxComponent.new(seekNodeByName(self, "Node_rulebox", "cc.Node"))
	self._uiTingTipBtnCmp = UIElemTingTipsComponent.new(seekNodeByName(self, "Node_tingTipsBtn", "cc.Node"))
	
	--金币场送礼卷面板默认不显示
	self._panelGift:setVisible(false)
	
	-- 非比赛隐藏详情按钮
    self._campaignDetail:setVisible(false)
	self._btnGiveup:setVisible(false)    
	
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
		-- 如果这时候还在显示晋级动画则关闭之
		if UIManager:getInstance():getIsShowing("UICampaignPromotion") == true then
			UIManager:getInstance():destroy("UICampaignPromotion")
		end
		
		self:_changeUIForScene('campaign')
	elseif game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		self:_changeUIForScene('gold')
	else
		game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._showSecurityButton), self)
		-- 设置语音模式
		self:_setRTVoice(args[1])
		self._timeDelay:setVisible(true)
		game.service.RT_VoiceService.getInstance():prepareForMessage(args[1])
	end
	
	-- 提审隐藏计时器
	if GameMain.getInstance():isReviewVersion() then
		self._timeDelay:setVisible(false)
	end
	
	game.service.LoginService.getInstance():addEventListener("EVENT_USER_RELOGIN", handler(self, self._onUserRelogin), self)	
	game.service.CampaignService.getInstance():addEventListener("EVENT_CAMPAIGN_CHANGEUI", function()
		self:_changeUIForScene('campaign')
    end, self)
    game.service.CampaignService.getInstance():addEventListener("EVENT_CAMPAIGN_RANK_HIDE",    handler(self, self.onCampaignHideGiveup), self)
    game.service.CampaignService.getInstance():addEventListener("EVENT_CAMPAIGN_RANK_DISPLAY",    handler(self, self.onCampaignDisplayGiveup), self)
	game.service.club.ClubService.getInstance():getClubActivityService():addEventListener("EVENT_CLUB_REDPACKET_CHANGED", handler(self, self._onRedPacketChanged), self)
	game.service.ChatService.getInstance():addEventListener("SHOW_EXPRESSION_TIPS", function(event)
		self._imgExpressionTips:setVisible(event.isVisible)
	end, self)
	
	local clubId = game.service.RoomService:getInstance():getRoomClubId()
	local club = game.service.club.ClubService:getInstance():getClub(clubId)
	self._btnRedPacket:setVisible(false)
	if game.service.RoomService:getInstance():getRoomClubId() ~= 0 then
		if club then
			local show = false
			if club.data then
				show = club.data.hasActivity
				self._btnRedPacket:setVisible(show)
			end
			self._particleRedPacket:setVisible(show and club:isRedPacketChanged())
		end
	end
	
	local goldService = game.service.GoldService:getInstance()
	goldService:addEventListener("EVENT_GOLD_GIFT_INFO_RECEIVE", handler(self, self._showGiftInfo), self)	
	goldService:addEventListener("EVENT_GOLD_BATTLE_REWARD_GIFT_RECEIVE", handler(self, self._showGiftAnima), self)	
end

function UIPlayerScene_btns:onHide()
	self:_hideSecurityButton();
	
	ccs.ActionManagerEx:getInstance():releaseActions()
	game.service.LoginService.getInstance():removeEventListenersByTag(self)
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
	game.service.CampaignService.getInstance():removeEventListenersByTag(self)
	game.service.RoomService.getInstance():removeEventListenersByTag(self)
	game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
	game.service.GoldService:getInstance():removeEventListenersByTag(self)
	game.service.ChatService.getInstance():removeEventListenersByTag(self)

	-- 如果组件不删除，在重新创建的时候是会出问题的
	self._uiRTVoiceCmp:dispose()
	self._uiRTVoiceCmp = nil
	self._uiRuleBoxCmp:dispose()
	self._uiRuleBoxCmp = nil
	self._uiTingTipBtnCmp:dispose()
	self._uiTingTipBtnCmp = nil
	
	if self._redPacketAnim then
		UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
		self._redPacketAnim = nil
	end	
end

-- 比赛时，金币场时 隐藏UI
function UIPlayerScene_btns:_changeUIForScene(type)
	self._Gps_Bay:setVisible(false)
	self:_setRTVoice(false)
	self._btnTalk:setVisible(false)
	self._timeDelay:setVisible(false)
	if type == "campaign" then
		self._campaignDetail:setVisible(game.service.CampaignService.getInstance():getCampaignList():getCurrentCampaignId() ~= config.CampaignConfig.ARENA_ID)
        self._btnMessage:setVisible(false)
        if game.service.CampaignService.getInstance():getCampaignList():getCurrentCampaignId() == config.CampaignConfig.ARENA_ID
            and game.service.CampaignService.getInstance():getArenaService():getCurrentRound() > 1 then
            self._btnGiveup:setVisible(true)
        end
	elseif type == "gold" then
		--金币场吧中减少按钮,设置下坐标
		self._btnMessage:setPositionY(self._btnSetting:getPositionY() - 48)
	end
end

function UIPlayerScene_btns:_setRTVoice(tf)
	-- 联盟房间隐藏语音
	if game.service.RoomService:getInstance():getRoomLeagueId() ~= 0 then
		self._btnTalk:setVisible(false)
		self._uiRTVoiceCmp:setVisible(false)
		return
	end

	--提审相关（语音隐藏）
	if GameMain.getInstance():isReviewVersion() then
		self._btnTalk:setVisible(false)
		tf = false
	else
		self._btnTalk:setVisible(not tf)
	end
	
	self._uiRTVoiceCmp:setEnable(tf)
end

-- 多地区语音开关,先这样针对个别需求设置ui，等日后积累了很多这种需求时，再统一做成可配置的
function UIPlayerScene_btns:_isCurAreaSupportVoice()
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	if areaId == 10004 then -- 安顺
		return false;
	end
	return true
end

function UIPlayerScene_btns:_onClickSettingButton()
	-- TODO:如果在进入结算后，那么roomservice会释放掉
	-- 因为显示UISetting界面的时候，需要跟roomService来判断显示解散房间，还是不显示
	-- 所以如果RoomService为空的时候，就不再显示界面了
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign()
	or campaign.CampaignFSM.getInstance():isState("CampaignState_InCampaignWait") == true then
		UIManager:getInstance():show("UISetting", "campaign")
		--TODO:偷个懒金币场用和比赛场一样的设置,如果以后不合理重新规划下
	elseif game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		UIManager:getInstance():show("UISetting", "campaign")
	else
		UIManager:getInstance():show("UISetting", "battle")
	end
	game.service.LocalPlayerService:getInstance():dispatchEvent({name = "GAME_HIDE_TING_TIPS"})
end

function UIPlayerScene_btns:_onClickMessageButton()
	-- TODO 这种靠获取状态的方式不好 考虑其他方案
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign()
	or campaign.CampaignFSM.getInstance():isState("CampaignState_InCampaignWait") == true then
		UIManager:getInstance():show("UIChatPanel", "campaign")
		--TODO:偷个懒金币场用和比赛场一样的设置,如果以后不合理重新规划下
	elseif game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		UIManager:getInstance():show("UIChatPanel", "campaign")
	else
		UIManager:getInstance():show("UIChatPanel")
	end
end


-- 语音消息
function UIPlayerScene_btns:_btnSpeakClick(sender, event)
	if event == ccui.TouchEventType.began then
		if game.service.ChatService.getInstance():checkSendInterval() == false then
			game.ui.UIMessageTipsMgr.getInstance():showTips("发言间隔中，请稍后")
			return
		end
		
		-- 开始录音
		self._imRecordCanceled = false
		self._mousePositionY = 0
		
		game.service.RT_VoiceService.getInstance():startRecording();
		-- 显示录制界面
		UIManager:getInstance():show("UI_Talking", true)
	elseif event == ccui.TouchEventType.moved then
		-- 录音过程, 点击位置移动
		if self._imRecordCanceled == false then
			if 0 == self._mousePositionY then
				self._mousePositionY = sender:getTouchMovePosition().y
			end
			if sender:getTouchMovePosition().y - self._mousePositionY > 30 then
				-- 取消录制
				self._imRecordCanceled = true
				self._mousePositionY = 0;
				
				game.service.RT_VoiceService.getInstance():stopRecording(false);
				
				-- 显示录制取消界面
				UIManager:getInstance():hide("UI_Talking")
				UIManager:getInstance():show("UI_Talking", false)
			end
		end
	elseif event == ccui.TouchEventType.ended	then
		if self._imRecordCanceled == false then
			-- 发送语音
			self._imRecordCanceled = true
			self._mousePositionY = 0;
			game.service.RT_VoiceService.getInstance():stopRecording(true);
		--[[self._btnTalk:setEnabled(false)
			local _callFunc = cc.CallFunc:create(function () self._btnTalk:setEnabled(true) end)
			local _delayTime = cc.DelayTime:create(3)
			local _sequence = cc.Sequence:create(_delayTime,_callFunc)
			self._btnTalk:runAction(_sequence)--]]
		end
		
		UIManager:getInstance():hide("UI_Talking")
	elseif event == ccui.TouchEventType.canceled then
		if self._imRecordCanceled == false then
			-- 发送语音
			self._imRecordCanceled = true
			self._mousePositionY = 0;
			
			game.service.RT_VoiceService.getInstance():stopRecording(false);
		end
		
		UIManager:getInstance():hide("UI_Talking")
	end
end

-----------------------------------
-- GPS相关
function UIPlayerScene_btns:_showSecurityButton()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	-- 如果两个人的时候，不显示
	if gameService:getMaxPlayerCount() <= 2 then
		securityChecker:setEnable(false)
	end
	
	if securityChecker:isEnable() == false then
		self._Gps_Bay:setVisible(false)
		return
	end
	
	securityChecker:addEventListener("EVENT_SRCURITY_PLAYER_ENTERED", handler(self, self._onSecurityPlayerEntered), self)
	securityChecker:addEventListener("EVENT_SRCURITY_STATUS_CHANGED", handler(self, self._onSecurityStatusChanged), self)
	securityChecker:addEventListener("EVENT_SRCURITY_INFO_INITIALIZED", handler(self, self._onSecurityInfoInitialized), self)
	
	-- 同一个房间只播放一次检测动画
	if securityChecker:isFirstTimeCheck() then
		self:_showCheckingButton(true)
		securityChecker:setChecked()
	else
		self:_refreshSafeButtonState(false)
	end	
end

function UIPlayerScene_btns:_hideSecurityButton()
	-- TODO：此处强改BUG，在总结算后，因ROOM被销毁引起的BUG
	if game.service.LocalPlayerService.getInstance() and
	game.service.RoomCreatorService.getInstance() and
	game.service.RoomService.getInstance() then
		local securityChecker = game.service.RoomService.getInstance():getSecurityChecker()
		if securityChecker ~= nil and securityChecker:isEnable() then
			securityChecker:removeEventListenersByTag(self)
		end
	end
	-- 停止动画
	self._danger:unscheduleUpdate();
	self:stopAllActions()
end

function UIPlayerScene_btns:_showCheckingButton(playAni)
	--	Logger.debug("_showCheckingButton")
	self._checking:setVisible(true)	
	self._danger:setVisible(false)
	self._danger:unscheduleUpdate();
	self._dangerAniPlaying = false;	
	self._safe:setVisible(false);
	
	if playAni == true then
		--		Logger.debug("_showCheckingButton 1")
		-- 如果当前没有播放check动画, 播放动画
		if self._checkingAniPlaying == false then
			local _action = cc.CSLoader:createTimeline(csbPath)
			self:runAction(_action)
			_action:play("animation0", false)
			
			local speed = _action:getTimeSpeed()
			local startFrame = _action:getStartFrame()
			local endFrame = _action:getEndFrame()
			local frameNum = endFrame - startFrame
			local delay = 1 /(speed * 60) * frameNum
			local _callFunc = cc.CallFunc:create(function()
				_action:stop()
				self._checkingAniPlaying = false;
				
				-- 动画播放完成.
				self:_refreshSafeButtonState(true);
			end)
			
			local sequ = cc.Sequence:create(cc.DelayTime:create(delay), _callFunc)
			self:runAction(sequ)
			self._checkingAniPlaying = true;
		end	
	end	
end

function UIPlayerScene_btns:_refreshSafeButtonState(playAni)
	-- 因为UI的生存周期要比RoomService的生命周期要长，如果在房间解散后，触发这里，那么会报错，也没有执行的意义了，直接返回吧
	if game.service.RoomService.getInstance() == nil then
		return
	end
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	
	if securityChecker == nil then
		return
	end
	
	if securityChecker:isSafe() then
		if self._checkingAniPlaying then
			-- 当前正在检测播放动画, 等动画播放完成之后再更新
			return
		end
		
		-- 警告动画直接打断
		if securityChecker:getPlayerCount() > 1 then
			self:_showSafeButton();
		else
			self:_showCheckingButton(false);
		end		
	elseif self._checkingAniPlaying == false and self._dangerAniPlaying == false then
		-- 当前正在播放动画, 等动画播放完成之后再更新
		self:_showUnsafeButton(playAni);
	end
end

function UIPlayerScene_btns:_showUnsafeButton(playWarningAni)
	--	Logger.debug("_showUnsafeButton")
	if self._checkingAniPlaying == true then
		-- 不能打断Check动画
		return
	end
	
	--	Logger.debug("_showUnsafeButton 1")
	self._checking:setVisible(false)
	self._danger:setVisible(true)
	self._danger:setOpacity(145)
	self._safe:setVisible(false)
	
	-- 停止check动画
	-- 播放警告动画
	if playWarningAni == true and self._dangerAniPlaying == false then
		self._danger:setOpacity(145)
		local fademax = cc.FadeTo:create(0.5, 255)
		local fademin = cc.FadeTo:create(0.5, 145)
		local seq = cc.Sequence:create(fademax, fademin)
		local rep = cc.Repeat:create(seq, 3)
		self._danger:runAction(rep)
	end
end

function UIPlayerScene_btns:_showSafeButton()
	--	Logger.debug("_showSafeButton")
	if self._checkingAniPlaying == true then
		-- 不能打断Check动画
		return
	end
	
	--	Logger.debug("_showSafeButton 1")
	self._checking:setVisible(false)
	self._danger:setVisible(false)
	self._danger:unscheduleUpdate();
	self._dangerAniPlaying = false;
	self._safe:setVisible(true)
end

function UIPlayerScene_btns:_onClickShowGps(sender)
	-- TODO:同设置按钮，只有当RoomService有效的时候，才显示
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	local serviceName = gameService.class.__cname;
	if game.service.RoomService:getInstance() ~= nil then
		if serviceName == "GameService_Paodekuai" or serviceName == "GameService_PaodekuaiReplay" then
			-- 跑的快，仍旧用旧的GPS
			UIManager:getInstance():show("UIGps")
		else
			UIManager:getInstance():show("UIGpsNew")
		end
	end
	game.service.TDGameAnalyticsService.getInstance():onEvent("CLICKED_GPS")
end

function UIPlayerScene_btns:_onSecurityPlayerEntered(event)
	Logger.debug("UIPlayerScene_btns(EVENT_SRCURITY_PLAYER_ENTERED)")
	-- 有用户进入, 播放检测动画
	self:_showCheckingButton(true);
end

function UIPlayerScene_btns:_onSecurityStatusChanged(event)
	Logger.debug("UIPlayerScene_btns(EVENT_SRCURITY_STATUS_CHANGED)")
	if game.service.RoomService.getInstance():isHaveBeginFirstGame() then
		-- 开局之后不放动画
		self:_refreshSafeButtonState(false);
	else
		-- 开局之前播放动画
		self:_refreshSafeButtonState(true);
	end
end

function UIPlayerScene_btns:_onSecurityInfoInitialized(event)
	Logger.debug("UIPlayerScene_btns(EVENT_SRCURITY_INFO_INITIALIZED)")
	self:_refreshSafeButtonState(false);
end

function UIPlayerScene_btns:_onClickTimeDelay()
	if game.service.RoomService:getInstance() then
		game.service.RoomService:getInstance():queryPlayerOPInfoREQ()
	end
	game.service.TDGameAnalyticsService.getInstance():onEvent("CLICKED_TIMEDELAY", {game.service.LocalPlayerService:getInstance():getRoleId()})
end

function UIPlayerScene_btns:_onClickCampaignDetail()
	game.service.CampaignService.getInstance():onQueryRoundInfo()
end

function UIPlayerScene_btns:_onClickGiveupCampaign()
	game.ui.UIMessageBoxMgr.getInstance():show("放弃比赛将由笨笨的机器人帮您打牌，退赛后将不会获得比赛奖励。\n是否确认退出？", {"再等一会","我要退出"},function()
		--退赛
		return
	end,function ()
		game.service.CampaignService.getInstance():sendCCAGiveUpREQ()
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Giveup_Arena);
	end,true)
end

function UIPlayerScene_btns:_onUserRelogin(event)
	-- 重新登录, 停止所有动画
	if type(self.stopAllActions) == "function" then
		self:stopAllActions();
	end
	self._checkingAniPlaying = false;
	self._uiTingTipBtnCmp:disableAll()
end

function UIPlayerScene_btns:_onRedPacketChanged(event)
	local clubId = game.service.RoomService:getInstance():getRoomClubId()
	if clubId ~= event.clubId then
		return
	end
	local club = game.service.club.ClubService:getInstance():getClub(clubId)
	if club then
		-- 这里的红包判断还有红包数量
		self._particleRedPacket:setVisible(true)
		if self._redPacketAnim ~= nil then
			UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
			self._redPacketAnim = nil
		end
		
		local pos = cc.p(display.width / 2, display.height / 2)
		pos = self:getParent():convertToWorldSpace(pos)
		-- 新的动画特效
		self._redPacketAnim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("csb/Effect_redbox.csb", function()
		end, - 1, pos, nil, nil, false, self._btnRedPacket:getParent()))
		local delay = cc.DelayTime:create(2)
		local move = cc.MoveTo:create(0.5, cc.p(self._btnRedPacket:getPosition()))
		local callback = cc.CallFunc:create(function()
			UI_ANIM.UIAnimManager:getInstance():delOneAnim(self._redPacketAnim)
			self._redPacketAnim = nil
		end)
		local seq = cc.Sequence:create(delay, move, callback)
		self._redPacketAnim._csbAnim:runAction(seq)
	end
end

function UIPlayerScene_btns:_onClickRedPacket()
	-- 统计牌桌内活动按钮点击次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Room_Activity);
	
	local clubId = game.service.RoomService:getInstance():getRoomClubId()
	local club = game.service.club.ClubService:getInstance():getClub(clubId)
	if club then
		club:mergeRedPacketChanged()
	end
	UIManager:getInstance():show("UIClubRedBox", clubId)
end

function UIPlayerScene_btns:_showGiftInfo(event)
	local data = game.service.GoldService.getInstance().giftCache
	if data then
		self._panelGift:setVisible(true)
		self._bmTextGift1:setString(string.format("%d", data.needRoundNextMallPoint))
		self._bmTextGift2:setString(data.rewardMallPoint)
		local _animAction = cc.CSLoader:createTimeline(csbPath)
		self:runAction(_animAction)
		_animAction:play("animation_quan", true)
	end
end

function UIPlayerScene_btns:_showGiftAnima(event)
	scheduleOnce(function()
		local anima = UI_ANIM.UIAnimManager:getInstance():onShow({
			_path = "ui/csb/Gold/UIGoldGxhd.csb",
			_parent = UIManager.getInstance():getTopMostLayer()
		})

		local textGift = anima:getChild("BitmapFontLabel_1", "ccui.TextBMFont")
		-- 处理一下动画中的文本控件,否则文字位置会有bug
		local labelp = textGift:getParent()
		textGift:removeFromParent()
		textGift:retain()
		scheduleOnce(function()
			labelp:addChild(textGift)
			textGift:release()
		end, 0.1)
		
	
		textGift:setString("X" .. event.protocol.rewardMallPoint)
	end, 2)
end

function UIPlayerScene_btns:onCampaignHideGiveup()
    self._btnGiveup:setEnabled(false)
end

function UIPlayerScene_btns:onCampaignDisplayGiveup()
    self._btnGiveup:setEnabled(true)
end

return UIPlayerScene_btns
