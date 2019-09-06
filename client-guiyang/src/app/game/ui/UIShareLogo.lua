local csbPath = "ui/csb/ShareLogo.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")

--[[
    分享截屏上的logo
]]

local UIShareLogo = class("UIShareLogo", super, function () return kod.LoadCSBNode(csbPath) end)

function UIShareLogo:ctor()
    self._txtAppName = seekNodeByName(self, "Text_1_Sharelogo", "ccui.Text")
end

function UIShareLogo:onShow(...)
    super.onShow(...)
    local name = config.GlobalConfig.getShareInfo()[1]
    self._txtAppName:setString(tostring(name) or "")

    local img = seekNodeByName(self, "Image_Sharelogo", "ccui.ImageView")
    game.util.PlayerHeadIconUtil.setIcon(img, share.config.getQRCodeUrl("other"))
end

function UIShareLogo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.TopMost; -- 凌驾于万物之上
end

return UIShareLogo