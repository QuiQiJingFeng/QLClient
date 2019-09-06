local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Gold/QuickCharge/UIGoldQuickCharge_Normal.csb'
local M = class("UIGoldQuickCharge_Normal", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor(...)
    super.ctor(self, ...)
    self._btnAbandon = seekNodeByName(self, "Button_Abandon", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnCharge = seekNodeByName(self, "Button_Charge", "ccui.Button")

    self._txtCharge = seekNodeByName(self._btnCharge, "BMFont", "ccui.TextBMFont")
    self._txtChargeCost = seekNodeByName(self._btnCharge, "BMFont_Cost", "ccui.TextBMFont")
    self._txtChargeCount = seekNodeByName(self, "BMFont_Charge_Count", "ccui.TextBMFont")
    self._txtChargeTitle = seekNodeByName(self, "Text_Charge_Title", "ccui.Text")
    self._txtChargeContent = seekNodeByName(self, "Text_Charge_Content", "ccui.Text")
end

function M:init()
    bindEventCallBack(self._btnAbandon, handler(self, self._onBtnAbandonClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCharge, handler(self, self._onBtnChargeClick), ccui.TouchEventType.ended)
end

function M:destroy()
end

function M:onShow(argv)
    self._txtCharge:setString(argv.isCharge == false and "兑换" or "充值")
    self._txtChargeCost:setString(tostring(argv.cost))
    self._txtChargeCount:setString(tostring(argv.chargeCount))

    self._clickHandler = argv.clickHandler

    --[[0
        虽然下面逻辑很乱，就将就着吧
    ]]
    local goldService = game.service.GoldService.getInstance()
    local grade = goldService:getlastSelectRoomGrade()
    if grade then
        local minGold = 0
        local roomName = ''
        local goldRoomInfo = goldService.dataRoomInfo.goldRooms[grade]
        -- 如果是普通场和快速场就改为金币场
        if grade == net.protocol.CGoldMatchREQ.Enum_RoomGrade.FIRST or
        grade == net.protocol.CGoldMatchREQ.Enum_RoomGrade.QUICK or
        grade == 0 then
            roomName = '金币场'
        else
            roomName = goldService:getRoomName(grade)
        end

        if goldRoomInfo then
            minGold = goldRoomInfo.minGold
        else
            minGold = goldService.dataRoomInfo.goldRooms[net.protocol.CGoldMatchREQ.Enum_RoomGrade.FIRST].minGold
        end
        self._txtChargeTitle:setString(string.format(
        "至少需要%s金币哦~",
        minGold))
        self._txtChargeContent:setString(string.format("推荐您兑换%s金币，畅玩%s！", argv.chargeCount, roomName))
    end
end

function M:onHide()
end

function M:_onBtnAbandonClick(sender)
    self:hideSelf()
end

function M:_onBtnCloseClick(sender)
    self:hideSelf()
    if game.service.GoldService.getInstance():checkIsNeedBrokeHelp() then
        UIManager:getInstance():show("UIGoldBrokeHelp")
    end
end

function M:_onBtnChargeClick(sender)
    if self._clickHandler then
        self._clickHandler()
    end
end

function M:needBlackMask() return true end

function M:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return M