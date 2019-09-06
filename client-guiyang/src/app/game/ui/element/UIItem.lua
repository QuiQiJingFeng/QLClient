local csbPath = "ui/csb/Icon_month.csb"

local UIItem = class("UIItem", function()
	return cc.CSLoader:createNode(csbPath)
end)

-- 新建物品(完全用预设的)
function UIItem:ctor(itemId, count, time, bTouch)
	self._itemId = itemId
	self._count = count
	self._time = time
	self._bTouch = bTouch
	self:init()
end

function UIItem:init()
	
	self._panelItem = seekNodeByName(self, "Panel_Item", "ccui.Layout")
	self._imageItem = seekNodeByName(self, "Image_Item", "ccui.ImageView")
	self._bmBack = seekNodeByName(self, "Image_Item_0", "ccui.ImageView")
	self._bmItem = seekNodeByName(self, "BM_Name", "ccui.TextBMFont")
	
	local icon = PropReader.getIconByIdAndCount(self._itemId, self._count)
	
	-- if PropReader.getTypeById(self._itemId) == "HeadFrame" or  PropReader.getTypeById(self._itemId) == "ConsumableTimeLimite" then
	if string.sub(icon, string.len( icon )-3) == ".csb" then
		--头像框的处理		
		self._imageItem:setVisible(false)
		local pNode = cc.CSLoader:createNode(icon)
		local ani = cc.CSLoader:createTimeline(icon)
		ani:gotoFrameAndPlay(0, true)
		pNode:setScale(0.5)
		pNode:runAction(ani)
		pNode:setPosition(self._imageItem:getPosition())
		self._panelItem:addChild(pNode)
		self._bmBack:setLocalZOrder(pNode:getLocalZOrder() + 1)
		self._bmItem:setLocalZOrder(pNode:getLocalZOrder() + 1)
	else
		--静态图的处理
		self._imageItem:ignoreContentAdaptWithSize(true)
		if string.find(icon, "http") then
			--远程文件
			-- 保存加载的地址, 下载之后对比是否需要中
			self._imageItem.iconUrl = icon
			manager.RemoteFileManager.getInstance():getRemoteFile("RealItem", icon, function(tf, fileType, fileName)
				if tf == true and not tolua.isnull(self._imageItem) and self._imageItem.iconUrl == icon then
					-- 清除缓存的url标记
					self._imageItem.iconUrl = nil
					
					-- 获取成功之后设置图片				
					local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
					self._imageItem:loadTexture(filePath)
				end
			end);
		else
			self._imageItem:loadTexture(icon)
		end
	end
	
	if PropReader.getTypeById(self._itemId) == "HeadFrame" or PropReader.getTypeById(self._itemId) == "ConsumableTimeLimite" then
		if self._time > 0 then
			self._bmItem:setString(self._time .. "天")
		else
			self._bmItem:setString("永久")
		end
	elseif PropReader.getTypeById(self._itemId) == "RedPackage" then
		self._bmItem:setString(self._count .. "元")
	else
		self._bmItem:setString("X" .. self._count)
	end
	
	bindEventCallBack(self._panelItem, handler(self, self._onClickItem), ccui.TouchEventType.ended)
	self._panelItem:setTouchEnabled(self._bTouch)
end

function UIItem:_onClickItem()
	UIManager:getInstance():show("UIElemItem", self._itemId, self._count)
end
--修改触摸状态
function UIItem:changeTouchState(bTouch)
	self._panelItem:changeTouchState(self._bTouch)
end
--修改触摸函数
function UIItem:setCallBackFunction(func)
	self:changeTouchState(true)
	bindEventCallBack(self._panelItem, func, ccui.TouchEventType.ended)
end

--修改字体颜色
function UIItem:changeFontColor(color)
	self._bmItem:setColor(color)
end

--隐藏文字
function UIItem:hideFont()
	self._bmItem:setVisible(false)
	self._bmBack:setVisible(false)
	self._imageItem:setPositionY(self._panelItem:getContentSize().height / 2)
end

function UIItem:fixItemSizeAndPos()
	local parent = self:getParent()
	local size = parent:getContentSize()
	
	item:setPosition(size.width / 2, size.height / 2)
	
	local imageSize = self:getContentSize()
	local _scale = 1
	if height / width > 120 / 120 then
		_scale = width / 120
	else
		_scale = height / 120
	end
	-- 解决如果放在 node 下， scale 会变成0 的问题
	if _scale <= 0 then
		_scale = 1
	end
	self:setScale(_scale)
end

local function getItemShowString(itemId, count, time)
	local itemName = PropReader.getNameById(itemId)
	if count then
		local count = "X" .. count
		if PropReader.getTypeById(itemId) == "HeadFrame" or PropReader.getTypeById(itemId) == "ConsumableTimeLimite" then
			if time > 0 then
				count = time .. "天"
			else
				count = " 永久"
			end
		elseif PropReader.getTypeById(itemId) == "RedPackage" then
			count = count .. "元"
		end
		return itemName .. " " .. count
	else
		return itemName
	end
	
end

function UIItem:showItemName()
	local name = getItemShowString(self._itemId, self._count, self._time)
	self._bmItem:setString(name)
end

-- 继承物品(用已有的控件设置,需要文本 和 一个容器,图标适配容器大小,文字不变),以上的方法无法使用
function UIItem.extend(panel, text, itemId, count, time)
	PropReader.setIconForNode(panel, itemId)
	if text ~= nil then
		text:setString(getItemShowString(itemId, count, time))
	end

	-- local t = tolua.getpeer(panel)
    -- if not t then
    --     t = {}
    --     tolua.setpeer(panel, t)
    -- end
    -- setmetatable(t, UIItem)
end


return UIItem
