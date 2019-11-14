local csbPath = "ui/csb/mengya/UIUserProtocol.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UIXMLView = game.UIXMLView
local UIUserProtocol = class("UIUserProtocol", super, function() return Util:loadCSBNode(csbPath) end)
 
function UIUserProtocol:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))
    local node = Util:seekNodeByName(self,"scrollProtocol","ccui.ScrollView")
    self._xmlView = UIXMLView.extend(node)

    self._xmlView:setContent(game.Languege.AGREEMENG)
end

function UIUserProtocol:_onBtnCloseClick()
    UIManager:getInstance():hide("UIUserProtocol")
end

function UIUserProtocol:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIUserProtocol:isFullScreen()
    return true
end

function UIUserProtocol:onShow()

end

 
return UIUserProtocol