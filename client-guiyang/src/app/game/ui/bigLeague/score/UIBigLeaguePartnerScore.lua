--[[
    俱乐部积分列表,展示该俱乐部下所有成员的昵称，Id和赛事分
]]
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local csbPath = "ui/csb/BigLeague/UIBigLeaguePartnerScore.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeaguePartnerScore:UIBase
local UIBigLeaguePartnerScore = super.buildUIClass("UIBigLeaguePartnerScore", csbPath)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

--我的积分
local UIClubScoreItem = class("UIClubScoreItem")

function UIClubScoreItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIClubScoreItem)
    self:_initialize()
    return self
end

function UIClubScoreItem:_initialize()
end

function UIClubScoreItem:setData(info)

    local item = self
    item:getChildByName("Text_Name"):setString(info.roleName)   --名称
    item:getChildByName("Text_Id"):setString(info.roleId)                  --id
    item:getChildByName("Text_Score"):setString(math.round(info.score* 100) / 100)   --分数
    item:getChildByName("Text_Title"):setString( ClubConstant:getClubTitle(info.title))

    bindEventCallBack(item:getChildByName("Button_Detail"), function()
        UIManager:getInstance():show("UIBigLeagueScoreDetail", 3, 1, info.clubId, info.partnerId, info.roleId)
    end, ccui.TouchEventType.ended)
end


function UIBigLeaguePartnerScore:ctor()

end

function UIBigLeaguePartnerScore:init()
    self._btnClose = seekNodeByName(self, "Button_back_History", "ccui.Button") -- 关闭

    
    self._listPartnerScore = UIItemReusedListView.extend(seekNodeByName(self, "ListView_ClubScore", "ccui.ListView"), UIClubScoreItem)

    self._textPlayerTotalScore = seekNodeByName(self, "Text_PlayerTotalScore", "ccui.TextBMFont")
end

function UIBigLeaguePartnerScore:_onBtnClose()
    self:hideSelf()
end

function UIBigLeaguePartnerScore:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

--
--nType:1表示盟主入口(A入口)
--2表示俱乐部入口(B入口)
--
function UIBigLeaguePartnerScore:onShow(nType, clubId, partnerId)
    self._nType = nType
    self._clubId = clubId and clubId or  self._bigLeagueService:getLeagueData():getClubId()
    self._partnerId = partnerId
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    
    self._bigLeagueService:addEventListener("EVENT_MEMBER_RECORD", handler(self, self._updateScoreRecord), self)

    self._bigLeagueService:sendCCLQueryClubRecordREQ(self._bigLeagueService:getLeagueData():getLeagueId(), clubId, self._partnerId, self._nType, 2)
    self:_registerCallBack()
end

function UIBigLeaguePartnerScore:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeaguePartnerScore:needBlackMask()
    return true
end

function UIBigLeaguePartnerScore:closeWhenClickMask()
    return false
end

function UIBigLeaguePartnerScore:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeaguePartnerScore:_updateScoreRecord()
    local data = self._bigLeagueService:getLeagueData():getPartnerRecord()
    self._listPartnerScore:deleteAllItems()
    local num = 0
    for _,info in ipairs(data) do
        info.clubId = self._clubId
        info.partnerId = self._partnerId
        self._listPartnerScore:pushBackItem(info)
        num = num + info.score
    end
    self._listPartnerScore:getInnerContainer():forceDoLayout()
    self._listPartnerScore:jumpToPercentVertical(0)
    self._textPlayerTotalScore:setString("搭档下属玩家总分:"..math.round( num * 100 )/ 100)
end
return UIBigLeaguePartnerScore