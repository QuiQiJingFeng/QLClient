--[[
    font tags:
    <#FF0000> or <#FF000080>    font color(rgb) and font opacity(rgba)
    <32>                        font size
    <italic> or <no-italic>
    <bold> or <no-bold>
    <underline> or <no-underline>
    <strike> or <no-strike>
    <outline> or <no-outline>
    <shadow> or <no-shadow>
    <glow> or <no-glow>
    <font font/stheiti.ttf>     font file, specify font file must start with <font> tag 
    <font>                      reset font to default

    all the font tags can combine with <font> tag, such as <font font/stheiti.ttf #FF0000 32 underline bold>   
    
    image tags:
    <img filename>:             image file or frame name
    <img 32*32 filename>:       image specify width and height
    <img 32*32 http(s)://xxx>:  image download from internet, must combine with width and height
    
    custom node tag:
    <xxxx> or <xxx yyy>:        any tag can not match the above, will be treat as a custom node, and trigger your callback

    special characters:         &lt; &gt; \n
--]]

local UIRichTextEx = class("UIRichTextEx", function()
    return ccui.RichText:create()
end)

function UIRichTextEx.extend(self, params)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIRichTextEx)
	self:ctor(params)
    return self
end


local string = string
local table = table

local function _parse_color(s)
    local l = string.len(s)
    if l == 7 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16))
    elseif l == 9 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16)), tonumber(string.sub(s, 8, 9), 16)
    end
    assert(false, "invalid color foramt")
    return cc.WHITE
end


ccui.RichText.FontStyle = {
    italic = 1,
    bold = 2,
    underline = 4,
    strike = 8,
    url = 16,
    outline = 32,
    shadow = 64,
    glow = 128
}
function UIRichTextEx:ctor(params)
    self._defaultFont = {
        color = cc.WHITE,
        opacity = 255,
        font = "Arial",
        size = 32,
        style = 0
    }
    self._outlineColor = cc.WHITE
    self._outlineSize = 2
    self._shadowColor = cc.BLACK
    self._shadowOffset = cc.size(2, -2)
    self._shadowBlurRadius = 0
    self._glowColor = cc.WHITE

    self:setDefaultFont(params)    
    self._font = clone(self._defaultFont)
    self._elementCount = 0
    self._textString = nil
    self._verticalAlignType = nil
    self._alignData = nil
end

function UIRichTextEx:setDefaultFont(params)
    local df = self._defaultFont
    if params["color"] then
        local color, opacity = _parse_color(params["color"])
        df.color = color
        df.opacity = opacity or df.opacity
    end
    if params["font"] then
        df.font = params["font"]    
    end
    if params["size"] then
        df.size = params["size"]
    end 
    if params["style"] then
        df.size = params["style"]
    end
    if params["outlineColor"] then
        self._outlineColor = _parse_color(params["outlineColor"])
    end
    if params["outlineSize"] then
        self._outlineSize = params["outlineSize"]
    end
    if params["shadowColor"] then
        self._shadowColor =  _parse_color(params["shadowColor"])
    end
    if params["shadowOffset"] then
        self._shadowOffset =  cc.size(unpack(params["shadowOffset"]))
    end
    if params["shadowBlur"] then
        self._shadowBlurRadius = params["shadowBlur"]
    end
    if params["glowColor"] then
        self._glowColor =  _parse_color(params["glowColor"])
    end
end

local _richtext_font_styles = {
    ["italic"] = { "italic", true },
    ["no-italic"] = { "italic", false },
    ["bold"] = { "bold", true },
    ["no-bold"] = { "bold", false },
    ["underline"] = { "underline", true },
    ["no-underline"] = { "underline", false },
    ["strike"] = { "strike", true },
    ["no-strike"] = { "strike", false },
    ["outline"] = { "outline", true },
    ["no-outline"] = { "outline", false },
    ["shadow"] = { "shadow", true },
    ["no-shadow"] = { "shadow", false },
    ["glow"] = { "glow", true },
    ["no-glow"] = { "glow", false }
}

function UIRichTextEx:_handleFontTag(t)
    if string.byte(t, 1) == 35 then -- start with '#'
        local color, opacity = _parse_color(t)
        self._font.color = color
        self._font.opacity = opacity or self._font.opacity
        return true
    end

    local size = tonumber(t)
    if size then
        self._font.size = size
        return true
    end
    
    local handler = _richtext_font_styles[t]
    if not handler then return false end
    if handler[2] then -- enabled
        self._font.style = bit.bor(self._font.style, ccui.RichText.FontStyle[handler[1]])
    else -- disabled
        self._font.style = bit.band(self._font.style, bit.bnot(ccui.RichText.FontStyle[handler[1]]))
    end
    return true
end

function UIRichTextEx:clear()
	for _ = 1, self._elementCount do
		self:removeElement(0)
	end
	self._elementCount = 0	
end

function UIRichTextEx:pushElement(element)	
	self:pushBackElement(element)
	self._elementCount = self._elementCount + 1	
end

