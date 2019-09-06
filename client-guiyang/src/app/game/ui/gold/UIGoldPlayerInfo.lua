local csbPath = 'ui/csb/Gold/UIGoldPlayerInfo.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIGoldPlayerInfo", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    self._txtIp = seekNodeByName(self, "Text_IP", "ccui.Text")
    -- self._txtId = seekNodeByName(self, "Text_Id", "ccui.Text")
    self._txtName = seekNodeByName(self, "Text_Name", "ccui.Text")
    self._imgIcon = seekNodeByName(self, "Image_Icon", "ccui.ImageView")
    self._imgFrame = seekNodeByName(self, "Image_Frame", "ccui.ImageView")
end

function M:init()
end

function M:onShow(playerInfo)
    self._txtName:setString(playerInfo:getShortName(16))
    -- self._txtId:setString(playerInfo.roleId)
    self._txtIp:setString("IP:" .. playerInfo.ip)
    game.util.PlayerHeadIconUtil.setIcon(self._imgIcon, playerInfo.headImageUrl or playerInfo.iconUrl)
    local headFrameId = playerInfo:getHeadFrame()
    if headFrameId then
        game.util.PlayerHeadIconUtil.setIconFrame(self._imgFrame, PropReader.getIconById(headFrameId), 0.9)
    end
end

function M:needBlackMask() return true end

function M:closeWhenClickMask() return true end

return M