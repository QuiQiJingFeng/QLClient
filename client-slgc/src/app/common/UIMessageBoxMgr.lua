local csbPath = "ui/csb/UIMessageBox.csb"
local super = game.UIBase
local Util = game.Util
local UIMessageBox = class("UIMessageBox", super, function () return Util:loadCSBNode(csbPath) end)

function UIMessageBox:ctor()
	-- 每次弹出都会有个全局唯一id
	self._boxId = 0 

	self._btnOK  = nil;
	self._btnCancel  = nil;
	self._btnOkSingle = nil;
	self._textInfo = nil;
	self._onOkCallBack = nil;
	self._onCancelCallBack = nil;
	self._strInfo = "";
	self._messageBoxType = nil
	self._btnOK_Img = nil
	self._btnCancel_Img = nil
	self._btnOkSingle_Img = nil

	self:init()
end

function UIMessageBox:getBoxId()
	return self._boxId
end

function UIMessageBox:setBoxId(id)
	self._boxId = id
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIMessageBox:getGradeLayerId()
	return game.UIConstant.UILAYER_LEVEL.TOP
end

function UIMessageBox:init()
	self._btnOK  = Util:seekNodeByName(self, "Button_qd_messagebox",  "ccui.Button") -- 左边的按钮
	self._btnOK_Img = Util:seekNodeByName(self, "BitmapFontLabel_1",  "ccui.TextBMFont") -- 左边的按钮显示的文字
	self._btnCancel  = Util:seekNodeByName(self, "Button_qx_messagebox",  "ccui.Button") -- 右边按钮
	self._btnCancel_Img  = Util:seekNodeByName(self, "BitmapFontLabel_1_0",  "ccui.TextBMFont") -- 右边按钮显示的文字
	self._btnOkSingle = Util:seekNodeByName(self, "Button_qd2_messagebox", "ccui.Button") -- 中间的按钮
	self._btnOkSingle_Img = Util:seekNodeByName(self, "BitmapFontLabel_1_0_0", "ccui.TextBMFont") -- 中间的按钮显示的文字
	self._textInfo = Util:seekNodeByName(self, "Text_messagebox", "ccui.Text") -- 内容
	self._btnClose = Util:seekNodeByName(self, "Button_1", "ccui.Button") --"X"按钮

	self:_registerCallBack()
end

function UIMessageBox:_registerCallBack()
	Util:bindTouchEvent(self._btnOK, handler(self, self.onOK));
	Util:bindTouchEvent(self._btnCancel, handler(self, self.onCancel));
	Util:bindTouchEvent(self._btnOkSingle, handler(self, self.onOK));
	Util:bindTouchEvent(self._btnClose, handler(self, self.onClose))
end

function UIMessageBox:_addCallBack(beforeCallback, callback )
	self._beforeFinishCallback = beforeCallback
	self._finishCallback = callback
end 

function UIMessageBox:_finish()
	if self._finishCallback then
		self._finishCallback(self)
	end
end

-- 开始关闭前的回调，通知manager设置脏标记
function UIMessageBox:_beforeFinish()
	if self._beforeFinishCallback then
		self._beforeFinishCallback()
	end
end

-- 1.是否播放关闭动画（如果是数据刷新则不用）
-- 2.显示的内容
-- 3.显示按钮的字体(确定、取消、反馈)   根据长度判断是否显示两个按钮还是一个按钮
-- 4.左边（中间）按钮的回调
-- 5.右边按钮的回调
-- 6.是否隐藏"X"按钮
-- 7.点X是否要关闭界面
-- 8.文字显示的水平对齐方式（0.left, 1.center(default),2.right）
function UIMessageBox:onShow(playAni, strInfo, buttonParams, onOkCallBack, onCancelCallBack, hideBtnClose, visibleBegin, textHAlign)
	self._strInfo = strInfo
	if nil == strInfo then
		self._strInfo = ""
	end

	local isVisible = #buttonParams == 2

	self._btnOK:setVisible(isVisible);
	self._btnOK:setTouchEnabled(isVisible);
	self._btnOK_Img:setString(buttonParams[1])
	self._btnCancel:setVisible(isVisible);
	self._btnCancel:setTouchEnabled(isVisible);
	self._btnCancel_Img:setString(isVisible and buttonParams[2] or "")
	self._btnOkSingle:setVisible(not isVisible);
	self._btnOkSingle:setTouchEnabled(not isVisible);
	self._btnOkSingle_Img:setString(buttonParams[1])

	self._messageBoxType = #buttonParams == 2
	self._onOkCallBack = onOkCallBack
	self._onCancelCallBack = onCancelCallBack
	self._btnClose:setVisible(not hideBtnClose)

	self._isVisible = not not visibleBegin
	
	self._textInfo:setTextHorizontalAlignment(1)
	self._textInfo:setString(self._strInfo);
	if textHAlign and type(textHAlign) == "number" and textHAlign >= 0 and textHAlign <= 2 then
		self._textInfo:setTextHorizontalAlignment(textHAlign)
	end

	self:setLocalZOrder(50 + self.getGradeLayerId())
	
	if playAni then
		-- 弹出动画
		self:playShowAction()
	end
end

function UIMessageBox:needBlackMask()
	return true;
end

function UIMessageBox:closeWhenClickMask()
	return false
end

function UIMessageBox:isPersistent()
	return true;
end

