local csbPath = "ui/csb/UIShouJiBangDing.csb"
local UIBindPhoneActivity = class("UIBindPhoneActivity",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

local cfg = game.globalConst.phoneMgr

function UIBindPhoneActivity:onHide()
	game.service.LoginService:getInstance():removeEventListenersByTag(self)
end

-- 手机绑定/登录时的校验
function UIBindPhoneActivity:onBtnConfirm()
	local phone = self._textFieldPhone:getString()
	local b = self:checkPhone(phone)
	if not b then 
		self._textFieldPhone:setVisible(true)
		self._textFieldPhone:setString('请输入正确的手机号')
		return
	end
	local code = self._textFieldKey:getString()
	code = code and code or ''
	local b = string.match(code,"%d%d%d%d%d%d")==code
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的六位验证码', {"确定"})
		return
	end

	game.service.LoginService.getInstance():phoneBindReq(phone,code,1)	
end

function UIBindPhoneActivity:init()
	self._textFieldPhone = seekNodeByName(self, "TextField__phone", "ccui.TextField")
	self._textFieldPhone:addEventListener(handler(self, self._onTextFieldChanged))
	self._textFieldPhone:setTextColor(cc.c4b(151, 86, 31, 255))

	self._textFieldKey = seekNodeByName(self, "TextField_key", "ccui.TextField")
	self._textFieldKey:setTextColor(cc.c4b(151, 86, 31, 255))

	self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
	self._btnCancel:addClickEventListener(handler(self, self._onClickCancel))
	
	--获取验证码
	self._btnSend = seekNodeByName(self, "Button_send", "ccui.Button")
	self._btnSend:addClickEventListener(handler(self, self.onCodeSendBtn))
	--绑定
	self._btnBind = seekNodeByName(self, "Button_bind", "ccui.Button")
	self._btnBind:addClickEventListener(handler(self, self.onBtnConfirm))
	--关闭
	self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
	self._btnClose:addClickEventListener(handler(self, self._onBtnClose))
	--奖励物品
	self._textPrize = seekNodeByName(self, "Text_prize", "ccui.Text")
	--按钮文本
	-- self._textGet = seekNodeByName(self, "Text_Get", "ccui.Text")
	self._textTime = seekNodeByName(self, "Text_Time", "ccui.Text")
	self._textTime:setString("点击获取验证码")
end

function UIBindPhoneActivity:_onClickCancel(sender)
	self._textFieldPhone:setString("")
end

function UIBindPhoneActivity:_onBtnClose(sender)
	UIManager:getInstance():hide("UIBindPhoneActivity")
end

-- 手机号的简单校验
function UIBindPhoneActivity:checkPhone(s)
	-- return string.match(s,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == s
	return true
end

--保证输入框只输入正整数
function UIBindPhoneActivity:_onTextFieldChanged(textField,eventType)
    if eventType == ccui.TextFiledEventType.insert_text then
        local str = textField:getString()
        -- if string.len(str) > 2 then
        --     str = string.sub(str, 1, 2)
        -- end
        local v = 0        
        for i = 1,string.len(str) do
            if string.byte(str,i) < string.byte('0') or string.byte(str,i) > string.byte('9') then
                break
            end
            v = i
        end
        if v == 0 then
            str = '1'
        else
            str = string.sub(str, 1, v)
        end
        if str == '0' then
            str = '1'
        end
    
        textField:setString(str)
    end
end
-- 通用的获取验证码的回调
function UIBindPhoneActivity:onCodeSendBtn()
	local newphone = self._textFieldPhone:getString()
	local b = self:checkPhone(newphone)
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的新手机号', {"确定"})
		return
	end
	game.service.LoginService.getInstance():phoneCodeReq(newphone, 1)
end


-- type 类型
-- 1：玩家绑定手机号  2：玩家更换手机号  3：玩家解绑手机号  4：玩家通过手机号登陆
function UIBindPhoneActivity:onShow(type)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.BIND_PHONE):queryAcitivityInfo()
	game.service.LoginService:getInstance():addEventListener("EVENT_VERIFYCODE", function()
		self._btnSend:setTouchEnabled(false)
		self:_startCountDown()
	end, self)
	game.service.LoginService:getInstance():addEventListener("EVENT_BINDPHONE_CHANGED", function()
		game.ui.UIMessageBoxMgr.getInstance():show('绑定成功，奖励已发放至您的账户', {"确定"})
		UIManager:getInstance():hide("UIBindPhoneActivity")		
	end, self)

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.BIND_PHONE):addEventListener("EVENT_BINDPHONE_ACTIVITY_INFO", function()
		if self._textPrize then
			self._textPrize:setString("完成手机绑定即可免费获得"..game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.BIND_PHONE):getPrizeStr())
		end
	end)
end


-- 收到验证码的回调
function UIBindPhoneActivity:_startCountDown()
    -- self._textGet:setVisible(false)
	self._textTime:setVisible(true)
    self._countDownTimer = 60
	self._textTime:setString(self._countDownTimer..'s后重新获取验证码')

	self._btnSend:setTouchEnabled(false)
	if self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end
	self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._timerCallback), 1, false)
end

-- countdown callback
function UIBindPhoneActivity:_timerCallback()
	if not self._countDownTimer then  return end
    if self._countDownTimer > 0 then
        self._countDownTimer = self._countDownTimer - 1
    end    
	self._textTime:setString(self._countDownTimer..'s后重新获取验证码')

	if self._countDownTimer == 0 and self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
		-- self._textGet:setVisible(true)
		-- self._textTime:setVisible(false)
		self._textTime:setString("点击获取验证码")
		self._btnSend:setTouchEnabled(true)
	end
end

function UIBindPhoneActivity:needBlackMask()
	return true;
end

function UIBindPhoneActivity:closeWhenClickMask()
	return false;
end	
return UIBindPhoneActivity