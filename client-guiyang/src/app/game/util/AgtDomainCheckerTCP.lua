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

local SocketTCP = require("app.net.core.SocketTCP")

-- 域名状态
local DOMAIN_STATUS = {
    -- 正在测试中的状态
    TESTING = 0,
    -- 可用
    AVAILABLE = 1,
    -- 不可用
    UNAVAILABLE = 2,
}

-- 测试连接的错误码
local CONNECT_STATUS = {
    CONNECT_SUCCESSED = "200", -- http成功为200
    CONNECT_FAILED = "0",
}

-- tcp超时时间
local TCP_CHECK_TIMEOUT = 5
-- dns解析超时
local RESOLVING_TIMEOUT = 5

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
end

function AgtDomainChecker:dispose()
    self._callback = nil
    self._domains = {}
    self._check_index = 1
end

-- 清除本次的
function AgtDomainChecker:_clear()
    self._callback = nil
    self._domains = {}
    self._check_index = 1
end

local __port = nil -- 端口号

-- 设置当前地区的端口号
function AgtDomainChecker:setPoot( poot )
    __port = poot
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
    if Macro.assertTrue(__port == nil, "[AgtDomainChecker] poot is nil") then
    -- if __port == nil then
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

    -- 检查是否为第三层，如果是，则不检测了，直接使用
    if self:_isTier3(domains) then
        return
    end

    self:_startCheck(domains)
end

-- 如果是tier3，不检查了，直接用！
function AgtDomainChecker:_isTier3( domains )
    local tier3 = config.GlobalConfig.AGT_FALLBACK_TIER3
    if domains[1] == tier3 then
        -- 如果是第三层，先标记不可用
        net.WebProfileManager.getInstance():markInvalidAGT(domains)
        -- 再获取一次，这样下次正常取的时候又从头开始，运维不希望所有人都堆到第三层
        net.WebProfileManager.getInstance():getIPsForAGT()
        -- 最后通知上层可用连接为第三层
        _print(string.format("[AgtDomainChecker] the available domain = %s!", tier3))
        self._callback(tier3)
        self:_clear()
        return true
    end
    return false
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
end

--[[
    @desc: 检查某个域名
    author:{author}
    time:2017-11-13 21:33:15
    --@d: 域名及状态
	--@callback: 回调
    return
]]
function AgtDomainChecker:_checkDomain( d, callback )
    -- 利用tcp去连接某个域名(或ip)，能连通则说明可用
    if self._isIPv4(d.domain) then
        -- 是ip地址
        self._connectIp(true, d.domain, d, callback, TCP_CHECK_TIMEOUT)
    else 
        -- 非ipv4地址
        self:_resolveHostAsync(d.domain, function(addrInfos) -- onSucceed
            local newhostipv4 = {}
            local newhostipv6 = {}
			for _, addrinfo in ipairs(addrInfos) do
				if addrinfo.family == "inet" then
					table.insert(newhostipv4, addrinfo.addr)
				elseif addrinfo.family == "inet6" then
					table.insert(newhostipv6, addrinfo.addr)
				end
			end
			local ipstacktype = loho.detectLocalIPStack()
			local connect_addr, connect_family_isipv4
			if (ipstacktype == net.LocalIPStack.IPv4 or ipstacktype == net.LocalIPStack.Dual) and #(newhostipv4) > 0 then
				-- 双栈环境优先使用ipv4连接
				connect_addr = newhostipv4[1]
				connect_family_isipv4 = true
			elseif (ipstacktype == net.LocalIPStack.IPv6 or ipstacktype == net.LocalIPStack.Dual) and #(newhostipv6) > 0 then
				connect_addr = newhostipv6[1]
				connect_family_isipv4 = false
			end
			if connect_addr then
                self._connectIp(connect_family_isipv4, connect_addr, d, callback, TCP_CHECK_TIMEOUT)
			else
				_print("[AgtDomainChecker] no ip resolved")
                _printConnectionLog(d, "no ip resolved")
                callback(d, DOMAIN_STATUS.UNAVAILABLE)
			end			
		end, function(err) -- onFailed					
			_print(string.format("[AgtDomainChecker] resolving host error: %s", err))
            _printConnectionLog(d, err)
            callback(d, DOMAIN_STATUS.UNAVAILABLE)
		end, RESOLVING_TIMEOUT)
    end
end

-- 输出和测试文件相同的log格式，保持兼容性
local _printConnectionLog = function( d, status )
    _print(string.format("[AgtDomainChecker] the domain = %s responsed, and status = %s", d.domain, status))
end

--[[
    @desc: 连接某个ip地址
    author:{author}
    time:2017-12-13 20:56:01
    --@d: domain对象
	--@callback: 成功失败回调
	--@timeout:  超时时间
    return
]]
function AgtDomainChecker._connectIp(isipv4, ip, d, callback, timeout)
    local socket = SocketTCP.new()
    socket:setConnectionCreatedCallback(function()
        _print(string.format("[AgtDomainChecker] domian %s : connection %s:%d created", d.domain, ip, __port))
        _printConnectionLog(d, CONNECT_STATUS.CONNECT_SUCCESSED)
        callback(d, DOMAIN_STATUS.AVAILABLE)
        socket:close()
    end)
    socket:setConnectionFailedCallback(function()
        _print(string.format("[AgtDomainChecker] domian %s : connection %s:%d failed", d.domain, ip, __port))
        _printConnectionLog(d, CONNECT_STATUS.CONNECT_FAILED)
        callback(d, DOMAIN_STATUS.UNAVAILABLE)
        socket:close()
    end)

    socket:connect(isipv4, ip, __port, timeout)
end

--[[
    @desc: dns解析某个域名
    author:{author}
    time:2017-12-13 21:05:42
    --@host: 域名
	--@onSucceed: 解析成功的回调
	--@onFailed: 解析失败的回调
	--@timeout: 解析超时时间
    return
]]
function AgtDomainChecker:_resolveHostAsync(host, onSucceed, onFailed, timeout)
	local timer = scheduleOnce(function()
		onFailed("timeout")
	end, timeout)
	loho.getAddrInfoAsync(host, function(addrinfo, err)
        unscheduleOnce(timer) -- 取消
        if err then
            onFailed(err)
		elseif addrinfo == nil or #addrinfo == 0 then
			onFailed("no records")
		else
			onSucceed(addrinfo)
		end
	end)
	return taskId
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

-- 判断是否为ipv4
function AgtDomainChecker._isIPv4(ip)
	return string.match(ip, "%d+%.%d+%.%d+%.%d+")
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