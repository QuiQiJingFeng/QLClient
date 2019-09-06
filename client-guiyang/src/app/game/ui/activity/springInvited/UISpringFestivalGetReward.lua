local csbPath = "ui/csb/Activity/SpringFestivalInvited/GetRewardSucess.csb"
local super = require("app.game.ui.UIBase")
local UISpringFestivalGetReward = class("UISpringFestivalGetReward", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalGetReward:ctor()
    self._btnClose = nil
end

function UISpringFestivalGetReward:init()
    self._btnClose = seekNodeByName(self, "Button_1","ccui.Button")
    self._rewardText = seekNodeByName(self, "Text_1", "ccui.Text")
    self._btnInvite = seekNodeByName(self, "Button_3", "ccui.Button")
    self._imgRewardNode = seekNodeByName(self, "Node_1", "cc.Node")
    self._imgReward = seekNodeByName(self._imgRewardNode, "Image_1", "ccui.ImageView")
    self._btnInvite = seekNodeByName(self, "Button_3", "ccui.Button")
    self._newBtnConfirm = seekNodeByName(self, "Button_3_0", "ccui.Button")

    self:_registerCallBack()
end

function UISpringFestivalGetReward:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite,   handler(self, self.onBtnInvited),  ccui.TouchEventType.ended)
    bindEventCallBack(self._newBtnConfirm,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
end

function UISpringFestivalGetReward:onShow(reward , openTimes)
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:dispatchEvent({name = "EVENT_SPRING_INVITED_WORSHIP",num = openTimes})
    self._imgRewardNode:removeAllChildren()
    self:_fillRewardText(reward)
    self:_createIcon(reward)
    self._newBtnConfirm:setVisible(false)
    if UIManager:getInstance():getIsShowing("UISpringFestivalInvitedNew") then
        self._newBtnConfirm:setVisible(true)
    end
end

function UISpringFestivalGetReward:onBtnInvited()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    if service ~= nil then
        service:inviteFriend()
    end    
end


function UISpringFestivalGetReward:_createIcon(reward)
    self._imgReward:setVisible(false)
    self._imgReward:retain()
    self._imgReward:removeFromParent(true)
    local begin = - 128 * #reward / 2
    table.foreach(reward,function (k,v)
        local item = self._imgReward:clone()
        local text = item:getChildByName("Text_2")
        item:setVisible(true)
        item:loadTexture(PropReader.getIconById(v.itemId))        
        if PropReader.getTypeById(v.itemId) == "RedPackage" then
            text:setString(PropReader.getNameById(v.itemId) .. "X" ..  v.count)
        else
            text:setString(PropReader.getNameById(v.itemId) .. "X" ..  math.floor( v.count ))
        end
        
        item:setPositionX(begin + (k-1) * 128)
        self._imgRewardNode:addChild(item)
    end)
end

function UISpringFestivalGetReward:_fillRewardText(reward)
    local string = "财神驾到！恭喜获得%s奖励！"
    local rewardString = ""
    -- table.foreach(reward,function (k,v)
    --     rewardString = rewardString .. PropReader.getNameById(v.itemId) .. "X" .. v.count .. " "
    -- end)
    self._rewardText:setString(string.format( string,rewardString ))
end

function UISpringFestivalGetReward:dispose()
    if self._imgReward ~= nil then
        self._imgReward:release()
        self._imgReward = nil
    end
end

function UISpringFestivalGetReward:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalGetReward");
end

function UISpringFestivalGetReward:needBlackMask()
    return true
end

function UISpringFestivalGetReward:closeWhenClickMask()
	return true
end

return UISpringFestivalGetReward