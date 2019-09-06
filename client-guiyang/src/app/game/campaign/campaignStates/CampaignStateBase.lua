--[[
麻将牌局状态, 这个状态中处理玩家打牌逻辑
--]]

local super = require("app.manager.GameStateBase")
local CampaignStateBase = class("CampaignStateBase", super)

function CampaignStateBase:ctor(parent)
	super.ctor(self,parent)
	self._name = "CampaignStateBase"
end

function CampaignStateBase:enter()
	
end

function CampaignStateBase:exit()    

end

function CampaignStateBase:getName()
	return self._name
end

-- 获取当前是否处于比赛阶段中
function CampaignStateBase:getIsInCampaign()
	return false
end

-- 当前是否处于比赛打牌阶段
function CampaignStateBase:getIsInBattle()
	return false
end

return CampaignStateBase