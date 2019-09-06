local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Down = nil;

if config.getIs3D() then
	UIRoomSeat_Down = require("app.gameMode.mahjong.ui.UIRoomSeat_Down_3D")
else
	UIRoomSeat_Down = require("app.gameMode.mahjong.ui.UIRoomSeat_Down_2D")
end

return UIRoomSeat_Down