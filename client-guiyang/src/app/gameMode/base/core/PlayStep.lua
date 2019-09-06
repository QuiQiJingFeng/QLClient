local PlayStep = class("PlayStep")

-- @param id: number
-- @param name: string
-- @param headIconUrl: string
-- @param position: number
-- @param ip: string
-- @param sex: number
-- @param seat: CardDefines.Chair
function PlayStep:ctor()
	self._roleId = 0;
    self._playType = 0;		-- 一个操作由2个bit表示，第一个bit标识是否有这个操作，第二个bit标识这个操作是否完成
    self._pointInGame= 0; 	-- 当前局得分
    self._sourceRoleId = 0
    self._cards = {};		-- 当前step打出的牌
    self._scoreData = nil; 	-- net.core.protocol.ResultScoreData;
    self._result = nil;		-- net.core.protocol.BCMatchResultSYN;
end

function PlayStep:getRoleId() return self._roleId; end
function PlayStep:getPlayType() return self._playType; end
function PlayStep:getPointInGame() return self._pointInGame; end
function PlayStep:getCards() return self._cards; end
function PlayStep:getSourceRoleId() return self._sourceRoleId; end
function PlayStep:getScoreData() return self._scoreData end
function PlayStep:getResult() return self._result end
function PlayStep:getDatas() 
    return self._datas 
end

-- @param protocol: net.core.protocol.PlayStepPROTO
-- @return PlayStep
function PlayStep:setProto(protocol)
    self._roleId = protocol.roleId;
    self._pointInGame = protocol.pointInGame;
    self._playType = protocol.playType;
    self._sourceRoleId = protocol.sourceRoleId;
    self._datas = protocol.datas
	for i=1,#protocol.cards do
		local cardValue = string.byte(protocol.cards, i)
		table.insert(self._cards, cardValue)
	end
   self._scoreData = protocol.scoreData;
   self._result = nil;

    return self;
end

return PlayStep;