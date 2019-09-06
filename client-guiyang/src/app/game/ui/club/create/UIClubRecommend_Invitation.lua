local csbPath = "ui/csb/Club/UIClubRecommend_Invitation.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
--[[
    用户推荐
        亲友圈邀请
]]

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemClubRecommendInvitationItem = class("UIElemClubRecommendInvitationItem")

function UIElemClubRecommendInvitationItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemClubRecommendInvitationItem)
    self:_initialize()
    return self
end

function UIElemClubRecommendInvitationItem:_initialize()
    self:setAnchorPoint(0, 0)
    self._textClubName = seekNodeByName(self, "Text_name_mjg", "ccui.Text") -- 亲友圈名字
    self._textCreateTime = seekNodeByName(self, "Text_time_mjg", "ccui.Text") -- 亲友圈创建时间
    self._textManagerName = seekNodeByName(self, "Text_name_jingli", "ccui.Text") -- 亲友圈群主昵称
    self._textNumber_People = seekNodeByName(self, "Text_z_renshu", "ccui.Text") --亲友圈人数
    self._textNumber_Card = seekNodeByName(self, "Text_z_jushu", "ccui.Text") -- 亲友圈牌局数
    self._textAbnormalRate = seekNodeByName(self, "Text_z_jsyc", "ccui.Text") -- 亲友圈异常率
    self._textInvitationTiem = seekNodeByName(self, "Text_wb_time", "ccui.Text") -- 邀请时间

    self._btnAccept = seekNodeByName(self, "Button_js", "ccui.Button") -- 接受
    self._btnRefuse = seekNodeByName(self, "Button_jj", "ccui.Button") -- 拒绝

    self._btnView = seekNodeByName(self, "Button_View", "ccui.Button") -- 查看

    self._textStatus = seekNodeByName(self, "Text_Status", "ccui.Text") -- 状态
end

function UIElemClubRecommendInvitationItem:setData(val)
    if self._data == val then
        return
    end

    self._data = val

    self._textClubName:setString(self:_getClubName(val.clubName))
    self._textCreateTime:setString(string.format("(创建时间:%s)", os.date("%Y-%m-%d", val.createTime/1000)))
    self._textManagerName:setString(self:_getClubName(val.managerName))
    self._textNumber_People:setString(string.format("%d", val.memberCount))
    self._textNumber_Card:setString(string.format("%d/%d", val.todayRoomCout, val.sevenDayRoomCount))
    self._textAbnormalRate:setString(string.format("%d%%", val.clubRoomAbnormalRate * 100))
    self._textInvitationTiem:setString(os.date("%m-%d %H:%M", val.invitedTime/1000))

    self._btnAccept:setVisible(val.status == ClubConstant:getClubInvitationStatus().NORMAL)
    self._btnRefuse:setVisible(val.status == ClubConstant:getClubInvitationStatus().NORMAL)

    -- 默认不显示
    self._textStatus:setVisible(false)
    self._btnView:setVisible(false)

    if val.status == ClubConstant:getClubInvitationStatus().ACCEPT then
        -- 如果群主没有填写内容就不显示查看按钮
        if val.invitedMsg == "" then
            self._textStatus:setVisible(true)
            self._textStatus:setString("已接受")
        else
            self._btnView:setVisible(true)
        end
    elseif val.status == ClubConstant:getClubInvitationStatus().REFUSE then
        self._textStatus:setVisible(true)
        self._textStatus:setString("已拒绝")
    end
    
    bindEventCallBack(self._btnAccept, function()
        -- 统计亲友圈用户点击邀请列表界面内的“接受” 
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_receive);

        -- 如果群主没有填写内容就不显示联系内容
        if val.invitedMsg == "" then
            self:_onClickAccept(val)
        else
            UIManager:getInstance():show("UIClubInformation", val)
        end
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRefuse, function()
        self:_onClickRefuse(val)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(self._btnView, function()
        -- 统计亲友圈用户点击已接受邀请，查看“邀请信息” 
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_club_recommend_check);
        UIManager:getInstance():show("UIClubInformation", val)
    end, ccui.TouchEventType.ended)
end

-- 同意
function UIElemClubRecommendInvitationItem:_onClickAccept(clubInvitationInfo)
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLClubInvitationResultREQ(clubInvitationInfo, true, ClubConstant:getClubInvitationSourceType().RECOMMAND)
end

