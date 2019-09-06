-------------------------------------------------
-- 玩家比赛缓存数据
local LocalStorageCampaignData = class("LocalStorageCampaignData")
function LocalStorageCampaignData:ctor()
    self._campaignShareList = {}  -- 玩家比赛分享数据
    self._notPopCampaignGuide = false  -- 弹出新手教程
end

-- 比赛玩家分享list
function LocalStorageCampaignData:addCampaignShareListItem( campaignId )
    table.insert( self._campaignShareList, campaignId )
end

function LocalStorageCampaignData:getCampaignShareStatus( campaignId )
    for i, data in ipairs(self._campaignShareList) do
        if data == campaignId then
            return true
        end
    end
    return false    
end

function LocalStorageCampaignData:setNotPopCampaignGuide( popOrNotPop)
    self._notPopCampaignGuide = popOrNotPop
end

function LocalStorageCampaignData:getNotPopCampaignGuide( )
    return self._notPopCampaignGuide  
end

return LocalStorageCampaignData