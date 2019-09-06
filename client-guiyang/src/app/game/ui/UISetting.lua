--[[	使用了CheckBoxGroup
	MyCheckBoxGroup 重写了 CheckBoxGroup的方法 ， see at bottom
]]
local csbPath = "ui/csb/UISetting.csb"
local super = require("app.game.ui.UIBase")
local UISetting = class("UISetting", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local MyCheckBoxGroup = class("MyCheckBoxGroup", CheckBoxGroup)
function UISetting:ctor() end

-- 初始化所有的控件
function UISetting:init()
	self._panel_main = seekNodeByName(self, "Panel_BG", "ccui.Layout")
	self._panel_sound = seekNodeByName(self, "Panel_Sound", "ccui.Layout")
	self._panel_effect = seekNodeByName(self, "Panel_Effect", "ccui.Layout")
	self._panel_desktop = seekNodeByName(self, "Panel_Desktop", "ccui.Layout")
	self._panel_update = seekNodeByName(self, "Panel_Update", "ccui.Layout")
	self._panelList = {self._panel_sound, self._panel_effect, self._panel_desktop, self._panel_update}
	
	-- main panel widget
	self._btn_close = seekNodeByName(self._panel_main, "Button_Close", "ccui.Button")
	self._btn_logout = seekNodeByName(self._panel_main, "Button_Logout", "ccui.Button")
	self._btn_breakbattle = seekNodeByName(self._panel_main, "Button_BreakBattle", "ccui.Button")
	
	self._cbx_sound = seekNodeByName(self._panel_main, "CheckBox_1_Setting", "ccui.CheckBox")
	self._cbx_effect = seekNodeByName(self._panel_main, "CheckBox_2_Setting", "ccui.CheckBox")
	self._cbx_desktop = seekNodeByName(self._panel_main, "CheckBox_3_Setting", "ccui.CheckBox")
	self._cbx_update = seekNodeByName(self._panel_main, "CheckBox_4_Setting", "ccui.CheckBox")
	
	-- sound panel widget
	self._slider_BGM = seekNodeByName(self._panel_sound, "Slider_BGM", "ccui.Slider")
	self._slider_SFX = seekNodeByName(self._panel_sound, "Slider_SFX", "ccui.Slider")
	self._cbx_dialect = seekNodeByName(self._panel_sound, "CheckBox_Dialect", "ccui.CheckBox")
	self._cbx_mandarin = seekNodeByName(self._panel_sound, "CheckBox_Mandarin", "ccui.CheckBox")
	
	-- desktop panel widget
	self._cbx_desktop_classic = seekNodeByName(self._panel_desktop, "cbx_desktop_classic", "ccui.CheckBox")
	self._cbx_desktop_green = seekNodeByName(self._panel_desktop, "cbx_desktop_green", "ccui.CheckBox")
	self._cbx_desktop_blue = seekNodeByName(self._panel_desktop, "cbx_desktop_blue", "ccui.CheckBox")
	
	self._panel_Card = seekNodeByName(self, "Panel_pm_Desktop", "ccui.Layout")
	self.cbx_card_1 = seekNodeByName(self._panel_Card, "cbx_card_1", "ccui.CheckBox")
	self.cbx_card_2 = seekNodeByName(self._panel_Card, "cbx_card_2", "ccui.CheckBox")
	self.cbx_card_3 = seekNodeByName(self._panel_Card, "cbx_card_3", "ccui.CheckBox")
	
	-- effect panel widget
	self._toggle_TuiSongKaiGuan = seekNodeByName(self._panel_effect, "cbx_jpush", "ccui.CheckBox")
	self._toggle_PengGangTiShi = seekNodeByName(self._panel_effect, "cbx_PengGang", "ccui.CheckBox")
	self._toggle_ChuPaiFangDa = seekNodeByName(self._panel_effect, "cbx_ChuPaiFangDa", "ccui.CheckBox")
	self._toggle_ChuPaiTiShi = seekNodeByName(self._panel_effect, "cbx_ChuPaiTiShi", "ccui.CheckBox")
	self._toggle_XieChaPai = seekNodeByName(self._panel_effect, "cbx_XieCha", "ccui.CheckBox")
	self._toggle_Danji = seekNodeByName(self._panel_effect, "cbx_Danji", "ccui.CheckBox")
	self._cbxMoreShare = seekNodeByName(self._panel_effect, "cbxMoreShare", "ccui.CheckBox")
	
	self._toggle_Expression = seekNodeByName(self._panel_effect, "cbx_expression", "ccui.CheckBox")
	self._toggle_ClubPush = seekNodeByName(self._panel_effect, "cbx_clubPush", "ccui.CheckBox")
	self._textClubPush = seekNodeByName(self._panel_effect, "Text_clubPush", "ccui.Text")
	self._toggle_ClubPush:setVisible(game.plugin.Runtime.isAccountInterflow())
	self._textClubPush:setVisible(game.plugin.Runtime.isAccountInterflow())

	-- update panel widget
	self._update_Button = seekNodeByName(self._panel_update, "update_Button", "ccui.Button")
	self._update_Text = seekNodeByName(self._panel_update, "Text_UpdateText", "ccui.Text")
	self._btn_fix_game = seekNodeByName(self._panel_update, "fixgame_Button", "ccui.Button")
	-- 暂时屏蔽
	self._btn_fix_game:setEnabled(false)

	--隐藏斜插牌功能
	self._toggle_XieChaPai:setVisible(false)
	
	self._is3D = seekNodeByName(self, "cbx_3D", "ccui.CheckBox")
	
	-- 经典模式
	self._checkBoxClassic = seekNodeByName(self, "cbx_classic", "ccui.CheckBox")
	
	self._isShowed = false -- 是否显示完成
	
	self._redForFunction = seekNodeByName(self, "imgRedForFuntion", "ccui.ImageView")
	
	self:_registerCallBack()
end

-- @see CheckBoxGroup.lua
-- 注册所有控件的监听，分为多组CheckBoxGroup，Group中已经处理了选择逻辑
function UISetting:_registerCallBack()
	self._main_cbx_group = CheckBoxGroup.new({self._cbx_sound, self._cbx_effect, self._cbx_desktop, self._cbx_update}, handler(self, self._onCheckBoxGroupMainClick))
	self._desktop_cbx_group = CheckBoxGroup.new({self._cbx_desktop_green, self._cbx_desktop_classic, self._cbx_desktop_blue}, handler(self, self._onCheckBoxGroupPanelDesktopClick), "desktop")
	self._lang_cbx_group = MyCheckBoxGroup.new({self._cbx_dialect, self._cbx_mandarin}, handler(self, self._onCheckBoxGroupLanguageClick))
	self._bg_cbx_card = CheckBoxGroup.new({self.cbx_card_1, self.cbx_card_2, self.cbx_card_3}, handler(self, self._onCheckBoxGroupPanelDesktopClick), "card")
	
	-- main panel widget
	bindEventCallBack(self._btn_close,	handler(self, self._onBtnCloseClick),	ccui.TouchEventType.ended)
	bindEventCallBack(self._btn_logout, handler(self, self._onBtnLogoutClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btn_fix_game, handler(self, self._onBtnFixGameClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btn_breakbattle, handler(self, self._onBtnBreakBattleClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._update_Button, handler(self, self._onBtnUpdateClick), ccui.TouchEventType.ended)
	
	-- sound panel widget
	self._slider_BGM:addEventListener(handler(self, self._onSliderBGMChanged))
	self._slider_SFX:addEventListener(handler(self, self._onSliderSFXChanged))
	
	-- effect panel widget
	-- 重写了CheckBoxGroup，只是为了保证每个CheckBox能够支持按下滑动取消特性
	self._EX_toggle_XieChaPai = MyCheckBoxGroup.new({self._toggle_XieChaPai}, handler(self, self._onMyCheckBoxGroupClick), "XieChaPai")
	self._EX_toggle_ChuPaiTiShi = MyCheckBoxGroup.new({self._toggle_ChuPaiTiShi}, handler(self, self._onMyCheckBoxGroupClick), "ChuPaiTiShi")
	self._EX_toggle_ChuPaiFangDa = MyCheckBoxGroup.new({self._toggle_ChuPaiFangDa}, handler(self, self._onMyCheckBoxGroupClick), "ChuPaiFangDa")
	self._EX_toggle_PengGangTiShi = MyCheckBoxGroup.new({self._toggle_PengGangTiShi}, handler(self, self._onMyCheckBoxGroupClick), "PengGangTiShi")
	self._EX_toggle_TuiSongKaiGuan = MyCheckBoxGroup.new({self._toggle_TuiSongKaiGuan}, handler(self, self._onMyCheckBoxGroupClick), "TuiSongKaiGuan")
	self._EX_toggle_Danji = MyCheckBoxGroup.new({self._toggle_Danji}, handler(self, self._onMyCheckBoxGroupClick), "Danji")
	self._EX_cbxMoreShare = MyCheckBoxGroup.new({self._cbxMoreShare}, handler(self, self._onMyCheckBoxGroupClick), "MoreShare")
	self._EX_toggle_Expressioni = MyCheckBoxGroup.new({self._toggle_Expression}, handler(self, self._onMyCheckBoxGroupClick), "ExpressionNewnew")
	self._EX_toggle_ClubPush = MyCheckBoxGroup.new({self._toggle_ClubPush}, handler(self, self._onMyCheckBoxGroupClick), "ClubPush")

	
	self._is3D_group = MyCheckBoxGroup.new({self._is3D}, handler(self, self._on3DChanged), "is3D")
	self._isClassicGroup = MyCheckBoxGroup.new({self._checkBoxClassic}, handler(self, self._onClassic), "classic")
	
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))

    -- 临时日志上传代码
	self._btn_fix_game:setEnabled(true)
	bindEventCallBack(self._btn_fix_game, handler(self, self._onBtnLogUploadClick), ccui.TouchEventType.ended)    
end

function UISetting:onShow(...)
	local args = {...}
	self._inBattleScene = args[1] == "battle"
	self._inCampaignScene = args[1] == "campaign"
	self._btn_breakbattle:setVisible(self._inBattleScene and not self._inCampaignScene)
	self._btn_logout:setVisible(not self._inBattleScene and not self._inCampaignScene)
	
	-- 牌局未开始不能点击设置中的解散房间
	if self._inBattleScene then
		local isBattleStart = gameMode.mahjong.Context.getInstance():getGameService()._isGameStarted
		local roomService = game.service.RoomService.getInstance()
		if roomService	~= nil then
			self._btn_breakbattle:setEnabled(isBattleStart or roomService:isHaveBeginFirstGame())
		end
	end
	
	-- 处理 在提审和 JPushService不支持的情况下隐藏的 逻辑
	if GameMain.getInstance():isReviewVersion() then
		self._btn_logout:setVisible(false)
	end
	local pushToggleText = seekNodeByName(self._panel_effect, "Text_3_1", "ccui.Text")
	local pushService = game.service.JPushService.getInstance()
	self._toggle_TuiSongKaiGuan:setVisible(false)
	pushToggleText:setVisible(false)
	
	self:_resetValues()
	
	-- 提示更新状态刷新
	local needUpdate = game.service.LoginService.getInstance():getIsNeedUpdate()
	self._cbx_update:getChildByName("Image_red_Update"):setVisible(needUpdate)	
	
	-- self._is3D:setTouchEnabled(not self._inBattleScene and not self._inCampaignScene)
	local globalSetting = game.service.GlobalSetting.getInstance()
	seekNodeByName(self, "Image_red_Update_3", "ccui.ImageView"):setVisible(globalSetting.isNew3D ~= false)
	
	self._isShowed = true

	self._main_cbx_group:setSelectedIndex(2)

	self:playAnimation_Scale()
end

-- 从永久性存储中读取设置，并且赋值到控件上
-- @todo 目前没做多语音的功能
function UISetting:_resetValues()
	local globalSetting = game.service.GlobalSetting.getInstance()
	local localSetting = game.service.LocalPlayerSettingService:getInstance()
	
	self._lang_cbx_group:setSelectedIndex(true) -- 多语音功能开启后需要读取设置
	
	-- sound panel reset values
	self._slider_BGM:setPercent(globalSetting.bgmVolume * 100)
	self._slider_SFX:setPercent(globalSetting.sfxVolume * 100)
	self._EX_cbxMoreShare:setSelectedIndex(globalSetting.enableMoreShare)
	-- TODO 多语音，后续开发，目前贵阳不需要多语音
	-- 推送服务 除了检查服务器支不支持，还要保证本地推送已经打开
	local enable = game.service.PushService.getInstance():isPushTypeEnabled(game.service.PushService.PushType.StartBattle)
	and not game.service.JPushService.getInstance():isPushStopped()
	-- 碰杠提示、出牌放大、斜插牌、出牌提示、推送开关 
	local values = localSetting:getEffectValues()
	self._EX_toggle_ChuPaiTiShi:setSelectedIndex(values.effect_ChuPaiTiShi)
	self._EX_toggle_XieChaPai:setSelectedIndex(values.effect_XieChaPai)
	self._EX_toggle_ChuPaiFangDa:setSelectedIndex(values.effect_ChuPaiTingLiu)
	self._EX_toggle_PengGangTiShi:setSelectedIndex(values.effect_PengGangTiShi)
	self._EX_toggle_Danji:setSelectedIndex(localSetting:getClickType() == 2)
	self._EX_toggle_TuiSongKaiGuan:setSelectedIndex(enable)
	
	self._is3D_group:setSelectedIndex(game.service.GlobalSetting.getInstance().is3D)
	self._isClassicGroup:setSelectedIndex(game.service.GlobalSetting.getInstance().isClassic)
	self._checkBoxClassic:setEnabled(not game.service.GlobalSetting.getInstance().is3D)

	self._EX_toggle_Expressioni:setSelectedIndex(values.effect_Expression == nil or values.effect_Expression)
	local userData = game.service.club.ClubService.getInstance():getUserData()
	self._EX_toggle_ClubPush:setSelectedIndex(userData:getOfflineInvitesSwitch())

	-- desktop background and card background
	self._desktop_cbx_group:setSelectedIndexWithoutCallback(localSetting:getTableBackgound())
	self._bg_cbx_card:setSelectedIndex(localSetting:getCardBackgound())
	
	self._redForFunction:setVisible(globalSetting.settingFeaturesRedCache)
	self:_updataClassicStatus(game.service.GlobalSetting.getInstance().isClassic)
end

-- 在关闭或者隐藏UI时，保存所有选项信息到永久性存储
-- @todo 目前没做多语音的功能
function UISetting:_saveValues()
	local globalSetting = game.service.GlobalSetting.getInstance()
	local localSetting = game.service.LocalPlayerSettingService:getInstance()
	-- sound panel 
	-- TODO 多语音，音量已即时保存了
	-- effect panel
	-- 碰杠提示、出牌放大、斜插牌、出牌提示、推送开关, 
	local values = {
		effect_ChuPaiTingLiu = self._EX_toggle_ChuPaiFangDa:isSelected(),
		effect_PengGangTiShi = self._EX_toggle_PengGangTiShi:isSelected(),
		effect_ChuPaiTiShi = self._EX_toggle_ChuPaiTiShi:isSelected(),
		effect_Expression = self._EX_toggle_Expressioni:isSelected(),
		effect_ClubPush	= self._EX_toggle_ClubPush:isSelected(),
	-- effect_Danji = self._EX_toggle_Danji:isSelected()
	}
	localSetting:setEffectValues(values) -- 必须与localplayersettingservice中的key一致
	
	-- desktop card panel
	-- 只能在大厅中更改牌值
	-- if not self._inBattleScene and not self._inCampaignScene then
	localSetting:setCardBackgound(self._bg_cbx_card:getSelectedIndex())
	-- end
	localSetting:setTableBackgound(self._desktop_cbx_group:getSelectedIndex())
	globalSetting.is3D = self._is3D_group:isSelected()
	globalSetting:saveSetting()
	localSetting:saveSetting()
end

-- 主面板的多选组
function UISetting:_onCheckBoxGroupMainClick(group, index)
	for i, v in ipairs(self._panelList) do
		v:setVisible(i == index)
	end
	
	self._panel_Card:setVisible(group[index] == self._cbx_desktop)
	local globalSetting = game.service.GlobalSetting.getInstance()
	if globalSetting.isNew3D ~= false then
		globalSetting.isNew3D = index ~= 3
	end
	seekNodeByName(self, "Image_red_Update_3", "ccui.ImageView"):setVisible(globalSetting.isNew3D ~= false)
	
	if group[index] == self._cbx_update then
		self:_refrashUpdatePannel()
	end
	
	if group[index] == self._cbx_effect and self._redForFunction:isVisible() then
		self:_refreshFunctionRed()
	end
	
	local uimain = UIManager:getInstance():getUI("UIMain")
	if uimain ~= nil then
		uimain:_updateSetting()
	end
end

--刷新功能标签红点
function UISetting:_refreshFunctionRed()
	self._redForFunction:setVisible(false)
	local globalSetting = game.service.GlobalSetting.getInstance()
	globalSetting.settingFeaturesRedCache = false
	globalSetting:saveSetting()
end

-- 贵阳没有多语音逻辑，后续合并多地区追加
function UISetting:_onCheckBoxGroupLanguageClick(group, index)
	group[index]:setSelected(true)
end

-- 桌面、牌面背景多选组
function UISetting:_onCheckBoxGroupPanelDesktopClick(group, index, token)
	if game.service.GlobalSetting.getInstance().isClassic and self._isShowed then
		group[index]:setSelected(false)
		group[1]:setSelected(true)
		game.ui.UIMessageTipsMgr.getInstance():showTips("经典模式不支持切换颜色!")
		return
	end
	
	if token == "desktop" then
		if gameMode.mahjong.Context.getInstance() and gameMode.mahjong.Context.getInstance():getGameService() then
			local gameService = gameMode.mahjong.Context:getInstance():getGameService()
			if gameService then
				if gameService.class.__cname == "GameService_Mahjong" or gameService.class.__cname == "GameService_MahjongReplay" then
					gameMode.mahjong.Context.getInstance():getGameService():getRoomUI():onChangeDestop(index)
					if self._inBattleScene or self._inCampaignScene then
						scheduleOnce(function()
							self:_saveValues()
							UIManager.getInstance():destroy("UISetting")
						end, 0.2)
					end
				end
			end
		end
	elseif token == "card" then
		-- 在牌局内给玩家提示
		-- if self._inBattleScene or self._inCampaignScene then
		-- 	if self._bg_cbx_card:getSelectedIndex() ~= game.service.LocalPlayerSettingService:getInstance():getCardBackgound() then
		-- 		self._bg_cbx_card:setSelectedIndex(game.service.LocalPlayerSettingService:getInstance():getCardBackgound())
		-- 		game.ui.UIMessageTipsMgr.getInstance():showTips("请在大厅设置中切换牌面!")
		-- 	end
		-- else
		if game.service.GlobalSetting.getInstance().is3D and self._isShowed then
			game.ui.UIMessageTipsMgr.getInstance():showTips("3D模式暂不支持选择麻将颜色!")
			return
		end
		local localSetting = game.service.LocalPlayerSettingService:getInstance()
		localSetting:setCardBackgound(self._bg_cbx_card:getSelectedIndex())
		-- end
	end
	
	local position =(self._inBattleScene or self._inCampaignScene) and "Room" or "Main"
	local descrption = string.format("SettingToggle_%s%s_%s_%s", position, token, index,(group[index]:isSelected() and " ON" or " OFF"))
	game.service.DataEyeService.getInstance():onEvent(descrption)
end

-- 自定义的多选组回调
function UISetting:_onMyCheckBoxGroupClick(group, index, token)
	-- 上报自定义消息 SettingToggle_ .. XXX  -- 推送不在这里上报
	local descrption = "SettingToggle_" .. token ..(group[index]:isSelected() and " ON" or " OFF")
	game.service.DataEyeService.getInstance():onEvent(descrption)

	if token == "TuiSongKaiGuan" then
		local isSelected = group[index]:isSelected()
		local isStopped = game.service.JPushService.getInstance():isPushStopped()
		if isSelected and isStopped then
			game.ui.UIMessageBoxMgr.getInstance():show("您尚未开启游戏推送！是否去设置中开启？", {"确定", "取消"},
			function() game.plugin.Runtime.openAppSetting() end,
			function() group[index]:setSelected(false) end
			) -- 不开的话 直接关掉
		end
		game.service.PushService.getInstance():enablePushType(game.service.PushService.PushType.StartBattle, group[index]:isSelected())
		return
	elseif token == "Danji" then
		game.service.LocalPlayerSettingService:getInstance():setClickType(group[index]:isSelected() and 2 or 1)
	elseif token == "MoreShare" then
		game.service.GlobalSetting.getInstance().enableMoreShare = group[index]:isSelected()
		--点击更多分享
		game.service.TDGameAnalyticsService.getInstance():onEvent("MoreShareSettingClick", group[index]:isSelected())
	elseif token == "ClubPush" then
		if group[index]:isSelected() then
			if game.plugin.Runtime.notificationsEnabled() == nil or game.plugin.Runtime.notificationsEnabled() == 0 then
				-- 没有开启
				game.ui.UIMessageBoxMgr.getInstance():show("接收离线邀请需要开启“通知”权限" , {"去开启", "取消"},
					function ()
						game.plugin.Runtime.openSetting()
						self:_onBtnCloseClick()
					end,
					function ()
						self._EX_toggle_ClubPush:setSelectedIndex(false)
					end
				)
			end
		end
	end
end

function UISetting:_onBtnCloseClick(sender)
	UIManager:getInstance():hide("UISetting")
end

-- 不应该在onHide中去销毁UI -- onHide中不能去上报事件，因为整个游戏退出，会调用所有的onHide，那时系统参数已经清空了
function UISetting:onHide()
	self:_saveValues()
	self._isShowed = false
end

function UISetting:_onBtnLogoutClick(sender)
	local serverId = game.service.LocalPlayerService.getInstance():getGameServerId();
	game.service.LoginService.getInstance():logout(serverId);
end

function UISetting:_onBtnFixGameClick(sender)
	-- 统计设置页修复游戏次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.SetupFix_Click)
	
	game.ui.UIMessageBoxMgr.getInstance():show("点击修复游戏会重新加载游戏资源，是否确认修复？", {"确定", "取消"}, function()
		game.service.UpdateService.getInstance():clearDownloadedData()
	end, function()
	end,
	true)
end

-- 申请解散房间
function UISetting:_onBtnBreakBattleClick(sender)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Application_Dissolution)
	-- 如果打开界面，然后进入最终结算的话，RoomService会被清空的
	if game.service.RoomService.getInstance() then
		game.service.RoomService.getInstance():startVoteDestroy()
	end
	
	UIManager:getInstance():destroy("UISetting")
