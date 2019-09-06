--[[房间结算界面
--]]
local csbPath = "ui/csb/UIFinalReport.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")
local Version = require "app.kod.util.Version"
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local PlayerUI = class("PlayerUI")
local UIFinalReport = class("UIFinalReport", super, function() return kod.LoadCSBNode(csbPath) end)

---------------------------------------------------------------
function PlayerUI:ctor(root, index)
	self._root = root
	self._index = index
	self._listview = seekNodeByName(root, "ListView_Score_Player" .. index .. "_FinalReport", "ccui.ListView")
	self._imageFace = seekNodeByName(root, "Image_face_Player" .. index .. "_FinalReport", "ccui.ImageView")
	self._textName = seekNodeByName(root, "Text_name_Player" .. index .. "_FinalReport", "ccui.Text")
	self._textID = seekNodeByName(root, "Text_ID_Player" .. index .. "_FinalReport", "ccui.Text")
	self._textScore = seekNodeByName(root, "BitmapFontLabel_Score_Player" .. index .. "_FinalReport", "ccui.TextBMFont")
	self._imgHost = seekNodeByName(root, "Image_fz_player" .. index .. "_FinalReport", "ccui.ImageView")
	self._timeLog = seekNodeByName(root, "Text_time_Player" .. index .. "_FinalReport", "ccui.Text")
	self._imgDissolve = seekNodeByName(root, "Image_js_player" .. index .. "_FinalReport", "ccui.ImageView")
	-- 不显示滚动条, 无法在编辑器设置
	self._listview:setScrollBarEnabled(false)
end

function PlayerUI:show()
	self._root:setVisible(true)
end

function PlayerUI:hide()
	self._root:setVisible(false)
end

function PlayerUI:setVisible(isShow)
	self._root:setVisible(isShow)
end

function PlayerUI:setData(player, matchResultsData)
	game.util.PlayerHeadIconUtil.setIcon(self._imageFace, player.headIconUrl)
	
	self._textName:setString(kod.util.String.getMaxLenString(player.name, 8))
	
	self._textID:setString("ID:" .. player.roleId)
	self._imgHost:setVisible(player:isHost())
	self._imgDissolve:setVisible(matchResultsData.applicant)
	UtilsFunctions.setScoreWithColor(self._textScore, matchResultsData.totalPoint)
	-- 设置延时显示
	-- local t = matchResultsData.averageTime
	-- s = "平均出牌时间"..os.date("%M", t).."分"..os.date("%S", t).."秒"
	--将平均出牌时间改为最长超时
	local s = nil
	local t = matchResultsData.delayTime
	s = "最长超时时间" .. os.date("%M", t) .. "分" .. os.date("%S", t) .. "秒"
	self._timeLog:setString(s)
	self:_fillListView(matchResultsData.gameResult)
end

function PlayerUI:_fillListView(gameResult)
	local modelNode = seekNodeByName(self._listview, "Panel_Score_PlayerLine_FinalReport", "ccui.Layout")
	modelNode:setVisible(false)
	local firstItem = true
	for _, data in ipairs(gameResult) do
		local node = nil
		if firstItem then
			firstItem = false
			modelNode:setVisible(true)
			node = modelNode
		else
			node = modelNode:clone()
			node:setName("Panel_Score_PlayerLine_FinalReport_cloned")
			self._listview:addChild(node)
		end
		local textName = seekNodeByName(node, "BitmapFontLabel_1_Playerline_FinalReport", "ccui.TextBMFont")
		local textTimes = seekNodeByName(node, "BitmapFontLabel_2_Playerline_FinalReport", "ccui.TextBMFont")
		if data.type == Constants.PlayType.DISPLAY_JI_COUNT then
			textName:setString(Constants.SpecialEvents.getName(data.type, data.addOperation) .. "个数")
		else
			textName:setString(Constants.SpecialEvents.getName(data.type, data.addOperation) .. "次数")
		end
		
		textTimes:setString(data.times)
	end
end

