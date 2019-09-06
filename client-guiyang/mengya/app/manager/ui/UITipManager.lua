local csbPath = "ui/csb/mengya/UIMessageTips.csb"

--------------------每一个tips的单个实例--------------------
local UIMessageTips = class("UIMessageTips", function () return app.Util:loadCSBNode(csbPath) end)

function UIMessageTips:ctor()
	self._textMessageTips  = nil
	self._strInfo = ""
	self._actionFinish = nil

	self:init()
end

function UIMessageTips:init()
	self._textMessageTips  = app.Util:seekNodeByName(self, "txtTip",  "ccui.Text")
	self._panelTips = app.Util:seekNodeByName(self, "panelLayout", "ccui.Layout")
end

function UIMessageTips:_addCallBack(callback)
	self._actionFinish = callback
end

function UIMessageTips:onShow(content)
	self._strInfo = content
	self._textMessageTips:setString(self._strInfo)
	-- 做一下背景根据提示文字适配
	local _size = self._textMessageTips:getVirtualRendererSize()
	self._panelTips:setContentSize(cc.size(_size.width + 300, self._panelTips:getContentSize().height))

	self:setLocalZOrder(1000)
end

function UIMessageTips:needBlackMask()
	return false
end

function UIMessageTips:closeWhenClickMask()
	return false
end

function UIMessageTips:_finish()
	self:removeFromParent()
	if self._actionFinish then
		self._actionFinish(self)
	end
end

-- tips的动画过程
function UIMessageTips:doAction(delay)
	local delayTime = delay or 1
	local spawnTime = 1

    local size = cc.Director:getInstance():getWinSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(size.width/2, size.height/2)
	self:setOpacity(255)

	local delay = cc.DelayTime:create(delayTime)
	local fadeout = cc.FadeOut:create(spawnTime)
    local move_ease_out = cc.EaseSineIn:create(cc.MoveTo:create(spawnTime, cc.p(size.width/2, size.height)))
    local callback = cc.CallFunc:create(handler(self, self._finish))
	local spawn = cc.Spawn:create(move_ease_out, fadeout)
    local seq = cc.Sequence:create(delay, spawn, callback)
    self:runAction(seq)
end

-----------------------UITipManager 管理器--------------------------
local UITipManager = class("UITipManager")

-- 单例
local instance = nil
function UITipManager:getInstance()
	if instance == nil then
		instance = UITipManager.new()
	end
	return instance
end

function UITipManager:ctor()
	-- 废弃列表
	self._poolFree = {}
	-- 当前使用中的列表
	self._poolUsed = {}
end

-- 创建一个tips显示
-- 参数为要显示的文字内容
function UITipManager:show(content,delay)
	local tips = nil
	if #self._poolFree > 0 then
		tips = self._poolFree[#self._poolFree]
		table.remove( self._poolFree, #self._poolFree )
	else
		tips = UIMessageTips.new()
		tips:retain()
		tips:_addCallBack(handler(self, self._actionFinish))
	end
	if nil ~= tips then
        self._poolUsed[#self._poolUsed + 1] = tips
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(tips)
        
		tips:onShow(content)
		tips:doAction(delay)
	end
	return tips
end
-- 清空当前的所有tips
function UITipManager:dispose()
	for i = 1, #self._poolFree do
		self._poolFree[i]:stopAllActions()
		self._poolFree[i]:release()
	end
	self._poolFree = {}
	for i = 1, #self._poolUsed do
		self._poolUsed[i]:stopAllActions()
		self._poolUsed[i]:release()
	end
	self._poolUsed = {}
end

-- 当每一个tips显示结束后的回调
function UITipManager:_actionFinish(tips)
	if nil == tips then
		return
	end

	for i = 1, #self._poolUsed do
		if self._poolUsed[i] == tips then
			table.remove( self._poolUsed, i )
			break
		end
	end
	self._poolFree[#self._poolFree + 1] = tips
end

return UITipManager