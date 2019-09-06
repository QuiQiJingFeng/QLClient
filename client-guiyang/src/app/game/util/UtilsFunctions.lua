local COLOR_CONFIG = {
    positive = {
        fntPath = "font/font_jsz2.fnt",
        color = cc.c4b(243, 99, 42, 255) -- red / orange
    },
    negative = {
        fntPath = "font/font_jsz1.fnt",
        color = cc.c4b(45, 161, 89, 255) -- green
    }
}
local M = {}

function M.setScoreWithColor(widget, score)
    if widget.setFntFile then
        M.setScoreWithColorForBMFont(widget, score)
    else
        M.setScoreWithColorForText(widget, score)
    end
end

function M.setScoreWithColorForBMFont(widget, score)
    local fntPath = nil
    local isPositive, scoreString = M.getScoreWithOperator(score)
    if isPositive then
        fntPath = COLOR_CONFIG['positive'].fntPath
    else
        fntPath = COLOR_CONFIG['negative'].fntPath
    end
    widget:setFntFile(fntPath)
    widget:setString(scoreString)
end

function M.setScoreWithColorForText(widget, score)
    -- M.assertDefaultColor(widget)
    local color = nil
    local isPositive, scoreString = M.getScoreWithOperator(score)
    if isPositive then
        color = COLOR_CONFIG['positive'].color
    else
        color = COLOR_CONFIG['negative'].color
    end
    widget:setColor(color)
    widget:setString(scoreString)
end

function M.setScore(widget, score)
    local isPositive, score = M.getScoreWithOperator(score)
    widget:setString(score)
end

function M.getScoreWithOperator(score)
    if tonumber(score) >= 0 then
        score = "+" .. score
        return true, score
    end
    return false, tostring(score)
end