function PlayerUI:clear()
	local children = self._listview:getChildren()
	for _, child in ipairs(children) do
		if child:getName() == "Panel_Score_PlayerLine_FinalReport_cloned" then
			child:removeFromParent()
		end
	end
end
---------------------------------------------------------------
---------------------------------------------------------------
function UIFinalReport:ctor()
	self._btnCardInfo = nil	    -- 底牌详情
	self._btnShare = nil		-- 分享
	self._btnContinue = nil		-- 返回
	self._playerUIs = {}
	self._players = {}
	self._finalReportData = nil
	
	self._text_Date = nil
	self._text_MaxRoundCount = nil
	self._text_RoomId = nil
	
	--是否展示评估信息
	self._bShowAccess = nil;
	
	-- 亲友圈显示
	self._textClubName = nil
	self._textClubId = nil
	self._panelClub	= nil

	-- 保存一下俱乐部Id
	self._clubId = 0
	-- 保存一下玩家id
	self._friendIds = {}
	-- 联盟id
	self._leagueId = 0
end

function UIFinalReport:init()
	self._btnShare = seekNodeByName(self, "Button_2_PlayerScene", "ccui.Button")
	self._btnContinue = seekNodeByName(self, "Button_fh_top_Clubpj", "ccui.Button")
	self._btnShareDingDing = seekNodeByName(self, "btnShareDing", "ccui.Button")
	self.__btnCardInfo = seekNodeByName(self, "Button_5_PlayerScene", "ccui.Button")
	self._btnSavePhoto = seekNodeByName(self, "Button_6_PlayerScene", "ccui.Button")
	
	self._text_Date = seekNodeByName(self, "Text_Date", "ccui.Text")
	self._text_MaxRoundCount = seekNodeByName(self, "Text_Count", "ccui.Text")
	self._text_RoomId = seekNodeByName(self, "Text_RoomId", "ccui.Text")
	self._textClubName = seekNodeByName(self, "Text_1_mjgId", "ccui.Text")
	self._panelClub = seekNodeByName(self, "Panel_mjgId", "ccui.Layout")
	self._textClubId = seekNodeByName(self, "Text_1_mjgId_0", "ccui.Text")

	self._btnRenewal = seekNodeByName(self, "Button_renewal", "ccui.Button")
	self._btnRenewal:setVisible(false)
	bindEventCallBack(self._btnRenewal, handler(self, self._onClickRenewale), ccui.TouchEventType.ended)
	--提审相关（微信分享按钮隐藏）
	--bindEventCallBack(self.__btnCardInfo, handler(self, self._onCardInfo),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShareDingDing, handler(self, self._onClickShareDing), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnContinue, handler(self, self._onClickContinue), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnSavePhoto, handler(self, self._onClickSavePhoto), ccui.TouchEventType.ended)
	self.__btnCardInfo:setVisible(false)
	if GameMain.getInstance():isReviewVersion() then
		self._btnShare:setVisible(false)
	end
	
	for i = 1, 4 do
		local root = seekNodeByName(self, "Panel_Player" .. i .. "_FinalReport", "ccui.Layout")
		self._playerUIs[i] = PlayerUI.new(root, i)
	end
	
end
function UIFinalReport:needBlackMask()
	return true
end

function UIFinalReport:closeWhenClickMask()
	return false
end

-- 是否使用个人名片功能
function UIFinalReport:_useIdentityShare()
	local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
	if club ~= nil and club.data ~= nil and club.data.clubWhiteList ~= nil then
		local result1 = bit.band(club.data.clubWhiteList, ClubConstant:getWhiteListType().BUSINESSCARD) > 0
		local result2 = bit.band(club.data.switches, ClubConstant:getClubSwitchType().FORBIDDEN_SHARE_WORDS) > 0
		return result1 and not result2
	else
		return false
	end
end

