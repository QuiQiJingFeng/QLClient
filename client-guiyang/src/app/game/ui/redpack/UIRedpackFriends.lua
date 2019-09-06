-- local csbPath = "ui/csb/Redpack/UIRedpackFriends.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackFriends.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackFriends= class("UIRedpackFriends",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackFriends:ctor()
end


function UIRedpackFriends:init()
	
	self._listFriends = seekNodeByName(self, "ListView_Friends", "ccui.ListView")

	--时间
	self._textHour = seekNodeByName(self, "BMFont_Hour", "ccui.TextBMFont")
	self._textMinute = seekNodeByName(self, "BMFont_Minute", "ccui.TextBMFont")
	self._textSecond = seekNodeByName(self, "BMFont_Second", "ccui.TextBMFont")
	self._textMiliSecond = seekNodeByName(self, "BMFont_MiliSecond", "ccui.TextBMFont")

	--已获得的钱
	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")
	--提现
	self._btnGet = seekNodeByName(self, "Button_Get", "ccui.Button")

	--规则
	self._btnRule = seekNodeByName(self, "Button_Rule", "ccui.Button")

	--我的红包
	self._btnMyPackage = seekNodeByName(self, "Button_MyPackage", "ccui.Button")

	--找朋友帮开
	self._btnCallFriends = seekNodeByName(self, "Button_CallFriends", "ccui.Button")

	--关闭
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")


	--跑马灯相关
	-- self._layoutMarquee = seekNodeByName(self, "Panel_Marquee", "ccui.Layout")
	-- self._layoutSingleMarquee = seekNodeByName(self, "Panel_SingleMarquee", "ccui.Layout")

	self._btnExtra = seekNodeByName(self, "Button_Extra", "ccui.Button")

	self._listFriends = seekNodeByName(self, "ListView_Friends", "ccui.ListView")
	self._layoutFriend = seekNodeByName(self, "Panel_Friend", "ccui.Layout")
	self._layoutFriend:retain()
	self._layoutFriend:removeFromParent()

	self:_updateMarquee()

end	

function UIRedpackFriends:_onDestroy()
	self._layoutFriend:release()
end

function UIRedpackFriends:_registerCallBack()

	bindEventCallBack(self._btnGet, handler(self, self._onClickGet), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnMyPackage, handler(self, self._onClickMyPackage), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRule, handler(self, self._onClickRule), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnCallFriends, handler(self, self._onClickShare), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnExtra, handler(self, self._onClickExtra), ccui.TouchEventType.ended)
end

function UIRedpackFriends:needBlackMask()
    return true
end

function UIRedpackFriends:closeWhenClickMask()
	return false
end
function UIRedpackFriends:onShow()	
	self:_registerCallBack()
	self:_updateFriends()
	self:_updateMoney()

	self._resetTime = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getResetTime()
	self._nowTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()

	if not self._schTime then
		self._schTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateTime),0.02,false)
		self._schMarquee = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateMarquee),3.0,false)
	end
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):addEventListener("WITH_DRAW_SUCCEED", handler(self, self._onWithDrawSucceed), self); --处理活动消息
end

function UIRedpackFriends:onHide()
	if self._schTime then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schTime)
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schMarquee)
		self._schTime = nil
		self._schMarquee = nil
	end
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end
--关闭
function UIRedpackFriends:_onClickClose() 
	-- UIManager:getInstance():hide("UIRedpackFriends")
	UIManager:getInstance():show("UIRedpackQuit", self)
end
function UIRedpackFriends:doHide()
	UIManager:getInstance():hide("UIRedpackFriends")
end

function UIRedpackFriends:_onWithDrawSucceed()
	self:_updateMoney()
end
--规则

function UIRedpackFriends:_onClickRule()
	UIManager:getInstance():show("UIRedpackHelp")
end

--分享
function UIRedpackFriends:_onClickShare()
	-- local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getShareData()
	-- share.ShareWTF:getInstance():share(share.constants.ENTER.OPEN_REDPACKAGE, data, handler(self,self._onShareCompleted))
	-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):doShare(handler(self, self._onShareCompleted))
	UIManager:getInstance():show("UIRedpackShare", handler(self, self._onShareCompleted))
end

--分享完成
function UIRedpackFriends:_onShareCompleted()
	UIManager:getInstance():show("UIRedpackShareComplete")
