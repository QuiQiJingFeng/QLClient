local ns = namespace("game.util")

local RequestHelper = class("RequestHelper")
ns.RequestHelper = RequestHelper

-- 发起Request
-- @param req: Request
-- @return boolean
function RequestHelper.request(req)
	game.service.ConnectionService.getInstance():sendRequest(req);
end