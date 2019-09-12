local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UITestItem = class("UITestItem",UITableViewCell)
local UIManager = app.UIManager

function UITestItem:init()
    self._panelPengGangBottom = Util:seekNodeByName(self,"panelPengGangBottom","ccui.Layout")
    self._panelHandleCardBottom = Util:seekNodeByName(self,"panelHandleCardBottom","ccui.Button")
    self._btnCard4 = Util:seekNodeByName(self,"btnCard4","ccui.Button")


end

function UITestItem:updateData(data)
    --[[init()
                {type = "peng"},
        {type = "gang"},
        {type = "handCard"},
        {type = "handCard"},
        {type = "handCard"},
    ]]

    self._panelPengGangBottom:setVisible(data.type == "peng" or data.type == "gang")
    self._panelHandleCardBottom:setVisible(data.type == "handCard")
    self._btnCard4:setVisible(data.type == "peng")
    if data.type == "peng" or data.type == "gang" then
        return self._panelPengGangBottom:getContentSize()
    else
        return self._panelHandleCardBottom:getContentSize()
    end
end
 

return UITestItem