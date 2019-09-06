----------------------------
-- 客户端协议处理层
-- Request所有客户端发起的延迟操作基类
-- 通常用于向服务器发起的协议操作  
----------------------------
---@class Request
local Request = class("Request")

local requenstIdGenerator = 0

function Request:ctor()
    -- private static requenstIdAllocator = new KodGames.IdAllocator();

    -- number
    requenstIdGenerator = requenstIdGenerator + 1
    self._id = requenstIdGenerator;

    self._responded = false;        -- 是否已经响应了
    self._timeoutTime = nil;        -- 超时时间, 如果为nil不计超时
end

-- 获取类型Id，用于实例同类型比较
---@return number
function Request:getTypeId()
    return 0;
end

---@return string
function Request:toString()
    return string.format("TypeId:0x%x", self:getTypeId());    
end

-- Request序号，每个实例id在程序执行周期不重复
---@return number
function Request:getId()  
    return self._id;
end

-- 在等待Response返回时是否做超时处理，当HasResponse和WaitForResponse为true时有效 
---@return boolean
function Request:getTimeoutTime()
    return self._timeoutTime;
end

function Request:setTimeoutTime(time)
    Macro:assetFalse(time ~= nil)
    self._timeoutTime = time;
end


-- 标记对应的Response是否已经处理
---@return boolean
function Request:getResponded()
    return self._responded; 
end

-- @param tf: boolean
---@return void
function Request:setResponded(tf) 
	self._responded = tf; 
end

-- 是否有对应的Response
---@return boolean
function Request:getHasResponse()
    return true;
end

-- 是否需要等待对应的Response返回，当HasResponse为true时有效
-- @return boolean
function Request:getWaitForResponse()
    return true; 
end

-- 是否支持在对应Response没有返回时，重复发送，当HasResponse和WaitForResponse为true时有效 
-- @return boolean
function Request:getMutuallyExclusive() 
    return true; 
end

return Request