local csbPath = "ui/csb/BigLeague/UIBigLeagueGameRuleEdit.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGameRuleEdit:UIBase
local UIBigLeagueGameRuleEdit = super.buildUIClass("UIBigLeagueGameRuleEdit", csbPath)

local ClubConstant = require("app.game.service.club.data.ClubConstant")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local RoomSetting = config.GlobalConfig.getRoomSetting()

-- 赛事系数配置
local COEFFICIENT =
{
    {id = 1, number = 0.5},
    {id = 2, number = 1},
    {id = 3, number = 2},
    {id = 4, number = -1} -- 默认不显示第四个系数
}
--抽奖区间 
local DRAWTAB = {
    {startScore = 1 ,endScore = 0 ,lotteryCost = 0 ,clubFireScore = 0}
}
--[[
    玩法编辑界面
        
]]

function UIBigLeagueGameRuleEdit:ctor()
    -- 显示类型 1-- 从 玩法管理-编辑 进入  2 -- 从玩法管理-添加新玩法 进入
    self._fromType = nil 
end

function UIBigLeagueGameRuleEdit:init()
    self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button") -- 帮助
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)

    self._listGameRule = seekNodeByName(self, "ListView_GameRule", "ccui.ListView")
    self._listGameRule:setScrollBarEnabled(false)
    self._listGameRule:setTouchEnabled(true)

    self._textGameRuleInfo = seekNodeByName(self, "Text_GameRuleInfo", "ccui.Text")
    self._textRuleName = seekNodeByName(self, "Text_RuleName", "ccui.Text") -- 玩法名称
    self._textThreshold = seekNodeByName(self, "Text_Threshold", "ccui.Text") -- 门槛分
    --self._textConsumption = seekNodeByName(self, "Text_Consumption", "ccui.Text") -- 赛事分
    --self._textWinner = seekNodeByName(self, "Text_Winner", "ccui.Text") -- 大赢家低分
    self._btnRuleName = seekNodeByName(self, "Button_RuleName", "ccui.Button")
    self._btnThreshold = seekNodeByName(self, "Button_Threshold", "ccui.Button")
    --self._btnWinner = seekNodeByName(self, "Button_Winner", "ccui.Button")
    --self._btnConsumption = seekNodeByName(self, "Button_Consumption", "ccui.Button")
    self._textCoefficient = seekNodeByName(self, "Text_Coefficient", "ccui.Text")
    self._btnCoefficient = seekNodeByName(self, "Button_Coefficient", "ccui.Button")

    self._textDisband = seekNodeByName(self, "Text_Disband", "ccui.Text") -- 解散门槛分
    self._btnDisband = seekNodeByName(self, "Button_Disband", "ccui.Button")

    self._checkBoxNegative = seekNodeByName(self, "CheckBox_Negative", "ccui.CheckBox")

    self._textDrawCofing = seekNodeByName(self, "Text_Draw_Config", "ccui.Text")
    self._textLottery = seekNodeByName(self, "BitmapFontLabel_Lottery", "ccui.TextBMFont")
    self._btnLottery = seekNodeByName(self, "Button_Lottery", "ccui.Button") -- 抽奖配置

    self._x, self._y = self._btnCoefficient:getPosition()

    bindEventCallBack(self._btnCoefficient, function ()
        UIManager:getInstance():show("UIKeyboard", "赛事分系数", 3,"赛事分系数输入有误，请重新输入", "确定", function (score)
            score = tonumber(score)
            if score < 3 then
                game.ui.UIMessageTipsMgr.getInstance():showTips("您设置的赛事分系数已存在")
                return
            end
            if score > 5 then
                game.ui.UIMessageTipsMgr.getInstance():showTips("赛事分系数限制在5以内整数")
                return
            end
            -- 设置了除了默认三个系数，btn往后移动
            for i, data in ipairs(COEFFICIENT) do
                if i == 4 then
                    self:_onItemTypeClicked(4)
                    self._checkBox[4]:setVisible(true)
                    self._btnCoefficient:setPosition(self._x, self._y)
                    self._textCoefficient:setString(score)
                    COEFFICIENT[4].number = score
                else
                    if data.number == score then
                        self._textCoefficient:setString("")
                        self._checkBox[4]:setVisible(false)
                        self._btnCoefficient:setPosition(self._checkBox[4]:getPositionX(), self._checkBox[4]:getPositionY())
                        self:_onItemTypeClicked(data.id)
                    end
                end
            end
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end, ccui.TouchEventType.ended)

    bindEventCallBack(self._btnRuleName, function ()
        if self._isSuperLeague then
            UIManager:getInstance():show("UIBigLeagueNameSetting", "玩法名称", "请输入玩法名称", 12, function (name)
                self._textRuleName:setString(name)
            end)
        end
    end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnThreshold, function ()
        self:_setPoint("赛事门槛分", 10, "赛事门槛分输入有误，请重新输入", "确定", self._textThreshold)
    end, ccui.TouchEventType.ended)
    -- bindEventCallBack(self._btnWinner, function ()
    --     self:_setPoint("抽奖资格", 10, "大赢家输入有误，请重新输入", "确定", self._textWinner)
    -- end, ccui.TouchEventType.ended)
    -- bindEventCallBack(self._btnConsumption, function ()
    --     self:_setPoint("抽奖消耗", 10, "赛事分输入有误，请重新输入", "确定", self._textConsumption)
    -- end, ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDisband, function ()
        self:_setPoint("解散门槛分", 10, "解散门槛分输入有误，请重新输入", "确定", self._textDisband)
    end, ccui.TouchEventType.ended)

    --self._textLottery = seekNodeByName(self, "BitmapFontLabel_Lottery", "ccui.TextBMFont")
    self._btnGameRule = seekNodeByName(self, "Button_GameRule", "ccui.Button") -- 玩法模版
    self._textGameRule = seekNodeByName(self, "BitmapFontLabel_GameRule", "ccui.TextBMFont")

    self._btnSave = seekNodeByName(self, "Button_Save", "ccui.Button") -- 保存玩法设置
    self._btnSave_1 = seekNodeByName(self, "Button_Save_1", "ccui.Button") -- 保存玩法设置
    self._btnDelete = seekNodeByName(self, "Button_Delete", "ccui.Button") -- 删除玩法设置

    bindEventCallBack(self._btnLottery, handler(self, self._onClickLottery), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGameRule, handler(self, self._onClickGameRule), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSave, handler(self, self._onClickSava), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSave_1, handler(self, self._onClickSava), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDelete, handler(self, self._onClickDelete), ccui.TouchEventType.ended)

    self._checkBox = {}
    for id, coefficient in ipairs(COEFFICIENT) do
        local isSelected = false
        local checkBox = seekNodeByName(self, "CheckBox_" .. id, "ccui.CheckBox")
        checkBox:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                isSelected = checkBox:isSelected()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                self:_onItemTypeClicked(self._isSuperLeague and coefficient.id or self._id)
                --checkBox:setSelected(true)
            elseif eventType == ccui.TouchEventType.canceled then
                checkBox:setSelected(isSelected)
            end
        end)
        self._checkBox[id] = checkBox
    end


    --抽奖配置外层的listView
    self._listviewInsideDraw = seekNodeByName(self, "listDrawSettings", "ccui.ListView")
    self._listviewInsideDraw:setSwallowTouches(false)
    self._listviewInsideDrawOriginSize = self._listviewInsideDraw:getContentSize()
    self._listviewInsideDrawHight = self._listviewInsideDraw:getContentSize().height
    --抽奖配置
    self._listviewDraw = seekNodeByName(self, "ListView_DrawSettings", "ccui.ListView")
    self._listViewDrawOriginSize = self._listviewDraw:getContentSize()
    self._listviewDraw:setSwallowTouches(false)

    --玩法设置动态算位置
    self._panelGameSetting = seekNodeByName(self, "Panel_GameSetting", "ccui.Layout")
    self._panelGameSetting:setSwallowTouches(false)

    --不滑动
    -- self._listviewDraw:setTouchEnabled(false)
    --不显示滚动条, 无法在编辑器设置
    self._listviewDraw:setScrollBarEnabled(false)

    --区间item
    --self._listviewItemDraw = seekNodeByName(self._listviewDraw, "Panel_DrawSettings","ccui.Layout")
    self._listviewItemDraw = seekNodeByName(self._listviewDraw, "Panel_DrawSettings","ccui.Layout")
    self._listviewItemDraw:removeFromParent(false)
    self._listviewItemDraw:setVisible(false)
    self:addChild(self._listviewItemDraw)



    self._btnAddSection = seekNodeByName(self, "Button_Add_Section", "ccui.Button") -- 增加区间
    self._textDrawCofing = seekNodeByName(self, "Text_Draw_Config", "ccui.Text")
    self._textLottery = seekNodeByName(self, "BitmapFontLabel_Lottery", "ccui.TextBMFont")
    self._btnLottery = seekNodeByName(self, "Button_Lottery", "ccui.Button") -- 抽奖配置

    bindEventCallBack(self._btnAddSection, handler(self, self._onClickAddSection), ccui.TouchEventType.ended)
    
