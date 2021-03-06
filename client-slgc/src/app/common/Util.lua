local Util = {}

--为了避免解压之前无法调用这些方法,将这些方法放到Util里面
----------------------------BEGIN--------------------
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function cc.p(_x,_y)
    if nil == _y then
         return { x = _x.x, y = _x.y }
    else
         return { x = _x, y = _y }
    end
end
----------------------------END--------------------
-- 通过名字查找子控件
function Util:seekNodeByName(view, name, property)
    local node = ccui.Helper:seekNodeByName(view, name)
    if property then
        return tolua.cast(node, property)
    end
    return node
end

function Util:getChildByNames(node,...)
    local names = {...}
    assert(#names > 0 ,"names must be none nil")
    local result = node
    for i, name in ipairs(names) do
        result = result:getChildByName(name)
        assert(result,"node not exist")
    end
    return result
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
    self._timeDiff = serverTime - self:getTimeNow()
end

--utc时间 纳秒
function Util:getTimeNow()
    return require("socket").gettime()
end

--获取服务器时间纳秒
--当帧率不稳定的时候,Schedule的时间就会出现误差,
--所以对于需要绝对时间的情况下使用这个
function Util:getCurrentTime()
    return self:getTimeNow() + (self._timeDiff or 0)
end

function Util:getCurrentTimeSecond()
    return self:getCurrentTime() / 1000
end

--[[year、month、day、hour、min、sec、yday、wday、isdst]]
function Util:getDateInfo(time)
    time = time or self:getCurrentTimeSecond()
    return os.date("*t",time)
end

--返回今天是周几, 周1~周7 分别对应数字
function Util:getWeekDay()
    local time = self:getCurrentTimeSecond()
    local dateInfo = os.date("*t",time)
    local realyDay = dateInfo.wday
    if realyDay == 1 then
        realyDay = 7
    else
        realyDay = realyDay - 1
    end
    return realyDay
end

--服务器时间的时分秒
function Util:getFormatDate(format,time)
    format = format or "%Y-%m-%d %H:%M:%S"
    time = time or self:getCurrentTimeSecond()
    return os.date(format,time)
end

function Util:getDaySeconds()
    return 24 * 60 * 60
end


function Util:parseCsvWithPath(path)
    local content = cc.FileUtils:getInstance():getStringFromFile(path)

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

-----------------------------------------------------
--UI适配
-----------------------------------------------------
local function loopallchild(node, callback)
    local children = node:getChildren()
    for _, child in ipairs(children) do
        loopallchild(child, callback)
    end
    --先放到下面试试,深度遍历
    callback(node)
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
			if self._winSize.width > CC_DESIGN_RESOLUTION.width then -- 在x方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(self._winSize.width - (CC_DESIGN_RESOLUTION.width - contentSize.width), contentSize.height))
			end
		elseif property == "height-scale" then
			if self._winSize.height > CC_DESIGN_RESOLUTION.height then  -- 在y方向超过设计比例
				local contentSize = node:getContentSize()
				node:setContentSize(cc.size(contentSize.width, self._winSize.height - (CC_DESIGN_RESOLUTION.height - contentSize.height)))
			end
		elseif property == "x-percent" then
			if self._winSize.width >  CC_DESIGN_RESOLUTION.width then -- 在x方向超过设计比例
                local x = pos.x /  CC_DESIGN_RESOLUTION.width * (self._winSize.width - self._safeAreaOffset_x * 2) - self._deltX + self._safeAreaOffset_x
				node:setPositionX(x)
			end
		elseif property == "y-percent" then
			if self._winSize.height > CC_DESIGN_RESOLUTION.height then  -- 在y方向超过设计比例
				local y = pos.y / CC_DESIGN_RESOLUTION.height * self._winSize.height
				local p = node:getParent():convertToNodeSpace(cc.p(0, y - self._deltY))
				node:setPositionY(p.y)
			end
		elseif property == "background" then
			local contentSize = node:getContentSize()
			if contentSize.width / contentSize.height > self._winSize.width / self._winSize.height then
				node:setScale(self._winSize.height / contentSize.height)
			else
				node:setScale(self._winSize.width / contentSize.width)
            end
		end
	end
end

function Util:loadCSBNode(csbPath)
    release_print("load ",csbPath)
    local node = cc.CSLoader:createNode(csbPath)
    assert(node)
    self._winSize = cc.Director:getInstance():getWinSize()
    --让留黑边的一侧居中
    self._deltX = (self._winSize.width - CC_DESIGN_RESOLUTION.width) * 0.5
    self._deltY = (self._winSize.height - CC_DESIGN_RESOLUTION.height) * 0.5
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

---------------------------------------------------
--获取从游戏开始到现在总的帧数
---------------------------------------------------
function Util:getTotalFramesSinceStart()
   return cc.Director:getInstance():getTotalFrames()
end

