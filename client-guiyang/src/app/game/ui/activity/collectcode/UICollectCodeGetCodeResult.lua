--[[0
    这是摇奖后的一个弹窗
]]
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeGetCodeResult.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local CodeSet = require("app.game.ui.activity.collectcode.CodeSet")
local UICollectCodeGetCodeResult = super.buildUIClass("UICollectCodeGetCodeResult", csbPath)

function UICollectCodeGetCodeResult:init()
    self._textOpenCodeTime = seekNodeByName(self, "Text_Open_Code_Time", "ccui.Text")
    self._btnMyCode = UtilsFunctions.seekButton(self, "Button_My_Code", handler(self, self._onBtnMyCodeClick))
    self._btnClose = UtilsFunctions.seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._codeSet = CodeSet.new(seekNodeByName(self, "Layout_Code", "ccui.Layout"))

    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
end

function UICollectCodeGetCodeResult:onShow(codeArray)
    self._codeSet:setCodes(codeArray)
    self._textOpenCodeTime:setString(self._service:getCurrentOpenCodeTime(true) .. "开奖，您获得幸运码")
end

function UICollectCodeGetCodeResult:_onBtnMyCodeClick(sender)
    self._service:sendCACCollectCodeQueryCodeREQ()
end

function UICollectCodeGetCodeResult:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeGetCodeResult:needBlackMask() return true end

return UICollectCodeGetCodeResult