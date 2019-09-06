local ElemAttachment = class("ElemAttachment")

--初始化list控件中的每个单元
local function initDetailList(listItem)
	listItem.icon = ccui.Helper:seekNodeByName(listItem, "imgIcon")
	listItem.nums = ccui.Helper:seekNodeByName(listItem, "textItemCount")
end

--给list中的控件赋值
local function setListData(listItem, value)
	PropReader.setIconForNode(listItem.icon,(value.id))
	listItem.nums:setString("X" .. value.count)
	
	listItem.nums:setVisible(value.count ~= 1)
	
	if tonumber(value.id) ~= nil then
		bindEventCallBack(listItem, function()
			UIManager.getInstance():show("UIPropDetail", value.id)
		end, ccui.TouchEventType.ended)
	end
end

function ElemAttachment:extend(...)
	local t = tolua.getpeer(self)
	if not t then
		t = {}
		tolua.setpeer(self, t)
	end
	setmetatable(t, ElemAttachment)
	self:_initialize()
	return self
end

function ElemAttachment:_initialize()
	self._posX = self:getPositionX() --缓存列表的初始坐标
	--处理列表
	self:setScrollBarEnabled(false)
	self._templateNode = self:getItem(0)
	self._templateNode:removeFromParent(false)
	self:getParent():addChild(self._templateNode)
	self._templateNode:setVisible(false)
	self:removeItem(0) -- 仅removeFromParent是不够的
end


function ElemAttachment:setAttachment(values)
	self:removeAllItems()
	self:setPositionX(self._posX)
	for k, v in ipairs(values) do
		local itemNode = self._templateNode:clone()
		initDetailList(itemNode)
		itemNode:setVisible(true)
		setListData(itemNode, v)
		self:pushBackCustomItem(itemNode)
	end
	
	local width = self:getContentSize().width
	local innerWidth = self:getItemsMargin() *(#values - 1) + self._templateNode:getContentSize().width * #values
	
	if innerWidth < width then
		self:setPositionX(self._posX +(width - innerWidth) / 2)
	end
end

return ElemAttachment 