function UIRichTextEx:setText(text, callback)
    self._textString = text
	self:clear()

    local prev, idx = 1, 1
    local l = string.len(text)
    while true do
        local sidx, eidx, tag = string.find(text, "<(.-)>", idx)
        if not sidx then -- not found
            self:_pushTextElement(string.sub(text, prev))
            break
        end
        
        -- advance
        self:_pushTextElement(string.sub(text, prev, sidx - 1))
        idx = eidx
        prev = eidx + 1

        -- handle tag
        local tags = string.split(tag, " ")
        if #tags >= 1 and #(tags[1]) > 0 then
            local t = tags[1]         
            if t == "font" then -- font node
                if #tags > 1 then
                    for i = 2, #tags do
                        if not self:_handleFontTag(tags[i]) then
                            self._font.font = tags[i]
                        end
                    end
                else
                    -- reset to default
                    for k, v in pairs(self._defaultFont) do
                        self._font[k] = v
                    end
                end
            elseif t == "img" then -- image node
                local width, height, src
                for i = 2, #tags do
                    local _, _, w, h = string.find(tags[i], "(%d+)*(%d+)")
                    if w and h then
                        width, height = w, h
                    else
                        src = tags[i]
                    end
                end
                self:_pushImageElement(src, width, height)
            elseif not self:_handleFontTag(t) then
                -- custom node
                if callback then
                    self._pushCustomElement(callback(unpack(tags)))
                end
            end
        end
        
        idx = idx + 1
    end
    self:_onSetText()
end

function UIRichTextEx:_pushTextElement(str)
    if str and string.len(str) > 0 then
        str = string.gsub(str, "&gt;", ">")
        str = string.gsub(str, "&lt;", "<")
        local font = self._font
        local arr = string.split(str, "\n")
        for n, text in ipairs(arr) do
            if n > 1 then
                self:pushElement(ccui.RichElementNewLine:create(0, cc.c3b(255,255,255), 255))
            end
            local element = ccui.RichElementText:create(0, font.color, font.opacity, text, font.font, font.size, font.style, "",
                self._outlineColor, self._outlineSize, 
                self._shadowColor, self._shadowOffset, self._shadowBlurRadius,
                self._glowColor)
            self:pushElement(element)
        end
        if string.byte(str, -1) == 10 then
            self:pushElement(ccui.RichElementNewLine:create(0, cc.c3b(255,255,255), 255))            
        end
    end
end

function UIRichTextEx:_pushCustomElement(node)
    if node then
        local element = ccui.RichElementCustomNode:create(0, cc.c3b(255,255,255), 255, node)
		self:pushElement(element)
    end
end

function UIRichTextEx:_pushImageElement(src, width, height)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(src)
    if frame then
        local spr = cc.Sprite:createWithSpriteFrame(frame)
        self:_pushCustomElement(spr)
    else
        local spr = cc.Sprite:create(src)
        if width and height then spr:setContentSize(cc.size(width, height)) end
        self:_pushCustomElement(spr)
    end
end

-- 通过普通的 Text 创建一个 RichText ， 会拷贝 Text 的部分属性
function UIRichTextEx.createByText(text, params)
    local richText = UIRichTextEx:create(params)
    text:getParent():addChild(richText)
    richText:setAnchorPoint(text:getAnchorPoint())
    richText:setPosition(text:getPosition())
    richText:ignoreContentAdaptWithSize(text:isIgnoreContentAdaptWithSize())
    richText:setContentSize(text:getContentSize())
    text:removeFromParent()
    return richText
end

-- 设置垂直居中的方式， 需要控件 isIgnoreContentAdaptWithSize = false， 并且需要控件预设的可容纳宽高个数
-- 可设置的有 center top
function UIRichTextEx:setVerticalAlignType(type, params)
    if self:isIgnoreContentAdaptWithSize() then
        Logger.error("UIRichTextEx setVerticalAlignType failed, plz take ignoreContentAdaptWithSize false first!")
        return
    end
    self._verticalAlignType = type
    self._alignData = params or {}
end

function UIRichTextEx:_onSetText()
    if self._verticalAlignType then
        local type = self._verticalAlignType
        local params = self._alignData or {}
        local maxCountInRow = params.row
        local maxCountInCol = params.col
        local yOffset = params.offsetY
    
        local charCount = self:getCharCount()
        if charCount == 0 then
            return
        end
    
        local size = self:getContentSize()
        local anchorPoint = self:getAnchorPoint()
        local y
        if type == 'center' then
            local realColCount = math.max(math.ceil(charCount / maxCountInRow), 1)
            local diff = maxCountInCol - realColCount
            local colHeight = size.height / maxCountInCol
            if diff >= 0 then
                y = (size.height + yOffset) * anchorPoint.x - colHeight * diff * 0.5
            else
                y = (size.height + yOffset) * anchorPoint.x
            end
        elseif type == 'top' then
            y = (size.height + yOffset) * anchorPoint.x
        else
            Macro.assertFalse(false, 'unknown type' .. tostring(type))
        end
        if y then
            self:setPositionY(y)
        end
    end
end

-- 通过传入的原始字符串 分析出 含有 color 与 str 的特性，只测试过多颜色的，其他特效加入后果位置
function UIRichTextEx:getTextElement()
    local rawText = self._textString or ''
    local search_idx = 1
    local idx = 1
    local textElemTable = {}
    while true do
        local l_idx, r_idx, str = string.find(rawText, "<font>", search_idx)
        if not r_idx then
            break
        end

        local elem = string.sub(rawText, idx, r_idx)
        -- print(l_idx, r_idx, elem)
        search_idx = r_idx
        idx = r_idx + 1

        table.insert(textElemTable, {
            color = string.sub(elem, 1, 9),
            str = string.sub(elem, 10, string.len(elem) - 6)
        })
    end
    return textElemTable
end

-- 获得文字长度 utf8 长度
function UIRichTextEx:getCharCount()
    local charCount = 0
    local elem = self:getTextElement()
    for _, item in ipairs(elem) do
        charCount = charCount + string.utf8len(item.str)
    end
    return charCount
end

return UIRichTextEx