end

-- 更新界面显示控制
function UISetting:_refrashUpdatePannel()
	-- body
	local needUpdate = game.service.LoginService.getInstance():getIsNeedUpdate()
	self._update_Button:setEnabled(needUpdate)
	if needUpdate == true then
		self._update_Text:setString("检测到有新版本")		
	else
		self._update_Text:setString("您已经是最新版本")		
	end
end

-- 下载最新版本
function UISetting:_onBtnUpdateClick(sender)
	local downloadUrl = config.GlobalConfig.getDownloadUrl();
	cc.Application:getInstance():openURL(config.GlobalConfig.getConfig().SHARE_HOSTNAME .. downloadUrl)
	--牌局回放点击量
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_Setting_Update)
end

function UISetting:_onSliderSFXChanged(sender)
	local sfx = sender:getPercent() * 0.01
	manager.AudioManager.getInstance():setEffectVolumeUser(sfx)		
end

function UISetting:_onSliderBGMChanged(sender)
	local volume = sender:getPercent() * 0.01
	manager.AudioManager.getInstance():setMusicVolumeUser(volume)	
end

function UISetting:needBlackMask() return true end

function UISetting:closeWhenClickMask() return true end

-- TODO:暂时这样处理
function UISetting:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

--[[	进入前台的时候，调整Push设置.
	除了检查服务器支不支持，还要保证本地推送已经打开
]]
function UISetting:_onEnterForeground()
	local isPushEnable = game.service.JPushService.getInstance():isEnabled()
	-- 推送按钮不显示（TODO:断线重连后接受到事件 isPushEnable 为 true 暂时直接隐藏）
	local pushToggleText = seekNodeByName(self._panel_effect, "Text_3_1", "ccui.Text")
	pushToggleText:setVisible(false)
	self._toggle_TuiSongKaiGuan:setVisible(false)
	
	if isPushEnable then
		local isStartBattlePushEnable = game.service.PushService.getInstance():isPushTypeEnabled(game.service.PushService.PushType.StartBattle)
		and not game.service.JPushService.getInstance():isPushStopped()
		self._toggle_TuiSongKaiGuan:setSelected(isStartBattlePushEnable)
	end
