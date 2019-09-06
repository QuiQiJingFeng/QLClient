local csbPath = "ui/csb/Club/UIClubMemberPage.csb"
local super = require("app.game.ui.UIBase")

--[[
    亲友圈成员主界面
        显示群主界面和成员界面
]]

local UIClubMemberPage = class("UIClubMemberPage", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubMemberPage:ctor()
    self._btnQuit = nil -- 返回
    self._uiElem = nil
    self._textPeoples = nil

    self._maxMemberCount = 0
    self._memberCount = 0
end

function UIClubMemberPage:init()
    self._btnQuit = seekNodeByName(self, "Button_Quit", "ccui.Button")
    self._textPeoples = seekNodeByName(self, "TextBMFont_Peoples", "ccui.TextBMFont")

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIClubMemberPage:onShow(clubId)
    self.clubId = clubId

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self.clubId)

    self:_setPeoples(0, 0)

    local isPermissions = club:isPermissions(game.service.LocalPlayerService:getInstance():getRoleId())

    local clz = require("app.game.ui.club.member.UIClubMemberPage_Member")
    if isPermissions then
        clz = require("app.game.ui.club.member.UIClubMemberPage_Manager")
    end

    if self._uiElem == nil then
        self._uiElem = clz.new(self)
        self:addChild(self._uiElem)
        self._uiElem:setPosition(0, 0)    
    end

    self._uiElem:show()

    -- 亲友圈成员信息
    local clubMemberService = clubService:getClubMemberService()
    local clubManagerService = clubService:getClubManagerService()
    clubMemberService:sendCCLClubMembersREQ(self.clubId)

    -- 亲友圈成员信息
    clubMemberService:addEventListener("EVENT_CLUB_MEMBER_DATA_RETRIVED", handler(self, self._onClubMemberRetrived), self)
    -- 自己退出的监听
    clubMemberService:addEventListener("EVENT_USER_CLUB_QUIT_INFO", handler(self, self._onClubQuitChanged), self)
    -- 备注变化监听
    clubMemberService:addEventListener("EVENT_CLUB_REMARK_CHANGE", handler(self, self._onClubRemarkChange), self)
    -- 成员头衔发生变化
    clubManagerService:addEventListener("EVENT_CLUB_MANAGER_CHANGED",          handler(self, self._onClubManagerChanged), self)
    -- 玩家被踢出
    clubManagerService:addEventListener("EVENT_CLUB_MEMBER_DATA_CHANGED",      handler(self, self._onClubMemberChanged), self)
end

-- 更新亲友圈人数显示
function UIClubMemberPage:_setPeoples(memberCount, maxMemberCount)
    local peoples = string.format("%d/%d", memberCount, maxMemberCount)
    self._textPeoples:setString(peoples)
end

-- 返回牌局界面
function UIClubMemberPage:_onBtnQuitClick()
    UIManager:getInstance():show("UIClubRoom", self.clubId)
    UIManager:getInstance():hide("UIClubMemberPage")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubMemberPage:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UIClubMemberPage:_onClubQuitChanged(event)
    if event.clubId ~= self.clubId then
        return
    end
    -- 自己退出，清空本地缓存，返回亲友圈主界面
    local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
    localStorageClubInfo:setClubId(0)
    game.service.club.ClubService.getInstance():saveLocalStorageClubInfo(localStorageClubInfo)
    GameFSM.getInstance():enterState("GameState_Lobby")
end

-- 玩家列表
function UIClubMemberPage:_onClubMemberRetrived(event)
    if event.clubId ~= self.clubId then
        return
    end

    local clubService = game.service.club.ClubService.getInstance()
    local club = clubService:getClub(self.clubId)
    self._maxMemberCount = event.maxMemberCount
    self._memberCount = #club.members

    self:_setPeoples(self._memberCount, self._maxMemberCount)

    if self._uiElem ~= nil then
        -- TODO:子界面重写
        self._uiElem:onClubMemberRetrived(club.members)
    end
end

-- 刷新玩家职位
function UIClubMemberPage:_onClubManagerChanged(event)
    if event.playerInfo.clubId ~= self.clubId then
        return
    end

    if self._uiElem ~= nil then
        -- TODO:子界面重写
        self._uiElem:onClubManagerChanged(event)
    end
end

-- 玩家被踢
function UIClubMemberPage:_onClubMemberChanged(event)
    if event.clubId ~= self.clubId then
        return
    end

    self._memberCount = self._memberCount - 1
    self:_setPeoples(self._memberCount, self._maxMemberCount)

    if self._uiElem ~= nil then
        -- TODO:子界面重写
        self._uiElem:onClubMemberChanged(event)
    end
end

-- 玩家备注
function UIClubMemberPage:_onClubRemarkChange(event)
    if event.clubId ~= self.clubId then
        return
    end

    if self._uiElem ~= nil then
        -- TODO:子界面重写
        self._uiElem:onClubRemarkChange(event)
    end
end

function UIClubMemberPage:onHide()
    self._uiElem:hide()
    self._uiElem = nil
    -- 键盘自动隐藏
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setIMEKeyboardState(false)

    -- 取消事件监听
    game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

return UIClubMemberPage