---------------------------------------------------
--开启一次回调
---------------------------------------------------
function Util:scheduleOnce(callback, delay, optActionNode)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:runAction(sequence)
    return sequence
end

---------------------------------------------------
--取消回调
---------------------------------------------------
function Util:unscheduleOnce(action, optActionNode)
    local node = optActionNode or cc.Director:getInstance():getRunningScene();
    node:stopAction(action)
end

---------------------------------------------------
--开启持续的调度,如果回调方法返回true,会自动取消注册
---------------------------------------------------
function Util:scheduleUpdate(callback, intervalSec)
    assert(callback)
    intervalSec = intervalSec or 0
    local scheduleId = nil
    scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        --如果回调方法返回true,那么直接停止调度
        local isStop = callback(dt)
        if isStop then
            if scheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
            end
        end
    end, intervalSec, false)
    return scheduleId
end

---------------------------------------------------
--取消持续的调度,
--如果在上一个方法中没有在回调方法中处理取消就需要手动取消
---------------------------------------------------
function Util:unscheduleUpdate(scheduleId)
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
    end
    return nil
end

--将Node转换成Widget
function Util:convertNodeToWidget(child)
    local parent = child:getParent()
    local descript = child:getDescription()
    if string.find(descript,"Node") then
        local widget = ccui.Widget:create()
        widget:setName(child:getName())
        widget:setPosition(cc.p(child:getPosition()))
        widget:setScaleX(child:getScaleX())
        widget:setScaleY(child:getScaleY())
        local children = child:getChildren()
        for _, node in ipairs(children) do
            node:retain()
            node:removeSelf()
            widget:addChild(node)
            node:release()
        end
        child:removeSelf()
        parent:addChild(widget)
        return widget
    end
    return child
end

function Util:saveNodeToPng(node, callback, name, size)
	assert(type(node) ~= "userdata")
    -- clone 一下node，防止对之前的node产生影响
    local localNode = node
    local n_visible = localNode:isVisible()
    local n_pos = cc.p(localNode:getPositionX(), localNode:getPositionY())
    localNode:setVisible(true)

    -- 如果储存的图片未定义名字，则设置默认名
    name = name or "saveNodeToPng.png"

    -- 可写路径，截图会存在这里
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local filePath = writablePath .. name
    -- 删除之前的
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        cc.FileUtils:getInstance():removeFile(filePath)
    end

    if size == nil then
        size = node:getContentSize() -- 截图的图片大小
    end

    -- 创建renderTexture
    -- fix:https://blog.csdn.net/themagickeyjianan/article/details/78500467
    local render = cc.RenderTexture:create(size.width, size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    localNode:setPosition(cc.p(size.width / 2, size.height / 2))
    -- 绘制
    render:begin()
    localNode:visit()
    render:endToLua()
    -- 保存
    render:saveToFile(name, cc.IMAGE_FORMAT_PNG)
    localNode:setVisible(n_visible)
    localNode:setPosition(n_pos)

    -- 返回存好的文件，如果有callback则调用callback，否则返回文件路径
    if type(callback) == "function" then
        -- 执行schedule检查文件，保存好就调用callback，可能会出问题，比如回调里的东西被释放了
        local checkTimer = nil
        checkTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
            -- body
            if cc.FileUtils:getInstance():isFileExist(filePath) then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(checkTimer)
                callback(filePath)

            end
        end, 0.01, false)
    end
    return filePath
end

function Util:captureScreen(callBack)
	local cb = function(success, file)
        assert(success,file)
        callBack(file)
    end
    -- 分享截图
    cc.utils:captureScreen(cb, "ScreenShotWithLogo.jpg")
end

--[[
* 根据两点的经纬度，计算出其之间的距离（返回单位为m）
* @param lat1 纬度1
* @param lng1 经度1
* @param lat2 纬度2
* @param lng2 经度2
* @return
--]]
function Util:getDistance(lat1, lng1, lat2, lng2)
	local EARTH_RADIUS = 6378137 --地球半径 米
	local radLat1 = math.rad(lat1)
	local radLat2 = math.rad(lat2)
	local a = math.rad(lat1) - math.rad(lat2)
	local b = math.rad(lng1) - math.rad(lng2)
	local _s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2),2) + math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)))
	_s = _s * EARTH_RADIUS
	local _z,_y = math.modf(_s * 100)
	if _y > 0.5 then
		_s = _z + 1
	else
		_s = _z
	end
	_s = _s / 100.0
	return _s
end

