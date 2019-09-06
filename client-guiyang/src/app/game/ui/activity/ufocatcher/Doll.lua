local CATCH_DEBUG = false
local CSBPathMap = {
    [1] = "csb/Activity/UFOCatcher/Dolls/Doll_1.csb",
    [2] = "csb/Activity/UFOCatcher/Dolls/Doll_2.csb",
    [3] = "csb/Activity/UFOCatcher/Dolls/Doll_3.csb",
}

---@class Doll:Node
local Doll = class("Doll", function()
    return cc.Node:create()
end)

function Doll:ctor(level)
    self.level = level
    self.node = cc.CSLoader:createNode(CSBPathMap[level])
    self:init()
end

function Doll:init()
    self.text = seekNodeByName(self.node, "Text")
    self.percentPoint = seekNodeByName(self.node, "Image")
    self.text:setString(level)
    self:addChild(self.node)

    local dollImg = seekNodeByName(self, "Image_5")
    local debugPanel = seekNodeByName(self, "Panel_1")
    self._size = dollImg:getContentSize()
    -- 这里直接改了宽度
    self._size.width = 140
    debugPanel:setContentSize(self._size)
    debugPanel:setVisible(CATCH_DEBUG)
end

---@return Doll
function Doll:clone()
    local ret = Doll.new(self.level)
    ret:setPosition(self:getPosition())
    return ret
end

---@return {width:number, height:number}
function Doll:getSize()
    return self._size
end

function Doll:changeLevel(level)
    if level == self.level then
        return
    end
    self.level = level
    self.node:removeFromParent()
    self.node = cc.CSLoader:createNode(CSBPathMap[level])
    self:init()
end

return Doll