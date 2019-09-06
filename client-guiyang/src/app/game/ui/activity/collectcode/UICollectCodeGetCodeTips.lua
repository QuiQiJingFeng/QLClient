local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeGetCodeTips.csb'
local super = require("app.game.ui.UIBase")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local UICollectCodeGetCodeTips = super.buildUIClass("UICollectCodeGetCodeTips", csbPath)
function UICollectCodeGetCodeTips:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)

    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnGetCode = seekButton(self, "Button_Get_Code", handler(self, self._onBtnGetCodeClick))
    self._textOpenCodeTime = seekNodeByName(self, "Text_Open_Code_Time", "ccui.Text")
end

function UICollectCodeGetCodeTips:onShow()
    local t = self._service:getCurrentOpenCodeTime(true)
    self._textOpenCodeTime:setString("本期开奖时间：" .. t)
end

function UICollectCodeGetCodeTips:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeGetCodeTips:_onBtnGetCodeClick(sender)
    self:hideSelf()
end

function UICollectCodeGetCodeTips:needBlackMask() return true end

return UICollectCodeGetCodeTips