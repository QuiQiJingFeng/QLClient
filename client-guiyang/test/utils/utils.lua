local _uitls = {}

-- 返回当前时间
_uitls.now = function ()
	return require("socket").gettime();
end

-- 判断一个文件是否存在
_uitls.file_exists = function ( path )
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

_G.tutils = _uitls