local ScrollText = require("app.game.util.ScrollText")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Common/UICommonHelp.csb"

---@class UICommonHelp:UIBase
local UICommonHelp = super.buildUIClass("UICommonHelp", csbPath)
function UICommonHelp:init()
    UtilsFunctions.attachCloseButton(self, true, 'button-close')
    UtilsFunctions.attachCloseButton(self, true, 'button-ensure')

    self._text = ScrollText.new(seekNodeByName(self, "content"), 24, true)
    self._title = seekNodeByName(self, "text-title")
end

function UICommonHelp:onShow(content, title, onCloseHandler)
    self._text:setString(content or "")
    self._title:setString(title or "")
    self._onCloseHandler = onCloseHandler
end

function UICommonHelp:onHide()
end

function UICommonHelp:onDestroy()
    if self._onCloseHandler then
        self._onCloseHandler()
    end
    self._onCloseHandler = nil
end

function UICommonHelp:needBlackMask()
    return true
end

return UICommonHelp