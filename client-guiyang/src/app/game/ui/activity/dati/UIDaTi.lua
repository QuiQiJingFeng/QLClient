local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Activity/DaTi/UIDaTi.csb"
local UIDaTi = super.buildUIClass("UIDaTi", csbPath)

function UIDaTi:init()
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnGo1 = seekButton(self, "Button_Go_1", handler(self, self._onbtnGoClick))
    self._btnGo2 = seekButton(self, "Button_Go_2", handler(self, self._onbtnGoClick))
    self:playAnimation(csbPath, nil, true)
end

function UIDaTi:onShow(protocol)
    self._url = protocol.url
end

function UIDaTi:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UIDaTi:_onbtnGoClick(sender)
    if self._url then
        game.service.WebViewService.getInstance():openWebView(self._url)
        self:hideSelf()
    end
    game.service.TDGameAnalyticsService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Wen_Juan_Link)
end

function UIDaTi:needBlackMask() return true end


return UIDaTi