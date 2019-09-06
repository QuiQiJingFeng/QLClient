local Util = {}

-- 通过名字查找子控件
function Util:seekNodeByName(view, name, property)
    local node = ccui.Helper:seekNodeByName(view, name)
    if property then
        return tolua.cast(node, property)
    end
    return node
end

function Util:show(...)
    local nodes = {...}
    for _, node in ipairs(nodes) do
        node:setVisible(true)
    end
end

function Util:hide(...)
    local nodes = {...}
    for _, node in ipairs(nodes) do
        node:setVisible(false)
    end
end

-- 给任何节点注册touch响应，不仅限于button，可以是node，layer，panel，sprite。。。
-- 一般都是ended的时候响应，不用传响应事件
function Util:bindTouchEvent(node, callback, touchScale)
    assert(node,"bindEventCallBack error!")
    node:setTouchEnabled(true)
    local originScale = node:getScale()
    local registerCallBack = function(sender, eventType)
        if touchScale then
            if eventType == ccui.TouchEventType.began then
                node:setScale(touchScale or originScale)
            elseif eventType == ccui.TouchEventType.moved then
            else    -- 其他情况，恢复按钮原始状态
                node:setScale(originScale)
            end
        end

        if eventType == ccui.TouchEventType.ended then
            local name = node:getName()
            callback(sender, eventType)
        end
    end

    node:addTouchEventListener(registerCallBack)
end

function Util:replaceTextFieldToEditBox(textField)
    local zorder = textField:getLocalZOrder()
    local size = textField:getContentSize()
    local pos = cc.p(textField:getPosition())
    local placeHolder = textField:getPlaceHolder()
    local anchor = textField:getAnchorPoint()
    local fontSize = textField:getFontSize()
    local fontName = textField:getFontName()
    local editBox = ccui.EditBox:create(size, ccui.Scale9Sprite:create("art/img/transparent.png"))
    editBox:setPosition(pos)
    editBox:setLocalZOrder(zorder)
    editBox:setPlaceHolder(placeHolder)
    editBox:setAnchorPoint(anchor)
    editBox:setFontSize(fontSize)
    editBox:setFontName(fontName)

    local parent = textField:getParent()
    parent:addChild(editBox)
    textField:removeFromParent()
    return editBox
end

function Util:setTimeDiff(serverTime)
    self._timeDiff = serverTime - os.time()
end

--获取服务器时间<服务器时间为东八区时间>
function Util:getCurrentTime()
    return os.time() + (self._timeDiff or 0)
end
--[[year、month、day、hour、min、sec、yday、wday、isdst]]
function Util:getDateInfo(time)
    time = time or self:getCurrentTime()
    return os.date("*t",time)
end

--服务器时间的时分秒
function Util:getFormatDate(format,time)
    format = format or "%Y-%m-%d %H:%M:%S"
    time = time or self:getCurrentTime()
    return os.date(format,time)
end

function Util:getDaySeconds()
    return 24 * 60 * 60
end


function Util:parseCsvWithPath(path)
    local file = io.open(path,"rb")
    local content = file:read("*a")
    file:close()

    content = string.gsub(content,"\r","")

    local datas = {}
    local lines = string.split(content,"\n")
    local keys
    local types
    for i = 1, #lines do
        local values = string.split(lines[i],",")
        if i == 1 then
            keys = values
        elseif i == 2 then
            types = values
        else
            local data = {}
            for idx, key in ipairs(keys) do
                local value = values[idx]
                if types[idx] == "number" then
                    value = tonumber(value)
                elseif types[idx] == "boolean" then
                    value = value == "true"
                end
                data[key] = value
            end
            datas[data.id] = data
        end
    end
    return datas
end

function Util:hash(text)
    local hash = 5381
    for n = 1, #text do
        hash = hash + bit.lshift(hash, 5) + string.byte(text, n)
    end
    return bit.band(hash, 2147483647)
end

local function loopallchild(node, callback)
    callback(node)
    local children = node:getChildren()
    for _, child in ipairs(children) do
        loopallchild(child, callback)
    end
end

