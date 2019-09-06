local csbPath = "ui/csb/BigLeague/UIBigLeagueList.csb"
local super = require("app.game.ui.UIBase")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local UIBigLeagueList = class("UIBigLeagueList", super, function() return kod.LoadCSBNode(csbPath) end)
local UIElemLeagueItem = class("UIElemLeagueItem")

function UIElemLeagueItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemLeagueItem)
    self:_initialize()
    return self
end

function UIElemLeagueItem:_initialize()
    self._textLeagueName      = seekNodeByName(self, "Text_LeagueName",   "ccui.Text") 
    self._textLeagueID    = seekNodeByName(self, "Text_LeagueID",    "ccui.Text")
    self._textHostName    = seekNodeByName(self, "Text_HostName",    "ccui.Text")
    self._textHostId = seekNodeByName(self, "Text_HostId",    "ccui.Text")
    self._textMemberCount = seekNodeByName(self, "Text_MemberCount", "ccui.Text")
    self._textBeginScore    = seekNodeByName(self, "Text_BeginScore",    "ccui.Text")
    --self._textFirePercent    = seekNodeByName(self, "Text_FirePercent",    "ccui.Text")
    self._textDesc        = seekNodeByName(self, "Text_Desc", "ccui.Text")
    self._btnManager = seekNodeByName(self, "Button_Manager", "ccui.Button")

    self._btnAddPoints = seekNodeByName(self, "Button_AddPoints", "ccui.Button") -- 加分
    self._btnMinusPoints = seekNodeByName(self, "Button_MinusPoints", "ccui.Button") -- 减分
end

function UIElemLeagueItem:setData(val)
    self._textLeagueName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.clubName))
    self._textLeagueID:setString(val.clubId)
    self._textHostName:setString(game.service.club.ClubService.getInstance():getInterceptString(val.managerName))
    self._textHostId:setString(val.managerId)
    self._textMemberCount:setString(val.memberCount)
    self._textBeginScore:setString(math.round(val.currentScore * 100) / 100)
    --self._textFirePercent:setString(string.format("%s%%", val.fireScoreRate))
    self._textDesc:setString(val.remark)

    bindEventCallBack(self._btnManager, function()
        local x, y = self._btnManager:getPosition()
        local pos = self._btnManager:getParent():convertToWorldSpace(cc.p(x, y))
        UIManager:getInstance():show("UIBigLeagueSetting", val, pos)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(self._btnAddPoints, function ()
        self:_setAdjustmentScore(val, "+")
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMinusPoints, function ()
        self:_setAdjustmentScore(val, "-")
    end, ccui.TouchEventType.ended)
end

function UIElemLeagueItem:_setAdjustmentScore(data, symbol)
    local str = string.format("参赛分可用%s", math.round(game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getTeamScore() * 100) / 100)
    UIManager:getInstance():show("UIBigLeagueScoreSetting", "积分修改", "请输入积分", str, true, symbol, function (score)
        game.service.bigLeague.BigLeagueService:getInstance():sendCCLModifyLeagueREQ(
                game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId(),
                data.clubId,
                tonumber(score),
                data.fireScoreRate,
                data.remark
        )
    end)
end

--[[    
        联盟列表界面
            用于A来管理俱乐部
]]
function UIBigLeagueList:ctor()
end

function UIBigLeagueList:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._listLeague =  UIItemReusedListView.extend(seekNodeByName(self, "ListView_League", "ccui.ListView"), UIElemLeagueItem)
    self:_registerCallBack()
end

-- 点击事件注册
function UIBigLeagueList:_registerCallBack()
    bindEventCallBack(self._btnClose,        handler(self, self._onBtnClose),        ccui.TouchEventType.ended)
end

function UIBigLeagueList:_onBtnClose()
    UIManager:getInstance():hide("UIBigLeagueList")
end

function UIBigLeagueList:onShow()
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()

    self._bigLeagueService:sendCCLQueryLeaguesREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_LEAGUEINFO", handler(self, self._upadtaListView), self)

    self:_upadtaListView({clubId = 0})
end

function UIBigLeagueList:_upadtaListView(event)
    -- clubId == 0 初始化联盟列表
    if event.clubId == 0 then
        self._listLeague:deleteAllItems()
        for _, league in ipairs(self._bigLeagueService:getLeagueData():getLeagusInfo()) do
            self._listLeague:pushBackItem(league)
        end
    else
        -- clubId ~= 0 更新数据
        local itemIdx = self:_indexOfApplicationItem(event.clubId)
        if Macro.assertFalse(itemIdx ~= false) then
            local league = self._bigLeagueService:getLeagueData():getLeagueByClubId(event.clubId)
            -- 如果本地数据没有该俱乐部信息，说明俱乐部已经被移出大联盟了
            if league == nil then
                self._listLeague:deleteItem(itemIdx)
            else
                self._listLeague:updateItem(itemIdx, league)
            end
        end
    end
end

-- 查找item
function UIBigLeagueList:_indexOfApplicationItem(clubId)
    for idx,item in ipairs(self._listLeague:getItemDatas()) do
        if item.clubId == clubId then
            return idx
        end
    end

    return false;
end

function UIBigLeagueList:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

return UIBigLeagueList