function UIFinalReport:_changeBtnStyle()
	local isBindDing = game.service.LocalPlayerService.getInstance():getIsBindDingTalk()
	local usingBusinessCard = self:_useIdentityShare()

	local btnYellowText = self._btnSavePhoto:getChildByName("BitmapFontLabel_2_0_0")
	local btnGreenText = self._btnShare:getChildByName("BitmapFontLabel_2")
	if usingBusinessCard then
		btnYellowText:setString("分享截图")
		btnGreenText:setString("复制战绩")
	else
		btnYellowText:setString("保存到相册")
		btnGreenText:setString("分享战绩")
	end
	if isBindDing then
		self._btnShareDingDing:setVisible(true)
		self._btnSavePhoto:setPositionPercent(cc.p(0.3, 0.078))
		self._btnShare:setPositionPercent(cc.p(0.5, 0.078))
		self._btnShareDingDing:setPositionPercent(cc.p(0.7, 0.078))
	else
		self._btnShareDingDing:setVisible(false)
		self._btnSavePhoto:setPositionPercent(cc.p(0.3, 0.078))
		self._btnShare:setPositionPercent(cc.p(0.7, 0.078))
	end
end
function UIFinalReport:onShow(...)
	local winPrize = game.service.LocalPlayerService:getInstance():getWinPrizeNum()
	if winPrize then
		UIManager:getInstance():show("UIAward", winPrize)
		game.service.LocalPlayerService:getInstance().winPirzeNum = nil
	end
	local args = {...}
	self:_clearData()
	local finalReportData = args[2] -- net.core.protocol.BCFinalMatchResultSYN
	if not finalReportData or not finalReportData.gameResults then return end
	
	local gameResults = finalReportData.gameResults
	self._gameResults = finalReportData
	self._players = args[1]
	
	for i = 1, #self._players do
		self._playerUIs[i]:setVisible(true)
		if i > #gameResults then
			self._playerUIs[i]:setVisible(false)
		else
			local playerData = self:_findPlayerData(gameResults[i].roleId)
			-- 保存一下当前的玩家
			if playerData.roleId ~= game.service.LocalPlayerService.getInstance():getRoleId() then
				table.insert(self._friendIds, playerData.roleId)
			end
			self._playerUIs[i]:setData(playerData, gameResults[i])
		end
	end
	
	for i = #self._players + 1, #self._playerUIs do
		self._playerUIs[i]:setVisible(false)
	end
	
	for i = 1, #self._players do
		if #gameResults == 4 then
		elseif #gameResults == 2 then
			self._playerUIs[i]._root:setPosition(self._playerUIs[i]._root:getPositionX() + 230, self._playerUIs[i]._root:getPositionY())
		elseif #gameResults == 3 then
			self._playerUIs[i]._root:setPosition(self._playerUIs[i]._root:getPositionX() + 115, self._playerUIs[i]._root:getPositionY())
		end
	end
	
	self._text_RoomId:setString(tostring(finalReportData.roomId));
	self._text_MaxRoundCount:setString(tostring(finalReportData.maxRoundCount));
	self._text_Date:setString(os.date("%Y-%m-%d %H:%M", finalReportData.roomCreateTime / 1000))

	self._leagueId = finalReportData.leagueId

	if finalReportData.clubId == nil or finalReportData.clubId == 0 then
		self._clubId = 0
		self._panelClub:setVisible(false)
	else
		self._clubId = finalReportData.clubId
		self._textClubName:setString(string.format(config.STRING.UIFINALREPORT_STRING_100, finalReportData.clubName))
		self._textClubId:setString(string.format("id:%d", finalReportData.clubId))
	end
	-- --判断是否符合打开ios评价功能的相关条件
	-- if game.plugin.Runtime.isCommentSupported() then
	--     local globalSettings = game.service.GlobalSetting.getInstance()
	-- 	--当前时间(下载游戏3天之后才可以弹出评价窗口)
	-- 	local nowtime = math.ceil(kod.util.Time.now())
	-- 	--展示次数条件(展示3次都未评价,则不再弹出评价窗口)
	-- 	local assessShowCount = globalSettings.assessShowCount +  1;
	-- 	if math.floor((nowtime - globalSettings.firstLoginTime) / 60 / 60) > 72 and assessShowCount <= 3 then
	-- 		--玩家个人id
	-- 		local selfRoleId = game.service.LocalPlayerService.getInstance():getRoleId();
	-- 		local maxPointId = 0;
	-- 		local maxPoint = 0;
	-- 		for i=1,#gameResults do
	-- 			if gameResults[i].totalPoint > maxPoint then
	-- 				maxPoint = gameResults[i].totalPoint;
	-- 				maxPointId = i;
	-- 			end
	-- 		end
	-- 		--大赢家条件(玩家总积分数 > 50)
	-- 		if gameResults[maxPointId].roleId == selfRoleId and maxPoint > 50 then
	-- 			globalSettings.assessShowCount = assessShowCount;
	-- 			globalSettings:saveSetting();
	-- 			self._bShowAccess = true;
	-- 		end
	-- 	end
	-- end
	self:_changeBtnStyle()
	-- 再来一局只有断线重连才显示
	self:_setRenewaleVisible(false)
	game.service.LoginService:getInstance():addEventListener("USER_DATA_RETRIVED", function()
		game.service.DataEyeService.getInstance():onEvent("RenewaleIsVisible_True")
		self:_setRenewaleVisible(true)
	end, self)

	self._clubRoomService = game.service.club.ClubService.getInstance():getClubRoomService()
	self._clubRoomService:addEventListener("GCBusinessCardInfoRES", handler(self, self._shareInfo), self)

	local lotteryGold = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLotteryGold()
	if lotteryGold >= 0 then
		game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setLotteryGold(-1)
		UIManager:getInstance():show("UIBigLeagueLottery", lotteryGold)
	end
