local csbPath = "ui/csb/UIOpenTuisong.csb"
local UIOpenTuisong = class("UIOpenTuisong",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIOpenTuisong:init()
    self._btnOpen = seekNodeByName(self, "Button_Open", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
end

function UIOpenTuisong:onShow()
    bindEventCallBack(self._btnOpen, handler(self, self._onClickOpen), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIOpenTuisong:needBlackMask()
    return true
end


function UIOpenTuisong:_onClickClose()
    cc.UserDefault:getInstance():setIntegerForKey("Type_Tuisong_Check", 2)
    cc.UserDefault:getInstance():flush()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.close_tuisong);
    UIManager:getInstance():hide("UIOpenTuisong")
end

function UIOpenTuisong:_onClickOpen()
    cc.UserDefault:getInstance():setIntegerForKey("Type_Tuisong_Check", 1)
    cc.UserDefault:getInstance():flush()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.open_tuisong);
    UIManager:getInstance():hide("UIOpenTuisong")
    game.plugin.Runtime.openSetting()
end

return UIOpenTuisong