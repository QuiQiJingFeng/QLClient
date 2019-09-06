local csbPath = "ui/csb/Club/UIClubInvitation.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    亲友圈邀请界面
        我的申请，其余玩家的邀请
]]

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemClubInvitationItem = class("UIElemClubInvitationItem")

function UIElemClubInvitationItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemClubInvitationItem)
    self:_initialize()
    return self
end

function UIElemClubInvitationItem:_initialize()
    local panelItem = seekNodeByName(self, "Panel_1_list_ClubSq", "ccui.Layout")
    self._objItem = bindNodeToTarget(panelItem)
end

-- 整体设置数据
function UIElemClubInvitationItem:setData(val) 
    self._data = val

    local textInvitationInfo = self._objItem.Text_dataInfo -- 邀请信息
    local textManagerName = self._objItem.Text_clubManagerName -- 群主名称
    local textPeople = self._objItem.Text_clubPeopleCount -- 亲友圈人数（现人数/总人数）
    local btnAgree = self._objItem.Button_agree -- 同意按钮
    local btnRefuse = self._objItem.Button_refuse -- 拒绝按钮
    local imgStatus = self._objItem.Image_status -- 状态
    local textClubName = self._objItem.Text_clubName -- 俱乐部名称
    local textClubCreateTime = self._objItem.Text_clubCreateTime -- 俱乐部创建时间
    local textRoomCard = self._objItem.Text_roomCard -- 玩家牌局数
    local textAbnormalRate = self._objItem.Text_abnormalRate -- 牌局异常率

    local invitationInfo = ""
    -- 推荐类型
    if val.sourceType == ClubConstant:getClubInvitationSourceType().RECOMMAND then
        invitationInfo = string.format(config.STRING.UICLUBINVITATION_STRING_100, val.cardFriends[1], #val.cardFriends > 1 and string.format("等%d人", #val.cardFriends) or "")

        textRoomCard:setVisible(true)
        textAbnormalRate:setVisible(true)
        local roomCard = string.format("今日/七日牌局数:%d/%d", val.todayRoomCout, val.sevenDayRoomCount)
        textRoomCard:setString(roomCard)
        local abnormalRate = string.format("牌局异常率:%d%%", val.clubRoomAbnormalRate * 100)
        textAbnormalRate:setString(abnormalRate)
    else
        if val.inviterId == game.service.LocalPlayerService:getInstance():getRoleId() then
            -- 自己申请加入不显示邀请人
            invitationInfo = string.format( "已申请加入%s(ID:%s)", self:_getClubName(val.clubName), tostring(val.clubId))
        else
            invitationInfo = string.format( "%s邀请你加入%s(ID:%s)", self:_getClubName(val.inviterName), self:_getClubName(val.clubName), tostring(val.clubId))
        end
        textRoomCard:setVisible(false)
        textAbnormalRate:setVisible(false)
    end
    textInvitationInfo:setString(invitationInfo)

    local managerName = string.format(config.STRING.UICLUBINVITATION_STRING_101, self:_getClubName(val.managerName))
    textManagerName:setString(managerName)

    local clubName = string.format(config.STRING.UICLUBINVITATION_STRING_102, self:_getClubName(val.clubName))
    textClubName:setString(clubName)

    local time = string.format("创建时间:%s", os.date("%Y-%m-%d", val.createTime/1000))
    textClubCreateTime:setString(time)

    local people = string.format(config.STRING.UICLUBINVITATION_STRING_103, tostring(val.memberCount), tostring(val.maxMemberCount))
    textPeople:setString(people)

    -- 0未处理,1已处理(等待群主审批)
    btnAgree:setVisible(val.status == ClubConstant:getClubInvitationStatus().NORMAL)
    btnRefuse:setVisible(val.status == ClubConstant:getClubInvitationStatus().NORMAL)
    imgStatus:setVisible(val.status == ClubConstant:getClubInvitationStatus().WAIT_MANAGER_OPERATE)

    -- 绑定按钮事件
    bindEventCallBack(btnAgree, function()
        self:_onClickAcceptBtn(val)
    end, ccui.TouchEventType.ended)
    bindEventCallBack(btnRefuse, function()
        self:_onClickRejectBtn(val)
    end, ccui.TouchEventType.ended)
end

-- 点击同意邀请
function UIElemClubInvitationItem:_onClickAcceptBtn(clubInvitationInfo)
    -- 如果群主没有填写内容就不显示联系内容
    if clubInvitationInfo.invitedMsg == "" then
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLClubInvitationResultREQ(clubInvitationInfo, true, clubInvitationInfo.sourceType)
    else
        UIManager:getInstance():show("UIClubInformation", clubInvitationInfo)
    end
end

-- 点击拒绝邀请
function UIElemClubInvitationItem:_onClickRejectBtn(clubInvitationInfo)
    game.service.club.ClubService.getInstance():getClubMemberService():sendCCLClubInvitationResultREQ(clubInvitationInfo, false, clubInvitationInfo.sourceType)
end

-- 截取名字
function UIElemClubInvitationItem:_getClubName(name)
    return game.service.club.ClubService.getInstance():getInterceptString(name, 8)
end


local UIClubInvitation = class("UIClubInvitation", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubInvitation:ctor()
    self._btnQuit               = nil       -- 返回
    self._reusedListInvitations = nil       -- 邀请人员列表
    self._textPrompt            = nil       -- 提示框
end

function UIClubInvitation:init()
    self._btnQuit               = seekNodeByName(self, "Button_quit", "ccui.Button")
    self._textPrompt            = seekNodeByName(self, "Text_tiao", "ccui.Text")
    self._reusedListInvitations = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_ClubSq", "ccui.ListView"), UIElemClubInvitationItem)
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListInvitations:setScrollBarEnabled(false)

    self:_registerCallBack()
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubInvitation:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

-- 点击事件注册
function UIClubInvitation:_registerCallBack()
    bindEventCallBack(self._btnQuit, 		handler(self, self._onBtnQuitClick), 		ccui.TouchEventType.ended)
end

function UIClubInvitation:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubInvitation")
end

function UIClubInvitation:onShow()
    -- 清空列表
    self._reusedListInvitations:deleteAllItems()
    self._textPrompt:getParent():setVisible(true)
    
    local clubMemberService = game.service.club.ClubService.getInstance():getClubMemberService()
     -- 监听事件
    clubMemberService:addEventListener("EVENT_USER_INVITATION_RETRIVED", handler(self, self._onUserInvitationRetrived), self)
    clubMemberService:addEventListener("EVENT_USER_INVITATION_CHANGED", handler(self, self._onUserInvitationChanged), self)

    -- 尝试请求数据
    clubMemberService:tryQueryDirtyUserInvitations()
end

function UIClubInvitation:onHide()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)

    -- 清空列表
    self._reusedListInvitations:deleteAllItems()
end

-- 查找item
function UIClubInvitation:_indexOfInvitation(clubId, inviterId)
    for idx,item in ipairs(self._reusedListInvitations:getItemDatas()) do
        if item.clubId == clubId and item.inviterId == inviterId then
            return idx
        end
    end

    return false;
end

-- 邀请列表整体数据更新
function UIClubInvitation:_onUserInvitationRetrived(event)
    -- 更新List中数据
    local clubService = game.service.club.ClubService.getInstance()
    
    -- 清空列表
    self._reusedListInvitations:deleteAllItems()

    -- 更新/添加数据
    for idx,invitation in ipairs(clubService:getUserData().invitations) do
        -- 客户端做一下处理已经接受的和拒绝的不显示
        if invitation.status <= ClubConstant:getClubInvitationStatus().WAIT_MANAGER_OPERATE then
            self._reusedListInvitations:pushBackItem(invitation)
        end
    end

    -- 没有邀请信息显示提示条
    self._textPrompt:getParent():setVisible(not (#self._reusedListInvitations:getItemDatas() > 0))
end

-- 邀请列表单条数据更新
function UIClubInvitation:_onUserInvitationChanged(event)
     -- 更新List中数据
    local clubService = game.service.club.ClubService.getInstance()
    
    local invitationIdx = clubService:getUserData():indexOfInvitation(event.clubId, event.inviterId)
    local itemIdx = self:_indexOfInvitation(event.clubId, event.inviterId)
    if invitationIdx == false then
        -- 删除数据        
        if Macro.assertFalse(itemIdx ~= false) then
            self._reusedListInvitations:deleteItem(itemIdx)
        end
    else
        -- 更新数据
        self._reusedListInvitations:updateItem(itemIdx, clubService:getUserData().invitations[invitationIdx])
    end
    -- 邀请信息已经查看
    clubService:getUserData():mergeInvitationChange()
end

function UIClubInvitation:needBlackMask()
	return true
end

function UIClubInvitation:closeWhenClickMask()
	return false
end

return UIClubInvitation
