local UIXMLText = class("UIXMLText",function() 
    return ccui.Text:create()
end)

local TEXT_ALIGN = {
    ["center"] = 1,
    ["left"] = 0,
    ["right"] = 2
}

local function convertColor(s)
    local l = string.len(s)
    if l == 7 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16))
    elseif l == 9 then
        return cc.c3b(tonumber(string.sub(s, 2, 3), 16), tonumber(string.sub(s, 4, 5), 16), tonumber(string.sub(s, 6, 7), 16)), tonumber(string.sub(s, 8, 9), 16)
    end
    assert(false, "invalid color foramt")
    return cc.WHITE
end
--[[
    
    左对齐,文本占一整行
    <Text color="#D4714D" size=30 align="left" wholeLine=true>说明说明</Text>
    居中对齐,文本占一整行
    <Text color="#D4714D" size=30 align="center" wholeLine=true>说明说明</Text>
    左对齐
    <Text color="#D4714D" size=30 align="left">说明说明</Text>
]]
function UIXMLText:ctor(delegate,propertyMap,value)
    local contentSize = delegate:getContentSize()
    if propertyMap.size then
        self:setFontSize(propertyMap.size)
    end
    if propertyMap.color then
        self:setTextColor(convertColor(propertyMap.color))
    end

    --对齐方式
    if propertyMap.align then
        self:setTextHorizontalAlignment(TEXT_ALIGN[propertyMap.align])
    end

    --是否占据整行,并且自适应高度
    if propertyMap.wholeLine then
        self:getVirtualRenderer():setDimensions(contentSize.width,0)
        self:setString(value)
        local renderSize = self:getVirtualRendererSize()
        self:setContentSize(renderSize)
    else
        self:setString(value)
        local renderSize = self:getVirtualRendererSize()
        self:setContentSize(renderSize)
    end
end

return UIXMLText