-- lua base64简单处理
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
-- character table string
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function Util:base64(data)
	return((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, - 1 do r = r ..(b % 2 ^ i - b % 2 ^(i - 1) > 0 and '1' or '0') end
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if(#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do c = c +(x:sub(i, i) == '1' and 2 ^(6 - i) or 0) end
		return b:sub(c + 1, c + 1)
	end) ..({'', '==', '='}) [#data % 3 + 1])
end

-- decoding
function Util:unbase64(data)
	data = string.gsub(data, '[^' .. b .. '=]', '')
	return(data:gsub('.', function(x)
		if(x == '=') then return '' end
		local r, f = '',(b:find(x) - 1)
		for i = 6, 1, - 1 do r = r ..(f % 2 ^ i - f % 2 ^(i - 1) > 0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if(#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do c = c +(x:sub(i, i) == '1' and 2 ^(8 - i) or 0) end
		return string.char(c)
	end))
end

-- 字符串保存到table
function Util:stringToTable(s)
	local tb = {}
	
	--[[    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字)
    ]]
	for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(tb, utfChar)
	end
	
	return tb
end

-- 获取字符串长度,英文字符为一个单位长, 中文字符为2个单位长
function Util:getUTFLen(s)
	local sTable = self:stringToTable(s)
	local len = 0
	local charLen = 0
	
	for i = 1, #sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		
		len = len + charLen
	end
	
	return len
end

-- 获取指定个数字符串长度
function Util:getUTFLenWithCount(s, count)
	local sTable = self:stringToTable(s)
	local len = 0
	local charLen = 0
	local isLimited =(count >= 0)
	
	for i = 1, #sTable do
		local utfCharLen = string.len(sTable[i])
		if utfCharLen > 1 then -- 长度大于1的就认为是中文
			charLen = 2
		else
			charLen = 1
		end
		-- 当超过截取的字符时舍去这个字符
		if isLimited then
			count = count - charLen
			if count < 0 then
				break
			end
		end
		
		len = len + utfCharLen
	end
	
	return len
end

-- 获取指定长度字符串, 超过最大长度则截断
function Util:getMaxLenString(s, maxLen)
	local len = self:getUTFLen(s)
	local dstString = s
	if len > maxLen then
		dstString = string.sub(s, 1, self:getUTFLenWithCount(s, maxLen))
	end
	
	return dstString
end

--[[
判断线段和矩形框是否有交点
line = {cc.p, cc.p}
rect = cc.rect
返回 true 相交中点
    false
]]
function Util:isLineIntersectRect(line, rect)
    local lp1 = line[1]
    local lp2 = line[2]

    if lp1.x == lp2.x then
        -- 与Y轴平行(计算xy坐标大小)
        local lpx = lp1.x
        if lpx < rect.x or lpx > rect.x + rect.width then
            return false
        else
            local minly = min(lp1.y, lp2.y)
            local maxly = max(lp1.y, lp2.y)

            if minly > rect.y + rect.height or maxly < rect.y then
                return false
            else
                -- 相交
                local maxiy = min(maxly, rect.y + rect.height)
                local miniy = max(minly, rect.y)

                local iy = (maxiy + miniy) / 2

                return true, cc.p(lpx, iy)
            end
        end
    else
        if lp1.y == lp2.y then
            -- 与X轴平行(计算xy坐标大小)
            local lpy = lp1.y
            if lpy < rect.y or lpy > rect.y + rect.height then
                return false
            else
                local minlx = min(lp1.x, lp2.x)
                local maxlx = max(lp1.x, lp2.x)

                if minlx > rect.x + rect.width or maxlx < rect.x then
                    return false
                else
                    -- 相交
                    local maxix = min(maxlx, rect.x + rect.width)
                    local minix = max(minlx, rect.x)

                    local ix = (maxix + minix) / 2

                    return true, cc.p(ix, lpy)
                end
            end
        else
            -- 不与Y轴平行(计算直线交点是否在区域内)
            local interPointArray = {}

            -- 计算直线函数
            local lA = (lp1.y - lp2.y) / (lp1.x - lp2.x)
            local lB = lp1.y - lA * lp1.x

            -- 区域范围
            local minrx = rect.x
            local maxrx = rect.x + rect.width
            local minry = rect.y
            local maxry = rect.y + rect.height

            -- 线段范围
            local minlx = min(lp1.x, lp2.x)
            local maxlx = max(lp1.x, lp2.x)
            local minly = min(lp1.y, lp2.y)
            local maxly = max(lp1.y, lp2.y)

            -- 左交点
            local ix1 = rect.x
            if ix1 > minlx and ix1 < maxlx then
                local iy1 = lA * ix1 + lB
                if iy1 < maxry and iy1 > minry then
                    interPointArray[#interPointArray + 1] = cc.p(ix1, iy1)
                end
            end

            -- 右交点
            local ix2 = rect.x + rect.width
            if ix2 > minlx and ix2 < maxlx then
                local iy2 = lA * ix2 + lB
                if iy2 < maxry and iy2 > minry then
                    interPointArray[#interPointArray + 1] = cc.p(ix2, iy2)
                end
            end

            -- 下交点
            local iy3 = rect.y
            if iy3 > minly and iy3 < maxly then
                local ix3 = (iy3 - lB) / lA
                if ix3 < maxrx and ix3 > minrx then
                    interPointArray[#interPointArray + 1] = cc.p(ix3, iy3)
                end
            end

            -- 上交点
            local iy4 = rect.y + rect.height
            if iy4 > minly and iy4 < maxly then
                local ix4 = (iy4 - lB) / lA
                if ix4 < maxrx and ix4 > minrx then
                    interPointArray[#interPointArray + 1] = cc.p(ix4, iy4)
                end
            end

            if #interPointArray >= 1 then
                if #interPointArray == 2 then
                    -- 有交点
                    local ip1 = interPointArray[1]
                    local ip2 = interPointArray[2]

                    return true, cc.p((ip1.x + ip2.x) / 2, (ip1.y + ip2.y) / 2)
                elseif #interPointArray == 1 then
                    local ip1 = interPointArray[1]

                    return true, ip1
                end
            else
                return false
            end
        end
    end

    return false
end

-- 获取2个rect交汇矩形中点
function Util:rectCenterPoint(rect1, rect2)
    -- 计算被击中点
    local xTable = {}
    xTable[#xTable + 1] = rect1.x
    xTable[#xTable + 1] = rect1.x + rect1.width
    xTable[#xTable + 1] = rect2.x
    xTable[#xTable + 1] = rect2.x + rect2.width

    table.sort(xTable, function(x1, x2)
        return x1 > x2
    end)

    local yTable = {}
    yTable[#yTable + 1] = rect1.y
    yTable[#yTable + 1] = rect1.y + rect1.height
    yTable[#yTable + 1] = rect2.y
    yTable[#yTable + 1] = rect2.y + rect2.height

    table.sort(yTable, function(y1, y2)
        return y1 > y2
    end)

    return cc.p((xTable[2] + xTable[3]) / 2, (yTable[2] + yTable[3]) / 2)
end

--检测矩形和圆是否相交
function Util:rectIntersectsCircle(rect, circleCenter, circleRadius)
    local circleRect = cc.rect(circleCenter.x - circleRadius, circleCenter.y - circleRadius, circleRadius * 2, circleRadius * 2)
    if cc.rectIntersectsRect(rect, circleRect) then
        -- 矩形相关再具体运算
        local rectCenter = cc.p(rect.x  + rect.width / 2, rect.y + rect.height / 2)
        local p1, p2 = nil, nil

        if circleCenter.x == rectCenter.x then
            if circleCenter.y == rectCenter.y then
                return true
            end

            p1 = cc.p(circleCenter.x, rect.y)
            p2 = cc.p(circleCenter.x, rect.y + rect.height)
        elseif circleCenter.y == rectCenter.y then
            if circleCenter.x == rectCenter.x then
                return true
            end

            p1 = cc.p(rect.x, circleCenter.y)
            p2 = cc.p(rect.x + rect.width, circleCenter.y)
        else
            local a = (circleCenter.y - rectCenter.y) / (circleCenter.x - rectCenter.x)
            local b = rectCenter.y - a * rectCenter.x

            local tpArray = {}
            local tp1 = cc.p(rect.x, a * rect.x + b)
            if tp1.y > rect.y and tp1.y < rect.y + rect.height then
                tpArray[#tpArray + 1] = tp1
            end
            local tp2 = cc.p(rect.x + rect.width, a * (rect.x + rect.width) + b)
            if tp2.y > rect.y and tp2.y < rect.y + rect.height then
                tpArray[#tpArray + 1] = tp2
            end
            local tp3 = cc.p((rect.y - b) / a, rect.y)
            if tp3.x > rect.x and tp3.x < rect.x + rect.width then
                tpArray[#tpArray + 1] = tp3
            end
            local tp4 = cc.p(((rect.y + rect.height) - b) / a, rect.y + rect.height)
            if tp4.x > rect.x and tp4.x < rect.x + rect.width then
                tpArray[#tpArray + 1] = tp4
            end

            if #tpArray < 2 then
                return false
            end

            p1 = tpArray[1]
            p2 = tpArray[2]
        end

        local circleRadiusSQ = circleRadius * circleRadius
        local calRadiusSQ1 = (p1.x - circleCenter.x) * (p1.x - circleCenter.x) + (p1.y - circleCenter.y) * (p1.y - circleCenter.y)
        local calRadiusSQ2 = (p2.x - circleCenter.x) * (p2.x - circleCenter.x) + (p2.y - circleCenter.y) * (p2.y - circleCenter.y)
        
        if calRadiusSQ1 < circleRadiusSQ or calRadiusSQ2 < circleRadiusSQ then
            return true
        else
            return false
        end
    else
        return false
    end
end

--method GET/POST/PUT
function Util:sendXMLHTTPrequrest(method,headers, url, body, callBack)
    headers = headers or {}
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(method, url) -- 打开链接

    for key, value in pairs(headers) do
        xhr:setRequestHeader(key, value);
    end

    -- 状态改变时调用
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local receive = xhr.response
            callBack(receive)
            xhr:unregisterScriptHandler()    
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
            xhr:unregisterScriptHandler()
            callBack()
        end
    end
    local content
    if method == "POST" then
        local params = {}
        for key, value in pairs(body) do
            table.insert(params, key .. "=" .. value)
        end
        content = table.concat(params, "&")
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(content)
end

--生成二维码
function Util:generalQrcode(message,callBack)
    local layer = cc.LayerColor:create(cc.c3b(255,255,255))
    local size = {width=250,height=250}
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer,-1)

    local drawNode = cc.DrawNode:create()
    layer:addChild(drawNode)
    local ok, tab_or_message = qrencode.qrcode(message)
    if not ok then
        error("qrencode failed")
    else
        local unit = 5
        local start = cc.p(0,0)
        local len = #tab_or_message
        size.width = len*unit + unit
        size.height = len*unit + unit
        for x,row in ipairs(tab_or_message) do
            for y,value in ipairs(row) do
                if value > 0 then
                    local newX = start.x + x * unit
                    local newY = start.y + y * unit
                    drawNode:drawPoint(cc.p(newX,newY),unit,cc.c4f(0,0,0,1))
                end
            end
        end
    end

    layer:setContentSize(size)
    self:saveNodeToPng(layer,function(path) 
        layer:removeFromParent()
        if callBack then
            callBack(path)
        end
    end)
end

--A~Z 65-90 所以最高支持format为36进制
--10进制转换目标进制
function Util:binaryConversion(format,value)
    assert(format <= 36,"unsupport format too biger")
    local list = {}
    repeat
        local var = value%format
        if var > 9 then
            var = string.char(55+var)
        end
        table.insert(list,1,var)
        value = math.floor(value/format)
    until (value == 0)
    return table.concat(list,"")
end

--生成36进制的玩家ID
function Util:generalUserId(serverId,instanceId)
    local id = tonumber(serverId .. string.format("%07d",intId))
    return self:binaryConversion(36,id)
end

function Util:encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function Util:convertColor(s)
    local l = string.len(s)
    if l == 7 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16))
    elseif l == 9 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16)), tonumber(string.sub(s, 8, 9), 16)
    end
    assert(false, "invalid color foramt")
    return cc.WHITE
end

function Util:convertPosToTarget(node,targetNode,pos)
    local worldPos = node:convertToWorldSpace(pos)
    local targetPos = targetNode:convertToNodeSpace(worldPos)
    return targetPos
end

----------------------------------------------------
-- shader 相关
----------------------------------------------------
-- 模拟灯光效果
-- pos 灯光的位置,lightColor<type:cc.vec4> 灯光的颜色  lightRange 灯光的强度(照亮范围)
function Util:shaderLight(node,pos,lightColor,lightRange)
	local vertDefaultSource = [[
        attribute vec4 a_position;
        attribute vec2 a_texCoord;
        
        #ifdef GL_ES
        varying mediump vec2 v_texCoord;
        varying mediump vec2 v_position;//将顶点的位置传给ps，用于计算该顶点与灯的距离
        #else
        varying vec2 v_texCoord;
        varying vec2 v_position;
        #endif
        
        void main()
        {
            v_position = a_position.xy;
            gl_Position = CC_PMatrix * a_position;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
        varying lowp vec2 v_texCoord;
        varying mediump vec2 v_position;
        #else
        varying vec2 v_texCoord;
        varying vec2 v_position;
        #endif
        
        uniform vec2 u_lightPosition;
        uniform vec4 u_lightColor;
        uniform float u_lightRange;
        vec4 getRenderColor(vec2 texPos, vec2 lightPos, float lightRange)
        {
            vec2 pos = texPos - lightPos;
            float d = length(pos);//顶点与灯的距离
            float rgb;//相当于光强度
            if(d>30.0)//距离大于30，在lightRange范围内，灯光离灯心越远颜色越亮的遮罩效果，下面需要对颜色进行反转以实现灯光变亮
            rgb = (d-30)/(lightRange);
            else//距离小于30灯光最强，为白色
            rgb = 0.0;
            rgb = 1.0 - clamp(rgb, 0.0, 1.0);//clamp意义为 min(max(a, b), c);将a的大小限制在b,c之间， 1-rgb是将颜色反转
            return vec4(rgb, rgb, rgb, 1.0);
        }
        void main()
        {
            vec4 color = u_lightColor * getRenderColor(v_position, u_lightPosition, u_lightRange);//灯光颜色与灯光强度混合
            color = clamp(color, 0.0, 1.0);
            gl_FragColor = texture2D(CC_Texture0, v_texCoord) * color ;//纹理与灯光混合
        }
    ]]

    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    
    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformVec2("u_lightPosition",pos)
    programState:setUniformVec4("u_lightColor", lightColor or cc.vec4(1, 1, 1, 1.0))
    programState:setUniformFloat("u_lightRange",lightRange or 100)
    node:setGLProgramState(programState)
    
    function node:updateLightPos(pos)
        programState:setUniformVec2("u_lightPosition",pos)
    end
    function node:updateLightColor(lightColor)
        programState:setUniformVec4("u_lightColor", lightColor)
    end
    function node:updateLightRange()
        programState:setUniformFloat("u_lightRange",lightRange)
    end
end

-- 高斯模糊效果 采样周边X个相邻像素的颜色，与当前像素颜色按比例混合
-- blurRadius 模糊半径  sampleNum 采样个数
function Util:shaderBlur(node,blurRadius,sampleNum)
	local vertDefaultSource = [[
        attribute vec4 a_position;
        attribute vec2 a_texCoord;
        attribute vec4 a_color;

        #ifdef GL_ES
        varying lowp vec4 v_fragmentColor;
        varying mediump vec2 v_texCoord;
        #else
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        #endif

        void main()
        {
            gl_Position = CC_PMatrix * a_position;
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }

    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
        precision mediump float;
        #endif
        
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        
        uniform vec2 resolution;
        uniform float blurRadius;
        uniform float sampleNum;
        
        vec4 blur(vec2);
        
        void main(void)
        {
            vec4 col = blur(v_texCoord); //* v_fragmentColor.rgb;
            gl_FragColor = vec4(col) * v_fragmentColor;
        }
        
        vec4 blur(vec2 p)
        {
            if (blurRadius > 0.0 && sampleNum > 1.0)
            {
                vec4 col = vec4(0);
                vec2 unit = 1.0 / resolution.xy;
                
                float r = blurRadius;
                float sampleStep = r / sampleNum;
                
                float count = 0.0;
                
                for(float x = -r; x < r; x += sampleStep)
                {
                    for(float y = -r; y < r; y += sampleStep)
                    {
                        float weight = (r - abs(x)) * (r - abs(y));
                        col += texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y)) * weight;
                        count += weight;
                    }
                }
                
                return col / count;
            }
            
            return texture2D(CC_Texture0, p);
        }
        
    ]]

    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
      
        
    local programState  = cc.GLProgramState:create(pProgram)
    local size = node:getContentSize()
    programState:setUniformVec2("resolution",cc.vec3(size.width,size.height));
    programState:setUniformFloat("blurRadius",blurRadius or 10)
    programState:setUniformFloat("sampleNum",sampleNum or 10)


    node:setGLProgramState(programState)
end

--老照片效果
function Util:shaderOldPhoto(node)
    local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        void main(void)
        {
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            gl_FragColor.x = 0.393*c.r + 0.769*c.g + 0.189*c.b;
            gl_FragColor.y = 0.349*c.r + 0.686*c.g + 0.168*c.b;
            gl_FragColor.z = 0.272*c.r + 0.534*c.g + 0.131*c.b; 
            gl_FragColor.w = c.w;
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
	node:setGLProgram(pProgram)
end


function Util:shaderGray(node)
    local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        void main(void)
        {
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
            gl_FragColor.w = c.w;
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
	node:setGLProgram(pProgram)
end

-- 流光效果 lightWidth(0,1)
function Util:shaderFlash(node,lightColor,angle,lightWidth,durationTime,preDelayTime,lastDelayTime)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform vec4 _Color;
        uniform float _Angle;
        uniform float _Width;
        uniform float _FlashTime;
        uniform float _DelayTime;
        uniform float _LoopInterval;
        uniform vec4 _MainTex_ST;
        uniform float _Time;

        // @计算亮度
        // @param uv 角度 宽度(x方向) 运行时间 开始时间 循环间隔
        float flash(vec2 uv, float angle, float w, float runtime, float delay, float interval)
        {
            float brightness = 0;
            float radian = 0.0174444 * angle;
            float curtime = _Time; //当前时间
            float starttime = floor(curtime/interval) * interval; // 本次flash开始时间
            float passtime = curtime - starttime;//本次flash流逝时间
            if (passtime > delay)
            {
                float projx = uv.y / tan(radian); // y的x投影长度
                float br = (passtime - delay) / runtime; //底部右边界
                float bl = br - w; // 底部左边界
                float posr = br + projx; // 此点所在行右边界
                float posl = bl + projx; // 此点所在行左边界
                if (uv.x > posl && uv.x < posr)
                {
                    float mid = (posl + posr) * 0.5; // flash中心点
                    brightness = 1 - abs(uv.x - mid)/(w*0.5);
                }
            }
            return brightness;
        }

        void main()
        {
            vec4 col = texture2D(CC_Texture0, v_texCoord);
            float bright = flash(v_texCoord, _Angle, _Width, _FlashTime, _DelayTime, _LoopInterval);
            gl_FragColor.xyzw = col + _Color*bright * col.a;  // * step(0.5, col.a);
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformVec4("_Color", lightColor or cc.vec4(1,1,1,1))
    --角度
    programState:setUniformFloat("_Angle",angle or 75)
    --宽度(x方向)
    programState:setUniformFloat("_Width",lightWidth or 0.2)
    durationTime = durationTime or 1
    --运行时间
    programState:setUniformFloat("_FlashTime",durationTime)
    preDelayTime = preDelayTime or 0
    --延时时间
    programState:setUniformFloat("_DelayTime",preDelayTime)
    lastDelayTime = lastDelayTime or 0
    --循环间隔
    programState:setUniformFloat("_LoopInterval",durationTime + preDelayTime + lastDelayTime)

    --当前时间
    programState:setUniformFloat("_Time",0)
    local delt = 0
    node:scheduleUpdateWithPriorityLua(function(dt) 
        delt = delt + dt
        programState:setUniformFloat("_Time",delt)
    end,0)
 
    node:setGLProgramState(programState)
end

--马赛克效果
function Util:shaderMosaic(node,squareWidth,texSize)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform float _SquareWidth;
        uniform vec4 _TexSize;

        void main()
        {
            float pixelX = int(v_texCoord.x * _TexSize.x / _SquareWidth) * _SquareWidth;
            float pixelY = int(v_texCoord.y * _TexSize.y / _SquareWidth) * _SquareWidth;
            vec2 uv = vec2(pixelX / _TexSize.x, pixelY / _TexSize.y);
            vec4 col = texture2D(CC_Texture0, uv);
            gl_FragColor = col;
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformFloat("_SquareWidth", squareWidth or 8)
    programState:setUniformVec4("_TexSize", texSize or cc.vec4(256,256,0,0))
     

    node:setGLProgramState(programState)
end

--内发光
function Util:shaderInnerGlow(node,color,factor,sampleRange,interval,texSize)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform vec4 _Color;
        uniform float _Factor;
        uniform int _SampleRange;
        uniform vec2 _TexSize;
        uniform vec2 _SampleInterval;

        void main()
        {   
            int range = _SampleRange;
            float radiusX = _SampleInterval.x / _TexSize.x;
            float radiusY = _SampleInterval.y / _TexSize.y;
            float inner = 0;
            float outter = 0;
            int count = 0;
            for (int k = -range; k <= range; ++k)
            {
                for (int j = -range; j <= range; ++j)
                {
                    vec4 m = texture2D(CC_Texture0, vec2(v_texCoord.x + k*radiusX , v_texCoord.y + j*radiusY));
                    outter += 1 - m.a;
                    inner += m.a;
                    count += 1;
                }
            }
            inner /= count;
            outter /= count;
            
            vec4 col = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
            float out_alpha = max(col.a, inner);
            float in_alpha = min(out_alpha, outter);
            col.rgb = col.rgb + in_alpha * _Factor * _Color.a * _Color.rgb;
            gl_FragColor = col;
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformVec4("_Color", color or cc.vec4(1,0,1,1))
    programState:setUniformFloat("_Factor",factor or 1)
    programState:setUniformInt("_SampleRange",sampleRange or 7)
    programState:setUniformVec2("_SampleInterval",interval or cc.p(1,1))
    programState:setUniformVec2("_TexSize",texSize or cc.p(256,256))

    function node:updateColor(color)
        programState:setUniformVec4("_Color", color)
    end
    function node:updateFactor(factor)
        programState:setUniformFloat("_Factor",factor)
    end
    function node:updateSampleRange(sampleRange)
        programState:setUniformFloat("_SampleRange",sampleRange)
    end

    node:setGLProgramState(programState)
end

--圆角效果
local function shaderRound(node,corner)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform float _corner;
        float fmod(float a,float b)
        {
            return (a / b) - floor(a / b);
        }

        float step(float a,float x)
        {
            if (x < a)
            {
                return 0;
            }else{
                return 1;
            }
        }

        float length(float x,float y)
        {
            return sqrt(x*x + y*y);
        }

        void main()
        {   
            vec4 col = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
            
            // 坐标系左移一半,求的UV坐标系上的点
            vec2 uv = v_texCoord.xy - vec2(0.5,0.5);
            float centerDist = 0.5 - _corner;
            vec2 reduce = abs(uv) - vec2(centerDist,centerDist);
            float rx = reduce.x;
            float ry = reduce.y;
            float mx = step(centerDist, abs(uv.x));
            float my = step(centerDist, abs(uv.y));
            float alpha = 1 - mx*my* step(_corner, length(vec2(rx,ry)));
            
            col.a *= alpha;
            
            gl_FragColor = col;
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformFloat("_corner",corner or 0.1)

    node:setGLProgramState(programState)
end

--调整饱和度
function Util:shaderSaturation(node,satIncrement)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform float _SatIncrement;
        
        float lerp(float a, float b, float w) {
            return a + w*(b-a);
        }
        void main()
        {  
            vec4 col = texture2D(CC_Texture0, v_texCoord);
            float rgbmax = max(col.r, max(col.g, col.b));
            float rgbmin = min(col.r, min(col.g, col.b));
            float delta = rgbmax - rgbmin;
            if (delta == 0)
            {
                gl_FragColor = col;
            }
            else{
                float value = (rgbmax + rgbmin);
                float light = value / 2;
                float cmp = step(light, 0.5);
                float sat = lerp(delta/(2-value), delta/value, cmp);
                if (_SatIncrement >= 0)
                {
                    cmp = step(1, _SatIncrement + sat);
                    float a = lerp(1-_SatIncrement, sat, cmp);
                    a = 1/a - 1;
                    col.r = col.r + (col.r - light) * a;
                    col.g = col.g + (col.g - light) * a;
                    col.b = col.b + (col.b - light) * a;
                }
                else
                {
                    float a = _SatIncrement;
                    col.r = light + (col.r - light) * (1+a);
                    col.g = light + (col.g - light) * (1+a);
                    col.b = light + (col.b - light) * (1+a);
                }
                gl_FragColor = col;
            } 
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformFloat("_SatIncrement",satIncrement or 0)

    function node:updateSatIncrement(satIncrement)
        programState:setUniformFloat("_SatIncrement",satIncrement)
    end
 
    node:setGLProgramState(programState)
end

--按照HSV调整颜色 H(-1,1) 色度 S(-1,1)  饱和度 V(-1,1) 亮度
function Util:shaderHSV(node,hsv)
	local vertDefaultSource = [[
        attribute vec4 a_position; 
        attribute vec2 a_texCoord; 
        attribute vec4 a_color;                                                     
        #ifdef GL_ES  
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else                      
            varying vec4 v_fragmentColor; 
            varying vec2 v_texCoord;  
        #endif    
        void main() 
        {
            gl_Position = CC_PMatrix * a_position; 
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
     
    local pszFragSource = [[
        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        uniform vec3 _HSV;

        float lerp(float a, float b, float w) {
            return a + w*(b-a);
        }

        vec4 lerp(vec4 a, vec4 b, float w) {
            return a + w*(b-a);
        }

        vec3 lerp(vec3 a, vec3 b, float w) {
            return a + w*(b-a);
        }

        vec3 frac(vec3 a)
        {
            return a - floor(a);
        }

        vec3 rgb2hsv(vec3 c) {
            vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            vec4 p = lerp(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g)); 
            vec4 q = lerp(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r)); 
            float d = q.x - min(q.w, q.y);
            float e = 1.0e-10;
            return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x); 
        }
        vec3 hsv2rgb(vec3 c) {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); 
        }
        
        void main()
        {  
            vec4 col = texture2D(CC_Texture0, v_texCoord);
            vec3 c_hsv = rgb2hsv(col.rgb); // Convert to HSV
            c_hsv += _HSV;
            vec3 c_rgb = hsv2rgb(c_hsv); // Red in RGB
            gl_FragColor = vec4(c_rgb, 1);
        }
    ]]

	local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()

    local programState  = cc.GLProgramState:create(pProgram)
    programState:setUniformVec3("_HSV",hsv or cc.vec3(1,1,1))
 
    node:setGLProgramState(programState)
end

--置灰image,sprite
function Util:shaderImage(imageNode)
    self:shaderGray(imageNode)
end

--取消置灰image,sprite
function Util:shaderImage(imageNode)
    self:removeNodeShader(imageNode)
end

--置灰button
function Util:shaderButton(buttonNode)
    self:shaderGray(buttonNode:getRendererNormal())
end

--取消置灰button
function Util:removeShaderButton(buttonNode)
    self:removeNodeShader(buttonNode:getRendererNormal())
end

function Util:removeNodeShader(node)
    local vertDefaultSource = [[
    attribute vec4 a_position; 
    attribute vec2 a_texCoord; 
    attribute vec4 a_color;                                                     
    #ifdef GL_ES  
        varying lowp vec4 v_fragmentColor;
        varying mediump vec2 v_texCoord;
    #else                      
        varying vec4 v_fragmentColor; 
        varying vec2 v_texCoord;  
    #endif    
    void main() 
    {
        gl_Position = CC_PMatrix * a_position; 
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
    ]]
    local pszFragSource = [[
    #ifdef GL_ES 
        precision mediump float; 
    #endif 
    varying vec4 v_fragmentColor; 
    varying vec2 v_texCoord; 
    void main(void) 
    { 
        gl_FragColor = texture2D(CC_Texture0, v_texCoord); 
    }
    ]]
    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
	node:setGLProgram(pProgram)
end

return Util