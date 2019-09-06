local csbPath = "ui/csb/Club/UIClubJoin_Recommend.csb"
local super = require("app.game.ui.UIBase")
local UIElemCombobox = require("app.game.ui.element.UIElemCombobox")
local UIClubElemRecommend = import(".UIClubElemRecommend")

--[[
    没有邀请码
        用户推荐
]]

local SHOW_SETTING = {
	{
		idx = {1,2},
		str = {config.STRING.UICLUBJOIN_RECOMMEND_STRING_100,config.STRING.UICLUBJOIN_RECOMMEND_STRING_101}
	},
}

local UIClubJoin_Recommend = class("UIClubJoin_Recommend", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubJoin_Recommend:ctor()
    self._btnStart = seekNodeByName(self, "Button_sqjl_Clublist_tj", "ccui.Button") -- 提交申请
    self._btnStop = seekNodeByName(self, "Button_sqjl_Clublist_tz", "ccui.Button") -- 停止接受邀请
    self._btnView = seekNodeByName(self, "Button_View", "ccui.Button") -- 查看邀请
    self._textNotice = seekNodeByName(self, "Text_xz_0", "ccui.Text") -- 显示亲友圈邀请的个数
    self._panelView = seekNodeByName(self, "Panel_View", "ccui.Layout") -- 查看的panel
    
    self._textOptionContent =seekNodeByName(self, "Text_OptionContent", "ccui.Text") -- 选项内容

    self._imgRed = seekNodeByName(self, "Image_red", "ccui.ImageView") -- 查看邀请小红点

    self._textTime = seekNodeByName(self, "Text_Tiem", "ccui.Text") -- 倒计时

    self._btnSelect = seekNodeByName(self, "Button_combo", "ccui.Button") -- 选择框

    self._releaseMsgType = 1 --保存选择发布语的类型
    self._isFirstTime = true -- 是不是第一次申请

    self._btnStart:setVisible(true)
    self._btnStop:setVisible(false)

    self._elemNotice = UIClubElemRecommend.extend(
        seekNodeByName(self, "pageview_Notice", "ccui.PageView"),
        nil,
        seekNodeByName(self, "listview_Indicator", "ccui.ListView")
	)

    self:_registerCallBack()
end

-- 按钮注册事件
function UIClubJoin_Recommend:_registerCallBack()
    bindEventCallBack(self._btnStart, handler(self, self._onClickStart), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnStop, handler(self, self._onClickStop), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnView, handler(self, self._onClickView), ccui.TouchEventType.ended)
end


function UIClubJoin_Recommend:show()
    self:setVisible(true)
    self:setPosition(0, 0)
    local clubMemberService = game.service.club.ClubService.getInstance():getClubMemberService()
    clubMemberService:addEventListener("EVENT_CLUB_RECOMMENDINFO_RETRIVED", function(event)
        self:_onClubRecommendinfoRetrived(event.isVisible, event.releaseTime)
    end, self)
    clubMemberService:addEventListener("EVENT_CLUB_RELEASE_STATUS", handler(self, self._onClubReleaseStatus), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)

    -- 请求推荐信息发布的状态
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    clubMemberService:sendCCLQueryReleaseStatusREQ(areaId)
    
    -- 初始化combo
	self._comboOptionContent = UIElemCombobox.new(self._btnSelect, function(index, str)
        self._releaseMsgType = index
        self._textOptionContent:setString(str)
    end)

    self._comboOptionContent:setTextArray(SHOW_SETTING[1].str)
	self._comboOptionContent:setDir(UIElemCombobox.DIR.DOWN)
    self:_showTabBadge()

    local data =
    {
        {tp = UIClubElemRecommend.NOTICE_CONFS.ELEM_TYPE.IMAGE, title = "", content = "club/img_tc1.png", content_ext = nil},
        {tp = UIClubElemRecommend.NOTICE_CONFS.ELEM_TYPE.IMAGE, title = "", content = "club/img_tc2.png", content_ext = nil},
        {tp = UIClubElemRecommend.NOTICE_CONFS.ELEM_TYPE.IMAGE, title = "", content = "club/img_tc3.png", content_ext = nil},
    }

    self._elemNotice:load(UIClubElemRecommend.NOTICE_CONFS.fromProtocol(data), {
		function()
		end,
		function()
		end,
        function()
		end,
	})
end

function UIClubJoin_Recommend:_showTabBadge()
    local service = game.service.club.ClubService.getInstance()
    self._imgRed:setVisible(service:getUserData():hasRecommandInvitationBadges())
end

-- 提交申请
function UIClubJoin_Recommend:_onClickStart()
    -- 统计亲友圈提交按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.club_submit_applications);

    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    self._btnSelect:setEnabled(false)
    if self._isFirstTime then
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLReleaseRecommandInfoREQ(areaId, self._textOptionContent:getString(), self._releaseMsgType)
    else
        game.ui.UIMessageBoxMgr.getInstance():show("重新发布信息，会清空之前的邀请信息，请确认您已经处理了之前的邀请？" , {"确定", "取消"}, function ()
            game.service.club.ClubService.getInstance():getClubMemberService():sendCCLReleaseRecommandInfoREQ(areaId, self._textOptionContent:getString(), self._releaseMsgType)
        end)
    end
end

-- 停止接受邀请
function UIClubJoin_Recommend:_onClickStop()
    -- 统计亲友圈停止接受邀请的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.club_stop_recieving_invitation);

    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLCancelRecommandInfoREQ(areaId)
end

-- 按钮改变状态
function UIClubJoin_Recommend:_onClubRecommendinfoRetrived(isVisible, releaseTime)
    self._btnStart:setVisible(not isVisible)
    self._btnStop:setVisible(isVisible)
    self._btnSelect:setEnabled(false)
    if releaseTime ~= -1 then
        local newTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
        -- 停止按钮不显示并且冷却时间没有到才能显示冷却时间提示
        local aa = newTime - releaseTime
        if isVisible or newTime > releaseTime then
            self._textTime:setString("")
            self._btnStart:setEnabled(true)
            self._btnSelect:setEnabled(true and not isVisible)
        else
            self._textTime:setString(string.format("%s后才能重新申请", os.date("%m-%d %H:%M", releaseTime/1000)))
            self._btnStart:setEnabled(false)
        end
    end

    self._panelView:setVisible(true)
end

function UIClubJoin_Recommend:_onClubReleaseStatus(event)
    self._textNotice:setString(string.format(config.STRING.UICLUBJOIN_RECOMMEND_STRING_102, event.releaseInfo.checkTimes, event.releaseInfo.invitedTimes))
    self:_onClubRecommendinfoRetrived(event.releaseInfo.isInRecommandList, event.releaseInfo.releaseTime)

    -- 第一次不显示查看邀请功能
    self._isFirstTime = event.releaseInfo.isFirstTime
    self._panelView:setVisible(not event.releaseInfo.isFirstTime)
end

-- 查看邀请
function UIClubJoin_Recommend:_onClickView()
    -- 统计亲友圈查看邀请的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_check_invitation);

    UIManager:getInstance():show("UIClubRecommend_Invitation")
end

function UIClubJoin_Recommend:hide()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIClubJoin_Recommend
