local csbPath = app.UIClubMemberInfoCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UIClubMemberInfo = class("UIClubMemberInfo", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubMemberInfo:ctor()
    
end

function UIClubMemberInfo:init()
    self._imgRealNameAuth = Util:seekNodeByName(self,"imgRealNameAuth","ccui.ImageView")
    self._imgHead = Util:seekNodeByName(self,"imgHead","ccui.ImageView")
    self._txtPlayerInfo = Util:seekNodeByName(self,"txtPlayerInfo","ccui.Text")
    self._txtCardCountInfo = Util:seekNodeByName(self,"txtCardCountInfo","ccui.Text")

    self._btnAddFriend = Util:seekNodeByName(self,"btnAddFriend","ccui.Button")
    self._btnPersonalRecord = Util:seekNodeByName(self,"btnPersonalRecord","ccui.Button")

    Util:bindTouchEvent(self._btnAddFriend,handler(self,self._onBtnAddFriendClick))
    Util:bindTouchEvent(self._btnPersonalRecord,handler(self,self._onBtnPersonalRecordClick))
end

-- @override 是否需要遮罩
function UIClubMemberInfo:needBlackMask()
    return true
end

-- @override 是否点击遮罩时关闭页面
function UIClubMemberInfo:closeWhenClickMask()
    return true
end

function UIClubMemberInfo:_onBtnAddFriendClick()

end

function UIClubMemberInfo:_onBtnPersonalRecordClick()
    --向服务器请求
end

function UIClubMemberInfo:needBlackMask()
	return true
end

function UIClubMemberInfo:onShow()

end

return UIClubMemberInfo