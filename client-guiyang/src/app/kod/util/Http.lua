local ns = namespace("kod.util")

ns.Http = {}

local responseTypeTbl = {
	text	    = cc.XMLHTTPREQUEST_RESPONSE_STRING,
	arraybuffer = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER,
    blob        = cc.XMLHTTPREQUEST_RESPONSE_BLOB,
    document 	= cc.XMLHTTPREQUEST_RESPONSE_DOCUMENT,
	json 		= cc.XMLHTTPREQUEST_RESPONSE_JSON,
}
function ns.Http.sendRequest(url, params, callback, method, responseType, timeout)
	local xhr = cc.XMLHttpRequest:new()
    if responseType and responseTypeTbl[responseType] then
		xhr.responseType = responseTypeTbl[responseType]
    else
    	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    end
	-- 原cocos2d-x的cc.XMLHttpRequest的timeout属性是假的
	-- 但已修改c++部分其实现, 增加了timeout支持
	-- 当timeout不设置或设置为0时, 内部timeout为30 + 60
    xhr.timeout = timeout or 0
    xhr:open(method or "GET", url)
    local formdata
	if type(params) == "table" then
		for name, param in pairs(params) do
			if not formdata then
				formdata = name .. "=" .. param
			else
				formdata = formdata .. "&" .. name .. "=" .. param
			end
		end
	elseif type(params) == "string" then	
		formdata = params
	end

    if responseType == "blob" then
        xhr:setRequestHeader("Content-Type", "application/octet-stream")
    end

    xhr:registerScriptHandler(function()
    	return callback and callback(xhr.response, xhr.readyState, xhr.status)
    end)
    xhr:send(formdata)
end

--[[
    lua 参数：
	@param url 要传的url，这里会接一个长度
	@param file 要传的文件，带路径
	@param LZ4Compressed 上传是否使用LZ4压缩
	@param postType 现在有2种上传，1，原始数据直接上传，不做任何修饰。2，表单文件上传
]]
local xhr
function ns.Http.uploadFile(url, file, LZ4Compressed, postType, callback, timeout)
	xhr = cc.XMLHttpRequest:new()
    -- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	-- 原cocos2d-x的cc.XMLHttpRequest的timeout属性是假的
	-- 但已修改c++部分其实现, 增加了timeout支持
	-- 当timeout不设置或设置为0时, 内部timeout为30 + 60
    xhr.timeout = timeout or 30
    xhr:registerScriptHandler(function(event)
    	return callback and callback(xhr, event)        
    end)
    xhr:uploadFile(url, file, LZ4Compressed, postType)
end

function ns.Http.parseUrl(url)
    -- initialize default parameters
    local parsed = {}
    -- empty url is parsed to nil
    if not url or url == "" then return nil, "invalid url" end
    -- remove whitespace
    -- url = string.gsub(url, "%s", "")
    -- get scheme
    url = string.gsub(url, "^([%w][%w%+%-%.]*)%:",
        function(s) parsed.scheme = s; return "" end)
    -- get authority
    url = string.gsub(url, "^//([^/]*)", function(n)
        parsed.authority = n
        return ""
    end)
    -- get fragment
    url = string.gsub(url, "#(.*)$", function(f)
        parsed.fragment = f
        return ""
    end)
    -- get query string
    url = string.gsub(url, "%?(.*)", function(q)
        parsed.query = q
        return ""
    end)
    -- get params
    url = string.gsub(url, "%;(.*)", function(p)
        parsed.params = p
        return ""
    end)
    -- path is whatever was left
    if url ~= "" then parsed.path = url end
    local authority = parsed.authority
    if not authority then return parsed end
    authority = string.gsub(authority,"^([^@]*)@",
        function(u) parsed.userinfo = u; return "" end)
    authority = string.gsub(authority, ":([^:%]]*)$",
        function(p) parsed.port = p; return "" end)
    if authority ~= "" then 
        -- IPv6?
        parsed.host = string.match(authority, "^%[(.+)%]$") or authority 
    end
    local userinfo = parsed.userinfo
    if not userinfo then return parsed end
    userinfo = string.gsub(userinfo, ":([^:]*)$",
        function(p) parsed.password = p; return "" end)
    parsed.user = userinfo
    return parsed
end

function ns.Http.uploadInfo(params, url)

    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 3000
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", "application/json");
    local formdata = json.encode(params)

    print = release_print
    dump(params, "uploadInfo~~:"..url)
    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207)   then
            release_print("upload finish")
        else
            release_print("upload failed~~")
        end
    end)
    xhr:send(formdata)
end