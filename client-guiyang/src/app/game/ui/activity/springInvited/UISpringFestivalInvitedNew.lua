local csbPath = "ui/csb/Activity/SpringFestivalInvited/UIActivity_SpringInvitedNew.csb"
local super = require("app.game.ui.UIBase")
local UISpringFestivalInvitedNew = class("UISpringFestivalInvitedNew", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalInvitedNew:ctor()
    self._btnWorship = nil
    self._btnHelp = nil
    self._btnClose = nil
    self._btnMyGift = nil  
    self._worshipTimes = nil         
    self._openCount = 0                                                                                                                                                                               
end

function UISpringFestivalInvitedNew:init()
    self._btnClose = seekNodeByName(self, "Button_x","ccui.Button")
    self._btnWorship = seekNodeByName(self, "Button_byb","ccui.Button")
    self._worshipTimes = seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")
    self._btnMyGift = seekNodeByName(self, "Button_wdlw","ccui.Button")
    self._btnHelp = seekNodeByName(self, "Button_wt","ccui.Button")
    self._btnInvited = seekNodeByName(self, "Button_yqwj", "ccui.Button")
    self._bgTimes = seekNodeByName(self, "Image_yqyj_0","ccui.ImageView")

    self:_registerCallBack()
end

function UISpringFestivalInvitedNew:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnWorship,   handler(self, self._onBtnWorship),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp,   handler(self, self._onHelp),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMyGift,   handler(self, self._onBtnMyGift),  ccui.TouchEventType.ended)

    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:addEventListener("EVENT_SPRING_INVITED_WORSHIP",    handler(self, self.refreshWorshipTimes), self)
end

function UISpringFestivalInvitedNew:onShow( content )
    self._openCount = content.openCount
    if self._openCount ~= 0 then
        self._worshipTimes:setString(self._openCount)
    else
        self._bgTimes:setVisible(false)
    end
    self._worshipTimes:setString(self._openCount)
end

function UISpringFestivalInvitedNew:onHide()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:removeEventListenersByTag(self);
end

function UISpringFestivalInvitedNew:refreshWorshipTimes(event)
    self._openCount = event.num
    if self._openCount > 0 then
        self._bgTimes:setVisible(true)
        self._worshipTimes:setString(self._openCount)
    else
        self._bgTimes:setVisible(false)
    end
end

function UISpringFestivalInvitedNew:_onBtnMyGift()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:sendCACGodOfWealthRecordREQ()
end

function UISpringFestivalInvitedNew:_onHelp()
    UIManager:getInstance():show("UISpringFestivalInvitedHelp")
end

function UISpringFestivalInvitedNew:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalInvitedNew");
end

function UISpringFestivalInvitedNew:_onBtnWorship()
    if self._openCount > 0 then
        local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
        service:sendCACGodOfWealthOpenREQ()
    else
        UIManager:getInstance():show("UISpringFestivalNoEnoughChance",true)
    end
end

function UISpringFestivalInvitedNew:needBlackMask()
    return true
end


return UISpringFestivalInvitedNew