local csbPath = "ui/csb/UIPlayerInfoNew.csb"

local UIPlayerInfo = class("UIPlayerInfo", function() return cc.CSLoader:createNode(csbPath) end)

function UIPlayerInfo:ctor(parent)
	self._parent = parent
	
	self._textName = seekNodeByName(self, "Text_name", "ccui.Text") -- 玩家昵称
	self._textIP = seekNodeByName(self, "Text_ip", "ccui.Text") -- 玩家ip
	self._textID = seekNodeByName(self, "Text_id", "ccui.Text") -- 玩家id
	self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 玩家头像
	
	self._btnCopy = seekNodeByName(self, "Button_copy", "ccui.Button") -- 拷贝
	self._btnChangeFrame = seekNodeByName(self, "Button_changeFrame", "ccui.Button") --更换头像框按钮
	self._btnAssociated = seekNodeByName(self, "Button_associated", "ccui.Button") --关联账户按钮
	-- self._btnFindOldAccount	= seekNodeByName(self, "btnFindOldAccount",	"ccui.Button")
	self._btnDingTalk = seekNodeByName(self, "Button_dingTalk", "ccui.Button") -- 绑定钉钉
	self._imgRed_DingTalk = ccui.Helper:seekNodeByName(self._btnDingTalk, "Image_red") -- 红点
	self._imgBind_DingTalk = ccui.Helper:seekNodeByName(self._btnDingTalk, "Image_bind") -- 绑定成功的Icon
	self._textDingTalk = ccui.Helper:seekNodeByName(self._btnDingTalk, "Text_name") -- btn名称
	
	self._btnPhone = seekNodeByName(self, "Button_phone", "ccui.Button") -- 绑定手机
	self._imgRed_Phone = ccui.Helper:seekNodeByName(self._btnPhone, "Image_red") -- 红点
	self._imgBind_Phone = ccui.Helper:seekNodeByName(self._btnPhone, "Image_bind") -- 绑定成功的Icon
	self._textPhone = ccui.Helper:seekNodeByName(self._btnPhone, "Text_name") -- btn名称
	
	self._btnIdentity = seekNodeByName(self, "Button_identity", "ccui.Button") -- 实名认证按钮
	self._imgRed_Identity = ccui.Helper:seekNodeByName(self._btnIdentity, "Image_red") -- 红点
	self._imgBind_Identity = ccui.Helper:seekNodeByName(self._btnIdentity, "Image_bind") -- 绑定成功的Icon
	self._textIdentity = ccui.Helper:seekNodeByName(self._btnIdentity, "Text_name") -- btn名称
	
	self._btnVerCode = seekNodeByName(self, "btnVerCode",	"ccui.Button")
	
	bindEventCallBack(self._btnCopy, handler(self, self._onCopyIDClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnChangeFrame, handler(self, self._onChangeFrameClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnAssociated, handler(self, self._onAssociatedClick), ccui.TouchEventType.ended)
	-- bindEventCallBack(self._btnFindOldAccount, handler(self, self._onBtnFindOldAccount), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnIdentity, handler(self, self._onIdentityClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnPhone, handler(self, self._onPhoneClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnVerCode, handler(self, self._onBtnVerCode), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDingTalk, handler(self, self._onDingTalkClick), ccui.TouchEventType.ended)
end

function UIPlayerInfo:show()
	self:setVisible(true)
	self._btnDingTalk:setEnabled(true)
	self:_initPlayerInfo()
	self:_updataIdentityStatus()
	self:_updataPhoneStatus()
	self:_updataDingTalkStatus()
	game.service.HeadFrameService:getInstance():addEventListener("EVENT_HEAD_CHANGE", handler(self, self._refrashHeadFrame), self)	
	game.service.HeadFrameService:getInstance():dispatchEvent({name = "EVENT_HEAD_CHANGE", data = game.service.LocalPlayerService.getInstance():getHeadFrameId()})
	game.service.CertificationService:getInstance():addEventListener("EVENT_VERIFIED_CHANGED", handler(self, self._updataIdentityStatus), self)
	game.service.LoginService.getInstance():addEventListener("EVENT_BINDPHONE_CHANGED", handler(self, self._updataPhoneStatus), self)
	game.service.LoginService.getInstance():getLoginDingTalkService():addEventListener("EVENT_BING_DING_TALK_CHANGE", handler(self, self._updataDingTalkStatus), self)
	game.service.LoginService.getInstance():getLoginDingTalkService():addEventListener("EVENT_DING_TALK_BUTTON_STATUS_CHAGE", function()
		self._btnDingTalk:setEnabled(true)
	end, self)
	
	-- self._btnFindOldAccount:setVisible(not game.service.LocalPlayerService.getInstance():getInterflow() and game.plugin.Runtime.isAccountInterflow())
	-- self._btnVerCode:setVisible(not game.plugin.Runtime.isAccountInterflow())
	self._btnVerCode:setVisible(false)
end

-- 头像框
function UIPlayerInfo:_refrashHeadFrame(event)
	local id = event.data
	local src = PropReader.getIconById(id)
	-- 添加头像框
	if self._imgHead ~= nil then
		game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, src, 0.8)
	end
end

-- 玩家基本信息
function UIPlayerInfo:_initPlayerInfo()
	local name = game.service.LocalPlayerService.getInstance():getName()
	local id = game.service.LocalPlayerService.getInstance():getRoleId()
	local ip = game.service.LocalPlayerService.getInstance():getIp()
	local url = game.service.LocalPlayerService.getInstance():getIconUrl()
	
	self._textName:setString(string.format("昵称:%s", name))
	self._textIP:setString(string.format("IP:%s", ip))
	self._textID:setString(string.format("ID:%s", id))
	
	if url ~= nil then
		game.util.PlayerHeadIconUtil.setIcon(self._imgHead, url)
	end
end

-- 更新实名认证状态
function UIPlayerInfo:_updataIdentityStatus()
	-- 是否实名认证
	local isIdentity = game.service.LocalPlayerService.getInstance():getCertificationService():getCertificationStatus()
	self._imgRed_Identity:setVisible(not isIdentity)
	self._imgBind_Identity:setVisible(isIdentity)
end

-- 更新手机绑定状态
function UIPlayerInfo:_updataPhoneStatus()
	-- 是否绑定手机号
	local isBIndPhone = checkbool(game.service.LocalPlayerService.getInstance():getBindPhone())
	self._imgRed_Phone:setVisible(not isBIndPhone)
	self._imgBind_Phone:setVisible(isBIndPhone)
	local name = isBIndPhone and "更改绑定" or "绑定手机"
	self._textPhone:setString(name)
end

-- 更新钉钉绑定状态
function UIPlayerInfo:_updataDingTalkStatus()
	local isBindDingTalk = game.service.LocalPlayerService.getInstance():getIsBindDingTalk()
	self._imgRed_DingTalk:setVisible(not isBindDingTalk)
	self._imgBind_DingTalk:setVisible(isBindDingTalk)
end

-- 钉钉绑定
function UIPlayerInfo:_onDingTalkClick(sender) 
	game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
	do return end   

	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Bind_DingTalk)
	-- 是否绑定了钉钉
	if game.service.LocalPlayerService.getInstance():getIsBindDingTalk() then
		game.ui.UIMessageTipsMgr.getInstance():showTips("已绑定")
		return
	end
	sender:setEnabled(false)
	game.service.LoginService:getInstance():getLoginDingTalkService():bindDingTalk()
end

-- 手机绑定
function UIPlayerInfo:_onPhoneClick()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Bind_Phone)
	-- 是否已绑定了手机号
	local isBIndPhone = checkbool(game.service.LocalPlayerService.getInstance():getBindPhone())
	UIManager:getInstance():show("UIPhoneLogin", isBIndPhone and game.globalConst.phoneMgr.phonechange or game.globalConst.phoneMgr.phonebind)
end

-- 实名认证
function UIPlayerInfo:_onIdentityClick()
	-- 统计实名认证功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_not_certification)
	if game.service.LocalPlayerService.getInstance():getCertificationService():getCertificationStatus() then
		game.ui.UIMessageTipsMgr.getInstance():showTips("已认证")
		return
	end
	-- TODO:下周上线删除，产品临时提的需求
	local time = game.service.TimeService:getInstance():getCurrentTime()
	if time >= 1536926400 and time <= 1536969600 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("功能维护中")
		return
	end
	
	UIManager:getInstance():show("UICertification")
