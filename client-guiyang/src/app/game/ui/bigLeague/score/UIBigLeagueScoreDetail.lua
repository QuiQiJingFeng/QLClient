--[[
    各种积分变化详情界面,包括：
    1.联盟积分变化，
    2.联盟活跃度变化
    3.俱乐部积分变化
    4.俱乐部活跃度变化
    5.玩家积分变化
]]
local csbPath = "ui/csb/BigLeague/UIBigLeagueScoreDetail.csb"
local super = require("app.game.ui.UIBase")
local ScoreItems = require("app.game.ui.bigLeague.score.UIBigLeagueScoreItem")
local UIBigLeagueScoreDetail = super.buildUIClass("UIBigLeagueScoreDetail", csbPath)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local titleStr ={
    "剩余赛事分明细","赛事活跃值","团队可支配分明细","团队活跃值", "玩家分数明细","","搭档可支配分明细","搭档活跃值明细"
}

function UIBigLeagueScoreDetail:ctor()

end

local nodeNames ={"LeagueScore", "LeagueFire", "ClubScore", "ClubFire", "MyScore"}

function UIBigLeagueScoreDetail:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

    -- self._panelMyScore = seekNodeByName(self, "Panel_MyScore", "ccui.Layout")
    -- self._panelClubScore = seekNodeByName(self, "Panel_ClubScore", "ccui.Layout")
    self._panelScores = {}
    self._listScores = {}
    --用于显示获得活跃值和活跃值兑换判断
    self._panelName = {}
   
    for i = 1,5 do
        self._panelScores[i] = seekNodeByName(self, "Panel_"..nodeNames[i], "ccui.Layout")
        self._listScores[i] =UIItemReusedListView.extend(seekNodeByName(self, "ListView_"..nodeNames[i], "ccui.ListView"), ScoreItems[i])
        self._panelName[i] = "Panel_"..nodeNames[i]
    end

  
    self._bmTitle = seekNodeByName(self, "BitmapFontLabel_6", "ccui.TextBMFont")

    self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox")
    self._btnYesterday = seekNodeByName(self, "CheckBox_Yesterday", "ccui.CheckBox")
    self._btnDate = seekNodeByName(self, "CheckBox_Date", "ccui.CheckBox")   
    self._btnTime = seekNodeByName(self, "Button_ChooseTime", "ccui.Button")

    self._panelDate = seekNodeByName(self, "Panel_Date", "ccui.Layout")
    self._panelTime = seekNodeByName(self, "Panel_Time", "ccui.Layout")
    self._textTime = seekNodeByName(self, "Text_SelectTime", "ccui.Text")

    self._textGetValue = seekNodeByName(self, "Text_GetActiveValue", "ccui.TextBMFont")
    self._textExchangeValue = seekNodeByName(self, "Text_ExchangeValue", "ccui.TextBMFont")
end

function UIBigLeagueScoreDetail:_onBtnClose()
    self:hideSelf()
end



function UIBigLeagueScoreDetail:_registerCallBack()
    local tbChkBox = {self._btnDate, self._btnToday, self._btnYesterday}

    local isSelected = false
    local pFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if sender:getName() == "CheckBox_Today" then 
                self:_onBtnToday()
            elseif sender:getName() == "CheckBox_Yesterday" then 
                self:_onBtnYesterday()
            elseif sender:getName() == "CheckBox_Date" then 
                self:_onBtnDate()
            end

            for _,btn in ipairs(tbChkBox) do 
                btn:setSelected(sender == btn)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end
    self._btnDate:addTouchEventListener(pFunc)
    self._btnToday:addTouchEventListener(pFunc)
    self._btnYesterday:addTouchEventListener(pFunc)
    self._btnDate:setSelected(false)
    self._btnToday:setSelected(false)
    self._btnYesterday:setSelected(false)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnTime,         handler(self, self._onBtnTime),         ccui.TouchEventType.ended)
end
--[[
    nType:1-大联盟，2-俱乐部，3-玩家
    nPage:1-积分，2活跃度
]]
function UIBigLeagueScoreDetail:onShow(nType, nPage, clubId, partnerId, roleId)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._curDate = 0
    self._curBeginTime = game.service.TimeService:getInstance():getStartTime(self._curDate)* 1000
    self._curEndDate = game.service.TimeService.getInstance():getCurrentTimeInMSeconds()
    self._nType = nType
    self._nPage = nPage or 1
    self._clubId = clubId or 0
    self._partnerId = partnerId or 0
    self._roleId = roleId or 0

    for i = 1,5 do
        self._panelScores[i]:setVisible(false)
    end
    local idx = self:_getIdx()
    self._panelScores[idx]:setVisible(true)
    self._bmTitle:setString(titleStr[idx])
    if self._nType == 4 then
        self._bmTitle:setString(titleStr[(self._nType - 1) * 2 + self._nPage])
    end
    -- self._bmTitle:setString(nType == 3 and "我的赛事分" or "可支配赛事分")

    self:updateTimePanel()
    self:_sendQueryRequest()
    self._bigLeagueService:addEventListener("EVENT_SCORE_RECORD", handler(self, self._updateScoreRecord), self)

    --只有赛事活跃值界面需要显示活跃值和兑换值
    self:_initActiveValueVisble(self._panelName[idx])
    self:_registerCallBack()
end

function UIBigLeagueScoreDetail:_getIdx()
    local idx = (self._nType - 1) * 2 + self._nPage
    if self._nType == 4 then
        idx = 2 + self._nPage
    end
    return idx
end

