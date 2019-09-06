local csbPath = "ui/csb/UIMessageTips.csb"
local super = require("app.game.ui.UIBase")

--------------------每一个tips的单个实例--------------------
local UIMessageTips = class("UIMessageTips", super, function () return kod.LoadCSBNode(csbPath) end)

function UIMessageTips:ctor()
	self._textMessageTips  = nil;
	self._strInfo = "";
	self._actionFinish = nil

	self:init()
end

function UIMessageTips:init()
	self._textMessageTips  = seekNodeByName(self, "Text_MessageTips",  "ccui.Text");
	self._panelTips = seekNodeByName(self, "Panel_MessageTips", "ccui.Layout")
end

function UIMessageTips:_addCallBack(callback)
	self._actionFinish = callback
end

function UIMessageTips:onShow(...)
	local args = {...};
	
	if (nil ~= args[1]) then
		self._strInfo = args[1];
	else
		self._strInfo = "";
	end
	
	self._textMessageTips:setString(self._strInfo);
	-- 做一下背景根据提示文字适配
	local _size = self._textMessageTips:getVirtualRendererSize()
	self._panelTips:setContentSize(cc.size(_size.width + 300, self._panelTips:getContentSize().height))

	self:setLocalZOrder(config.UIConstants.UIZorder + 5)
end

function UIMessageTips:needBlackMask()
	return false;
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

-----------------------UIMessageTipsMgr 管理器--------------------------
local ns = namespace("game.ui")

local UIMessageTipsMgr = class("UIMessageTipsMgr")
ns.UIMessageTipsMgr = UIMessageTipsMgr;

-- 单例
local instance = nil
function UIMessageTipsMgr.getInstance()
	if instance == nil then
		instance = UIMessageTipsMgr.new()
	end
	return instance
end

function UIMessageTipsMgr:ctor()
	-- 废弃列表
	self._poolFree = {}
	-- 当前使用中的列表
	self._poolUsed = {}
end

-- 创建一个tips显示
-- 参数为要显示的文字内容
function UIMessageTipsMgr:showTips(...)
	local tips = nil
	if #self._poolFree > 0 then
		tips = self._poolFree[#self._poolFree]
		table.remove( self._poolFree, #self._poolFree )
	else
		Logger.info("UIMessageTipsMgr ==> add new UIMessageTips!")
		tips = UIMessageTips.new()
		tips:retain()
		tips:_addCallBack(handler(self, self._actionFinish))
	end
	if nil ~= tips then
		self._poolUsed[#self._poolUsed + 1] = tips
		if nil ~= GameMain:getInstance() then
			GameMain:getInstance():addChild(tips);
		end
		tips:onShow(...)
		local args = {...}
		tips:doAction(args[2])
	end
	return tips
end
-- 清空当前的所有tips
function UIMessageTipsMgr:dispose()
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
function UIMessageTipsMgr:_actionFinish(tips)
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