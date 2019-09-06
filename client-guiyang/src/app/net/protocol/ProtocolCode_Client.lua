-- 客户端自定义的error code
-- 在最后require
-- 覆盖修改掉platform和battle里的

local _protocolCode = {}
_protocolCode.code = {
	-- 理论上不需要修改协议号，但是combin的时候需要这个字段
}


_protocolCode.text = {}
-- 自定义错误码



return _protocolCode