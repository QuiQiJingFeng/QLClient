local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Gold/UIGoldShareRoundResultTips.csb'
local M = class("UIGoldShareRoundResultTips", super, function() return kod.LoadCSBNode(csbPath) end)
function M:ctor()
    super.ctor(self)
end

function M:init()
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")
    bindEventCallBack(self._btnOk, handler(self, self._onBtnOkClick), ccui.TouchEventType.ended)
end

function M:_onBtnOkClick(sender)
    self:hideSelf()
end

-- overwrite
function M:needBlackMask()
    return true
end

return M