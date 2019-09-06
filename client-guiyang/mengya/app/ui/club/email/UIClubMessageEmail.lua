local UITableView = app.UITableView
local Util = app.Util
local UIClubMessageEmailItem = app.UIClubMessageEmailItem

local UIClubMessageEmail = class("UIClubMessageEmail")

function UIClubMessageEmail:ctor(parent)
    self._imgNoMailTip = Util:seekNodeByName(parent,"imgNoMailTip","ccui.ImageView")
    local node = Util:seekNodeByName(parent,"scrollListMail","ccui.ScrollView")
    self._scrollListMail = UITableView.extend(node,UIClubMessageEmailItem)

end

function UIClubMessageEmail:onShow()
    local datas = { {},{},{},{} }
    self._imgNoMailTip:setVisible(#datas <= 0)
    self._scrollListMail:updateDatas(datas)
end

function UIClubMessageEmail:dispose()

end

return UIClubMessageEmail