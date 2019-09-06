--[[
等待中
--]]

local super = require("app.game.campaign.campaignStates.CampaignState_InCampaign")
local CampaignState_InCampaignWait = class("CampaignState_InCampaignWait",super)

function CampaignState_InCampaignWait:ctor( parent )
    super.ctor(self,parent)
    self._name = "CampaignState_InCampaignWait"
end

function CampaignState_InCampaignWait:enter()    
    super.enter(self)
end

function CampaignState_InCampaignWait:exit()
    super.exit(self)
    UIManager:getInstance():hide("UICampaignWait")
end

return CampaignState_InCampaignWait