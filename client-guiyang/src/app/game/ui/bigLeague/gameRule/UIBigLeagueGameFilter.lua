local csbPath = "ui/csb/BigLeague/UIBigLeagueGameFilter.csb"
local super = require("app.game.ui.UIBase")
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

--================玩法模板==================================
local GamePlayTemp = class("GamePlayTemp")
function GamePlayTemp.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, GamePlayTemp)
    self:_initialize()
    return self
end

function GamePlayTemp:_initialize()
    self._objPanel = seekNodeByName(self, "Panel_Temp", "ccui.Layout")

    self._rules = {}
    for i = 1, 2 do
        self._rules[i]= seekNodeByName(self, "Panel_rule_" .. i , "ccui.Layout")
        self._rules[i]:setVisible(false)
    end
end

function GamePlayTemp:getData()
    return self._data
end

--设置模板数据
function GamePlayTemp:setData( Data )
    self._data = Data

    for i = 1,2 do 
        self._rules[i]:setVisible(false)
        local data = Data[i]
        if data and next(data) then 
            self._rules[i]:setVisible(true)
            self:updateRulePanel(i)
        end
    end
end

--设置单个模板
function GamePlayTemp:updateRulePanel(nIdx)
    local data = self._data[nIdx]
    self._rules[nIdx].chkbox = seekNodeByName(self._rules[nIdx],"CheckBox_select","ccui.CheckBox")
    self._rules[nIdx].chkbox:setSelected(data.bSelected)  --根据数据设置是否选中，选中操作里刷新数据

    local isSelected = false
    self._rules[nIdx].chkbox:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            data.bSelected = sender:isSelected()
            self:SaveData(data)
            self._rules[nIdx].redDot:setVisible( false )
            local uiGameFilter = UIManager:getInstance():getUI("UIBigLeagueGameFilter")
            if uiGameFilter then
                uiGameFilter:setChkAllState(sender:isSelected())
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end)

    local RuleName = seekNodeByName(self._rules[nIdx],"Text_name","ccui.Text")
    RuleName:setString(data.name)

    local btnDetail = seekNodeByName(self._rules[nIdx],"Button_detail","ccui.Button")

    bindEventCallBack(btnDetail,function() 
        UIManager:getInstance():show("UIBigLeagueGameInfoDetail", data)
        self:SaveData(data)
        self._rules[nIdx].redDot:setVisible( false )
    end, ccui.TouchEventType.ended)

    self._rules[nIdx].redDot = seekNodeByName(self._rules[nIdx],"Image_red","ccui.ImageView")
    self._rules[nIdx].redDot:setVisible( data.bNew or data.bChange )
end

--点击ChkBox或者详情按钮都要消除红点
function GamePlayTemp:SaveData(data)
    if data.bNew or data.bChange then  --原来有红点，点击后要设置下数据，保存下本地配置
        local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
        local tblocalGameData = bigLeagueService:getLeagueData():getGamePlay(bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法
        if data.bChange then 
            if tblocalGameData[tostring(data.id)] then 
                tblocalGameData[tostring(data.id)].modifyTime = data.modifyTime --刷新modifyTime
                tblocalGameData[tostring(data.id)].bRed = false
            end
            data.bChange = false
        end

        if data.bNew then 
            tblocalGameData[tostring(data.id)] = {modifyTime = data.modifyTime,bSelected = false,showRoomTime = 0, bRed = false}
            data.bNew = false 
        end

        bigLeagueService:getLeagueData():saveGamePlay(bigLeagueService:getLeagueData():getLeagueId(),tblocalGameData)
    end
end
--=========================================================
local UIBigLeagueGameFilter = class("UIBigLeagueGameFilter",super,function() return kod.LoadCSBNode(csbPath) end)

function UIBigLeagueGameFilter:ctor()
    self._bSelectAll = false
    self._ruleData = {}
    self._bShowRed = false
end

function UIBigLeagueGameFilter:init()
    self._btnClose = seekNodeByName(self,"Button_Close","ccui.Button")
    self._listPanel = seekNodeByName(self, "ListView_GameRule", "ccui.ListView") 
    self._listRule = UIItemReusedListView.extend(self._listPanel, GamePlayTemp)
    -- 不显示滚动条, 无法在编辑器设置
    self._listRule:setScrollBarEnabled(false)
    self._chkAll = seekNodeByName(self,"CheckBox_All","ccui.CheckBox")
    self._btnSave = seekNodeByName(self,"Button_Save","ccui.Button")

    self:_registerCallBack()
end

function UIBigLeagueGameFilter:_registerCallBack()
    bindEventCallBack(self._btnClose,handler(self,self._onClose) , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSave,handler(self,self._onSave) , ccui.TouchEventType.ended)
    
    local isSelected = false
    self._chkAll:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self:_onSelectAll()
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end)
end

