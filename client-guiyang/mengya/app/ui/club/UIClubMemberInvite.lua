local csbPath = app.UIClubMemberInviteCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UIClubMemberInvite = class("UIClubMemberInvite", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubMemberInvite:ctor()
    
end

function UIClubMemberInvite:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")

    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))
end

function UIClubMemberInvite:_onBtnCloseClick()
    UIManager:getInstance():hide("UIClubMemberInvite")
end


function UIClubMemberInvite:needBlackMask()
	return true
end

function UIClubMemberInvite:onShow()

end

return UIClubMemberInvite;