end

function UIFinalReport:_findPlayerData(roleId)
	for _, pdata in ipairs(self._players) do
		if pdata.player:getRoomSeat():getPlayer().id == roleId then
			return pdata.player:getRoomSeat():getPlayer()
		end
	end
end

function UIFinalReport:onHide()
	self:_clearData()
	game.service.LoginService.getInstance():removeEventListenersByTag(self)
	self._clubRoomService:removeEventListenersByTag(self)
end

function UIFinalReport:_clearData()
	self._players = {}
	self._friendIds = {}
	self._finalReportData = nil
	self._gameResults = {}
	-- 情况所有UI数据
	for _, playerUI in ipairs(self._playerUIs) do
		playerUI:clear()
	end
end

function UIFinalReport:_onClickShare()
	Logger.debug("_onClickShare")
	local roleIds = {}
	table.foreach(self._gameResults.gameResults,function (k,v)
		table.insert(roleIds, v.roleId)
	end)
	self._clubRoomService:_sendCGBusinessCardInfoREQ(
		{
			area = game.service.LocalPlayerService:getInstance():getArea(),
			roleId = roleIds
		}
	)
end

function UIFinalReport:_shareInfo(event)
	Logger.debug("_shareInfo")
    if self:_useIdentityShare() == true then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Mingpian);
        local textToShare = string.format("房号:%s\n时间:%s\n",self._gameResults.roomId,os.date("%Y-%m-%d %H:%M", self._gameResults.roomCreateTime / 1000))
        table.foreach(self._gameResults.gameResults,function (k,v)
			local upload = false
			if event.buffer.info ~= nil and #event.buffer.info > 0 then
				table.foreach(event.buffer.info, function (key,val)
					if val.roleId == v.roleId then
						upload = val.upload
						Logger.debug("val.roleId = %s", val.roleId)
					end
				end)
			end
            local player = self:_findPlayerData(v.roleId)
            if player == nil then return end
            local tmp = string.format("【%s】ID:%s %s %s\n",kod.util.String.getMaxLenString(player.name, 8), v.roleId, v.totalPoint > 0 and "+" .. v.totalPoint or v.totalPoint, upload and "" or "【✘】")
            textToShare = textToShare .. tmp
        end)
        local area = game.service.LocalPlayerService:getInstance():getArea()
        local str = config.UrlConfig.getBusinessCardUrl()
        local url = string.format( str,area, self._gameResults.roomId, self._gameResults.roomCreateTime, self._gameResults.clubId)
        kod.getShortUrl.doGet7(url,function (shortUrl)
            textToShare = textToShare .. "更多战绩详情请点击:" .. shortUrl
            Logger.debug(textToShare)
            game.plugin.Runtime.setClipboard(textToShare)
            game.ui.UIMessageTipsMgr.getInstance():showTips("已复制")
            if device.platform ~= "windows" then	
                game.service.WeChatService:getInstance():openWXApp()
            else
                game.service.WebViewService.getInstance():openWebView(url)
            end
        end)
    else
        share.ShareWTF.getInstance():share(share.constants.ENTER.FINAL_REPORT, {{enter = share.constants.ENTER.FINAL_REPORT}})
    end