function UIBigLeagueGameFilter:onShow() 
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY", handler(self, self._ShowViewList), self)
    self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId(),self._bigLeagueService:getLeagueData():getClubId())
    self._listPanel:setVisible(false) --数据回来在显示滑动列表
    self._chkAll:setSelected(false)
end

function UIBigLeagueGameFilter:_ShowViewList()
    self:_buildRuleData()
    self:_updateViewList()
    self:_setChkboxAll()
end

--[[处理数据
    拿服务器记录的玩法数据来做界面table数据，
    里面增加了bNew(新玩法标记)，bChange(旧玩法修改标记)，bSelected(是否选中)三个标记
    再处理成{ [1] = {{data1}，{data2}}，
             [2] = {{data1}，{data2}}，...} 格式方便设置滑动列表
]]
function UIBigLeagueGameFilter:_buildRuleData()
    local tbBuildData = {}
    local tbGameData = clone(self._bigLeagueService:getLeagueData():getGameRules())  --所有盟主设置玩法
    local tblocalGameData = self._bigLeagueService:getLeagueData():getGamePlay(self._bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法

    --处理下数据，是否选中，是否是新玩法，是否有小红点,删除的玩法就不会在显示了
    for i, gamePlay in ipairs(tbGameData) do
        local localGame = tblocalGameData[tostring(gamePlay.id)]
        if localGame then 
            gamePlay.bChange = localGame.bRed or (localGame.bSelected and localGame.modifyTime ~= gamePlay.modifyTime) --只要玩家关注的玩法修改了才显示红点
            gamePlay.bSelected = not gamePlay.bChange and localGame.bSelected or false  --玩法改变了的话不选中，否则看原来的配置
            localGame.bRed = gamePlay.bChange
            self._bShowRed = self._bShowRed or localGame.bRed
            localGame.bSelected = gamePlay.bSelected   --需要保存下修改之后的配置
            gamePlay.bNew = false
        else
            gamePlay.bSelected = false  
            gamePlay.bChange = false
            gamePlay.bNew = true --新玩法红点
            self._bShowRed = true
        end

        table.insert(tbBuildData, gamePlay)
    end

    local tbRule = {}
    for i, gamePlay in ipairs(tbBuildData) do
        table.insert(tbRule, gamePlay)

        if i % 2 == 0 then 
            table.insert(self._ruleData, tbRule)
            tbRule = {}
        end
    end

    if #tbRule > 0 then 
        table.insert(self._ruleData, tbRule)
        tbRule = {}
    end

    self._bigLeagueService:getLeagueData():saveGamePlay(self._bigLeagueService:getLeagueData():getLeagueId(),tblocalGameData)
end

--刷新列表显示
function UIBigLeagueGameFilter:_updateViewList()
    self._listPanel:setVisible(true)
    self._listRule:deleteAllItems()
    
    for i = 1,#self._ruleData do 
        self._listRule:pushBackItem(self._ruleData[i])
    end
end

--打开界面设置全选按钮的选中状态
function UIBigLeagueGameFilter:_setChkboxAll()
    local bChkAll = true
    for _,tbRule in ipairs(self._ruleData) do  
        for nIdx = 1, 2 do 
            if tbRule[nIdx] and not tbRule[nIdx].bSelected then 
                bChkAll = false
                break
            end
        end

        if not bChkAll then 
            break
        end
    end
    self._chkAll:setSelected(bChkAll)
    self._bSelectAll = bChkAll
end

--设置所有玩法ChkBox全选或取消全选
function UIBigLeagueGameFilter:_setAllChkboxStatus(bSelected)
    for idx, item in ipairs(self._listRule:getSpawnItems()) do
        for nIdx = 1, 2 do 
            if item._rules[nIdx]:isVisible() then 
                item._rules[nIdx].chkbox:setSelected(bSelected) 
                if bSelected then 
                    item._rules[nIdx].redDot:setVisible(false) 
                end
            end
        end
    end

    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local tblocalGameData = bigLeagueService:getLeagueData():getGamePlay(bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法

    --修改数据，这样item复用，滑动界面也是好的
    for _,tbRule in ipairs(self._ruleData) do  
        for nIdx = 1, 2 do 
            if tbRule[nIdx] then 
                local data = tbRule[nIdx]
                data.bSelected = bSelected
                if data.bNew or data.bChange then  --原来有红点，点击后要设置下数据，保存下本地配置
                    if data.bChange then 
                        if tblocalGameData[tostring(data.id)] then 
                            tblocalGameData[tostring(data.id)].modifyTime = data.modifyTime --刷新modifyTime
                            tblocalGameData[tostring(data.id)].bRed = false
                        end
                        data.bChange = false
                    end
            
                    if data.bNew then 
                        tblocalGameData[tostring(data.id)] = {modifyTime = data.modifyTime,bSelected = false,showRoomTime = 0, bRed = false}
                        data.bNew = false 
                    end
                end
            end
        end
    end
    bigLeagueService:getLeagueData():saveGamePlay(bigLeagueService:getLeagueData():getLeagueId(),tblocalGameData)
end

function UIBigLeagueGameFilter:onHide()
    self._bSelectAll = false
    self._ruleData = {}
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueGameFilter:_onClose()
    if self._bShowRed then  --如果有红点显示的话，需要刷新下联盟主界面的红点显示
        self._bigLeagueService:dispatchEvent({ name = "EVENT_LEAGUE_GAMEPLAY_MODIFYTIME" }) 
    end
    UIManager:getInstance():destroy("UIBigLeagueGameFilter")
end

--保存本地玩法筛选
function UIBigLeagueGameFilter:_onSave()
    if not self:_ProcSave() then 
        return 
    end
    self:_onClose()
end

function UIBigLeagueGameFilter:_ProcSave()
    local bLastChoiceOne = false
    local tbSaveRule = {}
    local tblocalGameData = self._bigLeagueService:getLeagueData():getGamePlay(self._bigLeagueService:getLeagueData():getLeagueId()) --玩家本地自己保存玩法

    for _,tbRule in ipairs(self._ruleData) do 
        for nIdx = 1,2 do 
            if tbRule[nIdx] and tbRule[nIdx].bSelected then 
                bLastChoiceOne = true
            end
            if tbRule[nIdx] then 
                local modifyTime = tblocalGameData[tostring(tbRule[nIdx].id)] and tblocalGameData[tostring(tbRule[nIdx].id)].modifyTime or 0
                if not (tbRule[nIdx].bNew or tbRule[nIdx].bChange) then  --只有没有红点才更新modifyTime
                   modifyTime = tbRule[nIdx].modifyTime
                end

                local showRoomTime = 0 
                if tbRule[nIdx].bSelected then  --只有选中才更新showRoomTime
                    showRoomTime = tbRule[nIdx].modifyTime
                end

                tbSaveRule[tostring(tbRule[nIdx].id)] = {modifyTime = modifyTime, bSelected = tbRule[nIdx].bSelected, showRoomTime = showRoomTime}
            end
        end
    end

    if not bLastChoiceOne then  --一个都没选择
        game.ui.UIMessageTipsMgr.getInstance():showTips("请至少选择一个玩法")
        return false
    end
         
    self._bigLeagueService:getLeagueData():saveGamePlay(self._bigLeagueService:getLeagueData():getLeagueId(),tbSaveRule)
    return true
end

--全选按钮点击
function UIBigLeagueGameFilter:_onSelectAll()
    if self._bSelectAll then 
        self:_setAllChkboxStatus(false)
    else
        self:_setAllChkboxStatus(true)
    end
    self._bSelectAll = not  self._bSelectAll
end

--全选按钮被chkbox影响
function UIBigLeagueGameFilter:setChkAllState(bSelect)
    if not bSelect then 
        self._chkAll:setSelected(bSelect)
        self._bSelectAll = bSelect
    else
        self:_setChkboxAll()
    end
end

function UIBigLeagueGameFilter:needBlackMask()
	return true;
end

function UIBigLeagueGameFilter:closeWhenClickMask()
	return false
end

return UIBigLeagueGameFilter