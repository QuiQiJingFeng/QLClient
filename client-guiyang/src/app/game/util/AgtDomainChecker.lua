--[[
    AgtDomainChecker
    Create by: machicheng 2017-11-13

    agt 域名检查
    返回一个可用的域名或者nil

    为了提高检查效率，一次检查一组
    但是会等待第一个的有效返回
    再依次检查可用的域名，最后返回一个最靠前的域名
]]

local ns = namespace("game.util")

local AgtDomainChecker = class("AgtDomainChecker")
ns.AgtDomainChecker = AgtDomainChecker

-- 域名状态
local DOMAIN_STATUS = {
    -- 正在测试中的状态
    TESTING = 0,
    -- 可用
    AVAILABLE = 1,
    -- 不可用
    UNAVAILABLE = 2,
}

-- 检查文件
local check_url = "/mint.txt"
-- http超时时间
local HTTP_CHECK_TIMEOUT = 10

-- 单例支持
local instance = nil

-- 打印调试log支持
local _print = function() end
local _dump = function() end

function AgtDomainChecker.create(printDebugLog)
    if instance then return false end
    if printDebugLog then
        _print = release_print
        _dump = dump
    end

    instance = AgtDomainChecker.new()
    return true
end

function AgtDomainChecker.getInstance()
    return instance
end

function AgtDomainChecker:ctor()
    self._callback = nil
    self._domains = {} -- 当前检查的域名组
    self._check_index = 1 -- 当前检查的域名
    self._timeout_timer = nil
end

function AgtDomainChecker:dispose()
    self._callback = nil
    self._domains = {}
    self._check_index = 1
    if self._timeout_timer then
        unscheduleOnce(self._timeout_timer)
        self._timeout_timer = nil
    end
end

-- 清除本次的
function AgtDomainChecker:_clear()
    self._callback = nil
    self._domains = {}
    self._check_index = 1
end

local __poot = nil -- 端口号

-- 设置当前地区的端口号
function AgtDomainChecker:setPoot( poot )
    __poot = poot
end

--[[
    @desc: 通过callback返回一个可用的域名，如果都不可用返回nil
    author:{author}
    time:2017-11-13 20:29:38
    --@callback: 处理域名的回调 function(domain) xxx end
    return
]]
function AgtDomainChecker:getAvailableDomain( callback )
    -- 如果当前的poot为nil，则直接返回不可用，并向bugly报错
    if Macro.assertTrue(__poot == nil, "[AgtDomainChecker] poot is nil") then
    -- if __poot == nil then
        callback(nil)
        return
    end
    -- callback包一层，返回的时候，停止转圈
    self._callback = function ( params )
        -- 取消转圈等待
	    dispatchGlobalEvent("EVENT_BUSY_RELEASE")
        callback(params)
    end 

    -- 转圈等待
	dispatchGlobalEvent("EVENT_BUSY_RETAIN")
    self:_getDomains()
end

-- 获取域名，并开始检查
function AgtDomainChecker:_getDomains()
    -- 和clear略有不同，这里不清理callback，因为之后还要用到
    self._domains = {}
    self._check_index = 1

    -- 向webprofile请求域名组
    local domains = net.WebProfileManager.getInstance():getIPsForAGT()
    _dump(domains, "[AgtDomainChecker] getIPsForAGT")

    -- 如果返回的是nil，说明所有域名都不可用
    if domains == nil then
        self._callback(nil)
        return
    end

    self:_startCheck(domains)
end

--[[
    @desc: 检查所有域名
    author:{author}
    time:2017-11-13 21:36:28
    --@domains: 纯域名数组
    return
]]
function AgtDomainChecker:_startCheck(domains)
    for i,v in ipairs(domains) do
        -- 先把域名和状态绑定
        self._domains[i] = { domain = v, status = DOMAIN_STATUS.TESTING}
        self:_checkDomain(self._domains[i], function( d, status )
            if self._callback == nil or self:_indexOfDomain(d.domain) == -1 then
                -- 如果响应过了会清除callback和domains，那么之后的域名返回时，不响应了
                _print(string.format("[AgtDomainChecker] available domain has found, domain(%s)'s response discard", d.domain))
                return
            end
            d.status = status -- 更改这个域名的状态
            -- 调用_checkAllResponse回调，检查当前域名的status
            self:_checkAllResponse()
        end)
    end
    -- 加一个timer，确保所有域名超时会调用一次_allResponsed
    -- 理论上如果底层的超时机制好使，那么是不会用到这里的，但是以防万一
    self._timeout_timer = scheduleOnce(function()
        -- 把所有testing的状态标记为unavailable
        for i,v in ipairs(self._domains) do
            if v.status == DOMAIN_STATUS.TESTING then
                _print(string.format("[AgtDomainChecker] this domain(%s) is testing when all timeout", v.domain))
                v.status = DOMAIN_STATUS.UNAVAILABLE
            end
        end

        self:_allResponsed()
    end, HTTP_CHECK_TIMEOUT + 0.1, false)
