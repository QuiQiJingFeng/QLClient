--[[
比赛中状态
--]]

local super = require("app.game.campaign.campaignStates.CampaignState_InCampaign")
local CampaignState_InCampaignBattle = class("CampaignState_InCampaignBattle",super)

function CampaignState_InCampaignBattle:ctor( parent )
    super.ctor(self,parent)
    self._name = "CampaignState_InCampaignBattle"   
end

function CampaignState_InCampaignBattle:enter()
    super.enter(self)
     local campaignService = game.service.CampaignService.getInstance()
     campaignService:dispatchEvent({name = "EVENT_CAMPAIGN_CHANGEUI"})

     UIManager:getInstance():hide("UICampaignWaitToStart")
end

function CampaignState_InCampaignBattle:exit()
    super.exit(self)
end

function CampaignState_InCampaignBattle:getIsInBattle()
    return true
end

return CampaignState_InCampaignBattle