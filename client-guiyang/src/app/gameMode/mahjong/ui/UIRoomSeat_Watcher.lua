local Constants = require("app.gameMode.mahjong.core.Constants")

local UIRoomSeat_Watcher = nil;

if config.getIs3D() then
	UIRoomSeat_Watcher = require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher_3D")
else
	UIRoomSeat_Watcher = require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher_2D")
end

return UIRoomSeat_Watcher