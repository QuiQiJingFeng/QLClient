local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Left = nil;

if config.getIs3D() then
	UIRoomSeat_Left = require("app.gameMode.mahjong.ui.UIRoomSeat_Left_3D")
else
	UIRoomSeat_Left = require("app.gameMode.mahjong.ui.UIRoomSeat_Left_2D")
end

return UIRoomSeat_Left