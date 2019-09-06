local csbPath = "ui/csb/Club/UIClubList2.csb"
local super = require("app.game.ui.UIBase")

local UIClubList2 = class("UIClubList2", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubList2:ctor()
end

function UIClubList2:init()
    self._panel = seekNodeByName(self, "Panel_clubs", "ccui.Layout")
    self._beginX = self._panel:getPositionX()

    self._btnFind = seekNodeByName(self, "Button_find", "ccui.Button") -- 搜索
    self._btnCreate = seekNodeByName(self, "Button_create", "ccui.Button") -- 创建俱乐部
    self._btnApply = seekNodeByName(self, "Button_apply", "ccui.Button") -- 申请列表
    self._imgApplyRed = seekNodeByName(self, "Image_red", "ccui.ImageView") -- 申请列表红点

    -- 俱乐部列表
    self._listClubs = seekNodeByName(self, "ListView_clubs", "ccui.ListView")
    self._listClubs:setScrollBarEnabled(false)

    self._clubInfoItemBig = ccui.Helper:seekNodeByName(self._listClubs, "Panel_club")
    self._clubInfoItemBig:removeFromParent(false)
    self:addChild(self._clubInfoItemBig)
    self._clubInfoItemBig:setVisible(false)


    bindEventCallBack(self._btnCreate, handler(self, self._onCreateClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFind, handler(self, self._onBtnFindClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnApply, handler(self, self._onBtnApplyClick), ccui.TouchEventType.ended)
end

function UIClubList2:onShow()
    self._panel:setPositionX(self._beginX - self._panel:getContentSize().width)
    self._panel:stopAllActions();
    local action1 = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(self._panel:getContentSize().width, 0)))
    self._panel:runAction(cc.Sequence:create(action1, action2))

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    if self._mask then
        self._mask:setOpacity(170)
    end

    self:_showTabBadge()
    self:_onUpdataClubList()
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_ADDED", handler(self, self._onUpdataClubList), self)
    game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_DELETED", handler(self, self._onUpdataClubList), self)

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView")
    self._mask:setVisible(true)
    bindEventCallBack(self._mask, handler(self, self._hide), ccui.TouchEventType.ended)
end

function UIClubList2:_hide()
    self._mask:setVisible(false)
    self._panel:stopAllActions();
    self._panel:setPositionX(self._beginX);
    local act1 = cc.MoveBy:create(0.3, cc.p(-self._panel:getContentSize().width, 0))
    local act2 = cc.CallFunc:create(function()
		UIManager:getInstance():hide("UIClubList2")
    end)
    self._panel:runAction(cc.Sequence:create(act1,act2))
end

function UIClubList2:_showTabBadge()
    local service = game.service.club.ClubService.getInstance()
    self._imgApplyRed:setVisible(service:getUserData():hasInvitationBadges())
end

function UIClubList2:_onUpdataClubList()
     local clubList = game.service.club.ClubService.getInstance():getClubList()

    -- 清空列表
    self._listClubs:removeAllChildren()

    if #clubList.clubs > 0 then
        for clubIdx, club in ipairs(clubList.clubs) do
            local node = self._clubInfoItemBig:clone()
            self._listClubs:addChild(node)
            node:setVisible(true)
            -- 俱乐部名字
            local textClubName = ccui.Helper:seekNodeByName(node, "Text_name")
            local name = game.service.club.ClubService.getInstance():getInterceptString(club.info.clubName)
            textClubName:setString(name)
            -- 俱乐部icon
            local imgClubIcon = ccui.Helper:seekNodeByName(node, "Image_icon")
            local name = game.service.club.ClubService.getInstance():getInterceptString(club.info.clubName)
            imgClubIcon:loadTexture(game.service.club.ClubService.getInstance():getClubIcon(club.info.clubIcon))
            -- 俱乐部id
            local textClubId = ccui.Helper:seekNodeByName(node, "Text_id")
            local id = string.format("(ID:%s)", tostring(club.info.clubId))
            textClubId:setString(id)
            -- 俱乐部红点
            local imgClubIcon = ccui.Helper:seekNodeByName(node, "Image_red")
            imgClubIcon:setVisible(club:hasApplicationBadges() or club:hasTaskBadges())

            bindEventCallBack(node, function()
                local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
                localStorageClubInfo:setClubId(club.info.clubId)
                game.service.club.ClubService.getInstance():saveLocalStorageClubInfo(localStorageClubInfo)
                game.service.club.ClubService.getInstance():enterClub()
            end, ccui.TouchEventType.ended)
        end
    end
    
    self._listClubs:requestDoLayout()
    self._listClubs:doLayout()
end

-- 查找亲友圈
function UIClubList2:_onBtnFindClick()
    UIManager:getInstance():show("UIKeyboard", "输入邀请码", 6, "邀请码输入有误，请重新输入", "提交申请", function (code)
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLAccedeToClubInfoREQ(code)
    end)
end

-- 我的申请列表
function UIClubList2:_onBtnApplyClick()
    UIManager:getInstance():show("UIClubInvitation")
end

function UIClubList2:_onCreateClick()
    UIManager:getInstance():show("UIClubCreate2")
end

function UIClubList2:onHide()
    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
end

function UIClubList2:needBlackMask()
	return true
end

function UIClubList2:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubList2:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubList2