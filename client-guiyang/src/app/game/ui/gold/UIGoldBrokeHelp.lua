local csbPath = "ui/csb/Gold/UIGoldBrokeHelp.csb"
local super = require("app.game.ui.UIBase")
local UIGoldBrokeHelp = class("UIGoldBrokeHelp", super, function() return kod.LoadCSBNode(csbPath) end)

function UIGoldBrokeHelp:ctor()

end

function UIGoldBrokeHelp:needBlackMask()
    return true
end

function UIGoldBrokeHelp:init()
    self._btnOk = seekNodeByName(self, "Button_OK", "ccui.Button")
    self._textTimes = seekNodeByName(self, "Text_Times", "ccui.Text")
    self._textContent = seekNodeByName(self, "Text_Content", "ccui.Text")
    self._textCount = seekNodeByName(self, "BMFont_Count", "ccui.TextBMFont")
    self:_registerCallBack()

end


function UIGoldBrokeHelp:onShow()
    --设置破产补助信息
    local brokeHelpInfo = game.service.GoldService.getInstance():getBrokeHelpInfo()
    if brokeHelpInfo then
        self._textContent:setString(string.format("送您%d救济金，继续游戏！", brokeHelpInfo.helpGoldAmount))
        self._textTimes:setString(string.format("今日第%s次领取，一共可以领取%s次", brokeHelpInfo.usedBrokeHelpNum + 1, brokeHelpInfo.maxBrokeHelpNum))
        self._textCount:setString(string.format("X%s", brokeHelpInfo.helpGoldAmount))
    else
        self:hideSelf()
    end
end


function UIGoldBrokeHelp:_registerCallBack()
    bindEventCallBack(self._btnOk, handler(self, self._onBtnOkClick), ccui.TouchEventType.ended)
end

--领取破产补助
function UIGoldBrokeHelp:_onBtnOkClick()
    game.service.GoldService.getInstance():sendCGoldBrokeHelpREQ()
    UIManager.getInstance():hide("UIGoldBrokeHelp")
end

function UIGoldBrokeHelp:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return UIGoldBrokeHelp