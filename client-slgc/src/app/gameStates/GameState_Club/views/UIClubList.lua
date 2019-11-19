local csbPath = "ui/csb/mengya/club/UIClubList.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UIClubListItem = import("items.UIClubListItem")
local UIClubList = class("UIClubList", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIClubList:ctor()
    
end

function UIClubList:init()
    self._panelClub = Util:seekNodeByName(self,"panelClub","ccui.Layout")
    self._beginX = self._panelClub:getPositionX()
    local node = Util:seekNodeByName(self,"scrollListClub","ccui.ScrollView")
    self._scrollListClub = UITableView.extend(node,UIClubListItem)
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

function UIClubList:showAction()
    self._panelClub:setPositionX(self._beginX)
    self._panelClub:stopAllActions()
    local action = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(self._panelClub:getContentSize().width - 80,0)))
    self._panelClub:runAction(action)

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0)
    local fadeTo = cc.EaseBackOut:create(cc.FadeTo:create(0.6, 0.5*255))
    self._imgMask:runAction(fadeTo)
end

function UIClubList:hideAction()
    self._panelClub:stopAllActions()
    local act1 = cc.MoveTo:create(0.3, cc.p(0,self._panelClub:getPositionY()))
    local act2 = cc.CallFunc:create(function()
		UIManager:getInstance():hide("views.UIClubList")
    end)
    self._panelClub:runAction(cc.Sequence:create(act1,act2))

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0.5*255)
    local fadeTo = cc.FadeTo:create(0.3, 0)
    self._imgMask:runAction(fadeTo)
end

function UIClubList:onShow()
    self:showAction()
    
    local datas = { {},{},{},{} }
    self._scrollListClub:updateDatas(datas)
end

function UIClubList:onHide()
    
end

return UIClubList