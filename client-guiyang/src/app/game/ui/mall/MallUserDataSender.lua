
--[[
    TalkingData数据发送帮助
]]
local MallUserDataSender = {}

MallUserDataSender.ACTION_ENUM = {
    ENTERED = "Mall_Enter",
    WANTED = "Mall_ShowGood_",
    CANCEL = "Mall_CancelBuy_",
    BILL = "Mall_ShowBill",
    BILL_PAY = "Mall_ShowBill_Pay",
    BILL_INCOME = "Mall_ShowBill_Income",
    GET_POINTS_CAMPAIGN = "Mall_JumpToCampaign",
    GET_POINTS_GOLD = "Mall_JumpToGold",
}

function MallUserDataSender._send(description)
    game.service.DataEyeService.getInstance():onEvent(description)
end

function MallUserDataSender.send(description, goodId)
    Macro.assertFalse(description ~= nil)
    goodId = goodId or ""
    MallUserDataSender._send(description .. goodId)
end

return MallUserDataSender
