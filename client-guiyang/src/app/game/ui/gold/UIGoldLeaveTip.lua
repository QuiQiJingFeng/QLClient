local csbPath = "ui/csb/Gold/UIGoldLeaveTip.csb"
local super = require("app.game.ui.UIBase")
local UIGoldLeaveTip = class("UIGoldLeaveTip", super, function() return kod.LoadCSBNode(csbPath) end)
local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade

function UIGoldLeaveTip:ctor()

end

function UIGoldLeaveTip:init()
    self._txtContent = seekNodeByName(self, "Text_messagebox", "ccui.Text")
    self._btnLeave = seekNodeByName(self, "btnOk", "ccui.Button")
    self._btnContiune = seekNodeByName(self, "btnClose", "ccui.Button")

    self:_registerCallBack()

end


function UIGoldLeaveTip:onShow(needRound, gitfCount)
    self._txtContent:setString(string.format("再玩%d局送您%d礼券喔~", needRound, gitfCount))
    -- 统计活动点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.try_leave_gold_battle)

    local roomGrade = game.service.GoldService.getInstance():getlastSelectRoomGrade()
    --如果获取不到本地缓存的房间类型则禁止继续(玩家比赛中换手机才会这样)
    self._btnContiune:setEnabled(roomGrade ~= 0)
end

function UIGoldLeaveTip:onHide()

end

function UIGoldLeaveTip:_registerCallBack()
    bindEventCallBack(self._btnLeave, handler(self, self._onBtnLeaveClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContiune, handler(self, self._onBtnContiuneClick), ccui.TouchEventType.ended)
end

function UIGoldLeaveTip:_onBtnLeaveClick(sender)
    GameFSM:getInstance():enterState("GameState_Gold")
end

function UIGoldLeaveTip:_onBtnContiuneClick(sender)
    local goldService = game.service.GoldService.getInstance()
    local roomGrade = goldService:getlastSelectRoomGrade()
    if roomGrade == 0 then
        roomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade.QUICK
    end
    goldService:trySendCGoldMatchREQ(roomGrade)
    -- 统计活动点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.leave_gold_battle)
end

function UIGoldLeaveTip:needBlackMask()
    return true
end

return UIGoldLeaveTip