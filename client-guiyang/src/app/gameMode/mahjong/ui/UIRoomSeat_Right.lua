local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Right = nil;

if config.getIs3D() then
	UIRoomSeat_Right = require("app.gameMode.mahjong.ui.UIRoomSeat_Right_3D")
else
	UIRoomSeat_Right = require("app.gameMode.mahjong.ui.UIRoomSeat_Right_2D")
end

return UIRoomSeat_Right