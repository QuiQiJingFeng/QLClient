local csbPath = "ui/csb/BigLeague/UIBigLeagueEventStatistics.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIBigLeagueEventStatistics = class("UIBigLeagueEventStatistics", super, function() return kod.LoadCSBNode(csbPath) end)


function UIBigLeagueEventStatistics:init()
    self._reusedListManager = ListFactory.get(
        seekNodeByName(self, "ListView_Event_Statist", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
     -- 不显示滚动条, 无法在编辑器设置
     self._reusedListManager:setScrollBarEnabled(false)

     self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") 
     bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
   
end

function UIBigLeagueEventStatistics:ctor()
   
end


function UIBigLeagueEventStatistics:_onListViewInit(listItem)
   
    listItem._textDate = seekNodeByName(listItem, "Text_Date", "ccui.Text") --时期
    listItem._textGameNumber = seekNodeByName(listItem, "Text_GameNumber", "ccui.Text") -- 参赛人数
    listItem._textPlayerCount = seekNodeByName(listItem, "Text_PlayerCount", "ccui.Text") -- 打牌人数
    listItem._textActiveNumber = seekNodeByName(listItem, "Text_ActiveNumber", "ccui.Text") -- 活跃人数
    listItem._textCardCost = seekNodeByName(listItem, "Text_FKZH", "ccui.Text") -- 房卡消耗数
    listItem._textActiveValue = seekNodeByName(listItem, "Text_ActiveValue", "ccui.Text") -- 赛事活跃值
    listItem._btnDetalis = seekNodeByName(listItem, "Button_Details", "ccui.Button") -- 详情按钮
end

function UIBigLeagueEventStatistics:_onListViewSetData(listItem, val)
    --日期特殊处理一下
    listItem._textDate:setString(kod.util.Time.dateWithFormat("%Y-%m-%d", val.date/1000))
    listItem._textGameNumber:setString(val.memberCount)
    listItem._textPlayerCount:setString(val.playMemberCount)
    listItem._textActiveNumber:setString(val.fireMemberCount)
    listItem._textCardCost:setString(val.cardCost)
    listItem._textActiveValue:setString(math.round(val.leagueFireScore*100)/100) 
     --点击详情
     bindEventCallBack(listItem._btnDetalis, function()
        UIManager:getInstance():show("UIBigLeagueSuperData",val.date)
    end, ccui.TouchEventType.ended)

end

function UIBigLeagueEventStatistics:onShow()

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self:_sendQueryRequest()
    self._bigLeagueService:addEventListener("EVENT_MATCH_ACTIVITY", handler(self, self._updateMemberList), self)
end


--发送请求
function UIBigLeagueEventStatistics:_sendQueryRequest()
   self._bigLeagueService:sendCCLQueryLeagueMatchActivityInfoREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    
end    

function UIBigLeagueEventStatistics:_updateMemberList()
    --获取成员数据
    local record = self._bigLeagueService:getLeagueData():getMatchActivityInfo()
     -- 清空数据
    self._reusedListManager:deleteAllItems()

    --按照时间排序
    table.sort(record, function(a, b)
		return a.date > b.date
	end)

    for _, data in ipairs(record) do
        self._reusedListManager:pushBackItem(data)
    end
    -- if #self._reusedListManager:getItemDatas() == 0 then
    --     game.ui.UIMessageTipsMgr.getInstance():showTips("该时间内无赛事数据")
    -- end

end
--
function UIBigLeagueEventStatistics:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueEventStatistics:onHide()
    self._bigLeagueService:removeEventListenersByTag(self)
end
return UIBigLeagueEventStatistics