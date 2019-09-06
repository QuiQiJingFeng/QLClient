--[[
    CampaignUtils
    Create by: heyi 2018/06/14

    比赛的一些需要使用的工具方法 提出来

    使得在使用相关功能时可以使用该工具，避免过多的冗余代码
]]

local ns = namespace("game.util")

local CampaignUtils = class("CampaignUtils")
ns.CampaignUtils = CampaignUtils

-- 从cost中获取最优先消耗的道具key
function CampaignUtils.getPriorityFeeKey(costs)
    -- 取出优先级最高的
    table.sort(costs, function (a,b)
        return a.key > b.key
    end)

    return costs[1].key
end

--------------------------------------------------------------------------------
--                                拦截类方法                                   --
--------------------------------------------------------------------------------
-- 若已报名比赛创建房间则弹窗 返回true则要先退赛才能继续操作
function CampaignUtils.forbidenMsgWhenJoinRoom(isSwitchArea)
    local campaignService = game.service.CampaignService.getInstance()
    if campaignService == nil then return false end

    if campaign.CampaignFSM.getInstance():isState("CampaignState_SignUp") then
        local str = "您当前已报名比赛，不能加入其它牌局，您可以选择退赛后加入其它牌局"
        if isSwitchArea == true then
            str = "您当前已报名比赛，不能切换地区，您可以选择退赛后加入其它牌局"
        end
        game.ui.UIMessageBoxMgr.getInstance():show(str, {"退赛","取消"},function()
		    --退赛
		    campaignService:sendCCASignUpCancelREQ(campaignService:getCampaignList():getCurrentCampaignId())
	    end,function ()
            return
        end,
        true)
        return true    
    else
        return CampaignUtils.forbidenMsgMtt()
    end
end

-- MTT比赛处理
function CampaignUtils.forbidenMsgMtt()
    local campaignService = game.service.CampaignService.getInstance()
    if campaignService == nil then return false end

    local startDuration = 0
    if campaignService:getCampaignList():getMttStartTime() ~= 0 then
        startDuration = campaignService:getCampaignList():getMttStartTime() - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    end
    -- mtt开赛3-15分钟
    if startDuration < 900000 and startDuration > 180000 then
        game.ui.UIMessageBoxMgr.getInstance():show("比赛将于".. os.date("%X", campaignService:getCampaignList():getMttStartTime() / 1000) .."开始",{"确定"})
        return false
    -- mtt开赛3分钟内
    elseif startDuration < 180000 and 0 < startDuration then
        campaignService:sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.STOP_WATCH_CAMPAIGN_LIST)
        game.ui.UIMessageBoxMgr.getInstance():show("比赛即将开始，您可以选择退赛后加入其它牌局", {"退赛","取消"},function()
		    --退赛
            campaignService:sendCCASignUpCancelREQ(campaignService:getCampaignList():getCurrentCampaignId())
        end,function ()
        end,
        true)
        return true
    end
    return false
end

return CampaignUtils