end

--[[
    @desc: 检查某个域名
    author:{author}
    time:2017-11-13 21:33:15
    --@d: 域名及状态
	--@callback: http回调
    return
]]
function AgtDomainChecker:_checkDomain( d, callback )
    -- 利用http get该域名下的某个文件，如果文件可用被get，则这个域名可用
    kod.util.Http.sendRequest("http://" .. d.domain .. ":" .. __poot .. check_url, {}, function(response, readyState, status)
        _print(string.format("[AgtDomainChecker] the domain = %s responsed, and status = %s", d.domain, status))
        if status == 200 then
            callback(d, DOMAIN_STATUS.AVAILABLE)
        else
            -- 其他一律算不可用
            callback(d, DOMAIN_STATUS.UNAVAILABLE)
        end
    end, "GET", nil, HTTP_CHECK_TIMEOUT)
end

--[[
    @desc: 每个http response后的回调
    author:{author}
    time:2017-11-14 11:12:47
    return
]]
function AgtDomainChecker:_checkAllResponse()
    -- 如果已经检查完了最后一个，那么调用_allResponsed(基本gg，可以下一组了)
    if self._check_index > #self._domains then
        self:_allResponsed()
        return
    end

    _print(string.format("[AgtDomainChecker] current check index = %s", self._check_index))

    local first_status = self._domains[self._check_index].status
    if first_status == DOMAIN_STATUS.AVAILABLE then
        -- 如果当前的成功就不用看之后的了
        self:_allResponsed()
    elseif first_status == DOMAIN_STATUS.TESTING then
        -- 如果当前还在测试中，就啥也不干，等待返回
    else
        -- 出错了
        self._check_index = self._check_index + 1
        self:_checkAllResponse()
    end
end

--[[
    @desc: 所有域名响应后的回调
    author:{author}
    time:2017-11-13 21:32:21
    return
]]
function AgtDomainChecker:_allResponsed()
    -- 已经提前响应了，那么取消掉超时timer
    if self._timeout_timer then
        unscheduleOnce(self._timeout_timer)
        self._timeout_timer = nil
    end

    _dump(self._domains, "[AgtDomainChecker] all domain when all responsed")

    local unavailable_list = {} -- 不可用列表
    local available = nil -- 可用的域名
    for i,d in ipairs(self._domains) do
        -- 顺序检查每个域名是否可用
        if d.status == DOMAIN_STATUS.AVAILABLE then
            -- 如果有可用的，则标记可用
            available = d.domain
            break
        else
            -- 如果为不可用，则放入不可用的列表里
            -- 因为一定是等到第一个返回后才去查，所以此时除非有可用的，其他的状态(testing)，也会被标记为不可用
            -- 并且在发现某一个可用后，之后的无论是否真正可用都不会被标记
            table.insert( unavailable_list, d.domain )
        end
    end

    -- 先把不可用的传给webprofile
    _dump(unavailable_list, "[AgtDomainChecker] the unavailable domains to webprofile")
    net.WebProfileManager.getInstance():markInvalidAGT(unavailable_list)

    -- 判断这一组里是否有可用的
    if available ~= nil then
        -- 有，调用callback返回可用agt域名，并清理
        _print(string.format("[AgtDomainChecker] the available domain = %s!", available))
        self._callback(available)
        self:_clear()
    else
        -- 否则，重新想webprofile请求新的域名组
        self:_getDomains()
    end
end

-- 找到域名的index
function AgtDomainChecker:_indexOfDomain(domain)
    return table.indexofcmp(self._domains, domain, 1, function(d, _d)
        return d.domain == _d
    end)
end

--[[
    @desc: table indexof 的扩展，添加了cmp比较方法
    author:{machicheng}
    time:2017-11-14 15:53:30
    --@array: table
	--@value: 值
	--@begin: 开始值
	--@cmp: 比较方法
    return
]]
function table.indexofcmp(array, value, begin, cmp)
    for i = begin or 1, #array do
        if cmp(array[i], value) then return i end
    end
    return -1
end