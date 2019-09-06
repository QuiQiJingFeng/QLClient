local ns = namespace("net")

local RequestManager = class("RequestManager")
ns.RequestManager = RequestManager

-------------------------
-- 单例支持
local _instance = nil;
function RequestManager.getInstance()
	if _instance == nil then
        _instance = RequestManager:new();
    end
    return _instance;
end

-------------------------
function RequestManager:ctor()
    self._responseHandlerMap = {}   -- 消息响应者
end

-- 注册Response处理器
-- @param typeId: number
-- @param handler: IResponseHandler
-- @return boolean
function RequestManager:registerResponseHandler(typeId, responder, func)
	if self._responseHandlerMap[typeId] == nil then
		self._responseHandlerMap[typeId] = {}
	end
	
	local handlers = self._responseHandlerMap[typeId]
	for _,handler in ipairs(handlers) do
		if Macro.assetTrue(handler.responder == responder, "Duplicate handler") then
			return
		end
	end
	
	table.insert(handlers, { func = func , responder = responder });
end

-- 注销Response处理器
-- @param handler: IResponseHandler
-- @return void
function RequestManager:unregisterResponseHandler(responder)
	if not self._responseHandlerMap then return end

    for typeId, handlers in pairs(self._responseHandlerMap) do
		local removeIdx = nil
		for idx,handler in ipairs(handlers) do
			if handler.responder == responder then
				removeIdx = idx;
			end
		end
		if removeIdx ~= nil then
			table.remove(handlers, removeIdx)
		end
    end
end

-- 根据Response TypeId获取Response处理器
-- @param typeId: number
-- @return {_responder, _func}
function RequestManager:getResponseHandler(typeId)
    return self._responseHandlerMap[typeId];
end