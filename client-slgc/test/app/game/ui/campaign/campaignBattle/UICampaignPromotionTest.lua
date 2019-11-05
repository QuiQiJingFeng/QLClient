-- 比赛场晋级页面测试用例
local super = require("core.TestCaseBase")
local cases = {}

cases["添加arena当前晋级数据"] = function ()
    local event = {}
    event = {
        rounds = {
            {
                playerCount = 90,
                count = 1
            },
            {
                playerCount = 60,
                count = 2
            },
            {
                playerCount = 20,
                count = 3
            },
            {
                playerCount = 12,
                count = 4
            },
            {
                playerCount = 6,
                count = 5
            },
            {
                playerCount = 6, 
                count = 6
            },
            {
                playerCount = 6,
                count = 7
            },
            {
                playerCount = 6,
                count = 8
            },
            {
                playerCount = 6,
                count = 9
            }
        },
        round = 3,
        status = 6,
        rewards = {
            {item = {count = 20, id = 0x0F000002},rank = 90}
        },
        rank = 90,
        configId = 2,
        name = "一亿元红包赛"
    }
    
    local resPack = net.protocol.CACArenaInfoRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    game.service.CampaignService.getInstance():getArenaService():onCACArenaInfoRES(response);
end

cases["destroy"] = function ()
    UIManager:getInstance():destroy("UICampaignPromotion")
end

local UICampaignPromotionTest = class("UICampaignPromotionTest", super)

function UICampaignPromotionTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UICampaignPromotionTest