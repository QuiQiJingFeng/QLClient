local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherTip.csb"

---@class UIUFOCatcherTip:UIBase
local UIUFOCatcherTip = super.buildUIClass("UIUFOCatcherTip", csbPath)
function UIUFOCatcherTip:init()
    UtilsFunctions.attachCloseButton(self, true)
    UtilsFunctions.attachCloseButton(self, true, "Button_Ensure")

    seekButton(self, "Button_Go_To_Mall", function()
        CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
        self:hideSelf()
    end)
end

function UIUFOCatcherTip:needBlackMask()
    return true
end

return UIUFOCatcherTip