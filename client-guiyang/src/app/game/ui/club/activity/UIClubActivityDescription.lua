local csbPath = "ui/csb/Club/UIEventDescription.csb"
local super = require("app.game.ui.UIBase")
local ScrollText = require("app.game.util.ScrollText")
local M = class("UIClubActivityDescription", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
end

function M:init()
    self._textContent = seekNodeByName(self, "Text_content", "ccui.Text")
    self._textContent = ScrollText.new(self._textContent, 24, true)
end

function M:onShow(str)
    self._textContent:setString(str)
end

function M:onHide()
end

function M:needBlackMask()
    return true
end

function M:closeWhenClickMask()
    return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M