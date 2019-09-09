local PlayerData = class("PlayerData")

local _instance = nil
function PlayerData:getInstance()
	if not _instance then
		_instance = PlayerData.new()
	end
	return _instance
end

function PlayerData:clear()

end

function PlayerData:ctor()
 
end

function PlayerData:initPlayerData()

end

return PlayerData