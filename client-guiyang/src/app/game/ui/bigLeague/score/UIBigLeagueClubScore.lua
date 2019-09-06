--[[
    俱乐部积分列表,展示该俱乐部下所有成员的昵称，Id和赛事分
]]
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local csbPath = "ui/csb/BigLeague/UIBigLeagueClubScore.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueClubScore:UIBase
local UIBigLeagueClubScore = super.buildUIClass("UIBigLeagueClubScore", csbPath)
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
        if info.title ~= ClubConstant:getClubPosition().PARTNER then
            UIManager:getInstance():show("UIBigLeagueScoreDetail", 3, 1, info.clubId, 0, info.roleId)
        else
            UIManager:getInstance():show("UIBigLeagueScoreMain", 4, info.clubId, info.roleId)
        end
    end, ccui.TouchEventType.ended)
end


function UIBigLeagueClubScore:ctor()

end

function UIBigLeagueClubScore:init()
    self._btnClose = seekNodeByName(self, "Button_back_History", "ccui.Button") -- 关闭

    
    self._listClubScore = UIItemReusedListView.extend(seekNodeByName(self, "ListView_ClubScore", "ccui.ListView"), UIClubScoreItem)

    self._textPlayerTotalScore = seekNodeByName(self, "Text_PlayerTotalScore", "ccui.TextBMFont")
end

function UIBigLeagueClubScore:_onBtnClose()
    self:hideSelf()
end

function UIBigLeagueClubScore:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

--
--nType:1表示盟主入口(A入口)
--2表示俱乐部入口(B入口)
--
function UIBigLeagueClubScore:onShow(nType, clubId)
    self._nType = nType
    self._clubId = clubId and clubId or  self._bigLeagueService:getLeagueData():getClubId()
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    
    self._bigLeagueService:addEventListener("EVENT_MEMBER_RECORD", handler(self, self._updateScoreRecord), self)

    self._bigLeagueService:sendCCLQueryClubRecordREQ(self._bigLeagueService:getLeagueData():getLeagueId(), clubId, 0, self._nType, 2)
    self:_registerCallBack()
end

function UIBigLeagueClubScore:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueClubScore:needBlackMask()
    return true
end

function UIBigLeagueClubScore:closeWhenClickMask()
    return false
end

function UIBigLeagueClubScore:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeagueClubScore:_updateScoreRecord()
    local data = self._bigLeagueService:getLeagueData():getMemberRecord(self._clubId)
    dump(data, "_updateScoreRecord~~~~~~~~~~~~")
    self._listClubScore:deleteAllItems()
    local num = 0
    for _,info in ipairs(data) do
        info.clubId = self._clubId
        self._listClubScore:pushBackItem(info)
        num = num + info.score
    end
    self._listClubScore:getInnerContainer():forceDoLayout()
    self._listClubScore:jumpToPercentVertical(0)
    self._textPlayerTotalScore:setString("玩家总分:"..math.round( num * 100 )/ 100)
end
return UIBigLeagueClubScore