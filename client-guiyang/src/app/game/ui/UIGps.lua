local csbPath = "ui/csb/UIGps.csb"
local super = require("app.game.ui.UIBase")
local SecurityChecker = require("app.gameMode.mahjong.SecurityChecker")

local UIGps = class("UIGps", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGps:ctor()
	self._btnClose    = nil
	self._btnOK       = nil
	self._list_IP     = nil
	self._list_GPS    = nil
	self._btnjsfj     = nil
	self._btnfhdt     = nil
	self._btnsqjsfj   = nil
	
	self._ipItemModel = nil
	self._gpsItemModel = nil

	self._btnTips = nil
	self._layoutTips = nil
	self._txtTips = nil
end

function UIGps:init()
	self._btnClose    = seekNodeByName(self, "Button_x_Gps","ccui.Button")
	self._btnOK       = seekNodeByName(self, "Button_btn1_Gps","ccui.Button")
	self._list_IP     = seekNodeByName(self, "list_1_Gps", "ccui.ListView")
	self._list_GPS    = seekNodeByName(self, "list_2_Gps", "ccui.ListView")
	self._btnjsfj     = seekNodeByName(self, "Button_btn2_Gps","ccui.Button")
	self._btnfhdt     = seekNodeByName(self, "Button_btn3_Gps","ccui.Button")
	self._btnsqjsfj   = seekNodeByName(self, "Button_btn4_Gps","ccui.Button")
	self._btnTips  	  = seekNodeByName(self, "Button_gth1_Gps","ccui.Button")
	self._layoutTips  = seekNodeByName(self, "Panel_tips2_Gps","ccui.Layout")
	self._txtTips     = seekNodeByName(self, "Text_1_Gps","ccui.Text")
	
	self._ipItemModel = seekNodeByName(self, "Panel_0_list1_1_Gps", "ccui.Layout")
	self._gpsItemModel = seekNodeByName(self, "Panel_0_list1_2_Gps", "ccui.Layout")
	
	bindEventCallBack(self._btnClose,    handler(self, self._onClose),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnOK,       handler(self, self._onOK),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnjsfj,     handler(self, self._onDestroyRoom),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnsqjsfj,   handler(self, self._onVoteDestoryRoom),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnfhdt,     handler(self, self._onQuitRoom),ccui.TouchEventType.ended)
	self._btnTips:addTouchEventListener(handler(self, self._onBtnTipsClick))
end

function UIGps:onShow(...)
	self._layoutTips:setVisible(false)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	local isInBattle =  gameService._isGameStarted
	local isHadBeginFirstGame = game.service.RoomService.getInstance():isHaveBeginFirstGame()
	local isWatcher = game.service.LocalPlayerService.getInstance():isWatcher() or false;
	-- 控制退出按钮的状态
	self._btnsqjsfj:setVisible(isInBattle or isHadBeginFirstGame)
	self._btnOK:setVisible(true)
	self._btnjsfj:setVisible(false)
	self._btnfhdt:setVisible(false)
	if (isInBattle or isHadBeginFirstGame) == false then
		local id = game.service.LocalPlayerService.getInstance():getRoleId()
		local player = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(id):getRoomSeat():getPlayer()
		if player ~= nil then
			self._btnjsfj:setVisible(player:isHost())
			self._btnfhdt:setVisible(player:isHost() == false)
		else
			self._btnfhdt:setVisible(true)
		end
	end

	-- 旁观者不从这里解散房间
	self._btnjsfj:setEnabled(not isWatcher);
	self._btnfhdt:setEnabled(not isWatcher);
	self._btnsqjsfj:setEnabled(not isWatcher);

	self._txtTips:setString(string.format("如需GPS检测正常使用，请在打开设备时允许使用GPS，或在设置中开启GPS总开关，并允许“%s”使用GPS。", config.GlobalConfig.getShareInfo()[1]))

	-- 这里只会是在重新进入房间，并且GPS界面打开的情况下才有用
	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._registerRTVoiceEvent), self)
	self:_registerRTVoiceEvent()
	self:_update()
end

function UIGps:onHide()
	-- TODO:如查提前打开界面，然后进入总结算界面，这时候会提前收到退出房间界面的，这个时候再次去手动关闭界面的时候，会报错的！强行保护一下
	if game.service.RoomService.getInstance() then
		local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
		if securityChecker ~= nil then
			securityChecker:removeEventListenersByTag(self)
		end	
	end
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
end

function UIGps:_registerRTVoiceEvent()
	-- 监听安全信息更事件
	if game.service.RoomService.getInstance() == nil then
		return
	end
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	if securityChecker == nil then
		return
	end
	securityChecker:addEventListener("EVENT_SRCURITY_INFO_CHANGED", handler(self, self._onSecurityInfoChanged), self)
end

function UIGps:_clearList()
	self._list_IP:removeAllItems()
	self._list_GPS:removeAllItems()
end