local function parseChildProperty(self,node)
    local cdata = node:getComponent("ComExtensionData")
    if not cdata then return end
    local traits = cdata:getCustomProperty()
    if not traits or traits == "" then return end
    local propertys = string.split(traits, ",")
    local pos = cc.p(node:getPosition())
    for _, property in ipairs(propertys) do
		if property == "left" then
			local x = pos.x - self._deltX + self._safeAreaOffset_x
			node:setPositionX(x)
		elseif property == "right" then
			local x = self._deltX + pos.x - self._safeAreaOffset_x
			node:setPositionX(x)
		elseif property == "top" then
			local y = self._deltY + pos.y
			node:setPositionY(y)
		elseif property == "bottom" then
			local y = pos.y - self._deltY
			node:setPositionY(y)
		elseif property == "x-center-parent" then -- x方向在父容器中间
			local p = node:getPositionPercent()
			node:setPositionPercent(cc.p(0.5, p.y))
		elseif property == "y-center-parent" then -- y方向在父容器中间
			local p = node:getPositionPercent()
			node:setPositionPercent(cc.p(p.x, 0.5))
		elseif property == "width-scale" then -- 刘海屏幕
			if display.width > CC_DESIGN_RESOLUTION.width then -- 在x方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(display.width - (CC_DESIGN_RESOLUTION.width - contentSize.width), contentSize.height))
			end
		elseif property == "height-scale" then
			if display.height > CC_DESIGN_RESOLUTION.height then  -- 在y方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(contentSize.width, display.height - (CC_DESIGN_RESOLUTION.height - contentSize.height)))
			end
		elseif property == "x-percent" then
			if display.width >  CC_DESIGN_RESOLUTION.width then -- 在x方向超过设计比例
                local x = pos.x /  CC_DESIGN_RESOLUTION.width * (display.width - self._safeAreaOffset_x * 2) - self._deltX + self._safeAreaOffset_x
				node:setPositionX(x)
			end
		elseif property == "y-percent" then
			if display.height > CC_DESIGN_RESOLUTION.height then  -- 在y方向超过设计比例
				local y = pos.y / CC_DESIGN_RESOLUTION.height * display.height
				local p = node:getParent():convertToNodeSpace(cc.p(0, y - self._deltY))
				node:setPositionY(p.y)
			end
		elseif property == "background" then
			local contentSize = node:getContentSize()
			if contentSize.width / contentSize.height > display.width / display.height then
				node:setScale(display.height / contentSize.height)
			else
				node:setScale(display.width / contentSize.width)
			end
		else
			assert(false, "error adaptation trait: " .. property)
		end
	end
end

function Util:loadCSBNode(csbPath)
    local node = cc.CSLoader:createNode(csbPath)
    --让留黑边的一侧居中
    self._deltX = (display.width - CC_DESIGN_RESOLUTION.width) * 0.5
    self._deltY = (display.height - CC_DESIGN_RESOLUTION.height) * 0.5
    node:setPosition(self._deltX, self._deltY)

    self._safeAreaOffset_x = 0
    local director = cc.Director:getInstance()
    if director.getSafeAreaRect then
        local visibleRect = director:getOpenGLView():getVisibleRect()
        local safeAreaRect = director:getSafeAreaRect()
        if safeAreaRect.width < visibleRect.width then
            self._safeAreaOffset_x = (visibleRect.width - safeAreaRect.width) / 2
        end
    end
    
    loopallchild(node,handler(self,parseChildProperty))

    return node
end

--获取从游戏开始到现在总的帧数
function Util:getTotalFramesSinceStart()
   return cc.Director:getInstance():getTotalFrames()
end

function Util:scheduleOnce(callback, delay, optActionNode)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:runAction(sequence)
    return sequence
end

function Util:unscheduleOnce(action, optActionNode)
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:stopAction(action)
end

function Util:scheduleUpdate(callback, intervalSec)
    assert(callback)
    intervalSec = intervalSec or 0
    local scheduleId = nil
    scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
        --如果回调方法返回true,那么直接停止调度
        local isStop = callback()
        if isStop then
            if scheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
            end
        end
    end, intervalSec, false)
    return scheduleId
end

-- 通过 id 去解绑更新， id 为 scheduleUpdate 的返回值
function Util:unscheduleUpdate(scheduleId)
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
    end
    return nil
end

return Util