--[[
    local storage 里存的基础数据，目前只用来做版本判断和提升版本
]]
local BaseLocalData = class("BaseLocalData")

function BaseLocalData:ctor()
    -- 数据的版本号
    self.__ver = 0
end

-- 检查ver
function BaseLocalData:checkVer(ver)
    return ver - self.__ver
end

--[[
    @desc: 升级
            注意只升级一个版本
    author:{author}
    time:2018-08-08 18:29:38
    --@args: 
    @return:
]]
function BaseLocalData:upgrade()
    -- need implement
end

function BaseLocalData:clear()
    -- need implement
end

return BaseLocalData