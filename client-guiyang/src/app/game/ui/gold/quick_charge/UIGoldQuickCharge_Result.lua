local Config = {
    ["UIGoldQuickCharge_Normal"] = {
        iconResPath = 'art/gold/icon_gold1.png',
        imageTextResPath = 'art/gold/z_dhcg.png',
    },
    ["UIGoldQuickCharge_Luck"] = {
        iconResPath = 'art/gold/icon_jblb.png',
        imageTextResPath = 'art/gold/z_qgcg.png',
    },
    ["UIGoldQuickCharge_Upgrade"] = {
        iconResPath = 'art/gold/icon_gold1.png',
        imageTextResPath = 'art/gold/z_lqcg.png',
    },
    ["UIGoldQuickCharge_Luck_Downgrade"] = {
        iconResPath = 'art/gold/icon_jblb.png',
        imageTextResPath = 'art/gold/z_qgcg.png',
    },
}
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Gold/QuickCharge/UIGoldQuickCharge_Result.csb'
local M = class("UIGoldQuickCharge_Result", super, function() return kod.LoadCSBNode(csbPath) end)


function M:ctor(...)
    super.ctor(self, ...)
    bindEventCallBack(seekNodeByName(self, "Button_Ensure", "ccui.Button"), handler(self, self._onBtnEnsureClick), ccui.TouchEventType.ended)

    self._imgIcon = seekNodeByName(self, "ImageView_Icon", "ccui.ImageView")
    self._imgText = seekNodeByName(self, "ImageView_Text", "ccui.ImageView")
end

function M:onShow(fromUIKey)
    local resPathCfg = Config[fromUIKey]
    if Macro.assertFalse(resPathCfg, 'unknown ui key = ' .. tostring(fromUIKey)) then
        self._imgIcon:loadTexture(resPathCfg.iconResPath)
        self._imgIcon:ignoreContentAdaptWithSize(true)
        self._imgText:loadTexture(resPathCfg.imageTextResPath)
    end
end

function M:_onBtnEnsureClick(sender)
    self:hideSelf()
end

function M:needBlackMask() return true end

function M:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return M