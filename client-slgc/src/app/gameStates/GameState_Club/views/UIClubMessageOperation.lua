--[[
    动态
]]
local UITableView = game.UITableView
local Util = game.Util
local UIClubMessageOperationItem = import("items.UIClubMessageOperationItem")
local UIClubMessageOperation = class("UIClubMessageOperation")

function UIClubMessageOperation:ctor(parent)
    self._txtNoMessageTip = Util:seekNodeByName(parent,"txtNoMessageTip","ccui.Text")
    local node = Util:seekNodeByName(parent,"scrollListMessage","ccui.ScrollView")
    self._scrollListMessage = UITableView.extend(node,UIClubMessageOperationItem)

    --register EVENT
end

function UIClubMessageOperation:onShow()
    --发送请求
    local datas = { {},{},{} }
    self._txtNoMessageTip:setVisible(#datas <= 0)
    self._scrollListMessage:updateDatas(datas)
end

function UIClubMessageOperation:dispose()
    --unregister EVENT
end

return UIClubMessageOperation