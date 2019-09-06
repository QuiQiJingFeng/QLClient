local csbPath = "ui/csb/Mail/UIApplicationPage.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UIElemStatusItem = class("UIElemStatusItem")
local UIApplicationPage = class("UIApplicationPage", function() return cc.CSLoader:createNode(csbPath) end)

--[[
    亲友圈入会申请列表
]]

local STATUS_TYPE = {
    "art/club/imgt_1.png",
    "art/club/imgt_2.png",
    "art/club/imgt_3.png",
}

function UIElemStatusItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemStatusItem)
    self:_initialize()
    return self
end

function UIElemStatusItem:_initialize()
    self._name = seekNodeByName(self, "Text_name_list_sq_CY_club", "ccui.Text")             -- 名字
    self._id = seekNodeByName(self, "Text_id_list_sq_CY_club", "ccui.Text")                 -- id
    self._time = seekNodeByName(self, "Text_daty_list_sq_CY_club", "ccui.Text")             -- 时间(申请时间/退出时间)
    self._btnAgree = seekNodeByName(self, "Button_1_list_sq_CY_club", "ccui.Button")        -- 同意
    self._btnRefuse = seekNodeByName(self, "Button_2_list_sq_CY_club", "ccui.Button")       -- 拒绝
    self._status = seekNodeByName(self, "Image_1", "ccui.ImageView")                        -- 状态（已同意或拒绝）
    self._admissionMethod = seekNodeByName(self, "Text_admissionMethod", "ccui.Text")       -- 入会方式

    bindEventCallBack(self._btnAgree, handler(self, self._onClickBtnAgree), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRefuse, handler(self, self._onClickBtnRefuse), ccui.TouchEventType.ended)
end

function UIElemStatusItem:getData()
    return self._data
end

-- 整体设置数据
function UIElemStatusItem:setData(applicationInfo)
    self._data = applicationInfo
    
    local roleName = game.service.club.ClubService.getInstance():getInterceptString(applicationInfo.roleName, 8)

    self._name:setString(roleName)
    self._id:setString(applicationInfo.roleId)
    self._time:setString(os.date("%Y-%m-%d\n%H:%M", applicationInfo.applyTimestamp/1000))

    
    local inviterName = game.service.club.ClubService.getInstance():getInterceptString(applicationInfo.inviterName, 8)
    local admissionMethod = applicationInfo.joinType == ClubConstant:getAdmissionMethod().InvitationCode and "邀请码入会" or string.format("%s\n%s", inviterName, "邀请")
    self._admissionMethod:setString(admissionMethod)

    if applicationInfo.status ~= false then
        --服务器是从0开始计数的
        self._status:loadTexture(STATUS_TYPE[applicationInfo.status + 1]);
        self._status:setVisible(true)
        self._btnAgree:setVisible(false);
        self._btnRefuse:setVisible(false);
    else
        self._btnAgree:setVisible(true);
        self._btnRefuse:setVisible(true);
        self._status:setVisible(false)
    end
end

function UIElemStatusItem:_onClickBtnAgree(sender)
    if self._data.isManager then
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBAPPLICATIONPAGE_STRING_100 , {"确定","取消"}, function()
            game.service.club.ClubService.getInstance():getClubManagerService():sendCCLClubApplicantREQ(self._data.clubId, self._data.roleId, 0, 2)
        end)
    else
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLClubApplicantREQ(self._data.clubId, self._data.roleId, 0, 2)
    end
end

function UIElemStatusItem:_onClickBtnRefuse(sender)
    game.ui.UIMessageBoxMgr.getInstance():show(string.format("将要拒绝%s(ID:%d)加入%s是否确认?", self._data.roleName, self._data.roleId, config.STRING.COMMON), {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLClubApplicantREQ(self._data.clubId, self._data.roleId, 1, 2)
    end)
end

function UIApplicationPage:ctor(parent)
    self._parent = parent
    self._textPrompt = seekNodeByName(self, "Text_tiao", "ccui.Text")

    self._reusedListApplications = UIItemReusedListView.extend(seekNodeByName(self, "ListView_list_ClubSq", "ccui.ListView"), UIElemStatusItem)
    self._reusedListApplications:setScrollBarEnabled(false)
end

function UIApplicationPage:show()
    self:setVisible(true)
    self:setPosition(0, 0)
    self._clubId = self._parent:getClubId()

    local clubManagerService = game.service.club.ClubService.getInstance():getClubManagerService()

    -- 尝试请求数据
    clubManagerService:sendCCLClubApplicantListREQ(self._clubId)

    -- 监听事件
    clubManagerService:addEventListener("EVENT_CLUB_APPLICATION_DATA_RETRIVED", handler(self, self._onClubApplicationRetrived), self)
    clubManagerService:addEventListener("EVENT_CLUB_APPLICATION_DATA_CHANGED", handler(self, self._onClubApplicationChanged), self)
end

function UIApplicationPage:hide()
    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
    -- 清空列表
    self._reusedListApplications:deleteAllItems()
    self:setVisible(false)
end

-- 查找item
function UIApplicationPage:_indexOfApplicationItem(roleId)
    for idx,item in ipairs(self._reusedListApplications:getItemDatas()) do
        if item.roleId == roleId then
            return idx
        end
    end

    return false;
end

-- 获取到了房间列表整体数据更新
function UIApplicationPage:_onClubApplicationRetrived(event)
    if event.clubId ~= self._clubId then
        return
    end

    -- 更新List中数据
    local clubService = game.service.club.ClubService.getInstance()
    clubService:getClub(event.clubId):mergeApplicationChange()

    --情况数据
    self._reusedListApplications:deleteAllItems()
    
    local applications = clubService:getClubApplications(event.clubId)
    -- 添加新数据
    for idx,application in ipairs(applications) do
        application.clubId = self._clubId
        self._reusedListApplications:pushBackItem( application)
    end

    self._textPrompt:setVisible(not (#self._reusedListApplications:getItemDatas() > 0))
end

-- 申请人员信息变化通知
function UIApplicationPage:_onClubApplicationChanged(event)
    if event.clubId ~= self._clubId then
        return
    end

    -- 更新List中数据
    local clubService = game.service.club.ClubService.getInstance()
    local clubList = clubService:getClubList()
    local applications = clubList.clubs[clubList:indexOfClub(self._clubId)].application
    local applicationIdx = nil
    for ii = 1, #applications do
        if applications[ii].roleId == event.roleId then
            applicationIdx = ii
        end
    end
    local itemIdx = self:_indexOfApplicationItem(event.roleId)

    if applicationIdx then
        if itemIdx then
            self._reusedListApplications:deleteItem(itemIdx)

            self._reusedListApplications:insertItem(#applications, applications[applicationIdx])
            table.remove( applications , applicationIdx )
        end
    else
        self._reusedListApplications:insertItem(#self._reusedListApplications:getItemDatas(), applications[applicationIdx])
    end

    self._textPrompt:setVisible(not (#self._reusedListApplications:getItemDatas() > 0))
end

return UIApplicationPage
