--[[0
    这是一个让文本框支持滑动的工具，本质上是通过嵌套 ListView 来达到滑动的效果
    
    Usage:
        1、提供一个固定宽高的 Text 控件（ Text的宽高就是滑动的宽高了 ）
        2、提供字体大小 （ 因为 cocos 在 iOS 与 Android 上的 Text 实现不同， 所以不能直接从给出的 text 获取字体大小 ）
    
        -- code:
        local ScrollText = require("ScrollText")
        local text = seekNodeByName(self, "Text", "ccui.Text")
        text = ScrollText.new(text, 24, true)
        text:setString("Hello World\n\n\n\n\n\ zzz")
]]
---@class ScrollText
local M = class("ScrollText")

-- 单独设置字体是因为在其他平台上有差异
function M:ctor(textView, fontSize, isRemoveOlderTextView)
    self._container = self:generateContainer(textView)
    self._innerText = self:generateInnerText(textView)
    self._innerText:setFontSize(fontSize)

    self._container:addChild(self._innerText)
    self:copyOlderTextViewProperty(textView, self._innerText)

    if isRemoveOlderTextView then
        self:removeOlderTextView(textView)
    end
end

function M:setString(str)
    self:onInnerTextSetString(str)
end

function M:setVisible(value)
    self._container:setVisible(value or false)
end

-- todo 加入改变字体大小和颜色的方法
function M:onInnerTextSetString(str)
    self._innerText:setString(str)
    self._container:requestDoLayout()
    self._container:doLayout()
end

function M:generateContainer(textView)
    local lv = ccui.ListView:create()
    textView:getParent():addChild(lv)
    lv:setAnchorPoint(cc.p(textView:getAnchorPoint()))
    lv:setPosition(cc.p(textView:getPosition()))
    lv:setContentSize(textView:getContentSize())
    lv:setScrollBarEnabled(false)
    lv:setClippingEnabled(true)
    lv:setTouchEnabled(true)
    lv:setBounceEnabled(true)
    return lv
end

function M:generateInnerText(textView)
    local innerText = ccui.Text:create()
    local size = textView:getContentSize()
    innerText:setTextAreaSize(cc.size(size.width, 0))
    return innerText
end

function M:copyOlderTextViewProperty(older, newer)
    newer:setTextColor(older:getTextColor())
    newer:setString(older:getString())
end

function M:removeOlderTextView(textView)
    textView:removeFromParent()
end

function M:getContainer()
    return self._container
end

function M:getInnerText()
    return self._innerText
end

return M