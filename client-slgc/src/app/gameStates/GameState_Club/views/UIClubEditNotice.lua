local csbPath = "ui/csb/mengya/club/UIClubEditNotice.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UIClubEditNotice = class("UIClubEditNotice", super, function() return Util:loadCSBNode(csbPath) end)

function UIClubEditNotice:ctor()
    
end

function UIClubEditNotice:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    self._btnConfirm = Util:seekNodeByName(self,"btnConfirm","ccui.Button")
    self._textFiledNotice = Util:seekNodeByName(self,"textFiledNotice","ccui.TextField")

    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))
    Util:bindTouchEvent(self._btnConfirm,handler(self,self._onBtnConfirmClick))
end

function UIClubEditNotice:_onBtnCloseClick()
    UIManager:getInstance():hide("views.UIClubEditNotice")
end

function UIClubEditNotice:_onBtnConfirmClick()
    --向服务器请求
end

function UIClubEditNotice:needBlackMask()
	return true
end

function UIClubEditNotice:onShow()

end

return UIClubEditNotice;