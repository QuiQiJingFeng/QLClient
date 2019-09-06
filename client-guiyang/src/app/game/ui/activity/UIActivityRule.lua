local csbPath = 'ui/csb/Activity/UIActivityRule.csb'
local super = require("app.game.ui.UIBase")
local UIActivityRule = class("UIActivityRule", super, function() return kod.LoadCSBNode(csbPath) end)
local ScrollText = require("app.game.util.ScrollText")

function UIActivityRule:ctor()    
end

function UIActivityRule:init()
    self._textContent = seekNodeByName(self, "Text_rule", "ccui.Text")
    self._textContent = ScrollText.new(self._textContent, 24, true)
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
end

function UIActivityRule:_onBtnCloseClick()
    UIManager:getInstance():destroy("UIActivityRule")
end

function UIActivityRule:onShow()
    local public = MultiArea.getNoPublic(game.service.LocalPlayerService:getInstance():getArea())
    local str = [[
活动时间：
    2019.1.28-2019.2.7
活动说明：
    1.活动期间，分享游戏海报到朋友圈即可获得1张房卡。
    2.如果分享到朋友圈的游戏海报获得了超过50个赞，可在当日12:00后或20:00后凭朋友圈截图联系客服领取价值218元的年货大礼包。（每日每个时段限200个，先到先得，送完为止）
    3.本活动最终解释权归聚友贵州麻将所有。]]

    self._textContent:setString(str)
end

function UIActivityRule:onHide()
end

function UIActivityRule:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

function UIActivityRule:needBlackMask() 
    return true
end

function UIActivityRule:closeWhenClickMask()
    return false
end

return UIActivityRule