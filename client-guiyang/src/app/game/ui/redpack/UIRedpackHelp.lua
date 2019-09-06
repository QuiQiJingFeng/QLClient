-- local super = require("app.game.ui.UIRedpackHelp")
-- local UIRedpackHelp= class("UIRedpackHelp",super)


-- function UIRedpackHelp:ctor()
-- end


-- function UIRedpackHelp:onShow()
-- 	local str = "1、所有游戏用户均可参与活动获得现金红包，也可以通过活动邀请新用户下载注册帮拆红包；\n2、所邀请新用户参与俱乐部牌局获胜1次（总结算分数>0），邀请者可以获得额外红包奖励；\n3、红包获得后在24小时内有效，请尽快在有效期内提现，逾期后已获得的红包奖励会重置；\n4、有效期内提现成功后，可关注微信公众号“聚友互动”点击“领红包”领取红包；\n5、如您对该活动有其他疑问，可联系咨询我们的公众号客服：myqhd2017；\n6、如存在恶意参与活动者，我们将保留禁止的权利。"
-- 	self._textRull:setString(str)

-- 	self._textRull:setTextAreaSize(cc.size(self._textRull:getContentSize().width, 0))

-- 	local size = self._textRull:getVirtualRendererSize()
-- 	self._textRull:setContentSize(size)
-- 	if size.height < self._scroll:getContentSize().height then
-- 		size.height = self._scroll:getContentSize().height
-- 	end
-- 	self._scroll:setInnerContainerSize(size)
-- 	self._textRull:setPositionY(size.height)

-- end

-- --关闭
-- function UIRedpackHelp:_onClickClose()
-- 	UIManager:getInstance():hide("UIRedpackHelp")
-- end

-- return UIRedpackHelp


local csbPath = "ui/csb/RedPackNew/UIRedpackHelp.csb"

local UIRedpackHelp= class("UIRedpackHelp",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackHelp:ctor()

end

function UIRedpackHelp:dispose()

end

function UIRedpackHelp:init()
	self._textRull = seekNodeByName(self, "Text_1", "ccui.Text")

	--关闭
	self._btnClose = seekNodeByName(self, "Button_1", "ccui.Button")


	self:_registerCallBack()
end

function UIRedpackHelp:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIRedpackHelp:needBlackMask()
    return true
end

function UIRedpackHelp:closeWhenClickMask()
	return true
end

function UIRedpackHelp:onShow(str)
	local str = "1、所有游戏用户均可参与活动获得现金红包，也可以通过活动邀请新用户下载注册帮拆红包；\n2、所邀请新用户参与俱乐部牌局获胜1次（总结算分数>0），邀请者可以获得额外红包奖励；\n3、红包获得后在24小时内有效，请尽快在有效期内提现，逾期后已获得的红包奖励会重置；\n4、有效期内提现成功后，可关注微信公众号“聚友互动”点击“领红包”领取红包；\n5、如您对该活动有其他疑问，可联系咨询我们的公众号客服：myqhd2017；\n6、如存在恶意参与活动者，我们将保留禁止的权利。"
	self._textRull:setString(str)

end

--关闭
function UIRedpackHelp:_onClickClose()
	UIManager:getInstance():hide("UIRedpackHelp")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIRedpackHelp:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIRedpackHelp
