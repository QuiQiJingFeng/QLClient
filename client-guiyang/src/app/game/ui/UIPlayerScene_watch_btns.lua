--------------
-- 旁观者操作按钮
--------------
local csbPath = "ui/csb/UIPlayerScene_watch_btns.csb"
local super = require("app.game.ui.UIBase")
local UIRTVoiceComponent = require("app.game.ui.element.UIRTVoiceComponent")

local UIPlayerScene_watch_btns = class("UIPlayerScene_watch_btns", super, function () return kod.LoadCSBNode(csbPath) end)

function UIPlayerScene_watch_btns:ctor()
	super.ctor(self);
	self._checking 		= seekNodeByName(self, "Button_1_2_Scene2", 	"ccui.Button");
	self._danger 		= seekNodeByName(self, "Button_2_2_Scene2", 	"ccui.Button");
	self._safe 			= seekNodeByName(self, "Button_3_2_Scene2", 	"ccui.Button");
	self._Gps_Bay 		= seekNodeByName(self, "Panel_2_Scene2",		"ccui.Layout");
	self._quitWatch		= seekNodeByName(self, "Button_quit_watch", 	"ccui.Button");
	self._destroyRoom	= seekNodeByName(self, "Button_destroy_room", 	"ccui.Button");
	
	bindEventCallBack(self._checking,	handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);
	bindEventCallBack(self._safe, 		handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);
	bindEventCallBack(self._danger,		handler(self, self._onClickShowGps),	ccui.TouchEventType.ended);

	bindEventCallBack(self._quitWatch,	 handler(self, self._onClickQuitWatch),		ccui.TouchEventType.ended);
	bindEventCallBack(self._destroyRoom, handler(self, self._onClickDertroyRoom),	ccui.TouchEventType.ended);

	self._mousePositionY = nil
	self._imRecordCanceled = false;
	self._checkingAniPlaying = false;
	self._dangerAniPlaying = false;
end

function UIPlayerScene_watch_btns:onShow(...)
	local args = {...};

	game.service.LoginService.getInstance():addEventListener("EVENT_USER_RELOGIN",handler(self, self._onUserRelogin) , self)	
	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._showSecurityButton), self)
end

function UIPlayerScene_watch_btns:onHide()
	self:_hideSecurityButton();
	
	ccs.ActionManagerEx:getInstance():releaseActions()
	game.service.LoginService.getInstance():removeEventListenersByTag(self)
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
end

-- 点击退出观战
function UIPlayerScene_watch_btns:_onClickQuitWatch()
	-- 当打到最后一句结算时，roomService已经施放了，群主点退出观战就会报错
	game.service.LocalPlayerService:getInstance():setIsWatcher(false)
	local roomService = game.service.RoomService.getInstance()
	if roomService ~= nil then
		local roomId = roomService:getRoomId();
		roomService:quitWatchBattleREQ(roomId);
	else
		GameFSM.getInstance():enterState("GameState_Club")
	end
end

-- 点击解散房间
function UIPlayerScene_watch_btns:_onClickDertroyRoom()
	game.ui.UIMessageBoxMgr.getInstance():show("游戏正在进行中，是否强制解散该房间？" , {"确定","取消"}, function()
			local roomService = game.service.RoomService.getInstance()
			-- 处理在群主解散时，房间已经解散时的问题
			if roomService ~= nil then
				local roomId = roomService:getRoomId();
				local clubId = roomService:getRoomClubId();
				if roomService._roomLeagueId > 0 then --是联盟房间的话，调用盟主解散房间的接口
					game.service.club.ClubService.getInstance():getClubManagerService():sendCCLDestroyRoomREQ(roomId, clubId , roomService._roomLeagueId);
					game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_SuperLeague_Play_Dis_Room);
				else
					game.service.club.ClubService.getInstance():getClubManagerService():sendCCLDestroyRoomREQ(roomId, clubId);
					game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_Play_Dis_Room);
				end
			end
        end);
end

function UIPlayerScene_watch_btns:_onClickMessageButton()
	UIManager:getInstance():show("UIChatPanel")
end

