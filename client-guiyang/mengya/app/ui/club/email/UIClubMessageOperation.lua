--[[
    动态
]]
local UITableView = app.UITableView
local Util = app.Util
local UIClubMessageOperationItem = app.UIClubMessageOperationItem
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