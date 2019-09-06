local UtilsFunctions = require("app.game.util.UtilsFunctions")
local csbPath = "ui/csb/UIMarqueeTips.csb"

local UIMarqueeTips = class("UIMarqueeTips", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)

function UIMarqueeTips:ctor()
    self._tip = nil
    self._rollSpeed = 120		-- 滚动速度
end

function UIMarqueeTips:init()
    self._tip = seekNodeByName(self, "Text_MarqueeTips", "ccui.Text")
    self._tip:setString("")
    self._tip:setAnchorPoint(cc.p(0, 0.5))

    self._tipLayout = seekNodeByName(self, "Panel_text_MarqueeTips", "ccui.Layout")
    self._tipLayout:setClippingEnabled(true)

    self._bgSize = self._tipLayout:getContentSize()
    self._tipInitPos = cc.p(self._bgSize.width, self._bgSize.height / 2)

    self._marqueeLayout = seekNodeByName(self, "Panel_MarqueeTips", "ccui.Layout")
    self._originMarqueeLayoutPosition = cc.p(self._marqueeLayout:getPosition())
end

-- 是否需要显示背景遮罩
function UIMarqueeTips:needBlackMask()
    return false
end

function UIMarqueeTips:onShow(marqueeStruct)
    self._tip:setPosition(self._tipInitPos)
    self._tip:setString(marqueeStruct.text)
    self._tip:setColor(UtilsFunctions.convert2CCColor(marqueeStruct.color))
    local tipLength = self._tip:getContentSize().width
    local delay = (tipLength + self._bgSize.width + 2) / self._rollSpeed
    local moveToAction = cc.MoveTo:create(delay, cc.p(-tipLength, self._bgSize.height / 2))
    local callFuncAction = cc.CallFunc:create(handler(self, self._onActionDone))
    self._tip:runAction(cc.Sequence:create(moveToAction, callFuncAction))

    self._marqueeLayout:setPosition(self._originMarqueeLayoutPosition)
    self:_adjustPositionByCurrentShowState()
end

function UIMarqueeTips:_onActionDone()
    UIManager:getInstance():hide(self.class.__cname)
end

function UIMarqueeTips:_adjustPositionByCurrentShowState()
    local lobbyType = game.service.LocalPlayerService.getInstance():getCurrentLobbyType()
    if lobbyType == game.globalConst.LobbyType.Gold then
        -- 做一个偏移
        local ui = UIManager:getInstance():getUI("UIGoldMain")
        local marqueeNode = seekNodeByName(ui, "Node_Marquee_Anchor", "cc.Node")
        self._marqueeLayout:setPosition(cc.p(marqueeNode:getPosition()))
    end
end

-- 隐藏跑马灯
function UIMarqueeTips:hideImmediately()
    self._isTweenning = false
    if self._tip ~= nil then
        self._tip:stopAllActions()
    end
    UIManager:getInstance():hide(self.class.__cname)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIMarqueeTips:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UIMarqueeTips