-----------------------------------
-- GPS相关
function UIPlayerScene_watch_btns:_showSecurityButton()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	-- 如果两个人的时候，不显示
	if gameService:getMaxPlayerCount() <= 2 then
		securityChecker:setEnable(false)
	end
	if securityChecker:isEnable() == false then
		self._Gps_Bay:setVisible(false)
		return;
	end

	securityChecker:addEventListener("EVENT_SRCURITY_PLAYER_ENTERED", handler(self, self._onSecurityPlayerEntered), self)
	securityChecker:addEventListener("EVENT_SRCURITY_STATUS_CHANGED", handler(self, self._onSecurityStatusChanged), self)
	securityChecker:addEventListener("EVENT_SRCURITY_INFO_INITIALIZED", handler(self, self._onSecurityInfoInitialized), self)

	-- 同一个房间只播放一次检测动画
	if securityChecker:isFirstTimeCheck() then
		self:_showCheckingButton(true);
		securityChecker:setChecked();
	else
		self:_refreshSafeButtonState(false);
	end	
end

function UIPlayerScene_watch_btns:_hideSecurityButton()
	-- TODO：此处强改BUG，在总结算后，因ROOM被销毁引起的BUG
	if game.service.LocalPlayerService.getInstance() and 
		game.service.RoomCreatorService.getInstance() and
		game.service.RoomService.getInstance() then
		local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
		if securityChecker ~= nil then
			securityChecker:removeEventListenersByTag(self)
		end
	end
	-- 停止动画
	self._danger:unscheduleUpdate();
	self:stopAllActions()
end

function UIPlayerScene_watch_btns:_showCheckingButton(playAni)
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
			_action:play("animation0",false)
			
			local speed = _action:getTimeSpeed()
			local startFrame = _action:getStartFrame()
			local endFrame = _action:getEndFrame()
			local frameNum = endFrame - startFrame
			local delay = 1.0 /(speed * 60.0) * frameNum
			local _callFunc = cc.CallFunc:create(function ()
				_action:stop()
				self._checkingAniPlaying = false;

				-- 动画播放完成.
				self:_refreshSafeButtonState(true);
			end)
			
			local sequ = cc.Sequence:create(cc.DelayTime:create(delay),_callFunc)
			self:runAction(sequ)
			self._checkingAniPlaying = true;
		end	
	end	
end

function UIPlayerScene_watch_btns:_refreshSafeButtonState(playAni)
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

function UIPlayerScene_watch_btns:_showUnsafeButton(playWarningAni)
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
		local fademin = cc.FadeTo:create(0.5,145) 
		local seq = cc.Sequence:create(fademax,fademin)
		local rep = cc.Repeat:create(seq, 3)
		self._danger:runAction(rep)
	end
end

function UIPlayerScene_watch_btns:_showSafeButton()
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

function UIPlayerScene_watch_btns:_onClickShowGps(sender)
	-- TODO:同设置按钮，只有当RoomService有效的时候，才显示
	if game.service.RoomService:getInstance() ~= nil then
		UIManager:getInstance():show("UIGpsNew")
	end
end

function UIPlayerScene_watch_btns:_onSecurityPlayerEntered(event)
	Logger.debug("UIPlayerScene_watch_btns(EVENT_SRCURITY_PLAYER_ENTERED)")
	-- 有用户进入, 播放检测动画
	self:_showCheckingButton(true);
end

function UIPlayerScene_watch_btns:_onSecurityStatusChanged(event)
	Logger.debug("UIPlayerScene_watch_btns(EVENT_SRCURITY_STATUS_CHANGED)")
	if game.service.RoomService.getInstance():isHaveBeginFirstGame() then
		-- 开局之后不放动画
		self:_refreshSafeButtonState(false);
	else
		-- 开局之前播放动画
		self:_refreshSafeButtonState(true);
	end
end

function UIPlayerScene_watch_btns:_onSecurityInfoInitialized(event)
	Logger.debug("UIPlayerScene_watch_btns(EVENT_SRCURITY_INFO_INITIALIZED)")
	self:_refreshSafeButtonState(false);
end

function UIPlayerScene_watch_btns:_onUserRelogin(event)
	-- 重新登录, 停止所有动画
	self:stopAllActions();
	self._checkingAniPlaying = false;
end

return UIPlayerScene_watch_btns
