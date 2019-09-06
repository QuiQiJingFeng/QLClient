local csbPath = "ui/csb/Club/UIClubManager.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local ListFactory = require("app.game.util.ReusedListViewFactory")

local UIClubManager = class("UIClubManager", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
	俱乐部管理界面
]]

local Click = {}

function UIClubManager:ctor()
	self._clubId = nil
end

function UIClubManager:init()
	self._imgMask = seekNodeByName(self, "Image_mask", "ccui.ImageView")
	self._panelManager = seekNodeByName(self, "Panel_3", "ccui.Layout")
	self._imgMask:setVisible(false)
	self._beginX = self._panelManager:getPositionX()


	self._listType = ListFactory.get(
        seekNodeByName(self, "ListView_clubManager", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
end

function UIClubManager:_onListViewInit(listItem)
	listItem.textIntroduction = seekNodeByName(listItem, "Text_introduction", "ccui.Text")
	listItem.textName = seekNodeByName(listItem, "BitmapFontLabel_typeName", "ccui.TextBMFont")
	listItem.checkBoxOperating = seekNodeByName(listItem, "CheckBox_operating", "ccui.CheckBox")
end

function UIClubManager:_onListViewSetData(listItem, data)
	listItem.textIntroduction:setString(data.text)
	listItem.textName:setString(data.name)
	listItem.checkBoxOperating:setVisible(data.isCheckBox)
	local clubService = game.service.club.ClubService.getInstance()
	if data.isCheckBox then
		-- checkBox 特殊处理一下
		if data.click == "Freeze" then
			listItem.checkBoxOperating:setSelected(clubService:getClubSettingInfo(self._clubId, ClubConstant.getClubSwitchType().FROZEN_ROOM))
		elseif data.click == "ShowOpenTable" then
			listItem.checkBoxOperating:setSelected(clubService:getClubSettingInfo(self._clubId, ClubConstant.getClubSwitchType().FULL_PLAYER_ROOM))
		elseif data.click == "ForbiddenShareWords" then
			listItem.checkBoxOperating:setSelected(clubService:getClubSettingInfo(self._clubId, ClubConstant.getClubSwitchType().FORBIDDEN_SHARE_WORDS))
		end
		
		bindEventCallBack(listItem.checkBoxOperating, function(sender)
			local func = Click[data.click]
			func(self._clubId, sender)
		end, ccui.TouchEventType.ended)
		
	else
		-- 自己做一个点击效果
		listItem:addTouchEventListener(function(sender, event)
			if event == ccui.TouchEventType.ended then
				local func = Click[data.click]
				if data.click == "RapidRoomSetting" then
					self:_hide()
				end
				func(self._clubId)
				sender:setScale(1)
			elseif event == ccui.TouchEventType.canceled then
				sender:setScale(1)
			elseif event == ccui.TouchEventType.began then
				sender:setScale(0.97)
			end
		end)
	end
end

function UIClubManager:onShow(clubId)
	self._clubId = clubId
	self._listType:deleteAllItems()

	local clubService = game.service.club.ClubService.getInstance()
	local isManager = clubService:isMeManager(self._clubId)

	-- 分享文字战绩白名单内是否开启
	local dcd = clubService:getClub(self._clubId).data
	local dd = ClubConstant:getWhiteListType()
	local openShareWordsReport = bit.band(clubService:getClub(self._clubId).data.clubWhiteList, ClubConstant:getWhiteListType().BUSINESSCARD) > 0

	local OPERATING_TYPE =
	{
		--[[
			name:名称
			text:介绍
			click:回调方法
			isCheckBox:是否显示chechBox
			isShow:是否显示改类型
		]]
		{name = "参与赛事", text = "输入赛事ID参与比赛", click = "JoinLeague", isCheckBox = false, isShow = isManager},
		{name = "数据统计", text = "统计打牌玩家数和房卡消耗数", click = "DataCount", isCheckBox = false, isShow = true},
		{name = "玩法禁用", text = string.format("可以禁用%s内的玩法", config.STRING.COMMON), click = "RullSetting", isCheckBox = false, isShow = true},
		{name = "活动", text = string.format("可以配置%s内活动", config.STRING.COMMON), click = "Activity", isCheckBox = false, isShow = isManager},
		{name = "一键开房设置", text = "设置快速开房的玩法详情", click = "RapidRoomSetting", isCheckBox = false, isShow = true},
		{name = "禁用分享文字战绩", text = "", click = "ForbiddenShareWords", isCheckBox = true, isShow = openShareWordsReport},
		{name = "显示已开局牌桌", text = "", click = "ShowOpenTable", isCheckBox = true, isShow = true},
		{name = string.format("冻结%s", config.STRING.COMMON), text = "", click = "Freeze", isCheckBox = true, isShow = true},
		{name = string.format("解散%s", config.STRING.COMMON), text = string.format("将%s解散", config.STRING.COMMON), click = "Dismiss", isCheckBox = false, isShow = isManager},
		{name = string.format("转让%s", config.STRING.COMMON), text = "将群主权限转移给其他亲友", click = "Transfer", isCheckBox = false, isShow = false},
	}

    clubService:getClubManagerService():addEventListener("EVENT_CLUB_SETTING_CHANGED", handler(self, self._refreshClubSetting), self)

    for k, v in ipairs(OPERATING_TYPE) do
		if v.isShow then
        	self._listType:pushBackItem(v)
		end
    end
	
	self._panelManager:setPositionX(self._beginX)
    self._panelManager:stopAllActions();
	local action1 = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(-self._panelManager:getContentSize().width,0)))
	self._panelManager:runAction(action1)

	self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
	if self._mask then
		self._mask:setOpacity(170)
	end

	self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
	self._mask:setVisible(true)
	bindEventCallBack(self._mask, handler(self, self._hide), ccui.TouchEventType.ended)
