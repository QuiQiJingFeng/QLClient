local csbPath = "ui/csb/UIApplyVote.csb"

--[[
    投票界面
]]

local UIApplyVote = class("UIApplyVote",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

function UIApplyVote:ctor()
    self._timerScheduler = nil
    self._countDownTimer = 0
    self._onOkCallBack = nil;
	self._onCancelCallBack = nil;
end

function UIApplyVote:init()
    self._btnAgree  = seekNodeByName(self, "Button_qd_DismissRoom", "ccui.Button")
    self._btnRefuse = seekNodeByName(self, "Button_qx_DismissRoom", "ccui.Button")
    self._btnClose  = seekNodeByName(self, "Button_close",          "ccui.Button")

    local textBg = seekNodeByName(self, "Image_word_DismissRoom", "ccui.ImageView")
    local textBgSize = textBg:getContentSize()
    self._divMessage = seekNodeByName(self, "Text_DismissRoom", "ccui.Text")
    self._divMessage:setTextAreaSize(cc.size(textBgSize.width - 20, 0))
    self._countdownText = seekNodeByName(self, "BitmapFontLabel_DismissRoom", "ccui.TextBMFont")
    self._textTitle =seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")

    -- bind callback
    bindEventCallBack(self._btnAgree,   handler(self, self._onAgreeDismissRoomButton),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRefuse,  handler(self, self._onRefuseDismissRoomButton), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose,   handler(self, self._onClickClose),              ccui.TouchEventType.ended)
end

function UIApplyVote:needBlackMask()
    return true
end

function UIApplyVote:closeWhenClickMask()
	return false
end

--[[
    1.显示内容
    2.是否隐藏同意拒绝按钮
    3.时间
    4.是否为观战
    5.标题
    6.同意的回调
    7.拒绝的回调
]]
function UIApplyVote:onShow(...)
    local args = { ... }
    local message = args[1]
    local isVoted = args[2]
    local remainTime = math.floor(args[3])
    local isWatch = args[4] or false;
    local title = args[5]
    self._onOkCallBack = args[6]
    self._onCancelCallBack = args[7]


    self._divMessage:setString(message)
    self._btnClose:setVisible(false);

    self._btnAgree:setVisible(not isVoted)
    self._btnRefuse:setVisible(not isVoted)
    
    -- 旁观
    if isWatch then
        self._btnAgree:setVisible(false);
        self._btnRefuse:setVisible(false);
        self._btnClose:setVisible(true);
    end

    self:_startCountDown(remainTime)
    -- self:setLocalZOrder(1010)

    self._textTitle:setString(title)
end

-- 隐藏窗口回调
function UIApplyVote:onHide()
    if self._timerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
        self._timerScheduler = nil
    end
end

function UIApplyVote:onDestroy()
    self:onHide()
end

-- 开始倒计时
function UIApplyVote:_startCountDown(remainTime)
    self._countDownTimer = remainTime
	self._countdownText:setString(""..self._countDownTimer)

	if self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end

	self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._timerCallback), 1, false)
end

-- countdown callback
function UIApplyVote:_timerCallback()
    if self._countDownTimer > 0 then
        self._countDownTimer = self._countDownTimer - 1
    end

	self._countdownText:setString(self._countDownTimer)

	if self._countDownTimer == 0 and self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end
end

-- 同意
function UIApplyVote:_onAgreeDismissRoomButton()
    if nil ~= self._onOkCallBack and "function" == type(self._onOkCallBack) then
		if self:_onOkCallBack() == false then
			return
		end
	end
end

-- 不同意
function UIApplyVote:_onRefuseDismissRoomButton()
    if nil ~= self._onCancelCallBack and "function" == type(self._onCancelCallBack) then
		if self:_onCancelCallBack() == false then
			return
		end
	end
end

-- 旁观者点击关闭投票弹窗
function UIApplyVote:_onClickClose(sender)
    UIManager:getInstance():hide("UIApplyVote");
end

function UIApplyVote:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIApplyVote
