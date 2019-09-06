local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherSuccess.csb"

---@class UIUFOCatcherSuccess:UIBase
local UIUFOCatcherSuccess = super.buildUIClass("UIUFOCatcherSuccess", csbPath)
function UIUFOCatcherSuccess:init()
    UtilsFunctions.attachCloseButton(self, true)
    UtilsFunctions.attachCloseButton(self, true, "Button_Ensure")

    self._text = seekNodeByName(self, "Text_Content")
    self._node = seekNodeByName(self, "Node")
end

function UIUFOCatcherSuccess:onShow(args)
    self._onHideCallback = args.callback
    local buffer = args.buffer
    local text = PropReader.generatePropTxt({buffer})
    self._text:setString(text)
    PropReader.setIconForNode(self._node, buffer.itemId)
end

function UIUFOCatcherSuccess:onHide()
    if self._onHideCallback then
        self._onHideCallback()
        self._onHideCallback = nil
    end
end

function UIUFOCatcherSuccess:needBlackMask()
    return true
end

return UIUFOCatcherSuccess