end
--点击我的红包
function UIRedpackFriends:_onClickMyPackage()
	UIManager:getInstance():show("UIRedpackMine")
end

--刷新钱
function UIRedpackFriends:_updateMoney()
	self._textMoney:setString(""..game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney())
end

--奖励红包
function UIRedpackFriends:_onClickExtra()
	UIManager:getInstance():show("UIRedpackOtherAward")
end

--刷新时间
function UIRedpackFriends:_updateTime(t)
	
	self._nowTime = self._nowTime + math.floor(t * 1000)
	local nTimeLeft = self._resetTime - self._nowTime
	if nTimeLeft < 0 then
		nTimeLeft = 0
	end
	
	local hour =  math.floor( nTimeLeft/ 3600000 )
	local strHour = hour < 10 and "0"..hour or ""..hour
	local minute = math.floor(nTimeLeft/ 60000) % 60
	local strMinute = minute < 10 and "0"..minute or ""..minute
	local second = math.floor(nTimeLeft/1000) - hour * 3600 - 60 * minute
	local strSecond = second < 10 and "0"..second or ""..second
	local milisec = math.floor((nTimeLeft % 1000)/ 10)
	local strMili = milisec< 10 and "0"..milisec or ""..milisec
	
	self._textHour:setString(strHour)
	self._textMinute:setString(strMinute)
	self._textSecond:setString(strSecond)
	self._textMiliSecond:setString(strMili)
end

function UIRedpackFriends:_createFriendNode(info)
	local node = self._layoutFriend:clone()
	local imgHead = seekNodeByName(node, "Image_Face", "ccui.ImageView")
	game.util.PlayerHeadIconUtil.setIcon(imgHead, info.headImgUrl)
	local textMoney = seekNodeByName(node, "PlayerMoney", "ccui.TextBMFont")
	textMoney:setString(info.money.. "元")

	local imgState = seekNodeByName(node, "Image_State", "ccui.ImageView")
	if info.isFinish then
		imgState:loadTexture("art/activity/Redpack/img_hp_chb.png")
	end
	return node
end
--刷新好友信息
function UIRedpackFriends:_updateFriends()
	local friends = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getInviteInfo()
	--  friends = {{nickname='a',money = 2, isFinish = true, headImgUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJlaNica7xRH6IForpfe5VgNl1k1Z3XgyNV4O3QxD4IT6Aj5ZlmA2cV3qlCbdToicWicySoa9kKdGSfw/96"},
	--  {nickname='a',money = 2, isFinish = true, headImgUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJlaNica7xRH6IForpfe5VgNl1k1Z3XgyNV4O3QxD4IT6Aj5ZlmA2cV3qlCbdToicWicySoa9kKdGSfw/96"},
	--  {nickname='a',money = 2, isFinish = false, headImgUrl = "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJlaNica7xRH6IForpfe5VgNl1k1Z3XgyNV4O3QxD4IT6Aj5ZlmA2cV3qlCbdToicWicySoa9kKdGSfw/96"}}
	self._listFriends:removeAllChildren()
	for i = 1,#friends do
		local info = friends[i]
		local node = self:_createFriendNode(friends[i])
		self._listFriends:pushBackCustomItem(node)
	end

	if #friends == 0 then
		local node = self._layoutFriend:clone()
		seekNodeByName(node, "Image_State", "ccui.ImageView"):setVisible(false)
		seekNodeByName(node, "Image_16_0_0_0", "ccui.ImageView"):setVisible(false)
		bindEventCallBack(node, handler(self, self._onClickShare), ccui.TouchEventType.ended)
		self._listFriends:pushBackCustomItem(node)
	end
end

--提现
function UIRedpackFriends:_onClickGet()
	UIManager:getInstance():show("UIRedpackWithDraw")
end

--跑马灯
function UIRedpackFriends:_updateMarquee()
	for i = 1,3 do
		local marquee = seekNodeByName(self, "Text_Marquee"..i, "ccui.Text")
		marquee:ignoreContentAdaptWithSize(false); 
		marquee:setContentSize(cc.size(210.00, 48.00)); 
		local name = config.TurnCardConfig.getOneName()
		local money = math.floor( (15 + 3*math.random())*100)/100
		marquee:setString("玩家  "..name.."  成功领取了"..money.."元")
	end
end


function UIRedpackFriends:showInviteLayer()
	UIManager:getInstance():show("UIRedpackShare", handler(self, self._onShareCompleted))
end

return UIRedpackFriends
