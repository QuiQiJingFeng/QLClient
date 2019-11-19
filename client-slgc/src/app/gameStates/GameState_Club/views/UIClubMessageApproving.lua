--[[
    审批
]]
local Util = game.Util
local UITableView = game.UITableView
local UIClubMessageApprovingItem = import("items.UIClubMessageApprovingItem")
local UIClubMessageApproving = class("UIClubMessageApproving")

function UIClubMessageApproving:ctor(parent)
    self._txtNoMessageTip = Util:seekNodeByName(parent,"txtNoMessageTip","ccui.Text")

    local node = Util:seekNodeByName(parent,"scrollListMessage","ccui.ScrollView")
    self._scrollListMessage = UITableView.extend(node,UIClubMessageApprovingItem)
end

function UIClubMessageApproving:onShow()
    local datas = {
        {},{},{}
    }
    self._txtNoMessageTip:setVisible(#datas <= 0)
    self._scrollListMessage:updateDatas(datas)
end

function UIClubMessageApproving:dispose()

end

return UIClubMessageApproving