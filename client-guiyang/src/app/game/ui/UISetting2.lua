local csbPath = "ui/csb/UISetting1.csb"
local super = require("app.game.ui.UIBase")
local UISetting2 = class("UISetting2", super, function () return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local MyCheckBoxGroup = class("MyCheckBoxGroup", CheckBoxGroup)
function UISetting2:ctor() end
function UISetting2:init()
	self._btn_close = seekNodeByName(self, "Button_x_user", "ccui.Button")
	self._cardLarger = seekNodeByName(self, "cbx_ChuPaiFangDa", "ccui.CheckBox")
	self._xieChaPai = seekNodeByName(self, "cbx_XieCha", "ccui.CheckBox")
	self._cardDanji = seekNodeByName(self, "cbx_Danji", "ccui.CheckBox") 
	self._pushSwitch = seekNodeByName(self, "cbx_jpush", "ccui.CheckBox")

	self.panelMode = {'classic','green', 'blue'}
	for _ , v in ipairs(self.panelMode or {}) do
		self['_panel'..v] = seekNodeByName(self,'cbx_desktop_'..v, 'ccui.CheckBox')
	end

	self._musicBGM = seekNodeByName(self, "cbx_BGM", "ccui.CheckBox")
	self._musicSFX = seekNodeByName(self, "cbx_SFX", "ccui.CheckBox")
	self._dialect = seekNodeByName(self, 'CheckBox_Mandarin', 'ccui.CheckBox')
	seekNodeByName(self,'Text_Language1_0', 'ccui.Text'):setString('贵阳话')
	seekNodeByName(self,'CheckBox_Dialect', 'ccui.CheckBox'):setVisible(false)
	seekNodeByName(self,'Text_Language1', 'ccui.Text'):setVisible(false)

	self._cardBg1 = seekNodeByName(self, "cbx_card_1", "ccui.CheckBox")
	self._cardBg2 = seekNodeByName(self, "cbx_card_2", "ccui.CheckBox")
	self._cardBgMask1 = seekNodeByName(self, "Image_card_1_tiao_1_mask", "ccui.ImageView")
	self._cardBgMask2 =	seekNodeByName(self, "Image_card_2_tiao_1_mask", "ccui.ImageView")
	self._is3D = seekNodeByName(self, "cbx_3D", "ccui.CheckBox")
	--[[
		1.在普通局 解散
		2.在大厅 退出登录
		3.在比赛场 不显示
	]]
	self._btn_breakbattle_logout = seekNodeByName(self, 'Checkout_Button', 'ccui.Button')
	-- 改为同一个按钮控制
	seekNodeByName(self, 'logout_Button', 'ccui.Button'):setVisible(false)
	self._text_breakbattle_logout = seekNodeByName(self._btn_breakbattle_logout, 'BitmapFontLabel_1_0_0_0_0', 'ccui.TextBMFont')
	self._update_Button = seekNodeByName(self, "update_Button", "ccui.Button")
	self._update_hint = seekNodeByName(self,'Image_red_update', 'ccui.ImageView')
	self._fix_button = seekNodeByName(self, 'fix_Button', 'ccui.Button')

	self:_registerCallBack()
end

function UISetting2:_onBtnCloseClick(sender)
	self:_saveValues()
	UIManager:getInstance():destroy("UISetting2")
end

function UISetting2:_onAudioChanged(group, index, token)
	local sfx = group[1]:isSelected() and 0.5 or 0
	if token == 'musicBGM' then
		manager.AudioManager.getInstance():setMusicVolumeUser(sfx)
	elseif token == 'musicSFX' then
		manager.AudioManager.getInstance():setEffectVolumeUser(sfx)
	end
end

function UISetting2:_on3DChanged(group, index, token)
	local val = group[1]:isSelected()
	game.service.GlobalSetting.getInstance().is3D = val
	config.change2D3DReset()
end

function UISetting2:_onGameFix( )
	-- TODO
end

function UISetting2:_registerCallBack()
	bindEventCallBack(self._btn_close,    handler(self, self._onBtnCloseClick),    ccui.TouchEventType.ended)
	self._cardLarger_group = MyCheckBoxGroup.new({self._cardLarger},handler(self, self._onMyCheckBoxGroupClick),'cardLarger')
	self._xieChaPai_group = MyCheckBoxGroup.new({self._xieChaPai},handler(self, self._onMyCheckBoxGroupClick),'xieChaPai')
	self._cardDanji_group = MyCheckBoxGroup.new({self._cardDanji},handler(self, self._onMyCheckBoxGroupClick),'Danji')
	self._pushSwitch_group = MyCheckBoxGroup.new({self._pushSwitch},handler(self, self._onMyCheckBoxGroupClick),'TuiSongKaiGuan')
	self._language_group = MyCheckBoxGroup.new({self._dialect}, handler(self, self._onMyCheckBoxGroupClick),'language')
	self._panel_group = CheckBoxGroup.new({self._panelclassic, self._panelgreen, self._panelblue}, handler(self, self._onCheckBoxGroupPanelDesktopClick), "desktop")
	self._musicBGM_group = MyCheckBoxGroup.new({self._musicBGM}, handler(self, self._onAudioChanged), 'musicBGM')
	self._musicSFX_group = MyCheckBoxGroup.new({self._musicSFX}, handler(self,self._onAudioChanged), 'musicSFX')
	self._cardBg_group = CheckBoxGroup.new({self._cardBg1, self._cardBg2}, handler(self, self._onCheckBoxGroupPanelDesktopClick), 'card') 
	bindEventCallBack(self._btn_breakbattle_logout, handler(self, self._onBtnBreakBattleOrLogoutClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._update_Button, handler(self, self._onBtnUpdateClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._fix_button, handler(self, self._onGameFix), ccui.TouchEventType.ended)
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))
	self._is3D_group = MyCheckBoxGroup.new({self._is3D}, handler(self, self._on3DChanged), "is3D")
end

-- 自定义的多选组回调
function UISetting2:_onMyCheckBoxGroupClick(group, index, token)
	if token == "TuiSongKaiGuan" then
		local isSelected = group[index]:isSelected()
		local isStopped = game.service.JPushService.getInstance():isPushStopped()
		if isSelected and isStopped then
			game.ui.UIMessageBoxMgr.getInstance():show("您尚未开启游戏推送！是否去设置中开启？" , {"确定","取消"}, 
				function() game.plugin.Runtime.openAppSetting() end, 
				function() group[index]:setSelected(false) end
			)
		end
		game.service.PushService.getInstance():enablePushType(game.service.PushService.PushType.StartBattle, group[index]:isSelected())
		return
	elseif token == "Danji" then
		game.service.LocalPlayerSettingService:getInstance():setClickType(group[index]:isSelected() and 2 or 1)
	elseif token == 'language' then
		self._language_group:setSelectedIndex(true)
	elseif token == 'is3D' then
		val = self._is3D_group:isSelected()
		game.service.GlobalSetting.getInstance().is3D = val
		config.change2D3DReset()
	end
	local descrption = "SettingToggle_" .. token .. (group[index]:isSelected() and " ON" or " OFF")
	game.service.DataEyeService.getInstance():onEvent(descrption) 
end

function UISetting2:_onBtnBreakBattleOrLogoutClick()
	-- 大厅内
	if not self.inBattleScene and not self.inCampaignScene then 
		local serverId = game.service.LocalPlayerService.getInstance():getGameServerId();
		game.service.LoginService.getInstance():logout(serverId);
		return
	end
	-- 解散房间
	-- 如果打开界面，然后进入最终结算的话，RoomService会被清空的
	if game.service.RoomService.getInstance() then
		game.service.RoomService.getInstance():startVoteDestroy()
	end
	UIManager:getInstance():destroy("UISetting")
end

function UISetting2:_onBtnUpdateClick()
	local downloadUrl = config.GlobalConfig.getDownloadUrl();
	cc.Application:getInstance():openURL(config.GlobalConfig.getConfig().SHARE_HOSTNAME .. downloadUrl)
	--牌局回放点击量
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_Setting_Update)
end