-- 拒绝
function UIElemClubRecommendInvitationItem:_onClickRefuse(clubInvitationInfo)
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLClubInvitationResultREQ(clubInvitationInfo, false, ClubConstant:getClubInvitationSourceType().RECOMMAND)
end

-- 截取名字
function UIElemClubRecommendInvitationItem:_getClubName(name)
    return game.service.club.ClubService.getInstance():getInterceptString(name, 8)
end


local UIClubRecommend_Invitation = class("UIClubRecommend_Invitation", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRecommend_Invitation:ctor()
    self._btnQuit = nil -- 退出
    self._reusedListInvitations = nil -- 邀请的list
    self._textNotProcess = nil -- 未处理
end

function UIClubRecommend_Invitation:init()
    self._btnQuit = seekNodeByName(self, "Button_x_ClubCL", "ccui.Button")
    self._textNotProcess = seekNodeByName(self, "Text_Notes_Accept", "ccui.Text")
    self._reusedListInvitations = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_Club", "ccui.ListView"), UIElemClubRecommendInvitationItem)
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListInvitations:setScrollBarEnabled(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuit), ccui.TouchEventType.ended)
end

function UIClubRecommend_Invitation:onShow()
    local clubMemberService = game.service.club.ClubService.getInstance():getClubMemberService()

    -- 清空列表
    self._reusedListInvitations:deleteAllItems()
    
    -- 监听事件
    clubMemberService:addEventListener("EVENT_USER_RECOMMAND_INVITATION_RETRIVED", handler(self, self._onRecommandInvitationRetrived), self)
    clubMemberService:addEventListener("EVENT_USER_RECOMMAND_INVITATION_CHANGED", handler(self, self._onRecommandInvitationChanged), self)

    -- 请求数据
    clubMemberService:_sendCCLAllInvitationREQ(ClubConstant:getClubInvitationSourceType().RECOMMAND)
end

function UIClubRecommend_Invitation:_onRecommandInvitationRetrived(event)
    -- 清空列表
    self._reusedListInvitations:deleteAllItems()

    self._textNotProcess:setString(string.format("未处理邀请:%d", event.unprocessedCount))

    local clubService = game.service.club.ClubService.getInstance()

    -- 排序:未处理的>已处理的,时间靠前的>时间靠后的
    table.sort(clubService:getUserData().RecommandInvitation, function(a, b)
        if a.status == b.status then
            return a.invitedTime > b.invitedTime
        end
        return a.status < b.status
    end)

    for idx,invitation in ipairs(clubService:getUserData().RecommandInvitation) do
        self._reusedListInvitations:insertItem(idx, invitation)
    end
end

-- 更新操作数据
function UIClubRecommend_Invitation:_onRecommandInvitationChanged(event)
     -- 更新List中数据
    local clubService = game.service.club.ClubService.getInstance()

    self._textNotProcess:setString(string.format("未处理邀请:%d", event.unprocessedCount))
    
    local invitationIdx = clubService:getUserData():indexOfRecommandInvitation(event.clubId, event.inviterId)
    local itemIdx = self:_indexOfInvitation(event.clubId, event.inviterId)
    if invitationIdx == false then
        -- 删除数据        
        if Macro.assertFalse(itemIdx ~= false) then
            self._reusedListInvitations:deleteItem(itemIdx)
        end
    else
        -- 更新数据
        self._reusedListInvitations:updateItem(itemIdx, clubService:getUserData().RecommandInvitation[invitationIdx])
    end

     -- 邀请信息已经查看
    clubService:getUserData():mergeRecommandInvitationChange()
end

-- 查找item
function UIClubRecommend_Invitation:_indexOfInvitation(clubId, inviterId)
    for idx,item in ipairs(self._reusedListInvitations:getItemDatas()) do
        if item.clubId == clubId and item.inviterId == inviterId then
            return idx
        end
    end

    return false;
end

function UIClubRecommend_Invitation:_onBtnQuit()
    UIManager:getInstance():hide("UIClubRecommend_Invitation")
end

function UIClubRecommend_Invitation:onHide()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)
    -- 清空列表
    self._reusedListInvitations:deleteAllItems()
end

function UIClubRecommend_Invitation:needBlackMask()
	return true
end

function UIClubRecommend_Invitation:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRecommend_Invitation:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRecommend_Invitation