--右边按钮的回调
function UIMessageBox:onCancel(sender)
	self:_beforeFinish()
	
	if nil ~= self._onCancelCallBack and "function" == type(self._onCancelCallBack) then
		if self:_onCancelCallBack() == false then
			return
		end
	end

	self:_finish()
end

--左边（中间）按钮的回调
function UIMessageBox:onOK(sender)
	self:_beforeFinish()

	if nil ~= self._onOkCallBack and "function" == type(self._onOkCallBack) then
		if self:_onOkCallBack() == false then
			return
		end
	end

	self:_finish()
end

--X按钮的回调
function UIMessageBox:onClose(sender)
	if self._messageBoxType or self._isVisible then
		self:onCancel(sender)
	else
		self:onOK(sender)
	end
end


-----------------------UIMessageBoxMgr 管理器--------------------------
--[[
	只使用同一个ui，数据存在堆栈离，每次控制显示栈顶的数据
	还有一个id堆栈和数据是绑定的，如果要隐藏特定ui，使用hide传入id
]]

local UIMessageBoxMgr = class("UIMessageBoxMgr")

-- box id 全局唯一
local _getBoxId = function()
	local i = 0
	return function()
		i = i + 1
		return i
	end
end
local getBoxId = _getBoxId()

-- 单例
local instance = nil
function UIMessageBoxMgr.getInstance()
	if instance == nil then
		instance = UIMessageBoxMgr.new()
	end
	return instance
end

function UIMessageBoxMgr:ctor()
	-- 数据堆栈
	self._boxDataStack = {}
	-- id堆栈，与数据堆栈同增同减
	self._boxIdStack = {}
	-- 缓存队列，在pop为脏时，新加的弹窗存入此队列
	self._boxDataCache = {}
	-- pop脏标记，当一个弹窗正在弹出时，不响应任何新加的弹窗
	self._popDirty = false
end

-- 设置Pop标记为脏
function UIMessageBoxMgr:_setPopDirty()
	self._popDirty = true
end

function UIMessageBoxMgr:createBox()
	local box = nil
	Logger.info("UIMessageBoxMgr ==> add new UIMessageBox!")
	box = UIMessageBox.new()
	box:retain() -- 保证remove后不被释放掉
	box:_addCallBack(handler(self, self._setPopDirty), handler(self, self._popBox))

	return box
end

-- 创建一个box显示
-- 参数为要显示的文字内容
function UIMessageBoxMgr:show(...)
	if self._box == nil then
		self._box = self:createBox()
	end

    if #self._boxDataStack == 0 then
        local scene = cc.Director:getInstance():getRunningScene()
		scene:addChild(self._box)
	end

	local args = {...}
	-- 检查当前是否为pop状态，如果是，则加入cache中，否则就直接弹出
	local boxId = getBoxId()
	if self._popDirty then
		table.insert(self._boxDataCache, args)
	else
		table.insert(self._boxDataStack, args)
		table.insert(self._boxIdStack, boxId)
	
		self:_showUI(true, ...)
	end

	return boxId
end

function UIMessageBoxMgr:showAlert(content, horizontalAlign)
	return self:show(content, {"确认"}, nil, nil, true, true, horizontalAlign)
end

function UIMessageBoxMgr:_showUI(playAnim, ...)
	if #self._boxDataStack == 0 then
		return -- 没有数据就无视
	end

	local current = self._boxDataStack[#self._boxDataStack]
	local id = self._boxIdStack[#self._boxIdStack]
	
	self._box:onShow(playAnim, ...)
	self._box:setBoxId(id)
end

-- 隐藏某个box，需要知道其boxId
function UIMessageBoxMgr:hide(boxId)
	for i, id in ipairs(self._boxIdStack) do
		if id == boxId then
			if i == #self._boxDataStack then
				-- 最上面的ui，直接调_popBox
				self:_popBox(self._box)
			else
				-- 其他的把数据删掉就好
				table.remove( self._boxDataStack, i )
				table.remove( self._boxIdStack, i )
			end
			return true
		end
	end
	
	-- Macro.assetTrue(true, "[WARN]hide A NOT Existed Box:"..id)
	return false
end

-- 清空当前的所有数据，释放box，instance
function UIMessageBoxMgr:dispose()
	self._boxDataStack = {}
    self._boxIdStack = {}
    if self._box then
        self._box:stopAllActions()
        self._box:release()
    end
	self._box = nil
	instance = nil
end

-- 当每一个box显示结束后的回调
function UIMessageBoxMgr:_popBox(box)
	assert(self._box == box)
	table.remove( self._boxDataStack, #self._boxDataStack )
	table.remove( self._boxIdStack, #self._boxIdStack )
	
	-- 删除已完成，恢复脏标记
	self._popDirty = false
	-- 检查是否有缓存中的弹窗，有则加入到堆栈中
	local playAni = self:_checkCache()

	if #self._boxDataStack > 0 then
		self:_showUI(playAni, unpack(self._boxDataStack[#self._boxDataStack]))
	else
		self._box:removeFromParent()
	end
end

-- 检查缓存队列，如果其中有弹窗则加入到堆栈中
function UIMessageBoxMgr:_checkCache()
	if #self._boxDataCache == 0 then
		return false
	end
	for _, v in ipairs(self._boxDataCache) do
		local boxId = getBoxId()
		table.insert(self._boxDataStack, v)
		table.insert(self._boxIdStack, boxId)
	end

	self._boxDataCache = {}
	return true
end

return UIMessageBoxMgr