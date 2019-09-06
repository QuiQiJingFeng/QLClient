--[[
比赛状态基类

TODO: 将比赛状态转为由状态机控制
--]]

local super = require("app.game.campaign.campaignStates.CampaignStateBase")
local CampaignState_InCampaign = class("CampaignState_InCampaign",super)

function CampaignState_InCampaign:ctor( parent )
    super.ctor(self,parent)
    self._name = "CampaignState_InCampaign"
    self._isArena = false
end

function CampaignState_InCampaign:enter()
    super.enter(self)
end

function CampaignState_InCampaign:exit()
    super.exit(self)
end

-- 获取当前是否处于比赛中
function CampaignState_InCampaign:getIsInCampaign()
	return true
end

return CampaignState_InCampaign