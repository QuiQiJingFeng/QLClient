local csbPath = app.UIClubMemberSettingCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableView = app.UITableView
local UIClubMemberSettingItem = app.UIClubMemberSettingItem
local UIClubMemberSetting = class("UIClubMemberSetting", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIClubMemberSetting:ctor()
    
end

function UIClubMemberSetting:init()
    self._panelMemberSetting = Util:seekNodeByName(self,"panelMemberSetting","ccui.Layout")
    self._beginX = self._panelMemberSetting:getPositionX()
    local node = Util:seekNodeByName(self,"scrollListOperators","ccui.ScrollView")
    self._scrollListOperators = UITableView.extend(node,UIClubMemberSettingItem,handler(self,self._onItemClick))
    self._imgMask = Util:seekNodeByName(self,"imgMask","ccui.ImageView")
    self._imgMask:setTouchEnabled(true)
    self._imgMask:setSwallowTouches(true)
    self._imgMask:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.begin then
            return true
        end
        if eventType == ccui.TouchEventType.ended then
            self:hideAction()
        end
    end)
end

function UIClubMemberSetting:_onItemClick(item,data,eventType)
    
end

function UIClubMemberSetting:showAction()
    self._panelMemberSetting:setPositionX(self._beginX)
    self._panelMemberSetting:stopAllActions()
    local action = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(-self._panelMemberSetting:getContentSize().width,0)))
    self._panelMemberSetting:runAction(action)

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0)
    local fadeTo = cc.EaseBackOut:create(cc.FadeTo:create(0.6, 0.5*255))
    self._imgMask:runAction(fadeTo)
end

function UIClubMemberSetting:hideAction()
    self._panelMemberSetting:stopAllActions()
    local act1 = cc.MoveTo:create(0.3, cc.p(display.width,self._panelMemberSetting:getPositionY()))
    local act2 = cc.CallFunc:create(function()
		UIManager:getInstance():hide("UIClubMemberSetting")
    end)
    self._panelMemberSetting:runAction(cc.Sequence:create(act1,act2))

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0.5*255)
    local fadeTo = cc.FadeTo:create(0.3, 0)
    self._imgMask:runAction(fadeTo)
end

function UIClubMemberSetting:onShow()
    self:showAction()
    
    local datas = { {
        name = "设为管理员",
    },{
        name = "设置备注",
    },{
        name = "设置准成员"
    },{
        name = "踢出亲友圈"
    } }
    self._scrollListOperators:updateDatas(datas)
end

function UIClubMemberSetting:onHide()
    
end

return UIClubMemberSetting