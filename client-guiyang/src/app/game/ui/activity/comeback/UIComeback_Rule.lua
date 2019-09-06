local RULES = {
    [true] = [[获得规则：
本活动只限有所亲友圈经理
邀请超过7日（包含7日）未登录的玩家登陆游戏即可点亮灯泡
点亮灯泡即可获得亲友圈房卡奖励，每日邀请人数越多奖励越大，即第一人登录给2房卡，第二人登录再给4房卡，以此类推，没有上限
快去邀请老玩家吧！老玩家登录也会获得专属回归奖励
每日24:00灯泡重新熄灭
灯泡需超过7日（包含7日）未登录的老玩家登录即点亮
对于恶意邀请用户，我方有权利进行禁止
]],
    [false] = [[活动规则：
老玩家专属回归奖励只针对通过分享回归的老玩家。
每日签到即可领取当日奖励，连续签到7天可获得红包大奖
每日签到首次分享也可获得房卡奖励
快邀请老朋友一起来领取丰厚大奖吧！
]],
}
local ScrollText = require("app.game.util.ScrollText")
local seekButton = require("app.game.util.UtilsFunctions").seekButton
local csbPath = 'ui/csb/Activity/Comeback/UIComeback_Rule.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIComeback_Rule", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    self._text = ScrollText.new(seekNodeByName(self, "Text", "ccui.Text"), 22, true) 
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
end

function M:onShow(isManager)
    local str = ''
    if isManager == true then
        str = RULES[true]
    else
        str = RULES[false]
    end
    self._text:setString(str)
end

function M:_onBtnCloseClick()
    self:hideSelf()
end

function M:needBlackMask() return true end

return M