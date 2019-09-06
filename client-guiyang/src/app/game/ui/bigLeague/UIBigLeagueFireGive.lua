local csbPath = "ui/csb/BigLeague/UIBigLeagueFireGive.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")

local UIBigLeagueFireGive = class("UIBigLeagueFireGive", super, function() return kod.LoadCSBNode(csbPath) end)


function UIBigLeagueFireGive:init()
    self._reusedListManager = ListFactory.get(
        seekNodeByName(self, "ListView_FireGive", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
     -- 不显示滚动条, 无法在编辑器设置
     self._reusedListManager:setScrollBarEnabled(false)

     self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") 
     bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)


    self._text1 = seekNodeByName(self, "Text_2", "ccui.Text")
end

function UIBigLeagueFireGive:ctor()
   
end


function UIBigLeagueFireGive:_onListViewInit(listItem)
   
    listItem._textPlayName = seekNodeByName(listItem, "Text_palyName", "ccui.Text") --玩法
    listItem._textPlayerNums = seekNodeByName(listItem, "Text_PlayerNums", "ccui.Text") -- 玩法人数
    listItem._textDrawCost = seekNodeByName(listItem, "Text_DrawCost", "ccui.Text") -- 抽奖消耗
    listItem._textFireValue = seekNodeByName(listItem, "Text_ActiveValue", "ccui.Text") -- 活跃值
    listItem._textFireChange = seekNodeByName(listItem, "Text_ChangeValue", "ccui.Text") -- 活跃值变化
    listItem._btnChange = seekNodeByName(listItem, "Button_ChangeScore", "ccui.Button") -- 调整活跃值
    listItem._btnSetting = seekNodeByName(listItem, "Button_Setting", "ccui.Button") -- 设置
    listItem._btnFinish = seekNodeByName(listItem, "Button_Finish", "ccui.Button") -- 完成
    listItem._textCount =  seekNodeByName(listItem, "Text_Count", "ccui.TextBMFont") -- 序号
end

function UIBigLeagueFireGive:_onListViewSetData(listItem, val)

    --显示两位小数处理
    local clubFireScore = val.clubFireScore
    if math.floor(clubFireScore) < clubFireScore then
        clubFireScore = string.format("%0.2f", clubFireScore)
        clubFireScore = tonumber(clubFireScore)
    end
    listItem._textCount:setString(val.index)
    listItem._textPlayName:setString(val.name)
    listItem._textPlayerNums:setString(val.playCount)
    listItem._textDrawCost:setString(val.lotteryCost)
    listItem._textFireValue:setString(clubFireScore)
    local partnerFireScore = math.round(tonumber(val.partnerFireScore) * 100) / 100
    listItem._textFireChange:setString(self._bigLeagueService:getIsSuperLeague() and clubFireScore or partnerFireScore)


    --初始化按钮
    listItem._btnChange:setTouchEnabled(false)
    listItem._btnSetting:setVisible(true)
    listItem._btnFinish:setVisible(false)



    bindEventCallBack(listItem._btnSetting, function ()
        self:_onClickSetting( listItem._textFireChange,listItem._btnSetting,listItem._btnFinish,val)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listItem._btnFinish, function ()
        if not self._bigLeagueService:getIsSuperLeague() then
            listItem._textFireChange:setString(partnerFireScore)
        end
        self:_onClickFinsheValue(listItem._btnSetting,listItem._btnFinish,val)
    end, ccui.TouchEventType.ended)


end

--[[
    clubId          俱乐部Id
    partnerId       搭档id
]]
function UIBigLeagueFireGive:onShow(clubId, partnerId)
    self._clubId = clubId
    self._partnerId = partnerId or 0
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local type = 0
    if self._bigLeagueService:getIsSuperLeague() then
        self._text1:setString("调整团队活跃值")
    else
        local str = self._partnerId == 0 and "搭档通用活跃值" or "调整搭档活跃值"
        self._text1:setString(str)
        type = self._partnerId == 0 and 1 or 0
    end

    self:playAnimation_Scale()
    self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId(),self._clubId, self._partnerId, true, type, true)
    self._bigLeagueService:addEventListener("EVENT_CLUB_FIRE_CHANGE", handler(self, self._updateMemberList), self)
end


--点击设置按钮 团队活跃值按钮可以点击
function UIBigLeagueFireGive:_onClickSetting(textFireChange,btnSetting,btnFinish,val)
    btnSetting:setVisible(false)
    btnFinish:setVisible(true)
    local str = "调整团队活跃值"
    if not self._bigLeagueService:getIsSuperLeague() then
        str = "调整搭档活跃值"
    end
    UIManager:getInstance():show("UIKeyboard3", str, 3, '活跃值输入错误', "确定", function (point)
        self:_checkAvtiveValue(tonumber(point),textFireChange,btnSetting,btnFinish,val)
        event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
    end)

end

function UIBigLeagueFireGive:_checkAvtiveValue(point,textFireChange,btnSetting,btnFinish,val)
    if math.floor(point)< point then 
        point = string.format("%0.2f", point)
        point = tonumber(point)
    end

    if not self._bigLeagueService:getIsSuperLeague() then
        textFireChange:setString(point)
        val.partnerFireScore = point
        return
    end

    local clubFireScore = point 
    local  limetPoint = (val.lotteryCost/val.playCount)
    if clubFireScore >  limetPoint then 
        limetPoint = math.floor(limetPoint*100)/100
        if math.floor(limetPoint) < limetPoint then 
            limetPoint = string.format("%0.2f", limetPoint)
            limetPoint = tonumber(limetPoint)
        end
        local str = string.format("调整团队活跃值不能大于:%s",limetPoint)
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
        val.clubFireScore = 0
        textFireChange:setString(val.clubFireScore)
        btnSetting:setVisible(true)
        btnFinish:setVisible(false)
        return 
    end 
    val.clubFireScore = point
    textFireChange:setString(point)
end

--发送协议 
function UIBigLeagueFireGive:_onClickFinsheValue(btnSetting,btnFinish,val)
    btnSetting:setVisible(true)
    btnFinish:setVisible(false)
    if self._bigLeagueService:getIsSuperLeague() then
        self._bigLeagueService:sendCCLModifyGamePlayClubFireScoreREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._clubId, val.id, val.startScore, val.endScore, val.clubFireScore, val.playCount)
    else
        self._bigLeagueService:sendCCLModifyGamePlayPartnerFireScoreREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._clubId, self._partnerId, val.id, val.startScore, val.endScore, val.partnerFireScore)
    end
end
    

function UIBigLeagueFireGive:_updateMemberList()
    --获取成员数据
    local lotteryProperty = self._bigLeagueService:getLeagueData():getClubFireScores()

    table.sort(lotteryProperty, function(a, b)
        if a.name == b.name then
            return a.endScore < b.endScore
        end
        return a.name < b.name
    end)


     -- 清空数据
    self._reusedListManager:deleteAllItems()
    for i,data in ipairs(lotteryProperty) do
        data.index = i 
        self._reusedListManager:pushBackItem(data)
    end

end
function UIBigLeagueFireGive:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueFireGive:onHide()
    self._bigLeagueService:removeEventListenersByTag(self)
end
function UIBigLeagueFireGive:needBlackMask()
    return true
end
return UIBigLeagueFireGive