function UISetting2:_onCheckBoxGroupPanelDesktopClick(group, index, token)
	if token == "desktop" then
		if gameMode.mahjong.Context.getInstance() and gameMode.mahjong.Context.getInstance():getGameService() then
			local gameService = gameMode.mahjong.Context:getInstance():getGameService()
			if gameService then
				if gameService.class.__cname == "GameService_Mahjong" or gameService.class.__cname == "GameService_MahjongReplay" then
					gameMode.mahjong.Context.getInstance():getGameService():getRoomUI():onChangeDestop(index)
				end
			end
		end
	elseif token == 'card' then
	end
end


function UISetting2:onShow(...)
	local args = {...}
	local inBattleScene = args[1] == "battle"
	local inCampaignScene = args[1] == "campaign"
	self.inBattleScene = inBattleScene
	self.inCampaignScene = inCampaignScene
	local text
	if inBattleScene and not inCampaignScene then
		text = '申请解散'
	elseif not inBattleScene and not inCampaignScene then
		text = '退出登录'
	end
	if text then 
		self._btn_breakbattle_logout:setVisible(true)
		self._text_breakbattle_logout:setString(text)
	else
		self._btn_breakbattle_logout:setVisible(false)
	end

	self._cardBgMask1:setVisible(inBattleScene or inCampaignScene)
	self._cardBgMask2:setVisible(inBattleScene or inCampaignScene)

	local needUpdate = game.service.LoginService.getInstance():getIsNeedUpdate()
	self._update_Button:setEnabled(needUpdate)
	self._update_hint:setVisible(needUpdate)

	-- 牌局未开始不能点击设置中的解散房间
	if inBattleScene then
		local isBattleStart = gameMode.mahjong.Context.getInstance():getGameService()._isGameStarted
		local roomService = game.service.RoomService.getInstance()
		if roomService ~= nil then
			self._btn_breakbattle_logout:setEnabled(isBattleStart or roomService:isHaveBeginFirstGame())
		end
	end

	--处理 在提审和 JPushService不支持的情况下隐藏的 逻辑
	if GameMain.getInstance():isReviewVersion() then
		if text=='退出登录' then
			self._btn_logout:setVisible(false)
		end
	end

	local pushToggleText = seekNodeByName(self, "Text_L_1_1", "ccui.Text")
	local pushService = game.service.JPushService.getInstance()
	self._pushSwitch:setVisible(pushService:isEnabled())
	pushToggleText:setVisible(pushService:isEnabled())

	self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView")
    bindEventCallBack(self._mask, function ()
			self:_saveValues()
			UIManager.getInstance():hide("UISetting")
		end, ccui.TouchEventType.ended)

	self:_resetValues()

	self._cardBg_group:forEach(function(idx, item)
		item:setEnabled(not inBattleScene and not inCampaignScene)
	end)
	
	self._is3D:setSelected(config.getIs3D())
	self._is3D:setEnabled(not inBattleScene and not inCampaignScene)
