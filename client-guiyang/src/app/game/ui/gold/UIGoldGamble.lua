local UtilsFunctions = require("app.game.util.UtilsFunctions")
local UIElemCombobox = require("app.game.ui.element.UIElemCombobox")
local UIRichTextEx = require("app.game.util.UIRichTextEx")
local csbPath = 'ui/csb/Gold/UIGoldGamble.csb'
local super = require("app.game.ui.UIBase")
local Const = game.globalConst.StatisticNames
local seekButton = UtilsFunctions.seekButton
local M = class("UIGoldGamble", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    self._curShowGambleId = -1
    self._gambleInfo = nil
    -- 最新滚动的节点
    self._currentScrollNode = nil
    -- 入口按钮
    self._btnMain = seekButton(self, "Button_Main", handler(self, self._onBtnMainClicked), Const.Gold_Gamble_Click_Main)
    -- 入口按钮的文本， 显示简略的当前的下注信息
    self._mainText = UIRichTextEx.createByText(seekNodeByName(self._btnMain, "Text", "ccui.Text"), { size = 17 })
    self._mainText:setVerticalAlignType('center', { row = 3, col = 3, offsetY = 10 })
    -- 可下注控件的容器
    self._layoutFirst = seekNodeByName(self, "Layout_First", "ccui.Layout")
    -- 显示下一局下注信息的容器
    self._layoutSecond = seekNodeByName(self, "Layout_Second", "ccui.Layout")
    -- 提示框的容器
    self._layoutTip = seekNodeByName(self, "Layout_Tip", "ccui.Layout")
    self._textTip = UIRichTextEx.createByText(seekNodeByName(self._layoutTip, "Text", "ccui.Text"), { size = 17 })
    self._layoutTip:setVisible(false)

    -- mask 是一个全屏全透明的 Image， 用于点击空白处收回功能
    self._mask = seekNodeByName(self, "Mask", "ccui.ImageView")
    bindEventCallBack(self._mask, handler(self, self._onBtnMainClicked), ccui.TouchEventType.ended)

    -- 两个容器的控件y值以第一个为准
    self._layoutSecond:setPositionY(self._layoutFirst:getPositionY())
    -- 保留一下初始位置， 因为动画需要重复播放
    self._layoutFirst.originPosition = cc.p(self._layoutFirst:getPosition())
    self._layoutSecond.originPosition = cc.p(self._layoutSecond:getPosition())

    -- 初始化一些计步器
    self._mainButtonClickCounter = UtilsFunctions.createCounter(1, 1)
    self._changeButtonClickCounter = UtilsFunctions.createCounter(0, 1, { max = 1 })
end

function M:init()
    self._afterBetWidget = {
        richText = UIRichTextEx.createByText(seekNodeByName(self._layoutSecond, "Text_Content", "ccui.Text"), { size = 22 }),
        richTextRoundInfo = UIRichTextEx.createByText(seekNodeByName(self._layoutSecond, "BMFont_Bet_Round_Info", "ccui.TextBMFont"), { size = 25 }),
        btnStop = seekButton(self, "Button_Stop", handler(self, self._onBtnStopClicked), Const.Gold_Gamble_Click_Stop)
    }

    self._beforeBetWidget = {
        richText = UIRichTextEx.createByText(seekNodeByName(self._layoutFirst, "Text_Content", "ccui.Text"), { size = 22 }),
        btnBet1 = seekButton(self._layoutFirst, "Button_Bet_1", handler(self, self._onBtnBet1Clicked), Const.Gold_Gamble_Click_Bet_1),
        btnBet2 = seekButton(self._layoutFirst, "Button_Bet_2", handler(self, self._onBtnBet2Clicked), Const.Gold_Gamble_Click_Bet_2),
        btnChange = seekButton(self._layoutFirst, "Button_Change", handler(self, self._onBtnChangeClicked), Const.Gold_Gamble_Click_Change)
    }
    self._beforeBetWidget.textBet1 = seekNodeByName(self._beforeBetWidget.btnBet1, "BMFont", "ccui.TextBMFont")
    self._beforeBetWidget.textBet2 = seekNodeByName(self._beforeBetWidget.btnBet2, "BMFont", "ccui.TextBMFont")
    self._beforeBetWidget.freeTip1 = seekNodeByName(self._beforeBetWidget.btnBet1, "Free_Tip")
    self._beforeBetWidget.freeTip2 = seekNodeByName(self._beforeBetWidget.btnBet2, "Free_Tip")

    -- 可下注控件中的局数选择空间
    local comboBox = UIElemCombobox.new(
    seekNodeByName(self._layoutFirst, "Button_ComboBox_Round", "ccui.Button"),
    handler(self, self._onCombBoxItemSelected),
    handler(self, self._onComboBoxItemCreate),
    handler(self, self._onComboBoxItemUpdate)
    )
    comboBox:setDir(UIElemCombobox.DIR.DOWN)
    comboBox:setAutoHideCallback(handler(self, self._onComboBoxAutoHide))
    self._beforeBetWidget.comboBox = comboBox

    -- comboBox 的模板
    self._comboBoxItemTemplate = seekNodeByName(self._layoutFirst, "ComboBoxItem", "ccui.ImageView")

    self:_registerEventCallback()
end

function M:_registerEventCallback()
    local helper = game.service.GoldService.getInstance():getGambleHelper()
    helper:addEventListener("EVENT_GOLD_GAMBLE_LAST_GUESS_RESULT", handler(self, self._onEventGoldGambleLastGuessResult), self)
    helper:addEventListener("EVENT_GOLD_GAMBLE_BET_RESULT", handler(self, self._onEventGoldGambleBetResult), self)
    helper:addEventListener("EVENT_GOLD_GAMBLE_CANCEL_BET_RESULT", handler(self, self._onEventGoldGambleCancelBetResult), self)
end

function M:onDestroy()
    game.service.GoldService.getInstance():getGambleHelper():removeEventListenersByTag(self)
    if self._beforeBetWidget.comboBox ~= nil and not tolua.isnull(self._beforeBetWidget.comboBox) then
        self._beforeBetWidget.comboBox:dispose()
        self._beforeBetWidget.comboBox = nil
    end
end

function M:onShow(gambleInfo)
    self:_resetStatus()
    -- 重新装载数据， 不直接引用时因为 pb 会有一些莫名其妙的错误
    self._gambleInfo = {}
    self._gambleInfo.selectGoldCount = gambleInfo.selectGoldCount or {}
    self._gambleInfo.selectRoundCount = gambleInfo.selectRoundCount or {}
    self._gambleInfo.todayFreeGambleTimes = gambleInfo.todayFreeGambleTimes or 0
    self._gambleInfo.nextGambleInfo = rawget(gambleInfo, "nextGambleInfo") or nil
    self._gambleInfo.curGambleInfo = rawget(gambleInfo, "curGambleInfo") or nil
    self._gambleInfo.selectGambleInfos = rawget(gambleInfo, "selectGambleInfos") or nil

    self:_updateNextRoundBetInfo(self._gambleInfo)
    self:_updateCurrentRoundBetInfo(self._gambleInfo)
    self:_updateCanBetInfo(self._gambleInfo)
    self:_scheduleStartTips(self._gambleInfo)
    -- 修改免费的提示
    self._beforeBetWidget.freeTip1:setVisible(self._gambleInfo.todayFreeGambleTimes > 0)
    self._beforeBetWidget.freeTip2:setVisible(self._gambleInfo.todayFreeGambleTimes > 0)
end

-- 重置一些状态， 隐藏之类的 tips就不隐藏了，可能在播放中
function M:_resetStatus()
    self._layoutFirst:setVisible(false)
    self._layoutSecond:setVisible(false)
    self._mask:setVisible(false)
    self._mask:setTouchEnabled(false)
    -- 也需要重置状态
    self._changeButtonClickCounter:reset()
    self._mainButtonClickCounter:reset()
end

function M:_onBtnMainClicked(sender)
    if self._gambleInfo == nil then
        return
    end

    self._mainButtonClickCounter:tick()
    -- 是否为出现的动画， 还是
    local isOutAnimation = self._mainButtonClickCounter.value % 2 == 0
    -- 以是否有 下一局 的下注信息为界限去判断是否要显示 可下注 界面
    local isFirstVisible = self._gambleInfo.nextGambleInfo == nil
    if isOutAnimation then
        self._layoutFirst:setVisible(isFirstVisible)
        self._layoutSecond:setVisible(not isFirstVisible)
        self._mask:setVisible(true)
        self._mask:setTouchEnabled(true)
    else
        self:_resetStatus()
    end

    local actionNode = nil
    if isFirstVisible then
        actionNode = self._layoutFirst
    else
        actionNode = self._layoutSecond
    end
    self:_playScrollAnimation(actionNode, isOutAnimation)
end

function M:_onBtnBet1Clicked(sender)
    local goldCount = self._gambleInfo.selectGoldCount[1] or 0
    self:_sendBetREQ(goldCount)
end

function M:_onBtnBet2Clicked(sender)
    local goldCount = self._gambleInfo.selectGoldCount[2] or 0
    self:_sendBetREQ(goldCount)
end

-- 发送下注请求
function M:_sendBetREQ(betGoldAmount)
    self:_playScrollAnimation(self._currentScrollNode, false, function()
        local index = self._beforeBetWidget.comboBox:getSelectIndex() or 1
        local roundCount = self._gambleInfo.selectRoundCount[index]
        if roundCount then
            local helper = game.service.GoldService.getInstance():getGambleHelper()
            helper:sendCGOSelectGoldGambleREQ(self._curShowGambleId, betGoldAmount, roundCount)
            self:_resetStatus()
        end
    end)
end

function M:_onBtnStopClicked(sender)
    self:_playScrollAnimation(self._currentScrollNode, false, function()
        local helper = game.service.GoldService.getInstance():getGambleHelper()
        helper:sendCGOCancelGoldGambleREQ()
    end)
end

function M:_onBtnChangeClicked(sender)
    self:_showNextGambleInfo()
end

function M:_onCombBoxItemSelected(index, str)
    local text = seekNodeByName(self._comboBoxItemTemplate, "BMFont", "ccui.TextBMFont")
    text:setString(str)
end

function M:_onComboBoxItemCreate(index)
    return self._comboBoxItemTemplate:clone()
end

function M:_onComboBoxItemUpdate(widget, index)
    local str = self._beforeBetWidget.comboBox:getText(index)
    local text = seekNodeByName(widget, "BMFont", "ccui.TextBMFont")
    text:setString(str)
end

function M:_onComboBoxAutoHide()
    if self._currentScrollNode then
        self:_playScrollAnimation(self._currentScrollNode, false)
        self._mainButtonClickCounter:tick()
    end
end

-- 显示下一个可下注的信息
function M:_showNextGambleInfo()
    local value = self._changeButtonClickCounter:tick()
    -- 如果有必要，重置 value
    if value > self._changeButtonClickCounter.extData.max then
        self._changeButtonClickCounter:reset()
        value = self._changeButtonClickCounter:tick()
    end
    local canSelectInfo = self._gambleInfo.selectGambleInfos
    if canSelectInfo then
        local info = canSelectInfo[value]
        if info == nil then
            return
        end
        self._curShowGambleId = info.id
        local description = info.description
        self._beforeBetWidget.richText:setText(description)
    end
end

-- 上局猜结果同步
function M:_onEventGoldGambleLastGuessResult(event)
    scheduleOnce(function()
        local data = event.data
        local rewardCount = data.lastRoundReward or 0
        local isChangeRoomGrade = data.isChangeGrade
        -- 提示上次已猜中
        if rewardCount > 0 then
            local str = ("<#FFF4b9>上局猜鸡成功<font><#FFCF11>\n%s金币<font><#FFF4b9>奖励已获得<font>"):format(rewardCount)
            self:_playTipAnimation(str)
        end

        -- 场次转换了
        if isChangeRoomGrade then
            self:_playTipAnimation("<#FFFFFF>变换场次啦，您需要重新下注喔~<font>")
        end
    end,
    -- 等待5秒后再执行，因为有开场动画
    5, self)
end

-- 下注结果
function M:_onEventGoldGambleBetResult(event)
    local data = event.data
    if data.ok then
        local title = ''
        if data.info and data.info.title then
            title = data.info.title
        end
        self:_playTipAnimation(("<#FFF4B9>下注成功，下局捉%s<font>"):format(title))
    end
end

-- 取消下注结果
function M:_onEventGoldGambleCancelBetResult(event)
    local data = event.data
    if data.ok then
        self:_playTipAnimation("<#FFF4B9>本局下注已停止，您可以重新下注<font>")
    end
end


-- 更新当前下一局的下注信息
function M:_updateNextRoundBetInfo(gambleInfo)
    local nextInfo = gambleInfo.nextGambleInfo
    if nextInfo == nil then
        return
    end
    self._afterBetWidget.richText:setText(nextInfo.description)
    local roundInfoStr = ''
    if nextInfo.isStop then
        roundInfoStr = ("已下注<#07FFEB>%s<font>/%s"):format(nextInfo.index, nextInfo.totalRound)
    else
        roundInfoStr = ("已下注%s/%s"):format(nextInfo.index, nextInfo.totalRound)
    end

    self._afterBetWidget.richTextRoundInfo:setText(roundInfoStr)
    self._afterBetWidget.btnStop:setEnabled(not nextInfo.isStop)
end

-- 更新当前此局的下注信息
function M:_updateCurrentRoundBetInfo(gambleInfo)
    local curInfo = gambleInfo.curGambleInfo
    local mainTextStr = '<#FFFFFF>猜鸡牌<font>'
    if curInfo then
        mainTextStr = ("<#FFFFFF>本局捉<font><#FFCF11>%s<font>"):format(curInfo.title)
    end
    self._mainText:setText(mainTextStr)
end

-- 更新当前可以下注的信息
function M:_updateCanBetInfo(gambleInfo)
    if gambleInfo.selectGambleInfos == nil then
        return
    end

    local bet1GoldCount = gambleInfo.selectGoldCount[1]
    local bet2GoldCount = gambleInfo.selectGoldCount[2]
    self._beforeBetWidget.textBet1:setString(bet1GoldCount or 0)
    self._beforeBetWidget.textBet2:setString(bet2GoldCount or 0)

    -- 可下注的局数
    local textArr = {}
    for idx, item in ipairs(gambleInfo.selectRoundCount) do
        table.insert(textArr, "猜" .. item .. "局")
    end
    self._beforeBetWidget.comboBox:setTextArray(textArr)
    seekNodeByName(self._comboBoxItemTemplate, "BMFont", "ccui.TextBMFont"):setString(textArr[1] or '')
    -- 新建一个计步器， 用于点击更换按钮的处理
    self._changeButtonClickCounter.extData.max = #gambleInfo.selectGambleInfos
    self:_showNextGambleInfo()
end

-- 规划开局的tips
function M:_scheduleStartTips(gambleInfo)
    local result = false
    local tipStr = "<#FFF4B9>每日下注第一\n局限时免费喔<font>"
    if storageTools.AutoShowStorage.isNeedShow(self.class.__cname) then
        -- 当日第一次必须显示
        result = true
    elseif gambleInfo.todayFreeGambleTimes > 0 then
        -- 如果当日未下注 (现以 todayFreeGambleTimes 大于 0 做判断, 因为默认只有1次, 若多次以后再说)
        -- 33%概率触发
        if math.random(1, 3) == 1 then
            result = true
        end
    end
    if result then
        -- 10 秒后触发
        scheduleOnce(function()
            self:_playTipAnimation(tipStr, 5)
        end, 10, self._textTip)
    end
    return result
end

-- todo 使用 Stack 来做
-- 一个简单的横向滚动动画
function M:_playScrollAnimation(node, isOutAnimation, callback)
    self._currentScrollNode = node
    node:setPosition(node.originPosition)
    local leftX = node.originPosition.x
    -- 保证出屏幕
    local rightX = display.width
    local startX, endX
    if isOutAnimation then
        startX = rightX
        endX = leftX
    else
        startX = leftX
        endX = rightX
    end
    local action = cc.Sequence:create(
    cc.Show:create(),
    cc.Place:create(cc.p(startX, node.originPosition.y)),
    cc.MoveTo:create(0.2, cc.p(endX, node.originPosition.y)),
    cc.CallFunc:create(function()
        if callback then
            callback(node, isOutAnimation)
        end
    end)
    )
    node:stopAllActions()
    node:runAction(action)

    -- 无论如何滚动，都关闭它
    if self._beforeBetWidget.comboBox then
        self._beforeBetWidget.comboBox:setVisible(false)
    end
end

function M:_playTipAnimation(str, stayTime)
    local tipStayTime = stayTime or 4
    self._textTip.waitActionCount = self._textTip.waitActionCount or 0
    self._textTip.waitActionCount = self._textTip.waitActionCount + 1
    local innerFunction = function()
        self._textTip:setText(str)
        local smallScaleSize = 0.1
        local bigScaleSize = 1
        local scaleTime = 0.1
        local action = cc.Sequence:create {
            cc.Show:create(),
            cc.ScaleTo:create(scaleTime, bigScaleSize),
            cc.DelayTime:create(tipStayTime),
            cc.ScaleTo:create(scaleTime, smallScaleSize),
            cc.Hide:create()
        }
        self._layoutTip:stopAllActions()
        self._layoutTip:setScale(smallScaleSize)
        self._layoutTip:runAction(action)
        if self._textTip.waitActionCount then
            self._textTip.waitActionCount = self._textTip.waitActionCount - 1
        end
    end
    if self._textTip.waitActionCount >= 1 then
        scheduleOnce(innerFunction, (self._textTip.waitActionCount - 1) * tipStayTime, self._textTip)
    else
        innerFunction()
    end
end

return M