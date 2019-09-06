local csbPath = "ui/csb/Activity/SpringFestivalInvited/UIActivity_SpringInvitedOld.csb"
local super = require("app.game.ui.UIBase")
local UISpringFestivalInvitedOld = class("UISpringFestivalInvitedOld", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalInvitedOld:ctor()
    self._btnHelp = nil
    self._btnClose = nil
    self._playerList = nil
    self._btnInvite = nil
    self._btnWorship = nil
    self._btnMyGift = nil
    self._worshipTimes = nil   
    self._openCount = 0
end

function UISpringFestivalInvitedOld:init()
    self._btnHelp = seekNodeByName(self, "Button_wt","ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_x","ccui.Button")
    self._btnMyGift = seekNodeByName(self, "Button_wdlw","ccui.Button")
    self._playerList = seekNodeByName(self, "ListView_tx","ccui.ListView")
    self._btnInvite = seekNodeByName(self, "Button_yqwj","ccui.Button")
    self._btnWorship = seekNodeByName(self, "Button_byb","ccui.Button")
    self._worshipTimes = seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")
    self._bgTimes = seekNodeByName(self, "Image_yqyj_0","ccui.ImageView")

    self._modelHead = seekNodeByName(self, "Panel_txk", "ccui.ImageView")

    self:_registerCallBack()
end

function UISpringFestivalInvitedOld:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnWorship,   handler(self, self._onBtnWorship),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp,   handler(self, self._onHelp),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMyGift,   handler(self, self._onBtnMyGift),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite,   handler(self, self.onBtnInvited),  ccui.TouchEventType.ended)

    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:addEventListener("EVENT_SPRING_INVITED_WORSHIP",    handler(self, self.refreshWorshipTimes), self)
end

function UISpringFestivalInvitedOld:onShow( content )
    self._openCount = content.openCount
    if self._openCount ~= 0 then
        self._worshipTimes:setString(self._openCount)
    else
        self._bgTimes:setVisible(false)
    end
    self._playerList:setTouchEnabled(false)
    self:_initHeadList(content.headImages)
end

function UISpringFestivalInvitedOld:onBtnInvited()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    if service ~= nil then
        service:inviteFriend()
    end
end

function UISpringFestivalInvitedOld:_initHeadList(headImages)
    self._modelHead:setVisible(false)
    self._modelHead:retain()
    self._modelHead:removeFromParent(true)
    for i=1,3 do
        local item = self._modelHead:clone()
        item:setVisible(true)
        self._playerList:addChild(item)
        if headImages[i] ~= nil then
            local icon = item:getChildByName("Image_tx")
            game.util.PlayerHeadIconUtil.setIcon(icon,headImages[i])
        end
    end
end

function UISpringFestivalInvitedOld:refreshWorshipTimes(event)
    self._openCount = event.num
    if self._openCount > 0 then
        self._bgTimes:setVisible(true)
        self._worshipTimes:setString(self._openCount)
    else
        self._bgTimes:setVisible(false)
    end
end

function UISpringFestivalInvitedOld:onHide()
    if self._modelHead ~= nil then
        self._modelHead:release()
        self._modelHead = nil
    end
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:removeEventListenersByTag(self);
end

function UISpringFestivalInvitedOld:dispose()
    if self._modelHead ~= nil then
        self._modelHead:release()
        self._modelHead = nil
    end
end

function UISpringFestivalInvitedOld:_onBtnMyGift()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:sendCACGodOfWealthRecordREQ()
end

function UISpringFestivalInvitedOld:_onBtnWorship()
    if self._openCount > 0 then
        local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
        service:sendCACGodOfWealthOpenREQ()
    else
        UIManager:getInstance():show("UISpringFestivalNoEnoughChance")
    end
end

function UISpringFestivalInvitedOld:_onHelp()
    UIManager:getInstance():show("UISpringFestivalInvitedHelp")
end

function UISpringFestivalInvitedOld:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalInvitedOld");
end

function UISpringFestivalInvitedOld:needBlackMask()
    return true
end

return UISpringFestivalInvitedOld