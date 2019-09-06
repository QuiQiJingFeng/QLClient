local csbPath = "ui/csb/UIwj.csb" --ui文件
local super = require("app.game.ui.UIBase")

local UIAnswer = class("UIAnswer",super,function () return kod.LoadCSBNode(csbPath) end )

UIAnswer.TYPE = {
	YES_NO = 1,
	GET = 2,
}

--构造函数
function UIAnswer:ctor()
	--这里可以写成员的声明等
	self._type = UIAnswer.TYPE.YES_NO
	self._callback = nil
	self._idxSelect = nil

	self._btnYES = nil
	self._btnNO = nil
	self._btnGET = nil
	self._title = nil
	self._titleTips = nil
	self._anwserList = nil
	self._anwserListItem = nil

	-- 当前传过来的配置
	self._conf = nil
end

--析构函数
function UIAnswer:destroy()
	--释放内存
end

--初始化函数
function UIAnswer:init()
	--这里可以写成员的定义等
	self._btnYES    = seekNodeByName(self, "Button_yes_Wj","ccui.Button")
	self._btnNO    = seekNodeByName(self, "Button_no_Wj","ccui.Button")
	self._btnGET    = seekNodeByName(self, "Button_qd2_Wj","ccui.Button")
	self._title    = seekNodeByName(self, "Text_3_Wj","ccui.Text")
	self._titleTips    = seekNodeByName(self, "Text_messagebox_0_0","ccui.Text")
	self._anwserList    = seekNodeByName(self, "listOption","ccui.ListView")
	self._anwserListItem    = seekNodeByName(self, "panelOption","ccui.Layout")

	self._anwserListItem:removeFromParent()
	self:addChild(self._anwserListItem)
	self._anwserListItem:setVisible(false)

	bindEventCallBack(self._btnYES, handler(self, self._onYES), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnNO, handler(self, self._onNO), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnGET, handler(self, self._onGET), ccui.TouchEventType.ended);
end

--显示函数
function UIAnswer:onShow(...)
	--界面显示逻辑
	local args = {...}
	args[1] = args[1] or {}
	self._callback = args[2]
	self._type = args[1].type_ or UIAnswer.TYPE.YES_NO
	if self._type == UIAnswer.TYPE.YES_NO then
		self._btnYES:setVisible(true)
		self._btnNO:setVisible(true)
		self._btnGET:setVisible(false)
		self._anwserList:setVisible(false)
	else
		self._btnYES:setVisible(false)
		self._btnNO:setVisible(false)
		self._btnGET:setVisible(true)
		self._anwserList:setVisible(true)
		self._anwserList:removeAllChildren()
		self._btnGET:setTouchEnabled(false)
		self._btnGET:setEnabled(false)
		local answers = args[1].anwsers_
		-- 所有item，只可同时选中一个
		local items = {}
		for i=1,#answers do
			local item = self._anwserListItem:clone()
			item:setVisible(true)
			self._anwserList:addChild(item)
			local textItem = seekNodeByName(item, "text","ccui.Text")
			local showText = answers[i] or ""
			textItem:setString(showText)
			local checkItem = seekNodeByName(item, "check","ccui.CheckBox")
			table.insert(items, checkItem)
			checkItem:setSelected(false)

			local isSelected = false
			checkItem:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					isSelected = checkItem:isSelected()
				elseif eventType == ccui.TouchEventType.moved then
				elseif eventType == ccui.TouchEventType.ended then
					for j=1,#items do
						items[j]:setSelected(false)
					end
					checkItem:setSelected(true)
					self._idxSelect = args[1].index_[i]
					self._btnGET:setTouchEnabled(true)
					self._btnGET:setEnabled(true)
				elseif eventType == ccui.TouchEventType.canceled then
					checkItem:setSelected(isSelected)
				end
			end)
		end
		self._anwserList:setScrollBarEnabled(false)
	end

	self._title:setString(args[1].title_ or "")
	self._titleTips:setString(args[1].titleTips_ or "")

	self._conf = args[1]
end

--隐藏函数
function UIAnswer:onHide()
	--界面隐藏逻辑
end

--返回界面层级
function UIAnswer:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIAnswer:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UIAnswer:needBlackMask()
	return false;
end

--关闭时操作
function UIAnswer:closeWhenClickMask()
	return false
end

-- 标记为Persistent的UI不会destroy
function UIAnswer:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UIAnswer:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
function UIAnswer:_hide()
	UIManager:getInstance():hide("UIAnswer")
end

function UIAnswer:_onYES()
	self:_hide()
	if self._callback then
		self._callback(self._conf.index_[1])
	end
end

function UIAnswer:_onNO()
	self:_hide()
	if self._callback then
		self._callback(self._conf.index_[2])
	end
end

function UIAnswer:_onGET()
	self:_hide()
	if self._callback then
		self._callback(self._idxSelect)
	end
end

return UIAnswer;