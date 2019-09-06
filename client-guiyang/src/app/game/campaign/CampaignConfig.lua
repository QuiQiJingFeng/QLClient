local ns = namespace("config")

local CampaignConfig = class("CampaignConfig")

ns.CampaignConfig = CampaignConfig

-- 比赛对应的图标配置
local CAMPAIGN_ICON = {
    [10001] = "art/campaign/campaignIcon/campaignIcon01.png",
    [10002] = "art/campaign/campaignIcon/campaignIcon02.png",
    [10003] = "art/campaign/campaignIcon/campaignIcon03.png",
    [10004] = "art/campaign/campaignIcon/campaignIcon04.png",
    [10005] = "art/campaign/campaignIcon/campaignIcon05.png",
    [10006] = "art/campaign/campaignIcon/campaignIcon06.png",
    [10007] = "art/campaign/campaignIcon/campaignIcon07.png",
    -- 默认id
    [0] = "art/club/imgt_3.png",
}

-- 比赛内的一些动画
CampaignConfig.CampaignAnim = {
    -- 比赛即将开始
    ["READY"] = "ui/csb/Campaign/anim/CampaignReady.csb",
    -- 比赛开始
    ["START"] = "ui/csb/Campaign/anim/CampaignStart2.csb",
    -- 比赛晋级
    ["PROMOTION"] = "ui/csb/Campaign/anim/PromotionAnim.csb",
    -- 晋级决赛卓
    ["FINALCAMPAIGN"] = "ui/csb/Campaign/anim/FinalCampaign.csb",
    -- 晋级决赛卓2
    ["FINALCAMPAIGN2"] = "ui/csb/Campaign/anim/FinalCampaign2.csb",
    -- 晋级奖励圈
    ["PROMOTREWARD"] = "ui/csb/Campaign/anim/PromotionReward.csb",

    --奖状相关动画
    ["NOREWARD"] = "ui/csb/Campaign/anim/medal/ContinueTheExert.csb",
    ["SOMEREWARD"] = "ui/csb/Campaign/anim/medal/ResultOfGoodJob.csb",
    ["1STREWARD"] = "ui/csb/Campaign/anim/medal/champion.csb",
    ["2NDREWARD"] = "ui/csb/Campaign/anim/medal/secondPlace.csb",
    ["3RDREWARD"] = "ui/csb/Campaign/anim/medal/thirdPlace.csb",

    -- 新手教程手指动画
    ["FingerTouch"] = "ui/csb/Campaign/anim/FingerTouchAnim.csb",
}

-- 比赛分享用的图片
CampaignConfig.ShareImagePath = "art/campaign/campaignIcon/activity3.jpg"

-- 分享免费标识
CampaignConfig.ShareFreeType = {
    OFF = 0,
    ON = 1
}

-- 打立赛标识
CampaignConfig.DaLiFlag = {
    UNKNOW = -1,
    FALSE = 0,
    TRUE = 1
}

-- arena比赛的固定id
CampaignConfig.ARENA_ID = 0x0fffffff

--[[-- 比赛玩家状态常量
-- 同步于服务器的 PlayerStatus
--]]
CampaignConfig.CampaignPlayerStatus = {
    SIGN_UP         = 0 , -- 报名
    WAITING         = 1 , -- 等待
    PLAYING         = 2 , -- 比赛中
    EXIT            = 3 , -- 淘汰
    STOP            = 4 , -- 比赛终止
    START           = 5 , -- 开始
    MATCHING        = 6 , -- 匹配中
}

--[[-- 比赛状态常量
-- 同步于服务器的 CampaignStatus
--]]
CampaignConfig.CampaignStatus = {
    SIGN_UP         = 0 , -- 报名
    ONGOING         = 1 , -- 比赛中 
    END             = 2 , -- 比赛结束
    STOP            = 3 , -- 比赛中止
    BEFORE          = 4 , -- 未开启
    AFTER           = 5 , -- 已关闭

    HASSIGNUP       = 11, -- 已经参加过了 客户端自己增加的一个状态
}

--[[-- 比赛状态常量
-- 同步于服务器的 CampaignStatus
--]]
CampaignConfig.FeeIconMap = {
    [0x0F000002] = "art/campaign/campaignIcon/small_card.png",
    [0x0F000007] = "art/campaign/campaignIcon/small_ticket.png",
    [0x0F000001] = "art/campaign/campaignIcon/small_bean.png",
    [0x01000001] = "art/campaign/campaignIcon/small_mp50.png",
    [0x01000002] = "art/campaign/campaignIcon/small_mp25.png",
}


-- 获取当前比赛对应的图标配置
CampaignConfig.getIconConfig = function(id)
    if CAMPAIGN_ICON[id] ~= nil then
        return CAMPAIGN_ICON[id]
    else
        return CAMPAIGN_ICON[0]
    end
end