local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat = nil;

if config.getIs3D() then
	UIRoomSeat = require("app.gameMode.mahjong.ui.UIRoomSeat_3D")
else
	UIRoomSeat = require("app.gameMode.mahjong.ui.UIRoomSeat_2D")
end

return UIRoomSeat