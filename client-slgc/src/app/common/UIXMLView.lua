local LuaXML = require("app.common.LuaXML")
local UIXMLView = class("UIXMLView")

function UIXMLView.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIXMLView)
    self:init()
    return self
end

function UIXMLView:init()
    self._container = self:getInnerContainer()
    self._contentSize = self:getContentSize()
    self:setScrollBarEnabled(false)
end

function UIXMLView:newLine()
    self._currentPos.y = self._currentPos.y - self._nodeSize.height - self._deltUnit
    self._currentPos.x = 0
end

function UIXMLView:parse(name,value,propertyMap)

    local contentSize = self._contentSize
    local node
    if name == "Text" then
        node = game.UIXMLText.new(self,propertyMap,value)
    elseif name == "Image" then
        node = game.UIXMLImageView.new(propertyMap)
    elseif name == "Cards" then
        node = game.UIXMLCard.new(propertyMap)
    else
        if name == "Line" then
            self._currentPos.y = self._currentPos.y - tonumber(propertyMap.height)
            self._currentPos.x = 0
        end
        return
    end
    self._nodeSize = node:getContentSize()
    node:setAnchorPoint(cc.p(0,1))
    local size = self._nodeSize
    -- assert(size.width <= contentSize.width)

    if propertyMap.wholeLine then
        if self._currentPos.x > 0 then
            self:newLine()
        end
        node:setPosition(cc.p(self._currentPos))
        self:newLine()
    else
        if self._currentPos.x + size.width <= contentSize.width then
            node:setPosition(cc.p(self._currentPos))
            self._currentPos.x = self._currentPos.x + size.width
        else
            --如果不是文本,则换一行显示
            if name ~= "Text" then
                self:newLine()
                node:setPosition(cc.p(self._currentPos))
                self._currentPos.x = self._currentPos.x + size.width
            else
                --如果是文本则拆成两个文本显示
                --超出的距离
                local reduceWidth = contentSize.width - self._currentPos.x
                local length = game.Util:getUTFLen(value)
                local reduceLength = length / size.width * reduceWidth
                local reduceText =  game.Util:getMaxLenString(value,math.floor(reduceLength))
                node:setString(reduceText)
                node:setPosition(self._currentPos)
                self._layout:addChild(node)
                self:newLine()
                local otherText = string.gsub(value,reduceText,"",1)
                self:parse(name,otherText,propertyMap)
                return
            end
        end
    end
    self._layout:addChild(node)
end

function UIXMLView:setContent(content,deltUnit)
    self:removeAllChildren()
    self._deltUnit = deltUnit or 0
    local contentSize = self:getContentSize()
    self._layout = ccui.Layout:create()
    self._layout:setContentSize(contentSize)
    self:addChild(self._layout)

    self._currentPos = cc.p(0,contentSize.height)
    local doc = LuaXML:getInstance():loadXML(content)
    local children = doc:children()
    for idx, elem in ipairs(children) do
        local name = elem:name()
        local value = elem:value()
        local properties = elem:properties()
        local propertyMap = {}
        for _, property in ipairs(properties) do
            propertyMap[property.name] = elem["@"..property.name]
        end
        self:parse(name,value,propertyMap)
    end
    local height = self._currentPos.y > 0 and contentSize.height or math.abs(self._currentPos.y) + contentSize.height
    height = height + self._deltUnit
    local innerSize = cc.size(contentSize.width,height)
    self:setInnerContainerSize(innerSize)
    local posY = self._currentPos.y > 0 and 0 or math.abs(self._currentPos.y)
    self._layout:setPosition(cc.p(0,posY + self._deltUnit))
end

--[[
example:
<test one="two">
    <three four="five" four="six"/>
    <three>eight</three>
    <nine ten="eleven">twelve</nine>
</test>

Using the simple method:

xml.test["@one"] == "two"
xml.test.nine["@ten"] == "eleven"
xml.test.nine:value() == "twelve"
xml.test.three[1]["@four"][1] == "five"
xml.test.three[1]["@four"][2] == "six"
xml.test.three[2]:value() == "eight"
or if your XML is a little bit more complicated you can do it like this:

xml:children()[1]:name() == "test"
xml:children()[1]:children()[2]:value() == "eight"
xml:properties()[1] == {name = "one", value = "two"}
]]
return UIXMLView