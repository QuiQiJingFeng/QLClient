--[[
    大联盟积分列表,展示该联盟下所有俱乐部的昵称，Id，管理名称，Id和赛事分
]]

local csbPath = "ui/csb/BigLeague/UIBigLeagueTeamScore.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueTeamScore:UIBase
local UIBigLeagueTeamScore = super.buildUIClass("UIBigLeagueTeamScore", csbPath)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

--我的积分
local UITeamScoreItem = class("UITeamScoreItem")

function UITeamScoreItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UITeamScoreItem)
    self:_initialize()
    return self
end

function UITeamScoreItem:_initialize()
end

function UITeamScoreItem:setData(info)
    local item = self
    item:getChildByName("Text_ClubName"):setString(getInterceptString(info.clubName))   --名称
    item:getChildByName("Text_ClubId"):setString(info.clubId)     --
    item:getChildByName("Text_PlayerName"):setString(getInterceptString(info.roleName))   --名称
    item:getChildByName("Text_PlayerId"):setString(info.roleId)     --
    item:getChildByName("Text_TotalScore"):setString(math.round(info.score* 100) / 100)       --积分变化

    bindEventCallBack(item:getChildByName("Button_Detail"), function()
        UIManager:getInstance():show("UIBigLeagueScoreMain", 2, info.clubId)
    end, ccui.TouchEventType.ended)
end

function UIBigLeagueTeamScore:ctor()

end

function UIBigLeagueTeamScore:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

    
    self._listTeamScore = UIItemReusedListView.extend(seekNodeByName(self, "ListView_TeamScore", "ccui.ListView"), UITeamScoreItem)

    self._textLeagueTotalScore = seekNodeByName(self, "Text_LeagueTotalScore", "ccui.TextBMFont")

    self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button")

    self._panelTips = seekNodeByName(self, "Panel_Tips", "ccui.Layout")
    self._panelTips:setVisible(false)
    
end

function UIBigLeagueTeamScore:_onBtnClose()
    UIManager:getInstance():show("UIBigLeagueScoreMain", 1)
    self:hideSelf()
end

function UIBigLeagueTeamScore:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    -- self._btnHelp:addTouchEventListener(handler(self, self._onBtnHelp))
end

function UIBigLeagueTeamScore:onShow()
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    
    self._bigLeagueService:addEventListener("EVENT_MEMBER_RECORD", handler(self, self._updateScoreRecord), self)

    self._bigLeagueService:sendCCLQueryClubRecordREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._bigLeagueService:getLeagueData():getClubId(), 0, 1, 1)
    self:_registerCallBack()
end

function UIBigLeagueTeamScore:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueTeamScore:needBlackMask()
    return true
end

function UIBigLeagueTeamScore:closeWhenClickMask()
    return false
end

function UIBigLeagueTeamScore:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeagueTeamScore:_updateScoreRecord()
    local data = self._bigLeagueService:getLeagueData():getMemberRecord()
    self._listTeamScore:deleteAllItems()
    local num = 0
    for _,info in ipairs(data) do
        self._listTeamScore:pushBackItem(info)
        num = num + info.score
    end
    self._listTeamScore:getInnerContainer():forceDoLayout()
    self._listTeamScore:jumpToPercentVertical(0)
    self._textLeagueTotalScore:setString("团队总分:"..math.round( num * 100 )/ 100)
end

function UIBigLeagueTeamScore:_onBtnHelp(obj, eventType)
    -- if eventType == ccui.TouchEventType.began then
    --     self._panelTips:setVisible(true)
    -- elseif eventType == ccui.TouchEventType.moved then
    -- else    -- 其他情况，恢复按钮原始状态
    --     node:setScale(originScale);
    -- end

end
return UIBigLeagueTeamScore