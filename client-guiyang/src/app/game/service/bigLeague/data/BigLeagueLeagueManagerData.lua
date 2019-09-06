local BigLeagueLeagueManagerData = class("BigLeagueLeagueManagerData")
local ClubConstant = require("app.game.service.club.data.ClubConstant")


function BigLeagueLeagueManagerData:ctor()
    self:init()
end

function BigLeagueLeagueManagerData:init() 
    self._memberList = {}   --联盟团队
    self._activeValue = 0  --贡献值
end

function BigLeagueLeagueManagerData:setLeagueManagerMemberData(proto)
    self._memberList= proto.record
    self._activeValue = proto.clubFireScore
end

function BigLeagueLeagueManagerData:getLeagueManagerMemberData()
    return self._memberList
end


function BigLeagueLeagueManagerData:getLeagueManagerActiveValue()
    return self._activeValue
end


return BigLeagueLeagueManagerData