end

-- 从永久性存储中读取设置，并且赋值到控件上
-- @todo 目前没做多语音的功能
function UISetting2:_resetValues()
	self._language_group:setSelectedIndex(true)
	local globalSetting = game.service.GlobalSetting.getInstance()
	local localSetting = game.service.LocalPlayerSettingService:getInstance()
	-- 推送服务 除了检查服务器支不支持，还要保证本地推送已经打开
	local enable = game.service.PushService.getInstance():isPushTypeEnabled(game.service.PushService.PushType.StartBattle) 
		and not game.service.JPushService.getInstance():isPushStopped()
	local values = localSetting:getEffectValues()
	self._xieChaPai_group:setSelectedIndex(values.effect_XieChaPai)
	self._cardLarger_group:setSelectedIndex(values.effect_ChuPaiTingLiu)
	self._cardDanji_group:setSelectedIndex(localSetting:getClickType() == 2)
	self._pushSwitch_group:setSelectedIndex(enable)

	self._panel_group:setSelectedIndex(localSetting:getTableBackgound())
	self._cardBg_group:setSelectedIndex(localSetting:getCardBackgound())

	self._musicBGM_group:setSelectedIndex(globalSetting.bgmVolume ~= 0)
	self._musicSFX_group:setSelectedIndex(globalSetting.sfxVolume ~= 0)
end

-- 在关闭或者隐藏UI时，保存所有选项信息到永久性存储
-- @todo 目前没做多语音的功能
function UISetting2:_saveValues()
	local globalSetting = game.service.GlobalSetting.getInstance()
	local localSetting = game.service.LocalPlayerSettingService:getInstance()
	local values = {
		effect_ChuPaiTingLiu = self._cardLarger_group:isSelected(),
		effect_XieChaPai = self._xieChaPai_group:isSelected(),
	}
	localSetting:setEffectValues(values) 
	localSetting:setCardBackgound(self._cardBg_group:getSelectedIndex()) -- 功能不上，开启同时要反注释LocalPlayerSetting中的对应部分
	localSetting:setTableBackgound(self._panel_group:getSelectedIndex())
	globalSetting:saveSetting()
	localSetting:saveSetting()
end

function UISetting2:needBlackMask() return true end

function UISetting2:closeWhenClickMask() return true end

function UISetting2:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

--[[
	进入前台的时候，调整Push设置.
	除了检查服务器支不支持，还要保证本地推送已经打开
]]
function UISetting2:_onEnterForeground()
	local isPushEnable = game.service.JPushService.getInstance():isEnabled()
	local pushToggleText = seekNodeByName(self, "Text_3_1", "ccui.Text")
	pushToggleText:setVisible(isPushEnable)
	self._pushSwitch:setVisible(isPushEnable)
	if isPushEnable then
		local isStartBattlePushEnable = game.service.PushService.getInstance():isPushTypeEnabled(game.service.PushService.PushType.StartBattle) 
			and not game.service.JPushService.getInstance():isPushStopped()
		self._pushSwitch:setSelected(isStartBattlePushEnable)
	end
end

-- 取消注册前后台切换事件监听
function UISetting2:destroy()
	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)
		self._listenerEnterForeground = nil;
	end
end

-- 重写一个CheckBoxGroup， 每个Group中只有一个CheckBox，只是为了让控件能够按下时滑动取消
-- @override
function MyCheckBoxGroup:_changeCheckBoxSelectedStatus(index)
end

-- @override
function MyCheckBoxGroup:setSelectedIndex(value)
	self._group[1]:setSelected(value)
end

-- add a new method, return is selected
function MyCheckBoxGroup:isSelected()
	return self._group[1]:isSelected()
end
return UISetting2