end

function UIFinalReport:_onClickShareDing()
	Logger.debug("_onClickShareDing")
	share.ShareWTF.getInstance():shareDing(share.constants.ENTER.FINAL_REPORT)
end

function UIFinalReport:_onClickSavePhoto()
	if self:_useIdentityShare() == true then
		share.ShareWTF.getInstance():share(share.constants.ENTER.FINAL_REPORT)
		return
	end
	Logger.debug("_onClickSavePhoto")
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(Version.new("4.4.0.0")) < 0 then
		game.ui.UIMessageBoxMgr.getInstance():show("仅最新版支持此功能！",
		{"立即下载", "取消"}, function()
			-- 跳下载页
			cc.Application:getInstance():openURL(config.GlobalConfig.getShareUrl())
		end)
		-- game.ui.UIMessageTipsMgr.getInstance():showTips("本版本暂不支持此功能，请下载新版!")
		return
	end
	-- 统计系统分享
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.ResultPhoto_Save);
	cc.utils:captureScreen(function(succeed, outputFile)
		if succeed == false then return end
		game.plugin.Runtime.savePhoto(outputFile)
		game.ui.UIMessageTipsMgr.getInstance():showTips("已保存至相册")
	end, "ScreenShot.jpg")
end

function UIFinalReport:_onClickContinue()
	-- if self._bShowAccess then
	-- 	--展示评估
	-- 	UIManager:getInstance():show("UIEvaluate")
	-- 	self._bShowAccess = false;
    -- end
    local springInviteService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    if springInviteService:getPopUpWindow() then
        springInviteService:sendCACGodOfWealthInfoREQ()
    end
	UIManager:getInstance():destroy("UIFinalReport")
end

-- 再来一局
function UIFinalReport:_setRenewaleVisible(isVisible)
	-- 只有俱乐部才显示
	self._btnRenewal:setVisible(isVisible and self._clubId ~= 0)
end

function UIFinalReport:_onClickRenewale()
	game.service.DataEyeService.getInstance():onEvent("Click_Renewale")
	if self._clubId ~= 0 then
		-- 获取俱乐部经理id
		local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
		local managerId = club.info.managerId or 0
		-- 创建俱乐部房间
		local roundCount, gamePlays = game.service.club.ClubService.getInstance():getClubRoomService():getRoomRule()
		game.service.RoomCreatorService.getInstance():createClubRoomReq(0, gamePlays, roundCount, self._clubId, managerId, false, {}, ClubConstant:getCreateRoomType().ANOTHER_ROOM_CREATE, self._friendIds)
	else
		local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
		bigLeagueService:sendCCLCreateLeagueRoomREQ(
				bigLeagueService:getLeagueData():getLeagueId(),
				bigLeagueService:getLeagueData():getLeaderId(),
				bigLeagueService:getLeagueData():getClubId(),
				bigLeagueService:getGamePlayId(),
				ClubConstant:getCreateRoomType().ANOTHER_ROOM_CREATE
		)
	end

end

return UIFinalReport