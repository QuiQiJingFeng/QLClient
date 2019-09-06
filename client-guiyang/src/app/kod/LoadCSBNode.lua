local ns = namespace("kod")

local widthDesigned = CC_DESIGN_RESOLUTION.width
local heightDesigned = CC_DESIGN_RESOLUTION.height
local width, height = display.width, display.height
local start_x, start_y -- cocostudio node默认坐标(0, 0)在适配后的坐标

-- 对于有safeArea的设备(如iphone-x), 我们以安全区宽度做为屏幕逻辑宽度处理控件
local safeAreaOffset_x = 0

local function getNodeTraits(node)
	local cdata = node:getComponent("ComExtensionData")
	if not cdata then return end
	local traits = cdata:getCustomProperty()
	if not traits or traits == "" then return end
	return string.split(traits, ",")
end

-- 先计算一轮设计数据(坐标转换)
-- 防止父节点先调整导致子节点无法得到正确设计数据
local function gatherDesignedData(node)
	local trait_tbl = getNodeTraits(node)
	if not trait_tbl then return end
	local x, y = node:getPosition()
	local p = node:getParent():convertToWorldSpace(cc.p(x, y))
	node.designedX, node.designedY = p.x, p.y
end

-- 调整节点
local function adjustNode(node)
	local trait_tbl = getNodeTraits(node)
    if not trait_tbl then return end
    local pos = cc.p(node:getPosition())
	for _, trait in ipairs(trait_tbl) do
		if trait == "left" then
			local designedLeft = node.designedX - start_x + safeAreaOffset_x
			local p = node:getParent():convertToNodeSpace(cc.p(designedLeft, 0))
			node:setPositionX(p.x)
		elseif trait == "right" then
			local designedRight = start_x + node.designedX - safeAreaOffset_x
			local p = node:getParent():convertToNodeSpace(cc.p(designedRight, 0))
			node:setPositionX(p.x)
		elseif trait == "top" then
			local designedTop = start_y + node.designedY
			local p = node:getParent():convertToNodeSpace(cc.p(0, designedTop))
			node:setPositionY(p.y)
		elseif trait == "bottom" then
			local designedBottom = node.designedY - start_y
			local p = node:getParent():convertToNodeSpace(cc.p(0, designedBottom))
			node:setPositionY(p.y)
		elseif trait == "x-center-parent" then -- x方向在父容器中间
			local p = node:getPositionPercent()
			node:setPositionPercent(cc.p(0.5, p.y))
		elseif trait == "y-center-parent" then -- y方向在父容器中间
			local p = node:getPositionPercent()
			node:setPositionPercent(cc.p(p.x, 0.5))
		elseif trait == "width-scale" then -- 刘海屏幕
			if width > widthDesigned then -- 在x方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(width - (widthDesigned - contentSize.width), contentSize.height))
			end
		elseif trait == "height-scale" then
			if height > heightDesigned then  -- 在y方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(contentSize.width, height - (heightDesigned - contentSize.height)))
			end
		elseif trait == "x-percent" then
			if width > widthDesigned then -- 在x方向超过设计比例
				local x = node.designedX / widthDesigned * (width - safeAreaOffset_x * 2)
				local p = node:getParent():convertToNodeSpace(cc.p(x - start_x + safeAreaOffset_x, 0))
				node:setPositionX(p.x)
			end
		elseif trait == "y-percent" then
			if height > heightDesigned then  -- 在y方向超过设计比例
				local y = node.designedY / heightDesigned * height
				local p = node:getParent():convertToNodeSpace(cc.p(0, y - start_y))
				node:setPositionY(p.y)
			end
		elseif trait == "background" then
			local contentSize = node:getContentSize()
			if contentSize.width / contentSize.height > width / height then
				node:setScale(height / contentSize.height)
			else
				node:setScale(width / contentSize.width)
			end
		else
			assert(false, "error adaptation trait: " .. trait)
		end
	end
	node.designedX = nil
	node.designedY = nil
end

local function loopallchild(node, callback)
    callback(node)
    local children = node:getChildren()
    for _, child in ipairs(children) do
        loopallchild(child, callback)
    end
end

-- 修正字体渲染质量, 需配合cpp侧修改达到最佳效果
local videoScale = cc.Director:getInstance():getOpenGLView():getScaleX()
local _node_getContentSize = cc.Node.getContentSize
local _node_setContentSize = cc.Node.setContentSize
function ccui.Text:fitToScreen()
	self:setFontSize(self:getFontSize() * videoScale)
	local size = _node_getContentSize(self)
	_node_setContentSize(self, size.width * videoScale, size.height * videoScale)
	self:setScale(self:getScale() / videoScale)
	self._scaleFitToScreen = videoScale
end

function ccui.Text:setContentSize(size)
	local scale = self._scaleFitToScreen or 1.0
	_node_setContentSize(self, size.width * scale, size.height * scale)
end

function ccui.Text:getContentSize()
	local scale = self._scaleFitToScreen or 1.0
	local size = _node_getContentSize(self)
	size.width = size.width / scale
	size.height = size.height / scale
	return size
end

local _uitext_getVirtualRendererSize = ccui.Widget.getVirtualRendererSize
function ccui.Text:getVirtualRendererSize()
	local scale = self._scaleFitToScreen or 1.0
	local size = _uitext_getVirtualRendererSize(self)
	size.width = size.width / scale
	size.height = size.height / scale
	return size
end

local _uitext_setTextAreaSize = ccui.Text.setTextAreaSize
function ccui.Text:setTextAreaSize(size)
	local scale = self._scaleFitToScreen or 1.0
	size.width = size.width * scale
	size.height = size.height * scale
	_uitext_setTextAreaSize(self, size)
end

-- 增加一个format支持
function ccui.Text:setStringFormat(formatStr, ...)
    return self:setString(string.format(tostring(formatStr), ...))
end

-- 增加一个format支持
function ccui.TextBMFont:setStringFormat(formatStr, ...)
    return self:setString(string.format(tostring(formatStr), ...))
end

local function textFitToScreen(node)
    if tolua.type(node) == "ccui.Text" then
		node:fitToScreen()
    end
end

local InputHolderColor = cc.c4b(158, 158, 158, 255)
local inputTextColor = cc.c4b(45, 45, 45, 255)
local function setDefaultProperty(node)
	local type = tolua.type(node) 
	if type == "ccui.ListView" or type == "ccui.ScrollView" then
		node:setScrollBarEnabled(false)
		node:setClippingEnabled(true)
	elseif type == "ccui.TextField" then
		-- 全局替换颜色
		node:setPlaceHolderColor(InputHolderColor)
		node:setTextColor(inputTextColor)
	end
end

function ns.LoadCSBNode(csbPath)
	local node = cc.CSLoader:createNode(csbPath)
	start_x = (width - widthDesigned) * 0.5
    start_y = (height - heightDesigned) * 0.5
	node:setPosition(start_x, start_y)

    local director = cc.Director:getInstance()
    if director.getSafeAreaRect then
        local visibleRect = director:getOpenGLView():getVisibleRect()
        local safeAreaRect = director:getSafeAreaRect()
        if safeAreaRect.width < visibleRect.width then
            safeAreaOffset_x = (visibleRect.width - safeAreaRect.width) / 2
        end
    end

	loopallchild(node, gatherDesignedData)
	loopallchild(node, adjustNode)
	loopallchild(node, setDefaultProperty)
    if videoScale > 1.0 then
        loopallchild(node, textFitToScreen)
    end
	return node
end