end

-- 刷新俱乐部设置状态
function UIClubManager:_refreshClubSetting(event)
	if event.clubId ~= self._clubId then
        return
    end
	-- 只更新带有checkBox的item
	for idx, item in ipairs(self._listType:getItemDatas()) do
        if item.isCheckBox then
			self._listType:updateItem(idx, item)
        end
    end

end

-- 设置玩法规则
Click.RullSetting = function(clubId)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_PlayingLaw_Click);
	local club = game.service.club.ClubService.getInstance():getClub(clubId)
	local banGameplays = club and club.data and club.data.banGameplays or {};        -- 服务器传回的已被禁止项
	UIManager:getInstance():show("UICreateRoom", clubId, ClubConstant:getGamePlayType().reverse, banGameplays)
end

-- 一键开房设置
Click.RapidRoomSetting = function(clubId)
	-- 统计经理创建房间模板点击次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_RapidRoomLaw_Click);
	local clubService = game.service.club.ClubService.getInstance();
	if clubService:getMaxPresetGamePlay(clubId) == 1 then
		local banGameplays = clubService:getBanGameplays(clubId)
		local presetGameplays = clubService:getPresetGameplays(clubId)
		UIManager:getInstance():show("UICreateRoom", clubId, ClubConstant:getGamePlayType().stencil, banGameplays, presetGameplays)
	else
		UIManager:getInstance():show("UIClubRuleSetting", clubId)
	end
end

--点击数据统计
Click.DataCount = function(clubId)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Data_Click);
	UIManager:getInstance():show("UIClubDataReview", clubId)
end

--解散亲友圈
Click.Dismiss = function(clubId)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Data_Click);
	game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBROOM_STRING_105, {"确定", "取消"}, function()
		local clubService = game.service.club.ClubService.getInstance()
		local club = clubService:getClub(clubId)
		if club.data ~= nil then
			-- 给群主二次确认是否解散亲友圈，亲友圈有其他成员就再次让群主确认，没有直接解散
			if club.data.memberCount > 1 then
				game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBROOM_STRING_108, {"确定", "取消"}, function()
					game.service.club.ClubService.getInstance():getClubManagerService():sendCCLRemoveClubREQ(clubId)
				end)
			else
				game.service.club.ClubService.getInstance():getClubManagerService():sendCCLRemoveClubREQ(clubId)
			end
		end
	end)
end

--转让亲友圈(暂无功能)
Click.Transfer = function(clubId)
	
end

--点击是否显示已开房间
Click.ShowOpenTable = function(clubId, sender)
    local isSelected = sender:isSelected()

    game.service.DataEyeService.getInstance():onEvent("alltable" .. (isSelected and "_on" or "_off")); 
    
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(clubId,  ClubConstant:getClubSwitchType().FULL_PLAYER_ROOM, isSelected)
end

--点击战绩分享
Click.ForbiddenShareWords = function(clubId, sender)
    local isSelected = sender:isSelected()

    game.service.DataEyeService.getInstance():onEvent("forbiddenshareWords" .. (isSelected and "_on" or "_off")); 
    
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(clubId,  ClubConstant:getClubSwitchType().FORBIDDEN_SHARE_WORDS, isSelected)
end

--点击是否冻结亲友圈
Click.Freeze = function(clubId, sender)
    local isSelected = sender:isSelected()
    game.service.DataEyeService.getInstance():onEvent("club_frozen" .. (isSelected and "_on" or "_off")); 
    if isSelected then
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBROOM_STRING_109 , {"确定","取消"}, function()
            game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(clubId,  ClubConstant:getClubSwitchType().FROZEN_ROOM, isSelected)
        end, function()
            sender:setSelected(not isSelected)
        end)
    else
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubSwitchREQ(clubId,  ClubConstant:getClubSwitchType().FROZEN_ROOM, isSelected)
    end
end

Click.JoinLeague = function(clubId)
	-- 显示参与赛事界面
	UIManager:getInstance():show("UIKeyboard", "参与赛事", 10, "赛事邀请码输入错误，请重新输入", "确定",function (leagueId)
		game.service.bigLeague.BigLeagueService:getInstance():sendCCLQueryLeagueNameREQ(leagueId, clubId)
	end)
end

-- 活动
Click.Activity = function(clubId)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Activity_System);
    UIManager:getInstance():show("UIClubActivityMain", clubId)
end

function UIClubManager:_hide()
	self._mask:setVisible(false)
	self._panelManager:stopAllActions();
    self._panelManager:setPositionX(display.width);
    local act1 = cc.MoveBy:create(0.3, cc.p(self._panelManager:getContentSize().width,0))
    local act2 = cc.CallFunc:create(function()
		UIManager:getInstance():hide("UIClubManager")
    end)
    self._panelManager:runAction(cc.Sequence:create(act1,act2))
end

function UIClubManager:onHide()
	game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
	self._listType:deleteAllItems()
end

function UIClubManager:needBlackMask()
	return true
end

function UIClubManager:closeWhenClickMask()
	return false
end

return UIClubManager