local csbPath = "ui/csb/mengya/UIPersonalCenter.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UIPersonalCenterLeftItem = import("items.UIPersonalCenterLeftItem")
local UIPersonalCenter = class("UIPersonalCenter", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIPersonalCenter:ctor()
    
end

function UIPersonalCenter:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))

    self._imgHead = Util:seekNodeByName(self,"imgHead","ccui.ImageView")
    self._btnBorderChange = Util:seekNodeByName(self,"btnBorderChange","ccui.Button")
    
    self._btnCopy = Util:seekNodeByName(self,"btnCopy","ccui.Button")
    self._txtRoleId = Util:seekNodeByName(self,"txtRoleId","ccui.Text")
    self._txtIp = Util:seekNodeByName(self,"txtIp","ccui.Text")
    self._txtRoleName = Util:seekNodeByName(self,"txtRoleName","ccui.Text")

    self._btnDingDing = Util:seekNodeByName(self,"btnDingDing","ccui.Button")
    self._btnPhone = Util:seekNodeByName(self,"btnPhone","ccui.Button")
    self._btnIdentity = Util:seekNodeByName(self,"btnIdentity","ccui.Button")


    self._imgDingRed = Util:seekNodeByName(self,"imgDingRed","ccui.ImageView")
    self._imgDingFinish = Util:seekNodeByName(self,"imgDingFinish","ccui.ImageView")
    self._imgPhoneRed = Util:seekNodeByName(self,"imgPhoneRed","ccui.ImageView")
    self._imgBindFinish = Util:seekNodeByName(self,"imgBindFinish","ccui.ImageView")
    self._imgIdentityRed = Util:seekNodeByName(self,"imgIdentityRed","ccui.ImageView")
    self._imgAuthFinish = Util:seekNodeByName(self,"imgAuthFinish","ccui.ImageView")

    local node = Util:seekNodeByName(self,"scrollListPlayerInfo","ccui.ScrollView")
    self._scrollListPlayerInfo = UITableView.extend(node,UIPersonalCenterLeftItem,handler(self,self._onItemClick))

    Util:bindTouchEvent(self._btnBorderChange,handler(self,self._onBtnBorderChangeClick))
end

function UIPersonalCenter:_onBtnBorderChangeClick()
    UIManager:getInstance():show("views.UIHeadFrameShop")
end

function UIPersonalCenter:_onItemClick(item,data,eventType)

end

function UIPersonalCenter:needBlackMask()
    return true
end

function UIPersonalCenter:_onBtnCloseClick()
    UIManager:getInstance():hide("views.UIPersonalCenter")
end

function UIPersonalCenter:onShow()
    local datas = { {name="基本资料",selected = false} }
    self._scrollListPlayerInfo:updateDatas(datas)

    local selectIdx = 1
    local item = self._scrollListPlayerInfo:getCellByIndex(selectIdx)
    self:_onItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UIPersonalCenter:onHide()

end

return UIPersonalCenter