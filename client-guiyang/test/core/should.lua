-- 结果检查类
local _should = {}

-- 相等
_should.equal = function ( msg, act, exp )
    if act == exp then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is %s", msg, tostring(act))
        return false
    end
end

-- 等于nil
_should.equalnil = function ( msg, act )
    if act == nil then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is %s", msg, tostring(act))
        return false
    end
end

-- 不等于nil
_should.equalnotnil = function ( msg, act )
    if act ~= nil then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        return false
    end
end

-- 等于true
_should.equaltrue = function ( msg, act )
    if act == true then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        return false
    end
end

-- 等于false
_should.equalfalse = function ( msg, act )
    if act == false then
        tlog.info("OK %s", msg)
        return true
    else
        tlog.error("%s, the act is nil", msg)
        return false
    end
end

_G.tshould = _should