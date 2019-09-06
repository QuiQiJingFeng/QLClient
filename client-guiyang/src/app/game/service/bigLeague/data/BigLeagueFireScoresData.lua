local BigLeagueFireScoresData = class("BigLeagueFireScoresData")
function BigLeagueFireScoresData:ctor()
    self:init()
end

function BigLeagueFireScoresData:init() 
    self._gameplays = {lotteryProperty ={}}  
    self._playerCount = 0 

end

function BigLeagueFireScoresData:setClubFireScores(proto)
    local t = {}
    -- self._gameplays = {lotteryProperty ={}}  
    for i, gameplay in pairs(proto.gameplays) do 
        local id = gameplay.id
        local playCount = gameplay.playCount
        local name = gameplay.name
        local lotteryProperty = gameplay.lotteryProperty

        -- if lotteryProperty == nil or #lotteryProperty == 0 then 
        --     return
        -- end 
        
        for j, property in pairs(lotteryProperty) do 
            property.id = id 
            property.name = name 
            property.playCount = playCount 
            table.insert( t, property)
        end 
    end
    self._gameplays.lotteryProperty = t
end

function BigLeagueFireScoresData:getClubFireScores()
    return self._gameplays.lotteryProperty
end
return BigLeagueFireScoresData