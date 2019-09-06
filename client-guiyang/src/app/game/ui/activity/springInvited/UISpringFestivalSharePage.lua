local csbPath = "ui/csb/Activity/SpringFestivalInvited/UIInviteShare.csb"
local super = require("app.game.ui.UIBase")

local PropTextConvertor = game.util.PropTextConvertor

local UISpringFestivalSharePage = class("UISpringFestivalSharePage", super, function() return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalSharePage:ctor()
    super.ctor(self)
    self._QRCode = nil
    self._root = seekNodeByName(self, "root", "ccui.Layout")
end

function UISpringFestivalSharePage:init()
    self._QRCode = seekNodeByName(self, "QRCode", "ccui.ImageView")
end

function UISpringFestivalSharePage:onShow( ... )
    -- todo 根据地区配置控制二维码
    local args = { ... }
    local qrCode = args[1]
    self._QRCode:loadTexture(qrCode)
end

function UISpringFestivalSharePage:getRoot()
    return self._root
end

function UISpringFestivalSharePage:onHide()
    
end

return UISpringFestivalSharePage