local csbPath = app.UIClubMemberCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UIClubMemberItem = app.UIClubMemberItem
local UIClubMember = class("UIClubMember", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubMember:ctor()
    
end

function UIClubMember:init()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    self._txtBmfMember = Util:seekNodeByName(self,"txtBmfMember","ccui.TextBMFont")
    local node = Util:seekNodeByName(self,"scrollListMember","ccui.ScrollView")
    self._scrollListMember = UITableView.extend(node,UIClubMemberItem,handler(self,self._onItemClick))

    self._panelBottomSearch = Util:seekNodeByName(self,"panelBottomSearch","ccui.Layout")
    self._panelBottomSearchOriginY = self._panelBottomSearch:getPositionY()
    self._btnSearchCancel = Util:seekNodeByName(self,"btnSearchCancel","ccui.Button")
    self._btnSearchOK = Util:seekNodeByName(self,"btnSearchOK","ccui.Button")

    self._txtFieldMemberName = Util:seekNodeByName(self,"txtFieldMemberName","ccui.TextField")

    self._btnSearchMember = Util:seekNodeByName(self,"btnSearchMember","ccui.Button")
    self._btnInviteMember = Util:seekNodeByName(self,"btnInviteMember","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))
    Util:bindTouchEvent(self._btnSearchMember,handler(self,self._onBtnSearchMemberClick))
    Util:bindTouchEvent(self._btnInviteMember,handler(self,self._onBtnInviteMemberClick))
    

    Util:bindTouchEvent(self._txtFieldMemberName,handler(self,self._onTextFieldMemberNameClick))

    Util:bindTouchEvent(self._btnSearchCancel,handler(self,self._onBtnSearchCancelClick))
    Util:bindTouchEvent(self._btnSearchOK,handler(self,self._onBtnSearchOKClick))
end

function UIClubMember:_onItemClick(item,data,eventType)
    if ccui.TouchEventType.ended == eventType then
        UIManager:getInstance():show("UIClubMemberInfo",data)
    end
end

function UIClubMember:_onBtnSearchOKClick()
    self._panelBottomSearch:setPositionY(self._panelBottomSearchOriginY)
end

function UIClubMember:_onTextFieldMemberNameClick()
    self._panelBottomSearch:setPositionY(self._panelBottomSearchOriginY + display.height/2)
end

function UIClubMember:_onBtnSearchCancelClick()
    Util:hide(self._panelBottomSearch)
    Util:show(self._btnSearchMember,self._btnInviteMember)
    self._txtFieldMemberName:setString("")
    self._panelBottomSearch:setPositionY(self._panelBottomSearchOriginY)
end

function UIClubMember:_onBtnSearchMemberClick()
    Util:show(self._panelBottomSearch)
    Util:hide(self._btnSearchMember,self._btnInviteMember)
end

function UIClubMember:_onBtnInviteMemberClick()
    UIManager:getInstance():show("UIClubMemberInvite")
end

function UIClubMember:_onBtnBackClick()
    UIManager:getInstance():hide("UIClubMember")
end

function UIClubMember:_onBtnConfirmClick()
    --向服务器请求
end

function UIClubMember:isFullScreen()
    return true
end

function UIClubMember:onShow()
    Util:hide(self._panelBottomSearch)
    Util:show(self._btnSearchMember,self._btnInviteMember)
    self._scrollListMember:updateDatas({ {},{},{},{},{},{},{},{} })
end

return UIClubMember;