end


-- 取消注册前后台切换事件监听
function UISetting:destroy()
	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)
		self._listenerEnterForeground = nil;
	end
	self._isShowed = false
end

function UISetting:_on3DChanged(group, index, token)
	local val = group[1]:isSelected()
	
	if self._inBattleScene or self._inCampaignScene then
		CardFactory:getInstance():change2or3D(val)
	else
		game.service.GlobalSetting.getInstance().is3D = val
		config.change2D3DReset()
	end
	
	
	-- 数据统计 点击
	local descrption = "THREED_Click_" ..(val and " ON" or " OFF")
	game.service.DataEyeService.getInstance():onEvent(descrption)
	-- 数据统计 状态
	game.service.DataEyeService.getInstance():onStatusEvent("THREED", "THREED_" ..(val and " ON" or " OFF"))
	
	if iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Mahjong") then
		game.service.RoomCreatorService.getInstance():queryBattleIdReq(game.service.RoomService:getInstance():getRoomId(), nil, false);
	end

	-- 3D模式没有经典模式
	self._checkBoxClassic:setEnabled(not val)

end

function UISetting:_onClassic(group, index, token)
	local val = group[1]:isSelected()
	game.service.GlobalSetting.getInstance().isClassic = val
	
	self:_updataClassicStatus(val)
	game.service.DataEyeService.getInstance():onEvent("THREED_" .. token ..(val and "_ON" or "_OFF"))
	if iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Mahjong") then
		game.service.RoomCreatorService.getInstance():queryBattleIdReq(game.service.RoomService:getInstance():getRoomId(), nil, false);
	end
end

-- 更新经典模式
function UISetting:_updataClassicStatus(isClassic)
	if isClassic then
		self._desktop_cbx_group:setSelectedIndexWithoutCallback(1)
		self._bg_cbx_card:setSelectedIndex(1)
		
		if self._isShowed then
			game.ui.UIMessageTipsMgr.getInstance():showTips("经典模式不支持切换颜色!")
		end
		
		-- self._desktop_cbx_group:forEach(function(idx, item)
		-- 	item:setSelected(false)
		-- end)
		-- self._bg_cbx_card:forEach(function(idx, item)
		-- 	item:setSelected(false)
		-- end)
	end
	
	-- self._desktop_cbx_group:forEach(function(idx, item)
	-- 	item:setEnabled(not isClassic)
	-- end)
	-- self._bg_cbx_card:forEach(function(idx, item)
	-- 	item:setEnabled(not isClassic)
	-- end)
end




function UISetting:_onBtnLogUploadClick()
    game.service.UploadLogService:getInstance():doUpload()
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

function MyCheckBoxGroup._selectedCanTouch()
	return true
end


return UISetting 