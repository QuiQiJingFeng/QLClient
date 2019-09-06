local csbPath = "ui/csb/BigLeague/UIBigLeagueMemberSetting.csb"
local super = require("app.game.ui.UIBase")
local UIBigLeagueMemberSetting = class("UIBigLeagueMemberSetting", super, function() return kod.LoadCSBNode(csbPath) end)
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local Click = {}

local ModifyMemberScoreType =
{
    ORDER = 1, -- 指派出战
    FORCE_QUIT = 2, -- 强制退赛
    MODIFY = 3, -- 调整分数
}

local settings =
{
    ["UIBigLeagueMember_Member"] =
    {
        [1] = {name = "指派参赛", isVisible = true, click = "AssignEntry", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [2] = {name = "强制退赛", isVisible = true, click = "ForcedWithdrawal", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [3] = {name = "调整分数", isVisible = false, click = "AdjustmentScore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [4] = {name = "设为管理", isVisible = true, click = "Manager", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [5] = {name = "撤职", isVisible = true, click = "Dismissal", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [6] = {name = "设为搭档", isVisible = true, click = "Partner", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [7] = {name = "暂停参与赛事", isVisible = true, click = "Suspend", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [8] = {name = "恢复参与赛事", isVisible = true, click = "Restore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
        [9] = {name = config.STRING.UICLUBMEMBERSETTING_STRING_101, isVisible = true, click = "Reject", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER},
    },
    ["UIBigLeagueMember_Partner"] =
    {
        [1] = {name = "调整分数", isVisible = false, click = "AdjustmentScore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().PARTNER},
        [2] = {name = "设置活跃值赠送", isVisible = true, click = "Gift", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().PARTNER},
        [3] = {name = "暂停参与赛事", isVisible = true, click = "Suspend", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().PARTNER},
        [4] = {name = "恢复参与赛事", isVisible = true, click = "Restore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().PARTNER},
        [5] = {name = "取消搭档", isVisible = true, click = "DismissalPartner", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().PARTNER},
    },
    ["UIBigLeagueMember"] =
    {
        [1] = {name = "指派参赛", isVisible = true, click = "AssignEntry", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
        [2] = {name = "强制退赛", isVisible = true, click = "ForcedWithdrawal", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
        [3] = {name = "调整分数", isVisible = true, click = "AdjustmentScore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
        [4] = {name = "暂停参与赛事", isVisible = true, click = "Suspend", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
        [5] = {name = "恢复参与赛事", isVisible = true, click = "Restore", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
        [6] = {name = config.STRING.UICLUBMEMBERSETTING_STRING_101, isVisible = true, click = "Reject", memberType = game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getMemberType().MEMBER_PARTNER},
    },
}

function UIBigLeagueMemberSetting:ctor()

end

function UIBigLeagueMemberSetting:init()
    self._listviewSetting = seekNodeByName(self, "ListView_Member_Setting", "ccui.ListView") -- 玩家权限修改列表

    self._listviewSetting:setScrollBarEnabled(false)
    self._listviewSetting:setTouchEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listviewSetting, "Button_Member_Setting")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

    self._img_bj = seekNodeByName(self, "Panel_Settings", "ccui.Layout")
end

function UIBigLeagueMemberSetting:onShow(pos, memberInfo, uiName)
    self._pos = pos
    self._memberInfo = memberInfo
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()

    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()

    if uiName == "UIBigLeagueMember_Member" then
        settings[uiName][1].isVisible = tonumber(memberInfo.gameScore) == 0 -- 指派参赛：玩家初始分为0显示
        settings[uiName][2].isVisible = tonumber(memberInfo.gameScore) ~= 0 -- 强制退赛：玩家初始分不为0显示
        -- 设为管理：该玩家的头衔为成员，自己是经理，并且不能给自己设置
        settings[uiName][4].isVisible = memberInfo.title == ClubConstant:getClubPosition().MEMBER and self._bigLeagueService:getLeagueData():isLeader() and memberInfo.roleId ~= localRoleId
        -- 撤职：该玩家的头衔为管理，自己是经理，并且不能给自己设置
        settings[uiName][5].isVisible = memberInfo.title == ClubConstant:getClubPosition().ASSISTANT and self._bigLeagueService:getLeagueData():isLeader() and memberInfo.roleId ~= localRoleId
        settings[uiName][6].isVisible = memberInfo.title == ClubConstant:getClubPosition().MEMBER
        settings[uiName][7].isVisible = not memberInfo.isPauseGame
        settings[uiName][8].isVisible = memberInfo.isPauseGame
        local isPermission = false
        if self._bigLeagueService:getLeagueData():isLeader() then
            isPermission = memberInfo.title ~= ClubConstant:getClubPosition().MANAFER
        elseif self._bigLeagueService:getLeagueData():isAssistant() then
            isPermission = memberInfo.title ~= ClubConstant:getClubPosition().ASSISTANT and memberInfo.title ~= ClubConstant:getClubPosition().MANAFER
        end
        settings[uiName][9].isVisible = isPermission
    elseif uiName == "UIBigLeagueMember_Partner" then
        settings[uiName][3].isVisible = not memberInfo.isPauseGame
        settings[uiName][4].isVisible = memberInfo.isPauseGame
    elseif uiName == "UIBigLeagueMember" then
        settings[uiName][1].isVisible = tonumber(memberInfo.gameScore) == 0 -- 指派参赛：玩家初始分为0显示
        settings[uiName][2].isVisible = tonumber(memberInfo.gameScore) ~= 0 -- 强制退赛：玩家初始分不为0显示
        settings[uiName][3].isVisible = false
        settings[uiName][4].isVisible = not memberInfo.isPauseGame
        settings[uiName][5].isVisible = memberInfo.isPauseGame
        settings[uiName][6].isVisible = memberInfo.title ~= ClubConstant:getClubPosition().PARTNER and self._bigLeagueService:getLeagueData():isPartner()
    end
    
    self:_initListViewSetting(uiName)
end

function UIBigLeagueMemberSetting:_initListViewSetting(uiName)
    self._listviewSetting:removeAllChildren()

    for _, v in ipairs(settings[uiName]) do
        if v.isVisible then
            local node = self._listviewItemBig:clone()
            self._listviewSetting:addChild(node)
            node:setVisible(true)

            local name = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_szgly")
            name:setString(v.name)

            bindEventCallBack(node, function()
                local func = Click[v.click]
                func(self._bigLeagueService, self._memberInfo, v.memberType)
                UIManager:getInstance():hide("UIBigLeagueMemberSetting")
            end, ccui.TouchEventType.ended)
        end
    end

    self._listviewSetting:setTouchEnabled(#self._listviewSetting:getItems() >= 5)

    self:_initPosition()
end

function UIBigLeagueMemberSetting:_initPosition()
    local isRotate = self._pos.y > display.height / 2
    self._pos = self._img_bj:getParent():convertToNodeSpace(self._pos)
    if isRotate then
        self._img_bj:setBackGroundImage("art/img/img_xialabg.png")
        self._img_bj:setAnchorPoint(cc.p(0.5, 1))
        self._img_bj:setPosition(cc.p(self._pos.x - 30, self._pos.y))
    else
        self._img_bj:setBackGroundImage("art/img/img_xialabg2.png")
        self._img_bj:setAnchorPoint(cc.p(0.5, 0))
        self._img_bj:setPosition(cc.p(self._pos.x - 30, self._pos.y - 6))
    end
    self._img_bj:setBackGroundImageCapInsets(cc.rect(25, 38, 12, 9))

    -- 设置list位置
    local count = #self._listviewSetting:getItems()
    -- 起始位置 + 每个item的大小 * item的个数
    local y = (isRotate and 70 or 90) + 70 * (count > 4 and 3.5 or count - 1)
    local y2 = 100 + 70 * (count > 4 and 3.5 or count - 1)
    -- 由于只有一个item时，显示太小，由于九宫格原因图片会变形，临时处理一下只有一个item时增大一下panel的大小
    self._listviewSetting:setPosition(cc.p(123, y + (count == 1 and 5 or 0)))
    self._img_bj:setContentSize(cc.size(245, y2 + (count == 1 and 10 or 0)))

    self._listviewSetting:requestDoLayout()
    self._listviewSetting:doLayout()
end

function UIBigLeagueMemberSetting:onHide()
    self._listviewSetting:removeAllChildren()
end

function UIBigLeagueMemberSetting:needBlackMask()
    return true
end

function UIBigLeagueMemberSetting:closeWhenClickMask()
    return true
end

function UIBigLeagueMemberSetting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end


Click.AssignEntry = function(bigLeagueService, memberInfo, memberType)
    -- 指派参赛
    local str = string.format("参赛分可用%s", math.round(bigLeagueService:getLeagueData():getCurrentScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "设置参赛分", "设置参赛玩家的初始分数", str, false, "", function (score)
        if memberType == bigLeagueService:getLeagueData():getMemberType().MEMBER then
            bigLeagueService:sendCCLModifyMemberScoreREQ(
                    bigLeagueService:getLeagueData():getLeagueId(),
                    bigLeagueService:getLeagueData():getClubId(),
                    memberInfo.roleId,
                    ModifyMemberScoreType.ORDER,
                    score
            )
        else
            bigLeagueService:sendCCLModifyPartnerScoreREQ(
                    bigLeagueService:getLeagueData():getLeagueId(),
                    bigLeagueService:getLeagueData():getClubId(),
                    memberInfo.roleId,
                    memberType - 1, -- 类型（1:经理给搭档调整，2：搭档给搭档成员调整）
                    score
            )
        end
    end)
end

Click.ForcedWithdrawal = function(bigLeagueService, memberInfo, memberType)
    -- 强制退赛
    local str = string.format("玩家参赛初始分数为%s，当前分数为%s，强制退赛后玩家分数将被清零，是否强制玩家退赛？", math.round(memberInfo.initialScore * 100) / 100, math.round(memberInfo.gameScore * 100) / 100)
    game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定","取消"}, function()
        if memberType == bigLeagueService:getLeagueData():getMemberType().MEMBER then
            bigLeagueService:sendCCLModifyMemberScoreREQ(
                    bigLeagueService:getLeagueData():getLeagueId(),
                    bigLeagueService:getLeagueData():getClubId(),
                    memberInfo.roleId,
                    ModifyMemberScoreType.FORCE_QUIT,
                    0
            )
        else
            bigLeagueService:sendCCLModifyPartnerScoreREQ(
                    bigLeagueService:getLeagueData():getLeagueId(),
                    bigLeagueService:getLeagueData():getClubId(),
                    memberInfo.roleId,
                    memberType - 1, -- 类型（1:经理给搭档调整，2：搭档给搭档成员调整）
                    -memberInfo.gameScore
            )
        end
    end)
end

Click.AdjustmentScore = function(bigLeagueService, memberInfo, memberType)
    -- 调整分数
    local str = string.format("参赛分可用%s", math.round(bigLeagueService:getLeagueData():getCurrentScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "调整分数", "请输入调整分数", str, true, "", function (score)
        local text = string.format("玩家调整分数%s，调整后分数为%s", score, math.round(memberInfo.gameScore * 100) / 100 + score)
        game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定"}, function()
            if memberType == bigLeagueService:getLeagueData():getMemberType().MEMBER then
                bigLeagueService:sendCCLModifyMemberScoreREQ(
                        bigLeagueService:getLeagueData():getLeagueId(),
                        bigLeagueService:getLeagueData():getClubId(),
                        memberInfo.roleId,
                        ModifyMemberScoreType.MODIFY,
                        score
                )
            else
                bigLeagueService:sendCCLModifyPartnerScoreREQ(
                        bigLeagueService:getLeagueData():getLeagueId(),
                        bigLeagueService:getLeagueData():getClubId(),
                        memberInfo.roleId,
                        memberType - 1, -- 类型（1:经理给搭档调整，2：搭档给搭档成员调整）
                        score
                )
            end
        end)
    end)
end

Click.Manager = function(bigLeagueService, memberInfo, memberType)
    -- 设为管理员
    local str = string.format("管理拥有除了任命撤职管理以外的所有权限，是否确认将%s设置管理", memberInfo.nickname)
    game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(bigLeagueService:getLeagueData():getClubId(), memberInfo.roleId, ClubConstant:getClubPosition().ASSISTANT)
    end)
end

Click.Dismissal = function(bigLeagueService, memberInfo, memberType)
    -- 撤职
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyMemberTitleREQ(bigLeagueService:getLeagueData():getClubId(), memberInfo.roleId, ClubConstant:getClubPosition().MEMBER)
end

Click.Partner = function(bigLeagueService, memberInfo, memberType)
    -- 设为搭档
    local str = "搭档可以邀请成员进群并对其下属成员加减分，设为搭档后，该成员会显示在搭档页签里，请确认是否将该成员设为搭档？"
    game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
        bigLeagueService:sendCCLOrderPartnerREQ(
                bigLeagueService:getLeagueData():getLeagueId(),
                bigLeagueService:getLeagueData():getClubId(),
                memberInfo.roleId,
                true
        )
    end)

end

Click.DismissalPartner = function(bigLeagueService, memberInfo, memberType)
    -- 取消搭档
    local str = "取消搭档后，其下属成员将同时被踢出团队，且无法恢复，请确认是否取消搭档？"
    game.ui.UIMessageBoxMgr.getInstance():show(str , {"确定","取消"}, function()
        bigLeagueService:sendCCLOrderPartnerREQ(
                bigLeagueService:getLeagueData():getLeagueId(),
                bigLeagueService:getLeagueData():getClubId(),
                memberInfo.roleId,
                false
        )
    end)
end

Click.Suspend = function(bigLeagueService, memberInfo, memberType)
    -- 暂停比赛
    bigLeagueService:sendCCLPauseMemberGameREQ(
            bigLeagueService:getLeagueData():getLeagueId(),
            bigLeagueService:getLeagueData():getClubId(),
            memberInfo.roleId,
            memberType,
            true
    )
end

Click.Restore = function(bigLeagueService, memberInfo, memberType)
    -- 恢复比赛
    bigLeagueService:sendCCLPauseMemberGameREQ(
            bigLeagueService:getLeagueData():getLeagueId(),
            bigLeagueService:getLeagueData():getClubId(),
            memberInfo.roleId,
            memberType,
            false
    )
end

Click.Reject = function(bigLeagueService, memberInfo, memberType)
    -- 踢出俱乐部
    game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMEMBERSETTING_STRING_104 , {"确定","取消"}, function()
        local leagueId = 0
        local partnerId = 0
        if memberType == bigLeagueService:getLeagueData():getMemberType().MEMBER_PARTNER then
            leagueId = bigLeagueService:getLeagueData():getLeagueId()
            -- 目前只能搭档能看见搭档成员界面，这里的搭档id就传自己
            partnerId = game.service.LocalPlayerService:getInstance():getRoleId()
        end
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLKickOffMemberREQ(bigLeagueService:getLeagueData():getClubId(), memberInfo.roleId, leagueId, partnerId)
    end)
end

Click.Gift = function(bigLeagueService, memberInfo, memberType)
    -- 活跃值赠送
    UIManager:getInstance():show("UIBigLeagueFireGive",bigLeagueService:getLeagueData():getClubId(), memberInfo.roleId)
end

return UIBigLeagueMemberSetting