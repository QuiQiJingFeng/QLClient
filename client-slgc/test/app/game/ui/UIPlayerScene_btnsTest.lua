local super = require("core.TestCaseBase")
local cases = {}

cases["example! hide btn Test"] = function ()
    if UIManager:getInstance():getIsShowing("UIPlayerScene_btns") == false then
        return false
    end
    local roomService = game.service.RoomService.getInstance();
	local uiName = "UIPlayerScene_btns";
	if game.service.LocalPlayerService:getInstance():isWatcher() then
		 uiName = "UIPlayerScene_watch_btns";
	end
    UIManager:getInstance():hide(uiName)
end

cases["example! show btn Test"] = function ()
    local roomService = game.service.RoomService.getInstance();
	local uiName = "UIPlayerScene_btns";
	if game.service.LocalPlayerService:getInstance():isWatcher() then
		 uiName = "UIPlayerScene_watch_btns";
	end
    UIManager:getInstance():show(uiName, roomService:isRTVoiceRoom());
end

local UIPlayerScene_btnsTest = class("UIPlayerScene_btnsTest", super)

function UIPlayerScene_btnsTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UIPlayerScene_btnsTest

