local csbPath = "ui/csb/BigLeague/UIBigLeagueGameRuleSelect.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGameRuleSelect:UIBase
local UIBigLeagueGameRuleSelect = super.buildUIClass("UIBigLeagueGameRuleSelect", csbPath)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    玩法选择界面
        用于B、C创建房间
]]

function UIBigLeagueGameRuleSelect:ctor()

end

function UIBigLeagueGameRuleSelect:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button") -- 确定
    self._listGameRules = seekNodeByName(self, "ListView_GamePlays", "ccui.ListView")
    self._listviewText = seekNodeByName(self, "ListView_1", "ccui.ListView")
    self._listGameRules:setScrollBarEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listGameRules, "GAME_TYPE_BUTTON")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

    self._reusedListGameRuleDetails = ListFactory.get(
        seekNodeByName(self, "ListView_GameRuleDetails", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    --Panel_Text
    self._panlText = seekNodeByName(self, "Panel_Text", "ccui.Layout")
    -- 不显示滚动条, 无法在编辑器设置
    self._reusedListGameRuleDetails:setScrollBarEnabled(false)
    self._reusedListGameRuleDetails:setTouchEnabled(true)
    self._reusedListGameRuleDetails:setSwallowTouches(false)
    self._listviewText:setSwallowTouches(false)
    self._listviewText:setTouchEnabled(true)

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
end

function UIBigLeagueGameRuleSelect:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueGameRuleSelect:_onClickOk()
    -- 创建房间
    self._bigLeagueService:sendCCLCreateLeagueRoomREQ(
            self._bigLeagueService:getLeagueData():getLeagueId(),
            self._bigLeagueService:getLeagueData():getLeaderId(),
            self._bigLeagueService:getLeagueData():getClubId(),
            self._gameRuleType,
            ClubConstant:getCreateRoomType().LEAGUE_ROOM_CREATE
    )

    self._bigLeagueService:getLeagueData():setLastCreateRoomSettings(self._gameRuleType,  self._gameRuleModifyTime)
end

function UIBigLeagueGameRuleSelect:onShow()
    self._btnCheckList = {}
    self._gameRuleType = nil

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()

    self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY", handler(self, self._upadtaListView), self)
end

-- 初始化list列表
function UIBigLeagueGameRuleSelect:_upadtaListView()
    -- 清空列表
    self._listGameRules:removeAllChildren()

    if #self._bigLeagueService:getLeagueData():getGameRules() < 1 then
        return
    end

    for i, gamePlay in ipairs(self._bigLeagueService:getLeagueData():getGameRules()) do
        self:_initActivityItem(gamePlay)
    end

    self._listGameRules:forceDoLayout()
    -- self:_onItemTypeClicked(self._bigLeagueService:getLeagueData():getGameRules()[1])
    local idx = self._bigLeagueService:getLeagueData():getLastSelectIndex()
    self:_onItemTypeClicked(self._bigLeagueService:getLeagueData():getGameRules()[idx])
end

function UIBigLeagueGameRuleSelect:_initActivityItem(gamePlay)
    local node = self._listviewItemBig:clone()
    self._listGameRules:addChild(node)
    node:setVisible(true)

    local textType = ccui.Helper:seekNodeByName(node, "Text_name")
    textType:setString(gamePlay.name)

    local isSelected = false
    node:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = node:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self:_onItemTypeClicked(gamePlay)
        elseif eventType == ccui.TouchEventType.canceled then
            node:setSelected(isSelected)
        end
    end)
    self._btnCheckList[gamePlay.id] = node
end

function UIBigLeagueGameRuleSelect:_onItemTypeClicked(gamePlay)
    -- 按钮的显示与隐藏
    for k,v in pairs(self._btnCheckList) do
        if k == gamePlay.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end

    if self._gameRuleType == gamePlay.id then
        return
    end

    self._gameRuleType = gamePlay.id
    self._gameRuleModifyTime = gamePlay.modifyTime

    self._reusedListGameRuleDetails:deleteAllItems()
    local roomSettingInfo = RoomSettingInfo.new(gamePlay.gameplays, gamePlay.roundType)
    local array = roomSettingInfo:getZHArray()
    local modeText = roomSettingInfo:getModeText()
    if modeText ~= nil and (not table.keyof(array, modeText)) then 
        table.insert(array, modeText)
    end 

    --抽奖区间有多个所以把抽奖描述拿出来
    local lotteryProperty  = gamePlay.lotteryProperty
    local str1 = string.format("赛事门槛分:%s  赛事分系数:%0.2f\n自动解散门槛分:%s 是否允许负分:%s\n",
    gamePlay.joinThreshold,
    gamePlay.scoreCoefficient,
    gamePlay.finishScore,
    gamePlay.canNegative and "是" or "否")
    local str2 = ''
    for _,v in ipairs(lotteryProperty) do
        str2 = str2 .. "大赢家抽奖分数区间:" .. v.startScore .."-" .. v.endScore .. '  ' ..'抽奖消耗赛事分：' .. v.lotteryCost .."\n" 
    end 
    local str3 = string.format("抽奖金币范围:%s ～ %s" , gamePlay.lotteryMin, gamePlay.lotteryMax)
    local str =  str1 .. str2 .. str3
    local gameRuleInfo =
    {
        {name = "玩法详情", details = table.concat(roomSettingInfo:getZHArray(), ",")},
        {name = "抽奖详情", details = str }
    }
 
    for _, ruleInfo in ipairs(gameRuleInfo) do
        self._reusedListGameRuleDetails:pushBackItem(ruleInfo)
    end
end

function UIBigLeagueGameRuleSelect:_onListViewInit(listItem)
    listItem:setSwallowTouches(false)
    listItem.textName = seekNodeByName(listItem, "Text_Name", "ccui.Text")
    listItem.textDetails = seekNodeByName(listItem, "Text_Details", "ccui.Text")

    listItem.listViewText = seekNodeByName(listItem, "ListView_1", "ccui.ListView")
    listItem.panelText = seekNodeByName(listItem, "Panel_Text", "ccui.Layout")
    listItem.listViewTextOriginSize = listItem.listViewText:getContentSize()
    listItem.textDetailsOriginPosY = listItem.textDetails:getPositionY()
    
    
end

function UIBigLeagueGameRuleSelect:_onListViewSetData(listItem, val)
    listItem.textName:setString(val.name)
    listItem.textDetails:setString(val.details)
 
    local sizeFontH = listItem.textDetails:getVirtualRendererSize().height
    if sizeFontH > listItem.listViewText:getContentSize().height then
        listItem.panelText:setContentSize(cc.size(listItem.panelText:getContentSize().width,sizeFontH))
        local deltHight = sizeFontH - listItem.listViewTextOriginSize.height
        listItem.textDetails:setPositionY(listItem.textDetailsOriginPosY + deltHight)
    end 
end

function UIBigLeagueGameRuleSelect:onHide()
    self._btnCheckList = {}
    self._gameRuleType = nil
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueGameRuleSelect:needBlackMask()
    return true
end

function UIBigLeagueGameRuleSelect:closeWhenClickMask()
    return false
end

function UIBigLeagueGameRuleSelect:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueGameRuleSelect