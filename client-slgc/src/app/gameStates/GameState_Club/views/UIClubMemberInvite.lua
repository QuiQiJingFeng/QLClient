local csbPath = "ui/csb/mengya/club/UIClubMemberInvite.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UIClubMemberInvite = class("UIClubMemberInvite", super, function() return Util:loadCSBNode(csbPath) end)

function UIClubMemberInvite:ctor()
    
end

function UIClubMemberInvite:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")

    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))
end

function UIClubMemberInvite:_onBtnCloseClick()
    UIManager:getInstance():hide("views.UIClubMemberInvite")
end


function UIClubMemberInvite:needBlackMask()
	return true
end

function UIClubMemberInvite:onShow()

end

return UIClubMemberInvite