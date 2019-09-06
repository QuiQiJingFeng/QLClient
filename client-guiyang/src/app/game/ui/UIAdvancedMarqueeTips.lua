local csbPath = "ui/csb/UIAdvancedMarqueeTips.csb"

local UIAdvancedMarqueeTips = class("UIAdvancedMarqueeTips", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)

function UIAdvancedMarqueeTips:ctor()
	self._tip = nil
	self._rollSpeed = 105		-- 滚动速度
end

function UIAdvancedMarqueeTips:init()
	self._tip = seekNodeByName(self, "Text_content", "ccui.Text")
	self._tip:setString("")
	self._tip:setAnchorPoint(cc.p(0, 0.5))

	self._tipBg = seekNodeByName(self, "Image_textbg", "ccui.ImageView")
	self._rocket = seekNodeByName(self, "Rocket", "ccui.ImageView")

	self._animAction = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._animAction)

    self._callbackNode = cc.Node:create();
    self:addChild(self._callbackNode);

	-- self._tipLayout = seekNodeByName(self, "Panel_text_MarqueeTips", "ccui.Layout")
	-- self._tipLayout:setClippingEnabled(true)

	-- self._bgSize = self._tipLayout:getContentSize()
	-- self._tipInitPos = cc.p(self._bgSize.width, self._bgSize.height / 2)
end

-- 是否需要显示背景遮罩
function UIAdvancedMarqueeTips:needBlackMask()
	return false
end

function UIAdvancedMarqueeTips:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.TopMost; -- 凌驾于万物之上
end

function UIAdvancedMarqueeTips:onShow(marquee)
	marquee.text = string.gsub(marquee.text, "[\n\r]", "")

	self._tip:setString(marquee.text)
	self._txtSize = self._tip:getContentSize()
	self._bgSize = self._tipBg:getContentSize()

	self._tipBg:setContentSize({width=self._txtSize.width+90, height=self._bgSize.height})
	self._bgSize = self._tipBg:getContentSize() -- 更新一下大小

	self._animAction:play("enter" , false)

	self._schedule = scheduleOnce(function()
		-- self._csbAnim:removeFromParent(true)
		-- 播放完成后，可能需要延时一会
		self._schedule = nil
		self:playMoveAction()
	end, self:getAnimTime(self._animAction),self._callbackNode)
end

function UIAdvancedMarqueeTips:playMoveAction()
	print('12313123')
	local distance = 1000 + self._bgSize.width
	local delay = distance / self._rollSpeed
	local moveByAction = cc.MoveBy:create(delay, cc.p(-distance, 0))
	local hide = function ()
		UIManager:getInstance():hide("UIAdvancedMarqueeTips", false)
	end
	local callFuncAction = cc.CallFunc:create(hide)
	
	self._tipBg:runAction(moveByAction:clone())
	self._rocket:runAction(cc.Sequence:create(moveByAction, callFuncAction))
end

function UIAdvancedMarqueeTips:getAnimTime(timeline)
    local speed = timeline:getTimeSpeed()
    local startFrame = timeline:getStartFrame()
    local endFrame = timeline:getEndFrame()
    local frameNum = endFrame - startFrame

    return 1.0 /(speed * 60.0) * frameNum
end

function UIAdvancedMarqueeTips:onHide()
    if self._schedule then
        unscheduleOnce(self._schedule,self._callbackNode);
    end
	if self._tip ~= nil then
		self._tip:stopAllActions()
		self._tipBg:stopAllActions()
		self._rocket:stopAllActions()
	end
end

-- 隐藏跑马灯
function UIAdvancedMarqueeTips:hideImmediately()
	if self._tip ~= nil then
		self._tip:stopAllActions()
		self._tipBg:stopAllActions()
		self._rocket:stopAllActions()
	end
	UIManager:getInstance():hide("UIAdvancedMarqueeTips", false)
end

return UIAdvancedMarqueeTips
