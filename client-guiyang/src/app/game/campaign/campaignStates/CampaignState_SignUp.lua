--[[
比赛报名了未比赛的状态
--]]

local super = require("app.game.campaign.campaignStates.CampaignStateBase")
local CampaignState_SignUp = class("CampaignState_SignUp",super)

function CampaignState_SignUp:ctor( parent )
    super.ctor(self,parent)
    self._name = "CampaignState_SignUp"
end

function CampaignState_SignUp:enter()
    super.enter(self)
end

function CampaignState_SignUp:exit()
    super.exit(self)
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
end
return CampaignState_SignUp