end

function UIPlayerInfo:_onCopyIDClick()
	if game.plugin.Runtime.setClipboard(tostring(game.service.LocalPlayerService.getInstance():getRoleId())) == true then
		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
		--记录复制ID点击量
		game.service.DataEyeService.getInstance():onEvent("CopyID_Click")
	end	
end


function UIPlayerInfo:_onChangeFrameClick()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Change_Frame_Click)
	game.service.HeadFrameService:getInstance():queryHeadFrame()
end

function UIPlayerInfo:_onAssociatedClick()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Account_Recovery)
	UIManager:getInstance():show("UIAccountAssociation")
end

function UIPlayerInfo:hide()
	-- 取消事件监听
	game.service.HeadFrameService.getInstance():removeEventListenersByTag(self)
	game.service.CertificationService:getInstance():removeEventListenersByTag(self)
	game.service.LoginService.getInstance():getLoginDingTalkService():removeEventListenersByTag(self)
	game.service.LoginService.getInstance():removeEventListenersByTag(self)
	
	self:setVisible(false)
end

-- function UIPlayerInfo:_onBtnFindOldAccount()
-- 	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.personal_center_account_find)
-- 	UIManager:getInstance():show("UIAccountBindForNew")
-- end
function UIPlayerInfo:_onBtnVerCode()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.get_account_verification_code)
	UIManager:getInstance():show("UIAccountBindCode")
end

return UIPlayerInfo
