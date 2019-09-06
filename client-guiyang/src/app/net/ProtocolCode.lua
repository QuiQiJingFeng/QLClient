------------------------
-- 服务器端协议码
------------------------
local _protocolCode = {}
local _codeText = {}

function _protocolCode._tableCopyTo(fromTable, toTable)
	-- 检查参数
	if Macro.assetTrue(type(fromTable) ~= "table") then
		return;
	end
	if Macro.assetTrue(type(toTable) ~= "table") then
		return;
	end	
	
	for key, value in pairs(fromTable) do
        toTable[key] = value
    end
end

function _protocolCode._combinCode(protocolCode)
	_protocolCode._tableCopyTo(protocolCode.code, _protocolCode)
	_protocolCode._tableCopyTo(protocolCode.text, _codeText)
end

-- TODO : 改为静态
-- 错误码转换为错误描述
-- @param code: number
-- @return string
function _protocolCode.code2Str(code)
	local codeStr = _codeText[code];
	if codeStr == nil or codeStr == "" then
		codeStr = string.format("遇到了不应该发生的错误:0x%x", code);
	end
	Logger.error(codeStr);
	return codeStr;
end

_protocolCode._combinCode(require("app.net.protocol.ProtocolCode_Platform"))
_protocolCode._combinCode(require("app.net.protocol.ProtocolCode_Battle"))
_protocolCode._combinCode(require("app.net.protocol.ProtocolCode_Client")) -- 最后require
namespace("net").ProtocolCode = _protocolCode