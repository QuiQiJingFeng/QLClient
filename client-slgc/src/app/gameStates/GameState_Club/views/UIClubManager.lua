local csbPath = "ui/csb/mengya/club/UIClubManager.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableView = game.UITableView
local UIClubManagerItem = import("items.UIClubManagerItem")
local UIClubManager = class("UIClubManager", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIClubManager:ctor()
    
end

function UIClubManager:init()
    self._panelManager = Util:seekNodeByName(self,"panelManager","ccui.Layout")
    self._beginX = self._panelManager:getPositionX()
    local node = Util:seekNodeByName(self,"scrollListManager","ccui.ScrollView")
    self._scrollListManager = UITableView.extend(node,UIClubManagerItem,handler(self,self._onItemClick))
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

function UIClubManager:_onItemClick(item,data,eventType)
    if data.id == 1 then
        UIManager:getInstance():show("UIReverseRoom")
    end
end

function UIClubManager:showAction()
    self._panelManager:setPositionX(self._beginX)
    self._panelManager:stopAllActions()
    local action = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(-self._panelManager:getContentSize().width,0)))
    self._panelManager:runAction(action)

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0)
    local fadeTo = cc.EaseBackOut:create(cc.FadeTo:create(0.6, 0.5*255))
    self._imgMask:runAction(fadeTo)
end

function UIClubManager:hideAction()
    self._panelManager:stopAllActions()
    local act1 = cc.MoveTo:create(0.3, cc.p(display.width,self._panelManager:getPositionY()))
    local act2 = cc.CallFunc:create(function()
		UIManager:getInstance():hide("views.UIClubManager")
    end)
    self._panelManager:runAction(cc.Sequence:create(act1,act2))

    self._imgMask:stopAllActions()
    self._imgMask:setOpacity(0.5*255)
    local fadeTo = cc.FadeTo:create(0.3, 0)
    self._imgMask:runAction(fadeTo)
end

function UIClubManager:onShow()
    self:showAction()
    
    local datas = { {
        id = 1,
        name = "玩法禁用"
    }
    }
    self._scrollListManager:updateDatas(datas)
end

function UIClubManager:onHide()
    
end

return UIClubManager