function UIGps:_onBtnTipsClick(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self._layoutTips:setVisible(true)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._layoutTips:setVisible(false)
	end
end

function UIGps:_getBGImage(isSafe)
	local safeImg = "function/icon_risk0.png"
	local ussafeImg = "function/icon_risk1.png"
	
	if isSafe then
		return safeImg, cc.c3b(0x3F,0x91,0x17)
	else
		return ussafeImg, cc.c3b(0xFF, 0xD8, 0x00)
	end
end

function UIGps:_onSecurityInfoChanged(event)
	self:_update();
end

function UIGps:_update()
	-- TODO:在结算前打开GPS界面并且在结算的时候有人掉线就会报错，这里做一层保护
	local securityChecker = game.service.RoomService.getInstance():getSecurityChecker();
	if securityChecker == nil then
		return
	end
	self:_clearList();
	self:_updateIp()
	self:_updateGps()
end

function UIGps:_updateIp()
	local roomService = game.service.RoomService.getInstance();
	local securityChecker = roomService:getSecurityChecker();
	
	-- 获取玩家数组, 按照座位排序
	local players = {}
	for _,v in pairs(roomService:getPlayerMap()) do
		table.insert(players, v);
	end	
	table.sort(players, function(l,r) return l.position < r.position end);
	
	self._list_IP:setItemModel(self._ipItemModel)
	
	for idx,player in ipairs(players) do
		local safe = table.indexof(securityChecker:getSecurityInfo().ipConflictPlayerIds, player.id) == false;		
		local bg, fontColor = self:_getBGImage(safe)
		
		self._list_IP:pushBackDefaultItem()
		
		local _item = self._list_IP:getItem(idx-1)
		local _name = seekNodeByName(_item, "Text_0_name_list1_1_Gps", "ccui.Text")
		local _ip = seekNodeByName(_item, "Text_0_ip_list1_1_Gps", "ccui.Text")
		local _bg = seekNodeByName(_item, "Image_0_list1_1_Gps", "ccui.ImageView")
		
		_name:setString("["..kod.util.String.getMaxLenString(player.name, 8).."]")
		_name:setTextColor(fontColor)
		_ip:setString(player.ip)
		_ip:setTextColor(fontColor)
		_bg:loadTexture(bg)
	end
end

function UIGps:_updateGps()
	local roomService = game.service.RoomService.getInstance();
	local securityChecker = roomService:getSecurityChecker();
	
	self._list_GPS:setItemModel(self._gpsItemModel)
	
	for idx,info in ipairs(securityChecker:getSecurityInfo().gpsConflictInfos) do
		local playerName = kod.util.String.getMaxLenString(self:_getLimitName(roomService:getPlayerById(info.roleId).name), 8);

		local safe = false;
		local desc = "";
		if info.status == SecurityChecker.GPSCheckStatus.DEFAULT then
			-- 玩家正在检测
			desc = "["..playerName.."]GPS信息获取中…";
			safe = true;
		elseif info.status == SecurityChecker.GPSCheckStatus.CLOSE then
			desc = "["..playerName.."]未开启GPS功能";
			-- 玩家GPS关闭
			safe = false;
		elseif info.status == SecurityChecker.GPSCheckStatus.FAIL then
			-- 玩家GSP获取失败
			desc = "["..playerName.."]GPS获取失败";
			safe = false;
		elseif info.status == SecurityChecker.GPSCheckStatus.UNSAFE then
			-- 有冲突
			local playerName2 = kod.util.String.getMaxLenString(self:_getLimitName(roomService:getPlayerById(info.conflictRoleId).name), 8);
			desc = "["..playerName.."]和["..playerName2.."]距离过近"
			safe = false;
		else
			Macro.assetFalse(false);
		end
		
		-- 构造界面
		self._list_GPS:pushBackDefaultItem()
		local _item = self._list_GPS:getItem(idx-1)
		local _text = seekNodeByName(_item, "Text_0_name_list1_2_Gps", "ccui.Text")
		
		local bgImg,fontColor = self:_getBGImage(safe)
		_text:setTextColor(fontColor)
		_text:setString(desc)
		local _img = seekNodeByName(_item, "Image_0_list1_2_Gps", "ccui.ImageView")
		_img:loadTexture(bgImg)
	end
	
	if #securityChecker:getSecurityInfo().gpsConflictInfos == 0 then
		-- 没有要显示的条目, 填充提示内容
		local desc = 0;
		if securityChecker:getPlayerCount() > 1 then
			desc = "GPS检测通过，距离安全"
		else
			desc = "等待其他玩家进入房间"
		end
		
		-- 构造界面
		self._list_GPS:pushBackDefaultItem()
		local _item = self._list_GPS:getItem(0)
		local _text = seekNodeByName(_item, "Text_0_name_list1_2_Gps", "ccui.Text")
		
		local bgImg,fontColor = self:_getBGImage(true)
		_text:setTextColor(fontColor)
		_text:setString(desc)
		local _img = seekNodeByName(_item, "Image_0_list1_2_Gps", "ccui.ImageView")
		_img:loadTexture(bgImg)
	end
end

function UIGps:_getLimitName(name)
	--如果玩家名字长度大于4，则取前4个字
	if string.utf8len(name) > 8 then
		return string.utf8sub(name,1,4)
	end
	return name;
end

function UIGps:_onClose(sender)
	UIManager:getInstance():hide("UIGps")
end

function UIGps:_onOK(sender)
	UIManager:getInstance():hide("UIGps")
end

function UIGps:_onDestroyRoom(sender)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	local isInBattle =  gameService._isGameStarted
	local isHadBeginFirstGame = game.service.RoomService.getInstance():isHaveBeginFirstGame()
	if (isInBattle or isHadBeginFirstGame) == false then
		game.service.RoomService.getInstance():quitRoom()
		UIManager:getInstance():hide("UIGps")
	else
		game.service.RoomService.getInstance():startVoteDestroy()
		UIManager:getInstance():hide("UIGps")
	end
end

function UIGps:_onQuitRoom(sender)
	game.service.RoomService.getInstance():quitRoom()
	UIManager:getInstance():hide("UIGps")
end

function UIGps:_onVoteDestoryRoom(sender)
	game.service.RoomService.getInstance():startVoteDestroy()
	UIManager:getInstance():hide("UIGps")
	game.service.TDGameAnalyticsService.getInstance():onEvent("UI_GPS_DISMISS_ROOM")
end

function UIGps:needBlackMask()
	return true
end

function UIGps:closeWhenClickMask()
	return true
end

return UIGps