end

--添加item 动态调整坐标
function UIBigLeagueGameRuleEdit:_adjustPos()

    local size = self._listviewItemDraw:getContentSize()
    local itemHight = size.height
    local otherHight = self._listviewInsideDrawHight-50 - itemHight
    local count = #self._listviewDraw:getItems()
    local listHight = itemHight * (count -1) + otherHight 
    size.height = listHight 
    
   
    local deltHight = size.height - self._listViewDrawOriginSize.height
    local size2 = self._listviewInsideDrawOriginSize
    local height = size2.height + deltHight
    self._listviewInsideDraw:setContentSize(cc.size(size2.width,height))
    self._listviewDraw:setContentSize(size)
    local contentSize = self._listGameRule:getContentSize()
    self._listGameRule:setInnerContainerSize(cc.size(contentSize.width,contentSize.height + deltHight ))

end

--刷新列表 添加item 调整显示位置
function UIBigLeagueGameRuleEdit:_upadtaListView()
    self._listviewDraw:removeAllChildren()
    --添加item
    for i,section in ipairs(DRAWTAB) do 
        local listItem =  self._listviewItemDraw:clone()
        listItem:setSwallowTouches(false)
        self._listviewDraw:addChild(listItem)
        listItem:setVisible(true)
        local isVisible = self._bigLeagueService:getIsSuperLeague() or self._bigLeagueService:getLeagueData():isManager()
        local isEnable = self._bigLeagueService:getIsSuperLeague()
        local textGive = seekNodeByName(listItem, "Text_Give", "ccui.Text")  --团队活跃值文案
        local textDrawStart = seekNodeByName(listItem, "Text_Draw_1", "ccui.Text") --抽奖区间开始
        local textDrawEnd = seekNodeByName(listItem, "Text_Draw_2", "ccui.Text") -- 抽奖区间结束
        local textCostScore = seekNodeByName(listItem, "Text_Cost_Score", "ccui.Text") --消耗分数
        local textGiveScore = seekNodeByName(listItem, "Text_Give_Score", "ccui.Text") --团队活跃值赠送
        local btnCost = seekNodeByName(listItem, "Button_Cost", "ccui.Button") --抽奖消耗按钮
        local btnGive = seekNodeByName(listItem, "Button_Give", "ccui.Button") --团队活跃值赠送按钮
        local btnDrawStart = seekNodeByName(listItem, "Button_Draw_1", "ccui.Button") --抽奖区间开始按钮
        local btnDrawEnd = seekNodeByName(listItem, "Button_Draw_2", "ccui.Button") -- 抽奖区间结束按钮
        local btnSub = seekNodeByName(listItem, "Button_Sub_Section", "ccui.Button")  --团队活跃值文案
        ---按钮显示和点击
        textGive:setVisible(isVisible)
        btnGive:setVisible(isVisible)
        textGiveScore:setVisible(isVisible)
        btnSub:setVisible(isEnable and i == #DRAWTAB and i ~= 1)
        --抽奖分数按钮 消耗赛事分按钮
        btnDrawStart:setTouchEnabled(false)
        btnDrawEnd:setTouchEnabled(isEnable)
        btnCost:setTouchEnabled(isEnable)
        btnGive:setTouchEnabled(isEnable)


        table.insert(self._assBtnSetting,btnDrawEnd)
        table.insert(self._assBtnSetting,btnCost)
        table.insert(self._assBtnSetting,btnGive)


        --服务器给的数据进行去两位处理
        if math.floor(section.lotteryCost) < section.lotteryCost then
            section.lotteryCost = string.format("%0.2f", section.lotteryCost)
            section.lotteryCost = tonumber(section.lotteryCost)
        end

        if math.floor(section.clubFireScore) < section.clubFireScore then
            section.clubFireScore = string.format("%0.2f", section.clubFireScore)
            section.clubFireScore = tonumber(section.clubFireScore)
        end


        ----------抽奖显示 --------------- 
        textDrawStart:setString(section.startScore)
        textDrawEnd:setString(section.endScore)
        textCostScore:setString(section.lotteryCost)
        textGiveScore:setString(section.clubFireScore)
        

        ---按钮绑定事件
        bindEventCallBack(btnDrawEnd, function ()
            self:_setPoint("抽奖结束区间", 4, "抽奖结束区间分数输入有误", "确定", textDrawEnd,btnDrawEnd,i,'endScore')
        end, ccui.TouchEventType.ended)

        --小数点保留两位小数未处理
        bindEventCallBack(btnCost, function ()
            self:_setGivePoint("抽奖消耗赛事分数", 3, "抽奖赛事消耗赛事输入有误", "确定", textCostScore,btnCost,i,'lotteryCost')
        end, ccui.TouchEventType.ended)

        bindEventCallBack(btnGive, function ()
            self:_setGivePoint("团队活跃值赠送分数", 3, "团队活跃值赠送分数输入有误", "确定", textGiveScore,btnGive,i,'clubFireScore')
        end, ccui.TouchEventType.ended)
        bindEventCallBack(btnSub, handler(self, self._onClickSubSection), ccui.TouchEventType.ended)
    end 
    self:_adjustPos()  
end

--刷新item
function UIBigLeagueGameRuleEdit:_onClickAddSection()
    local maxGameplayRegion = self._bigLeagueService:getLeagueData():getmaxGameplayRegion()
    if self._playerNums == 0 then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("请先进行玩法设置")
        return 
    end

    if #DRAWTAB ==  maxGameplayRegion then 
        local str = string.format("最多添加:%s个区间",maxGameplayRegion)
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
        return 
    end 
    
    -- if #DRAWTAB == 5 then 
    --     game.ui.UIMessageTipsMgr.getInstance():showTips("最多添加五个区间")
    --     return 
    -- end 
    --添加一个item
    --{startScore = 0 ,endScore = 0 ,lotteryCost = 0 ,clubFireScore = 0}
    local itemTab = {startScore = 0 ,endScore = 0 ,lotteryCost = 0 ,clubFireScore = 0}
    local index = #DRAWTAB
    if DRAWTAB[index]['startScore'] >= DRAWTAB[index]['endScore'] then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖区间输入有误")
        return 
    end 
    if DRAWTAB[index]['endScore'] + 1 > 9999 then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("抽奖区间范围在：1 - 9999")
        return 
    else 
        itemTab.startScore = DRAWTAB[index]['endScore'] + 1
    end 

    table.insert(DRAWTAB,itemTab)  
     
    self:_upadtaListView()  
    --self:_adjustPos()
end

--刷新item
function UIBigLeagueGameRuleEdit:_onClickSubSection()
    local index = #DRAWTAB
    table.remove(DRAWTAB,index)
     
    self:_upadtaListView() 
    --self:_adjustPos() 
end

function UIBigLeagueGameRuleEdit:getCheckBoxId(coefficientId)
    for id, number in ipairs(COEFFICIENT) do
        if id == coefficientId then
            return number
        end
    end
end

function UIBigLeagueGameRuleEdit:_onItemTypeClicked(id)
    -- 按钮的显示与隐藏
    for k,v in pairs(self._checkBox) do
        if k == id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end

    self._id = id
end

function UIBigLeagueGameRuleEdit:_setPoint(title, limit, tips, btnName, node,callBackBtn,index,type)
    if self._isSuperLeague then
        if self._playerNums == 0 and table.indexof(self._assBtnSetting,callBackBtn) then 
            game.ui.UIMessageTipsMgr.getInstance():showTips("请先进行玩法设置")
            return 
        end 
        UIManager:getInstance():show("UIKeyboard", title, limit, tips, btnName, function (point)
            if tonumber(point) == 0  and not  table.indexof(self._assBtnSetting,callBackBtn) then
                game.ui.UIMessageTipsMgr.getInstance():showTips("分数不能为0")
                return
            end
            if table.indexof(self._assBtnSetting,callBackBtn) then 
                self:_setDrawdata(index,type,tonumber(point),node)
            else 
                node:setString(tonumber(point))
            end 
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end
end

--设置抽奖区间数据  {startScore = 1 ,endScore = 0 ,lotteryCost = 0 ,clubFireScore = 0}
function UIBigLeagueGameRuleEdit:_setDrawdata(index, type, point, node)
    local coefficient = self:getCheckBoxId(self._id)
	if math.floor(point) < point then
		point = string.format("%0.2f", point)
		point = tonumber(point)
    end
    DRAWTAB[index][type] = point
	local drawValue = DRAWTAB[index]
	if drawValue['startScore'] >= drawValue['endScore'] and type == 'endScore' then
        game.ui.UIMessageTipsMgr.getInstance():showTips("输入抽奖区间有误，请重新输入")
        node:setString('0')
		DRAWTAB[index][type] = 0
		return
	end
	
	if drawValue['clubFireScore'] * self._playerNums > drawValue['lotteryCost'] and type == 'clubFireScore' then
		game.ui.UIMessageTipsMgr.getInstance():showTips("团队活跃值设置过高")
		node:setString('0')
		DRAWTAB[index][type] = 0
		return
    end

    --抽奖消耗赛事分提示
    if drawValue['lotteryCost'] > drawValue['startScore']*coefficient.number and type == 'lotteryCost' then 
        local limitPoint = drawValue['startScore']*coefficient.number
        local str = string.format("抽奖消耗赛事分应不大于:%s",limitPoint)
        game.ui.UIMessageTipsMgr.getInstance():showTips(str)
        node:setString('0')
        DRAWTAB[index][type] = 0
        return 
    end
	node:setString(point)
    if DRAWTAB[index + 1] ~= nil then
        if DRAWTAB[index + 1] ['startScore'] >= 9999 then 
            game.ui.UIMessageTipsMgr.getInstance():showTips("输入抽奖区间范围：1 - 9999")
            DRAWTAB[index][type] = 0
            return 
        else
            DRAWTAB[index + 1] ['startScore'] = DRAWTAB[index] ['endScore'] + 1
        end 
    end
    
    self:_upadtaListView()
	
end 

function UIBigLeagueGameRuleEdit:_setGivePoint(title, limit, tips, btnName, node,callBackBtn,index,type)
    if self._isSuperLeague then
        if self._playerNums == 0 then 
            game.ui.UIMessageTipsMgr.getInstance():showTips("请先进行玩法设置")
            return 
        end 
        UIManager:getInstance():show("UIKeyboard3", title, limit, tips, btnName, function (point)
            -- if tonumber(point) == 0 then
            --     game.ui.UIMessageTipsMgr.getInstance():showTips("分数不能为0")
            --     return
            -- end
            self:_setDrawdata(index,type,tonumber(point),node)
            --node:setString(tonumber(point))
            event.EventCenter:dispatchEvent({ name = "EVENT_KEYBOARD", isClear = true, isDestroy = true})
        end)
    end
end

function UIBigLeagueGameRuleEdit:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueGameRuleEdit:_onClickHelp()
    -- 帮助界面
    local str =
    [[
1.参赛分门槛：玩家参赛分高于参赛门槛分可参加比赛；
2.允许负分：牌局中是否可以出现负分情况；
3.自动解散门槛：牌局中某位玩家赛事分不高于此门槛时，系统自动解散房间；
4.抽奖设置：根据大赢家分数所在的区间，抽奖消耗对应的赛事分;
5.团队活跃值赠送：参与牌局的单个玩家给对应群主赠送的活跃值数量
6.抽奖奖励：赛事奖励优秀牌局，为优秀选手提供奖励。

    ]]

    UIManager:getInstance():show("UIBigLeagueHelp", str)
end

function UIBigLeagueGameRuleEdit:_onClickLottery()
    -- 抽奖设置
    UIManager:getInstance():show("UIBigLeagueGoldSetting", self._data.lotteryMin, self._data.lotteryMax, function (min, max)
        self._data.lotteryMin = tonumber(min)
        self._data.lotteryMax = tonumber(max)
    end)
end

function UIBigLeagueGameRuleEdit:_onClickGameRule()
    local roomSettings =
    {
        gameplays = self._data.gameplays,
        roundType = self._data.roundType,
        index = self._data.id
    }

    local type = self._bigLeagueService:getIsSuperLeague() and ClubConstant:getGamePlayType().superLeague or ClubConstant:getGamePlayType().league
    UIManager:getInstance():show("UICreateRoom", 0, type, {}, #roomSettings.gameplays == 0 and {} or {roomSettings}, function (gameRule)
        self._data.gameplays = gameRule.gameplays
        self._data.roundType = gameRule.roundType
        self._data.id = gameRule.index
        self:_setGameRuleInfo()
    end, self._fromType)
end

function UIBigLeagueGameRuleEdit:_onClickSava()
    -- 保存玩法
    self._data.name = self._textRuleName:getString()
    self._data.joinThreshold = tonumber(self._textThreshold:getString())
   -- self._data.winnerThreshold = tonumber(self._textWinner:getString())
   -- self._data.lotteryCost = tonumber(self._textConsumption:getString())
    self._data.finishScore = tonumber(self._textDisband:getString())
    self._data.canNegative = self._checkBoxNegative:isSelected()
    self._data.lotteryProperty = DRAWTAB
    self._data.playCount = self._playerNums
    for _, score in ipairs(COEFFICIENT) do
        if score.id == self._id then
            self._data.scoreCoefficient = score.number
        end
    end

    if self._data.name == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("玩法名称不能为空")
        return
    end

    if #self._data.gameplays == 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请设置玩法规则")
        return
    end

    -- if self._data.winnerThreshold < 1 then
    --     game.ui.UIMessageTipsMgr.getInstance():showTips("大赢家分数底分大于0")
    --     return
    -- end

    if self._data.finishScore < 1 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("自动解散门槛分大于0")
        return
    end

    if self._data.finishScore >= self._data.joinThreshold then
        game.ui.UIMessageTipsMgr.getInstance():showTips("赛事门槛分需大于自动解散门槛分")
        return
    end

    -- if self._data.lotteryCost > self._data.winnerThreshold * self._data.scoreCoefficient then
    --     local str = string.format("抽奖消耗赛事分应不大于%0.2f", self._data.winnerThreshold * self._data.scoreCoefficient)
    --     game.ui.UIMessageTipsMgr.getInstance():showTips(str)
    --     return
    -- end

    for i,section in ipairs(self._data.lotteryProperty) do 
        if section['startScore'] >= section['endScore']  then 
            game.ui.UIMessageTipsMgr.getInstance():showTips("输入抽奖区间有误，请重新输入") 
            return
        end
        if section['clubFireScore'] *self._playerNums > section['lotteryCost'] then 
            game.ui.UIMessageTipsMgr.getInstance():showTips("团队活跃值设置过高")
            return
        end
         --抽奖消耗赛事分提示
        if section['lotteryCost'] > section['startScore']*self._data.scoreCoefficient then 
            local limitPoint = section['startScore']*self._data.scoreCoefficient
            local str = string.format("抽奖消耗赛事分应不大于:%s",limitPoint)
            game.ui.UIMessageTipsMgr.getInstance():showTips(str)
            return 
        end 
    end 
    self._bigLeagueService:sendCCLModifyLeagueGameplayREQ(
            self._bigLeagueService:getLeagueData():getLeagueId(),
            self._data.id,
            self._data
    )
end

function UIBigLeagueGameRuleEdit:_onClickDelete()
    -- 删除玩法
    game.ui.UIMessageBoxMgr.getInstance():show("确定要删除已编辑玩法吗？", {"确定", "取消"}, function ()
        self._bigLeagueService:sendCCLDeleteLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._data.id)
    end)
end

function UIBigLeagueGameRuleEdit:onShow(data,isGameplayEnter)
    data = clone(data)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    -- 等服务器返回在关闭界面
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY", function ()
        --是玩法统计界面进来的保存玩法的成功发送协议
        if isGameplayEnter then 
            self._bigLeagueService:sendCCLQueryGameplayStatisticsREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
            isGameplayEnter.date)
        end 
        self:hideSelf()
    end , self)

    self._playerNums = 0
    self._assBtnSetting = {}

   
    -- 添加进入类型，用于判定玩家进入创建房间的托管模式默认选择相关
    if data == nil then 
        self._fromType = 2 
    else 
        self._fromType = 1
    end 
    self._isSuperLeague = self._bigLeagueService:getIsSuperLeague()
    -- 如果没有玩法，客户端默认赋值（详细看LeagueGameplayPROTO）
    self._data = data or {
        id = 0,
        name = "",
        joinThreshold = 0,
        scoreCoefficient = 0.5,
        winnerThreshold = 0,
        lotteryCost = 0,
        lotteryMin = 0,
        lotteryMax = 0,
        roomType = 0,
        roundType = 1,
        gameplays = {},
        finishScore = 0,
        canNegative = false,
        lotteryProperty = {{startScore = 1 ,endScore = 0 ,lotteryCost = 0 ,clubFireScore = 0}},
        playCount = 0
    }
    self:_setGameRuleInfo()
    self._data.lotteryProperty = clone(self._data.lotteryProperty)
    DRAWTAB = self._data.lotteryProperty
    self:_upadtaListView()
    self._btnAddSection:setVisible(self._bigLeagueService:getIsSuperLeague())
    self._textLottery:setString(self._isSuperLeague and "点击配置" or "点击查看")
    self._textGameRule:setString(self._isSuperLeague and "点击设置" or "点击查看")
    -- 除了A能点击按钮设置玩法，B、C只能浏览
    self._btnSave:setVisible(self._isSuperLeague and self._data.id ~= 0)
    self._btnDelete:setVisible(self._isSuperLeague and self._data.id ~= 0)
    self._btnSave_1:setVisible(self._isSuperLeague and self._data.id == 0)
    self._btnCoefficient:setVisible(self._isSuperLeague)
    self._checkBoxNegative:setTouchEnabled(self._isSuperLeague)
    -- 给界面复制
    self._textRuleName:setString(self._data.name)
    self._textThreshold:setString(self._data.joinThreshold)
    --self._textConsumption:setString(self._data.lotteryCost)
    --self._textWinner:setString(self._data.winnerThreshold)
    self._textDisband:setString(self._data.finishScore)
    self._checkBoxNegative:setSelected(self._data.canNegative)

    -- 因为赛事系数分可以自己选择一个系数，这里就是判断是否设置了第四个系数分，设置了显示第四个系数分，btn往后移动
    COEFFICIENT[4].number = -1
    for _, score in ipairs(COEFFICIENT) do
        if self._data.scoreCoefficient == score.number then
            self._textCoefficient:setString("")
            self._checkBox[4]:setVisible(false)
            self._btnCoefficient:setPosition(self._checkBox[4]:getPositionX(), self._checkBox[4]:getPositionY())
            self:_onItemTypeClicked(score.id)
            return
        end
    end

    self:_onItemTypeClicked(4)
    self._checkBox[4]:setVisible(true)
    self._btnCoefficient:setPosition(self._x, self._y)
    self._textCoefficient:setString(self._data.scoreCoefficient)
    COEFFICIENT[4].number = self._data.scoreCoefficient
