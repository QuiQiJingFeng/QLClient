-- 结果检查类
-- 比shoud强烈一点点，如果不对，会直接assert
local _must = {}

-- 相等
_must.equal = function ( msg, act, exp )
    if act == exp then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is %s", msg, tostring(act))
        assert(act ~= exp)
    end
end

-- 等于nil
_must.equalnil = function ( msg, act )
    if act == nil then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is %s", msg, tostring(act))
        assert(act ~= nil)
    end
end

-- 不等于nil
_must.equalnotnil = function ( msg, act )
    if act ~= nil then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        assert(act == nil)
    end
end

-- 等于true
_must.equaltrue = function ( msg, act )
    if act == true then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        assert(not act)
    end
end

-- 等于false
_must.equalfalse = function ( msg, act )
    if act == false then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        assert(act)
    end
end

_G.tmust = _must