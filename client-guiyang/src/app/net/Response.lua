---@class Response
local Response = class("Response")

----------------------------
-- 客户端协议处理层
-- Response所有客户端收到的延迟操作基类
-- 通常用于从服务器收到的协议操作  
-- 使用requestId对应发起的Request
----------------------------
function Response:ctor()
    self._request = nil;
end

---@return string
function Response:toString()
    return string.format("TypeId: 0x%x", self:getTypeId());
end

---@return number
function Response:getTypeId()
    return 0;
end

-- 对应发起Request的Id
---@return number
function Response:getRequestId()
    return 0;
end

---@param request Request
function Response:setRequest(request)
    self._request = request;
end

---@return Request
function Response:getRequest()	
    return self._request;
end

return Response