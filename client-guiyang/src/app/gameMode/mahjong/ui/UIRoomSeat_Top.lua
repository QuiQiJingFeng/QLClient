local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Top = nil;

if config.getIs3D() then
	UIRoomSeat_Top = require("app.gameMode.mahjong.ui.UIRoomSeat_Top_3D")
else
	UIRoomSeat_Top = require("app.gameMode.mahjong.ui.UIRoomSeat_Top_2D")
end

return UIRoomSeat_Top