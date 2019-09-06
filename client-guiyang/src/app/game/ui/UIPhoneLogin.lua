local csbPath = "ui/csb/UIPhonebind2.csb"
local UIPhoneLogin = class("UIPhoneLogin",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

local cfg = game.globalConst.phoneMgr
function UIPhoneLogin:onHideUI()
	-- game.service.LoginService.getInstance():dispatchEvent({name = "EVENT_BINDPHONE_CHANGED"})
	UIManager.getInstance():hide("UIPhoneLogin")
end

function UIPhoneLogin:onHide()
	game.service.LoginService:getInstance():removeEventListenersByTag(self)
end

-- 叉号清除文本
function UIPhoneLogin:onBtnClear()
	self.comphoneinput:setString('')
	self.comclear:setVisible(false)
end

-- 发送验证码时的校验
function UIPhoneLogin:onCodeCheck()
	local s = self.comphoneinput:getString()
	local b = self:checkPhone(s)
	if not b then 
		self.comHint:setVisible(true)
		self.comHint:setString('请输入正确的手机号')
		return
	end
	game.service.LoginService.getInstance():phoneCodeReq(s, self.type)
end

-- 手机绑定/登录时的校验
function UIPhoneLogin:onBtnConfirm()
	local phone = self.comphoneinput:getString()
	local b = self:checkPhone(phone)
	if not b then 
		self.comHint:setVisible(true)
		self.comHint:setString('请输入正确的手机号')
		return
	end
	local code = self.code:getString()
	code = code and code or ''
	local b = string.match(code,"%d%d%d%d%d%d")==code
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的六位验证码', {"确定"})
		return
	end
	--如果是手机登录
	if self.type==cfg.phonelogin then
		game.service.LoginService.getInstance():startPhoneLogin(phone,code,false,0,'')
	--如果是绑定
	elseif self.type==cfg.phonebind then
		game.service.LoginService.getInstance():phoneBindReq(phone,code, cfg.phonebind)	
	end
end

function UIPhoneLogin:init()
	self.comlayer = seekNodeByName(self, "Panel_bind", 'ccui.Layout')
	self._pannel=seekNodeByName(self, "Panel_BG", "ccui.Layout");
	self.comtitle = self.comlayer:getChildByName('BitmapFontLabel_2')
	local btnx = seekNodeByName(self, "Button_x_bind", "ccui.Button")
	bindEventCallBack(btnx, handler(self,self.onHideUI), ccui.TouchEventType.ended)
	self.comclear = self.comlayer:getChildByName('Panel_srk1_bind'):getChildByName('Button_1')
	bindEventCallBack(self.comclear, handler(self,self.onBtnClear), ccui.TouchEventType.ended)
	self.comclear:setVisible(false)
	self.comphoneinput = self.comlayer:getChildByName('Panel_srk1_bind'):getChildByName('TextField__srk1_shuzi_bind')
	-- self.flag=true
	self.comphoneinput:addEventListener(handler(self, self._onTextFieldChanged))
	self.comHint = self.comlayer:getChildByName('Text_z_bind_0')
	self.comHint:setVisible(false)
	self.sendcodebtn = self.comlayer:getChildByName('Panel_srk2_bind'):getChildByName('Button_fs2_bind')
	bindEventCallBack(self.sendcodebtn, handler(self,self.onCodeCheck), ccui.TouchEventType.ended)
	self.buttonText=self.comlayer:getChildByName('Panel_srk2_bind'):getChildByName('Button_fs2_bind'):getChildByName('Text_1')
	self.buttonText:setString('点击获取验证码')
	self.code = self.comlayer:getChildByName('Panel_srk2_bind'):getChildByName('TextField_srk2_number_bind')
	self.code:addEventListener(handler(self, self.resetPositon))	
	self.confirm=self.comlayer:getChildByName('Button_qx_bind')
	bindEventCallBack(self.confirm,handler(self,self.onBtnConfirm),ccui.TouchEventType.ended)
	self.codehint=self.comlayer:getChildByName('Text_z_bind_0_0')
	self.codehint:setString('')

	self._TextPhone = seekNodeByName(self, "Text_bingPhone", "ccui.Text")

	self.comphoneinput:setTextColor(cc.c4b(151, 86, 31, 255))
	self.code:setTextColor(cc.c4b(151, 86, 31, 255))
end

-- 手机号的简单校验
function UIPhoneLogin:checkPhone(s)
	-- return string.match(s,"[1][3,4,5,7,8,9]%d%d%d%d%d%d%d%d%d") == s
	return true
end

-- 验证码框/没有清除按钮 文本输入框的监听
function UIPhoneLogin:resetPositon(sender,eventType)
	if eventType == 0  then
		if device.platform == "ios" then
			self._pannel:setPositionPercent(cc.p(0.5,0.7))
		end
		if sender:getString() == "" then
			sender:setString(" ")
		end
	end
	if eventType == 1 then
		if device.platform == "ios" then 
			self._pannel:setPositionPercent(cc.p(0.5,0.5))
		end
		if sender:getString() == " " then		
			sender:setString("")
		end
	end
	if eventType== 2 or eventType==3 then
        local str = sender:getString()
        str=string.trim(str)
        local sTable = kod.util.String.stringToTable(str)
        local roomNumber = ""
        for i=1,#sTable do
            if tonumber(sTable[i]) ~= nil then
                roomNumber = roomNumber .. sTable[i]
            else
            	game.ui.UIMessageTipsMgr.getInstance():showTips('只能输入数字')
            end
        end
        sender:setString(roomNumber)
    end
    --[[
	if device.platform == "ios" then
      	local height = CC_DESIGN_RESOLUTION.screen.toPercentY(200)
      	if event == ccui.TextFiledEventType.attach_with_ime then
          	self:stopAllActions()
          	local move = cc.MoveTo:create(0.3, cc.p(self._originPos.x, self._originPos.y + height))
         	self:runAction(move)
     	elseif event == ccui.TextFiledEventType.detach_with_ime then
          	self:stopAllActions()
          	local move = cc.MoveTo:create(0.3, cc.p(self._originPos.x, self._originPos.y))
          	self:runAction(move)
      	end
  	end]]
end

-- 带清除按钮文本框的监听
function UIPhoneLogin:_onTextFieldChanged(sender, eventtype)
	if eventtype == 0  then
		if sender:getString() == "" then
			sender:setString(" ")
		end
		if device.platform == "ios" then
			self._pannel:setPositionPercent(cc.p(0.5,0.7))
		end
	end
	if eventtype == 1 then
		if sender:getString() == " " then		
			sender:setString("")
		end
		if device.platform == "ios" then 
			self._pannel:setPositionPercent(cc.p(0.5,0.5))
		end
	end
	if eventtype==2 or eventtype==3 then
		self.comHint:setVisible(false)
		local str = self.comphoneinput:getString()
		local length = kod.util.String.getUTFLen(str)
		local s=string.trim(str)
		self.comphoneinput:setString(s)
		self.comclear:setVisible(length>=1)
		-- 处理首次空字符串的影响
		-- if self.flag then self.comclear:setVisible(false) self.flag=nil end
		-- 转通用的监听
		self:resetPositon(sender,event)
	end
end

-- 新手机号监听
function UIPhoneLogin:onNewPhoneChanged(sender, eventtype)
	if eventtype == 0  then
		if sender:getString() == "" then
			sender:setString(" ")
		end
		if device.platform == "ios" then
			self._pannel:setPositionPercent(cc.p(0.5,0.7))
		end
	end
	if eventtype == 1 then
		if sender:getString() == " " then		
			sender:setString("")
		end
		if device.platform == "ios" then 
			self._pannel:setPositionPercent(cc.p(0.5,0.5))
		end
	end
	if eventtype==2 or eventtype==3 then
		self.newclear:setVisible(false)
		local str = self.newphone:getString()
		local length = kod.util.String.getUTFLen(str)
		local s=string.trim(str)
		self.newphone:setString(s)
		self.newclear:setVisible(length>=1)
		-- 处理首次空字符串的影响
		-- if self.flag then self.newclear:setVisible(false) self.flag=nil end
		-- 转通用的监听
		self:resetPositon(sender,event)
	end
end

-- 旧手机号监听
function UIPhoneLogin:onOldPhoneChanged(sender, eventtype)
	if eventtype == 0  then
		if sender:getString() == "" then
			sender:setString(" ")
		end
		if device.platform == "ios" then
			self._pannel:setPositionPercent(cc.p(0.5,0.7))
		end
	end
	if eventtype == 1 then
		if sender:getString() == " " then		
			sender:setString("")
		end
		if device.platform == "ios" then 
			self._pannel:setPositionPercent(cc.p(0.5,0.5))
		end
	end
	if eventtype==2 or eventtype==3 then
		self.changeclear:setVisible(false)
		local str = self.changephone:getString()
		local length = kod.util.String.getUTFLen(str)
		local s=string.trim(str)
		self.changephone:setString(s)
		self.changeclear:setVisible(length>=1)
		-- 处理首次空字符串的影响
		-- if self.flag then self.changeclear:setVisible(false) self.flag=nil end
		-- 转通用的监听
		self:resetPositon(sender,event)
	end
end
-- 通用的获取验证码的回调
function UIPhoneLogin:onCodeSendBtn()
	local newphone = self.newphone:getString()
	local b = self:checkPhone(newphone)
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的新手机号', {"确定"})
		return
	end
	game.service.LoginService.getInstance():phoneCodeReq(newphone, self.type)
end

-- 手机换绑的校验
function UIPhoneLogin:onChangeConfirm()
	local oldphone = self.changephone:getString()
	local b = self:checkPhone(oldphone)
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的原手机号', {"确定"})
		return
	end
	local newphone = self.newphone:getString()
	local b = self:checkPhone(newphone)
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的新手机号', {"确定"})
		return
	end
	local code = self.changecode:getString()
	code = code and code or ''
	local b = string.match(code,"%d%d%d%d%d%d")==code
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show('请输入六位验证码', {"确定"})
		return
	end
	-- print("_______________________________!!  ddd",newphone, code, self.type, oldphone)
	game.service.LoginService.getInstance():phoneBindReq(newphone, code, self.type, oldphone)
end

-- 手机换绑初始化
function UIPhoneLogin:phoneChange()
	seekNodeByName(self,'Panel_bind3','ccui.Layout'):setVisible(true)
	local t = {'Panel_bind','Panel_bind2','Panel_Popup_bind'}
	for i, v in ipairs(t) do
		seekNodeByName(self,v,'ccui.Layout'):setVisible(false)
	end
	self.changephone = seekNodeByName(self,'changephone','ccui.TextField')
	self.changephone:addEventListener(handler(self, self.onOldPhoneChanged))
	self.changeclear = seekNodeByName(self,'changeclear','ccui.Button')
	self.changeclear:setVisible(false)
	bindEventCallBack(self.changeclear,function()
		self.changephone:setString('')
		self.changeclear:setVisible(false)
	end)
	self.newphone = seekNodeByName(self,'newphone','ccui.TextField')
	self.newphone:addEventListener(handler(self, self.onNewPhoneChanged))
	self.newclear = seekNodeByName(self,'newclear','ccui.TextField')
	self.newclear:setVisible(false)
	bindEventCallBack(self.newclear,function()
		self.newphone:setString('')
		self.newclear:setVisible(false)
	end)
	self.changecounttext=seekNodeByName(self,'changecounttext','ccui.Text')
	self.changecounttext:setString('点击发送验证码')
	self.codesendbtn = seekNodeByName(self,'codesendbtn','ccui.Button')
	bindEventCallBack(self.codesendbtn, handler(self,self.onCodeSendBtn), ccui.TouchEventType.ended)
	self.changecode = seekNodeByName(self,'changecode','ccui.TextField')
	self.changecode:addEventListener(handler(self, self.resetPositon))
	local changesetbtn = seekNodeByName(self,'changesetbtn','ccui.Button')
	bindEventCallBack(changesetbtn,handler(self, self.onChangeConfirm), ccui.TouchEventType.ended)

	self.changephone:setTextColor(cc.c4b(151, 86, 31, 255))
	self.newphone:setTextColor(cc.c4b(151, 86, 31, 255))
	self.changecode:setTextColor(cc.c4b(151, 86, 31, 255))
end

-- type 类型
-- 1：玩家绑定手机号  2：玩家更换手机号  3：玩家解绑手机号  4：玩家通过手机号登陆
function UIPhoneLogin:onShow(type)
	self.type = type or cfg.phonelogin
	local phone = game.service.LocalPlayerService.getInstance():getBindPhone()
	self._TextPhone:setString(string.format("当前绑定的手机号:%s", phone or ""))
	
	local titles = {'手机绑定','更改绑定','','手机登录'}
	self.comtitle:setString(titles[type])
	local c =seekNodeByName(self,'Panel_bind','ccui.Layout') 
	c:setVisible(true)
	local s = self.type==cfg.phonelogin and '登录' or '绑定'
	seekNodeByName(self,'BitmapFontLabel_1_0','ccui.TextBMFont'):setString(s)
	local t = {'Panel_bind2','Panel_bind3','Panel_Popup_bind'}
	if type~=cfg.phonechange then
		for _, v in ipairs(t) do 
			seekNodeByName(self,v,'ccui.Layout'):setVisible(false)
		end
	else
		self:phoneChange()
	end

	game.service.LoginService:getInstance():addEventListener("EVENT_VERIFYCODE", function()
		self.sendcodebtn:setTouchEnabled(false)
		self:_startCountDown()
	end, self)
end

function UIPhoneLogin:getGradeLayerId( )
    return config.UIConstants.UI_LAYER_ID.Top
end

-- 收到验证码的回调
function UIPhoneLogin:_startCountDown()
    self._countDownTimer = 60
    local text = self.type==cfg.phonechange and self.changecounttext or self.buttonText
	text:setString(self._countDownTimer..'s后重新获取验证码')
	local btn = self.type==cfg.phonechange and self.codesendbtn or self.sendcodebtn
	btn:setTouchEnabled(false)
	if self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
	end
	self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._timerCallback), 1, false)
