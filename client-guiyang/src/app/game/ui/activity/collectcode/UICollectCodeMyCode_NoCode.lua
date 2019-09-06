local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeMyCode_NoCode.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local bindClick = UtilsFunctions.bindClick
local UICollectCodeMyCode_NoCode = super.buildUIClass("UICollectCodeMyCode_NoCode", csbPath)
function UICollectCodeMyCode_NoCode:init()
    self._btnGetCode = UtilsFunctions.seekButton(self, "Button_Get_Code", handler(self, self._onBtnGetCodeClick))
    self._btnClose = UtilsFunctions.seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))

    self._textRule = seekNodeByName(self, "Text_Rule", "ccui.Text")
    bindClick(self._textRule, handler(self, function()
        UIManager:getInstance():show("UICollectCodeHelp", true)
    end))

    self._textOpenCodeTime = seekNodeByName(self, "Text_Open_Code_Time", "ccui.Text")
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
end

function UICollectCodeMyCode_NoCode:onShow()
    self._textOpenCodeTime:setString(self._service:getCurrentOpenCodeTime(true) .. " 时开奖")
end

function UICollectCodeMyCode_NoCode:_onBtnGetCodeClick(sender)
    self:hideSelf()
end

function UICollectCodeMyCode_NoCode:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeMyCode_NoCode:needBlackMask() return true end

return UICollectCodeMyCode_NoCode