--[[0
    #FFFFFF cc.c4b(255, 255, 255, 255)
]]
local __default_color__ = cc.c4b(255, 255, 255, 255)
function M.convert2CCColor(input, alphaValue)
    if not Macro.assertFalse(type(input) == 'string', 'input must be a string value') then
        return __default_color__
    end

    if not Macro.assertFalse(#input == 7, 'input string length must equals 7') then
        return __default_color__
    end

    local r = tonumber("0x" .. string.sub(input, 2, 3))
    local g = tonumber("0x" .. string.sub(input, 4, 5))
    local b = tonumber("0x" .. string.sub(input, 6, 7))
    local check = function(v)
        return v ~= nil and (v >= 0 and v <= 255)
    end

    if not Macro.assertFalse(check(r) and check(g) and check(b), 'illegal color') then
        return __default_color__
    end

    local ret = cc.c3b(r, g, b)
    if alphaValue then
        ret.a = alphaValue
    end
    return ret
end

function M.assertDefaultColor(widget)
    -- local color = widget:getColor()
    -- return Macro.assertFalse(color.r == 255 and color.g == 255 and color.b == 255, 'color must white')
end

function M.singleton(_class)
    if not Macro.assertFalse(_class and _class.__cname, '_class must is a class') then
        return
    end

    if _class.getInstance then
        Logger.info("class already have singleton function, class name is " .. tostring(_class.class.__cname))
        return
    end

    if not Macro.assertFalse(_class.__instance__ == nil, '_class.__instance__ not a nil value') then
        return
    end

    _class.getInstance = function()
        if _class.__instance__ == nil then
            _class.__instance__ = _class.new()
        end
        return _class.__instance__
    end

    return _class
end

---@return Button
function M.seekButton(root, nodeName, clickHandler, clickValue)
    local btn = seekNodeByName(root, nodeName, "ccui.Button")
    if btn then
        return M.bindClick(btn, clickHandler, clickValue)
    end
end

---@return Button
function M.bindClick(node, clickHandler, clickValue)
    bindEventCallBack(node, function(...)
        if clickValue then
            game.service.TDGameAnalyticsService.getInstance():onEvent(clickValue)
        end
        if clickHandler then
            clickHandler(...)
        end
    end, ccui.TouchEventType.ended)
    return node
end

---@param parent Node
---@param onClickIsHideOrClose boolean
function M.attachCloseButton(parent, onClickIsHideOrClose, btnName)
    return M.seekButton(parent, btnName or "Button_Close", function()
        if onClickIsHideOrClose then
            if parent.hideSelf then
                parent:hideSelf()
            else
                parent:setVisible(false)
            end
        else
            if parent.destroySelf then
                parent:destroySelf()
            else
                parent:removeFromParent()
            end
        end
    end)
end

---@param node Node
---@param onPressing function
---@param interval number 执行间隔(second) 如果为 nil 表示每帧执行
---内部是通过 Action 执行的，如果 node 有其他的 action 正在执行会被终止，如果外部清理了所有的 Action 那么这个方法也会被终止
function M.registerPressTouchEvent(node, onPressStart, onPressing, onPressEnd, interval)
    if node and onPressing then
        local action
        node:stopAllActions()
        node:addTouchEventListener(function(sender, eventStatus)
            if eventStatus == ccui.TouchEventType.began then
                if interval then
                    action = cc.RepeatForever:create(
                            cc.Sequence:create(
                                    cc.CallFunc:create(function()
                                        onPressing()
                                    end),
                                    cc.DelayTime:create(interval))
                    )
                else
                    action = cc.RepeatForever:create(
                            cc.Sequence:create(cc.CallFunc:create(function()
                                onPressing()
                            end))
                    )
                end
                sender:runAction(action)
                if onPressStart then
                    onPressStart()
                end
            elseif eventStatus == ccui.TouchEventType.ended or eventStatus == ccui.TouchEventType.canceled then
                if action then
                    sender:stopAction(action)
                    action = nil
                    if onPressEnd then
                        onPressEnd()
                    end
                end
            end
        end)
    end
end

function M.createListViewEmptyText(listView, textContent, fontSize, fontColor)
    if not Macro.assertFalse(listView, 'listView is a nil value') then
        return nil
    end

    if listView.emptyText then
        Logger.info('list view already have empty tip text')
        return listView.emptyText
    end

    fontSize = fontSize or 26
    fontColor = fontColor or cc.c4b(255, 255, 255, 255)
    textContent = textContent or '空空如也 ~'

    local text = ccui.Text:create()
    text:setAnchorPoint(cc.p(0.5, 0.5))
    text:setFontSize(fontSize)
    text:setColor(fontColor)
    text:setString(textContent)
    listView:getParent():addChild(text)

    -- show at listView center
    local lvAnchorPoint = listView:getAnchorPoint()
    local lvPosition = cc.p(listView:getPosition())
    local lvSize = listView:getContentSize()
    text:setPosition(cc.p(
            lvPosition.x + (0.5 - lvAnchorPoint.x) * lvSize.width,
            lvPosition.y + (0.5 - lvAnchorPoint.y) * lvSize.height))

    listView.emptyText = text
    return text
end

function M.destroyListViewEmptyText(listView)
    if listView == nil then
        return false
    end

    if listView.emptyText == nil or tolua.isnull(listView.emptyText) then
        listView.emptyText = nil
        return false
    end

    listView.emptyText:removeFromParent()
    listView.emptyText = nil
    return true
end

function M.createCounter(startValue, step, extData)
    local counter = {}
    counter.extData = extData
    counter.value = startValue or 0
    counter.step = step or 1
    counter.tick = function()
        counter.value = counter.value + step
        return counter.value
    end
    counter.reset = function()
        counter.value = startValue
        return counter.value
    end
    return counter
end

-- 通用的 toString 函数
function M.toString(obj)
    local _type = type(obj)
    if _type == "number" or _type == "string" or _type == "nil" then
        return tostring(obj)
    elseif _type == "userdata" or _type == "function" then
        return _type
    elseif _type == "table" then
        local fields = {}
        for key, value in pairs(obj) do
            if key ~= "class" then
                local _type = type(value)
                if _type == "function" then
                    -- pass
                elseif _type == "table" then
                    fields[key] = M.toString(value)
                else
                    fields[key] = value
                end
            else
                --pass class
            end
        end
        return json.encode(fields)
    end
end

-- 这里只是设置 reused list view 的数据
function M.resetListViewData(listView, data, isReverse)
    if listView and data then
        listView:deleteAllItems()
        if isReverse then
            for i = #data, 1, -1 do
                listView:pushBackItem(data[i])
            end
        else
            for _, item in ipairs(data) do
                listView:pushBackItem(item)
            end
        end
    end
    return listView
end

-- 异步加载网络图片，支持 Sprite 与 ImageView
function M.loadTextureAsync(image, imageSourceUrl, defaultSourcePath, onFinish)
    if image == nil or imageSourceUrl == "" or imageSourceUrl == nil then
        return
    end

    local func = image.loadTexture or image.setTexture
    if func == nil then
        return
    end

    if defaultSourcePath ~= nil and defaultSourcePath ~= "" then
        func(image, defaultSourcePath)
    end

    image.defaultSourcePath = defaultSourcePath
    image.imageSourceUrl = imageSourceUrl

    local loadHandler = function(isSuccess, fileType, fileName)
        local filePath
        local _imageSourceUrl = image.imageSourceUrl
        if not isSuccess or tolua.isnull(image) or _imageSourceUrl == nil or _imageSourceUrl ~= imageSourceUrl then
        else
            filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
            func(image, filePath)
        end
        if onFinish then
            onFinish(isSuccess, image, filePath)
        end
    end
    manager.RemoteFileManager.getInstance():getRemoteFile("AsyncNetworkImageSource", imageSourceUrl, loadHandler, false)
end

function M.sizeAdd(a, b)
    return cc.size(a.width + b.width, a.height + b.height)
end

function M.sizeSub(a, b)
    return cc.size(a.width - b.width, a.height - b.height)
end

function M.sizeMul(a, factor)
    return cc.size(a.width * factor, a.height * factor)
end

function M.onEvent(eventId)
    if eventId then
        game.service.TDGameAnalyticsService.getInstance():onEvent(eventId)
    end
end

function M.tip(str)
    if str then
        return game.ui.UIMessageTipsMgr.getInstance():showTips(str)
    end
end

function M.tipFormat(format, ...)
    return M.tip(string.format(format, ...))
end

return M