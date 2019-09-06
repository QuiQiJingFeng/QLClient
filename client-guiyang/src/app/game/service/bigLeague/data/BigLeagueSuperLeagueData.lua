local BigLeagueSuperLeagueData = class("BigLeagueSuperLeagueData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


function BigLeagueSuperLeagueData:ctor()
    self:init()
end

function BigLeagueSuperLeagueData:init() 
    self._leagueMember = {}   --联盟团队
    self._activeValue = 0  --贡献值
    self._teamRecord = {} --团队数据
end

function BigLeagueSuperLeagueData:setSuperLeagueData(proto)
    self._leagueMember= proto.record
    self._activeValue = proto.leagueFireScore
end

function BigLeagueSuperLeagueData:getSuperLeagueData()
    return self._leagueMember
end


function BigLeagueSuperLeagueData:getSuperLeagueActiveValue()
    return self._activeValue
end

function BigLeagueSuperLeagueData:setMatchActivityInfo(proto)
     self._teamRecord = proto.record
end

function BigLeagueSuperLeagueData:getMatchActivityInfo()
    return self._teamRecord
end

return BigLeagueSuperLeagueData