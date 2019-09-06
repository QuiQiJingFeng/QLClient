--[[
比赛没有报名的状态
--]]

local super = require("app.game.campaign.campaignStates.CampaignStateBase")
local CampaignState_NotSignUp = class("CampaignState_NotSignUp",super)

function CampaignState_NotSignUp:ctor( parent )
    super.ctor(self,parent)
    self._name = "CampaignState_NotSignUp"
end

function CampaignState_NotSignUp:enter()
    super.enter(self)
    local campaignService = game.service.CampaignService.getInstance()
    campaignService:getCampaignList():setCurrentCampaignId(0)
end

function CampaignState_NotSignUp:exit()
    super.exit(self)
end

return CampaignState_NotSignUp