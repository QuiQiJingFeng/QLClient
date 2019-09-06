-------------------------------------------------
-- 玩家比赛状态数据
local CampaignData = class("CampaignData")
function CampaignData:ctor()
    self._rank = 0                                              -- 当前玩家排名
    self._round = 0                                             -- 当前轮次
    self._multiple = 0                                          -- 当前倍数
    self._playerCount = 0                                       -- 剩余玩家数量
    self._nextPlayerCount = 0                                   -- 本轮可晋级玩家数量
    self._totalPoint = 0                                        -- 当前玩家总分
    self._roomCount = 0                                         -- 当前剩余房间数量
    self._thisPlayerCount = 0                                   -- 当前比赛最大人数
    self._daliFlag = config.CampaignConfig.DaLiFlag.UNKNOW      -- 当前是否打立赛     
    self._campaignName = ""               
end

function CampaignData:getRank() 				    return self._rank; end
function CampaignData:setRank(value) 			    self._rank = value; end
function CampaignData:getRound() 				    return self._round; end
function CampaignData:setRound(value) 			    self._round = value; end
function CampaignData:getPlayerCount() 			    return self._playerCount; end
function CampaignData:setPlayerCount(value) 	    self._playerCount = value; end
function CampaignData:getNextPlayerCount() 		    return self._nextPlayerCount; end
function CampaignData:setNextPlayerCount(value)    self._nextPlayerCount = value; end
function CampaignData:getTotalPoint() 				return self._totalPoint; end
function CampaignData:setTotalPoint(value) 			self._totalPoint = value; end
function CampaignData:getRoomCount() 				return self._roomCount; end
function CampaignData:setRoomCount(value) 			self._roomCount = value; end
function CampaignData:getThisPlayerCount() 			return self._thisPlayerCount; end
function CampaignData:setThisPlayerCount(value) 	self._thisPlayerCount = value; end
function CampaignData:getDaLiFlag() 			    return self._daliFlag; end
function CampaignData:setMultiple(value) 	        self._multiple = value; end
function CampaignData:getMultiple() 			    return self._multiple; end
function CampaignData:getCampaignName()             return self._campaignName   end
function CampaignData:setCampaignName(value)        self._campaignName = value  end

-- 打立赛标签
function CampaignData:setDaLiFlag(value) 	
    if value == false then        
        self._daliFlag = 0; 
    else
        self._daliFlag = 1; 
    end
end

--重置数据
function CampaignData:resetData()
    self._rank = 0                                              -- 当前玩家排名
    self._round = 0                                             -- 当前轮次
    self._multiple = 0                                          -- 当前倍数    
    self._playerCount = 0                                       -- 剩余玩家数量
    self._nextPlayerCount = 0                                   -- 本轮可晋级玩家数量
    self._totalPoint = 0                                        -- 当前玩家总分
    self._roomCount = 0                                         -- 当前剩余房间数量
    self._thisPlayerCount = 0                                   -- 当前比赛最大人数
    self._daliFlag = config.CampaignConfig.DaLiFlag.UNKNOW      -- 当前是否打立赛
end

-- 整体修改数据 如果如果没有则不修改
function CampaignData:updateData( rank, round, multiple, playerCount, nextPC, totalPoint, roomCount, thisPC, daliFlag)
    self._rank = rank
    self._round = round
    self._multiple = multiple
    self._playerCount = playerCount
    self._nextPlayerCount = nextPC
    self._totalPoint = totalPoint
    self._roomCount = roomCount
    self._thisPlayerCount = thisPC
    self:setDaLiFlag(daliFlag)
end

return CampaignData