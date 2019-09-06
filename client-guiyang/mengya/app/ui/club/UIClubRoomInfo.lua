local csbPath = app.UIClubRoomInfoCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UIClubRoomInfo = class("UIClubRoomInfo", super, function() return app.Util:loadCSBNode(csbPath) end)
function UIClubRoomInfo:ctor()

end

function UIClubRoomInfo:onShow()
    self._btnConfirm = Util:seekNodeByName(self,"btnConfirm","ccui.Button")
    self._btnJoinRoom = Util:seekNodeByName(self,"btnJoinRoom","ccui.Button")
    self._btnWatcher = Util:seekNodeByName(self,"btnWatcher","ccui.Button")
    self._btnDestroyRoom = Util:seekNodeByName(self,"btnDestroyRoom","ccui.Button")

    self._btnInvitedByClub = Util:seekNodeByName(self,"btnInvitedByClub","ccui.Button")
    self._btnInvitedByWechat = Util:seekNodeByName(self,"btnInvitedByWechat","ccui.Button")

    Util:bindTouchEvent(self._btnConfirm,handler(self,self._onBtnConfirmClick))

end

function UIClubRoomInfo:_onBtnConfirmClick()
	UIManager:getInstance():hide("UIClubRoomInfo")
end

function UIClubRoomInfo:needBlackMask()
	return true
end

return UIClubRoomInfo