-- 比赛场晋级页面测试用例
local super = require("core.TestCaseBase")
local cases = {}

cases["左侧tab假数据"] = function ()
    local ui = UIManager:getInstance():getUI("UICampaignMain")
    local list = ui._elemCampaignList._reusedCampaignTab
    local tabs = {
        [1] = {index = 1,text = "第1个tab"},
        [2] = {index = 2,text = "第2个tab"},
        [3] = {index = 3,text = "第3个tab"},
    }

    for i,v in ipairs(tabs) do
        list:pushBackItem(v)
    end

    scheduleOnce(function()
        UIManager:getInstance():show("UICampaignGuide", {target = ui._elemCampaignList._reusedCampaignTab, swallow = true})
    end,0)
end

cases["收到比赛list"] = function ()
    local event = {}
    event = {
        result = net.ProtocolCode.CAC_FOCUS_ON_CAMPAIGN_LIST_SUCCESS,
        campaignList = {
            campaignList = {
                {
                    configId       = 2,
                    cost = {},
                    freeTimes      = 0,
                    id             = 268435455,
                    image          = 10001,
                    instructions   = "1.60名玩家将进行6轮瑞士移位比赛",
                    isMtt          = false,
                    maxPlayerCount = 60,
                    name           = "快速房卡赛",
                    playerCount    = 121,
                    rewardList = {
                    },
                    shareFree      = 0,
                    signUp         = false,
                    sort           = 3,
                    status         = 0,
                    type           = 1,
                    startTime = 0,
                    endTime = 1000,
                    enterTime = 500,
                    tab = 1,
                },
                {
                    configId       = 1,
                    cost = {},
                    freeTimes      = 0,
                    id             = 268435454,
                    image          = 10001,
                    instructions   = "1.60名玩家将进行6轮瑞士移位比赛",
                    isMtt          = false,
                    maxPlayerCount = 60,
                    name           = "慢速房卡赛",
                    playerCount    = 121,
                    rewardList = {
                    },
                    shareFree      = 0,
                    signUp         = false,
                    sort           = 3,
                    status         = 0,
                    type           = 1,
                    startTime = 0,
                    endTime = 1000,
                    enterTime = 500,
                    tab = 2,
                },
                {
                    configId       = 4,
                    cost = {},
                    freeTimes      = 0,
                    id             = 268435452,
                    image          = 10001,
                    instructions   = "1.60名玩家将进行6轮瑞士移位比赛",
                    isMtt          = false,
                    maxPlayerCount = 60,
                    name           = "中速房卡赛",
                    playerCount    = 121,
                    rewardList = {
                    },
                    shareFree      = 0,
                    signUp         = false,
                    sort           = 3,
                    status         = 0,
                    type           = 1,
                    startTime = 0,
                    endTime = 1000,
                    enterTime = 500,
                    tab = 3,
                },
            },
            signUpInfoList = {},
        },
        receiveFlag = false,
        tabInfo = {
            [1] = {key = 1,name = "领取红包"},
            [2] = {key = 2,name = "赚取房卡"},
            [3] = {key = 3,name = "超强福利"},
        }
    }
    
    local resPack = net.protocol.CACFocusOnCampaignListRES.new()
    resPack._protocolBuf = event
    local response = net.NetworkResponse.new(resPack)

    local service = game.service.CampaignService:getInstance()
    service:onCACFocusOnCampaignListRES(response);
end

local UICampaignMainTest = class("UICampaignMainTest", super)

function UICampaignMainTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UICampaignMainTest