function UIBigLeagueScoreDetail:_initActiveValueVisble(panelName)
    --只有赛事活跃值界面需要显示活跃值和兑换值
    local showPanlFire = {'Panel_LeagueFire','Panel_ClubFire'}
    local textBg1 = seekNodeByName(self, "Image_TextBg1", "ccui.ImageView")
    local textBg2 = seekNodeByName(self, "Image_TextBg2", "ccui.ImageView")
    if table.indexof(showPanlFire,panelName) then 
        self._textGetValue:setVisible(true)
        self._textExchangeValue:setVisible(true)
        textBg1:setVisible(true)
        textBg2:setVisible(true)
    else
        self._textGetValue:setVisible(false)
        self._textExchangeValue:setVisible(false)
        textBg1:setVisible(false)
        textBg2:setVisible(false)
    end 
end

function UIBigLeagueScoreDetail:updateTimePanel()
    -- print("updateTimePanel~~~~~~~~~~~~~", self._nPage)
    -- self._panelDate:setVisible(not self._nPage == 2)
    -- self._panelTime:setVisible(self._nPage == 2)
    if self._nPage == 2 then
        self._panelDate:setVisible(false)
        self._panelTime:setVisible(true)
        local strBegin = kod.util.Time.dateWithFormat("%m.%d %H:%M", game.service.TimeService:getInstance():getStartTime(self._curDate))
        local strEnd = kod.util.Time.dateWithFormat("%m.%d %H:%M", self._curEndDate/1000)
        self._textTime:setString(strBegin .. " - "..strEnd)
    else
        self._panelDate:setVisible(true)
        self._panelTime:setVisible(false)
    end
end

function UIBigLeagueScoreDetail:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueScoreDetail:needBlackMask()
    return true
end

function UIBigLeagueScoreDetail:closeWhenClickMask()
    return false
end

function UIBigLeagueScoreDetail:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeagueScoreDetail:_updateScoreRecord()
    local idx = self:_getIdx()
    self._listScores[idx]:deleteAllItems()
    local scoreData = self._bigLeagueService:getLeagueData():getScoreRecord()
    for _,info in ipairs(scoreData) do
        self._listScores[idx]:pushBackItem(info)
    end

    self:updateTotalScore()
    self:updateActiveValue()
    self:_updateDateShow()
end

function UIBigLeagueScoreDetail:updateTotalScore()
    local idx = self:_getIdx()
    if idx == 1 then
        seekNodeByName(self._panelScores[idx], "Text_TotalScore", "ccui.Text"):setString( self._bigLeagueService:getLeagueData():getTotalScoreChange())
        seekNodeByName(self._panelScores[idx], "Text_TotalFire", "ccui.Text"):setString( self._bigLeagueService:getLeagueData():getScoreChangeByType(8))
    else
    end
end

function UIBigLeagueScoreDetail:updateActiveValue()
    local getValue = self._bigLeagueService:getLeagueData():getActiveValue()
    local exValue = self._bigLeagueService:getLeagueData():getExChangeActiveValue()
    self._textGetValue:setString("获得活跃值:" .. math.round(getValue*100)/100)
    self._textExchangeValue:setString("活跃值兑换:" ..  math.round(exValue*100)/100)
end

-- 更新日期显示
function UIBigLeagueScoreDetail:_updateDateShow()
	local titleText = self._btnDate:getChildByName("BitmapFontLabel_startTime")
	local _date = game.service.TimeService:getInstance():getStartTime(self._curDate)
	titleText:setString(os.date("%m-%d", _date))
end 

function UIBigLeagueScoreDetail:_onBtnTime()
    local time = game.service.TimeService:getInstance():getCurrentTime()
    local minute = tonumber(os.date("%M", time))
    local second = tonumber(os.date("%S", time))
    local nowTime = (time + 60 * minute - second) * 1000
    UIManager:getInstance():show("UIClubLeaderboardTime", nowTime - 86400000 * 6, nowTime, function(startTime, endTime)
        self._curBeginTime = math.round(startTime /1000)* 1000
        self._curEndDate =  math.round(endTime /1000)* 1000

        self:_sendQueryRequest()
        local strBegin = kod.util.Time.dateWithFormat("%m.%d %H:%M", self._curBeginTime/1000)
        local strEnd = kod.util.Time.dateWithFormat("%m.%d %H:%M", self._curEndDate/1000)
        self._textTime:setString(strBegin .. " - "..strEnd)
    end)
end

function UIBigLeagueScoreDetail:_onBtnToday()
    self:_setTime(0)
end


function UIBigLeagueScoreDetail:_onBtnYesterday()
    self:_setTime(1)
end

function UIBigLeagueScoreDetail:_onBtnDate()
    UIManager:getInstance():show("UIBigLeagueDateSet", game.service.TimeService.getInstance():getStartTime(self._curDate), self)
end

function UIBigLeagueScoreDetail:_setTime(date)
    if self._curDate == date then
        return
    end

    self._curDate = date
    self._curBeginTime =  game.service.TimeService:getInstance():getStartTime(self._curDate)* 1000
    self:_sendQueryRequest()
end


function UIBigLeagueScoreDetail:_sendQueryRequest()
    -- local nType = 3
    -- if self._bigLeagueService:getIsSuperLeague() then
    --     nType = 1
    -- elseif self._bigLeagueService:getLeagueData():isManager() then
    --     nType = 2
    -- elseif self._bigLeagueService:getLeagueData():isPartner() then
    --     nType = 4
    -- end

    self._curBeginTime = game.service.TimeService:getInstance():getOneDayStartTime(self._curBeginTime / 1000) * 1000
    self._bigLeagueService:sendCCLQueryScoreRecordREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._clubId, self._partnerId,self._roleId, self._nType, self._nPage, self._curBeginTime, self._curEndDate)
end
return UIBigLeagueScoreDetail