end

-- countdown callback
function UIPhoneLogin:_timerCallback()
	if not self._countDownTimer then  return end
    if self._countDownTimer > 0 then
        self._countDownTimer = self._countDownTimer - 1
    end
    local text = self.type==cfg.phonechange and self.changecounttext or self.buttonText
	text:setString(self._countDownTimer..'s后重新获取验证码')
	local btn = self.type==cfg.phonechange and self.codesendbtn or self.sendcodebtn
	btn:setTouchEnabled(false)
	if self._countDownTimer == 0 and self._timerScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
		self._timerScheduler = nil
		text:setString("重新获取验证码")
		btn:setTouchEnabled(true)
		bindEventCallBack(self.sendcodebtn, function()
		local s = self.comphoneinput:getString()
		local b = self:checkPhone(s)
		if not b then 
			self.comHint:setVisible(true)
			self.comHint:setString('请输入正确的手机号')
			return
		end
		game.service.LoginService.getInstance():phoneCodeReq(s, self.type)
	end, ccui.TouchEventType.ended)
	end
end

-- 绑定结果的回调
function UIPhoneLogin:bindResult(b,text)
	if not b then
		game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定"})
		return
	end
	local t = {'Panel_bind','Panel_bind3','Panel_Popup_bind'}
	for _, v in ipairs(t) do 
		seekNodeByName(self,v,'ccui.Layout'):setVisible(false)
	end
	seekNodeByName(self,'Panel_bind2','ccui.Layout'):setVisible(true)
	local bindsuccess = seekNodeByName(self,'bindsuccess','ccui.TextBMFont')
	local bindfail = seekNodeByName(self,'bindfailure','ccui.TextBMFont')
	bindsuccess:setVisible(b)
	bindfail:setVisible(not b)
	local buttonok = seekNodeByName(self, "Button_phonebind", "ccui.Button")
	bindEventCallBack(buttonok,handler(self,self.onHideUI),ccui.TouchEventType.ended)
	seekNodeByName(self,'Text_phonebindres','ccui.Text'):setString(b and '绑定成功！' or text)
	-- 绑定成功清除文本
	if b then 
    	if self.changephone then self.changephone:setString('') end
		if self.newphone then self.newphone:setString('') end
		if self.changecode then self.changecode:setString('') end
	end
end

function UIPhoneLogin:needBlackMask()
	return true;
end

return UIPhoneLogin