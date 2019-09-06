-- ui 组件基类
local UIComponent = class("UIComponent")
function UIComponent:ctor()
end

function UIComponent:dispose()
end

-- 检查事件是否响应
function UIComponent:_eventFilter()
    return true
end

-- 事件注册容器调用
function UIComponent:getEvents()
    local events = self:_getEvents()
    local ret = {}
    -- 包一层检查，上层不用关心是否是自己，调得到的一定是自己
    for k, v in pairs(events) do
        ret[k] = function(e)
            if self:_eventFilter() then
                v(self, e)
            end
        end 
    end
    return ret
end

-- 事件注册子类实现
function UIComponent:_getEvents()
    return {
    }
end

return UIComponent