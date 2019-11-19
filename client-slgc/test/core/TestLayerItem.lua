local Util = game.Util
local UITableViewCell = game.UITableViewCell
local TestLayerItem = class("TestLayerItem",UITableViewCell)
local UIManager = game.UIManager

function TestLayerItem:init()
    self._txtName = ccui.Text:create()
    self:addChild(self._txtName)
    self._txtName:setAnchorPoint(cc.p(0,0))
    local size = self:getContentSize()
    self._txtName:setPosition(cc.p(0,0))
    self._txtName:setFontSize(30)
end

function TestLayerItem:updateData(data)
    self._txtName:setString(data.name)
end
 

return TestLayerItem