end

function UIBigLeagueGameRuleEdit:_setGameRuleInfo()
    local str = "玩法规则未设置"
    local roomSettingInfo = RoomSettingInfo.new(self._data.gameplays, self._data.roundType)
    if #self._data.gameplays > 0 then
        self._playerNums = self:_conVerPlayerNums(self._data.gameplays)
        str = string.format("%s,%s,%s", roomSettingInfo:getZHArray()[1], roomSettingInfo:getZHArray()[2], roomSettingInfo:getZHArray()[3])
        local modeText = roomSettingInfo:getModeText()
        if modeText ~= nil then 
            str = str .. "," .. modeText
        end 
    end

    self._textGameRuleInfo:setString(str)
end

function UIBigLeagueGameRuleEdit:_conVerPlayerNums(gameplays)
    local GamePlay =  RoomSetting.GamePlay
    
    for k,v  in ipairs(gameplays) do 
        if v == GamePlay.PLAYER_FOUR then 
            return 4
        elseif v == GamePlay.PLAYER_THREE  or  v == GamePlay.PLAYER_NUM_3 then 
            return 3 
        elseif v == GamePlay.PLAYER_TWO or  v == GamePlay.REGION_LIANGDING or v == GamePlay.PLAYER_NUM_2 then 
            return 2
        end 
    end 

end

function UIBigLeagueGameRuleEdit:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueGameRuleEdit:needBlackMask()
    return true
end

function UIBigLeagueGameRuleEdit:closeWhenClickMask()
    return false
end

function UIBigLeagueGameRuleEdit:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueGameRuleEdit