--[[
    通过百度获取链接，通过callback返回
    参数两个：第二个表示成功还是失败，如果成功则第一个参数是超短链接，如果失败则第一个参数是原长链接
    调用方式举例:kod.getShortUrl.doGet("http://www.baidu.com",callback)
    参考链接：https://dwz.cn/#/apidoc?_k=uww4ta
]]

local ns = namespace("kod.getShortUrl")

local function getCallBack(response,state, status, callback)
    local obj = json.decode(response)
    if not callback then
        return
    end
    if state == 4 and (status >= 200 and status < 207) and obj.Code == 0 then
        callback(obj.ShortUrl, true)
    else
        Macro.assertFalse(false, "get short url failed:"..response.LongUrl)
        callback(obj.LongUrl, false)
    end
end

local function sendRequest(url, params, callback)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 3000
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", "application/json");
    xhr:setRequestHeader("Token", "57e1a562a8d59b717ac186e3dd1e4aa4");
    local formdata = json.encode(params)

    xhr:registerScriptHandler(function()
        getCallBack(xhr.response, xhr.readyState, xhr.status, callback)
    end)

    xhr:send(formdata)
end


--百度平台
function ns.doGet(ourUrl, callback)
    local obj = {}
    obj.url = ourUrl

    --正式url
    local url = "https://dwz.cn/admin/v2/create"
    sendRequest(url, obj, callback)    
end

--http://suolink.cn/api.html平台
function ns.doGet2(ourUrl, callback)
    local xhr = cc.XMLHttpRequest:new()
    local url = "http://api.suolink.cn/api.php?format=json&url=%s"
    url = string.format( url, string.urlencode(ourUrl) )
    xhr.timeout = 3000
    xhr:open("get", url)

    xhr:registerScriptHandler(function()
        local obj = json.decode(xhr.response)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) and obj.err == "" then
            callback(obj.url, true)
        else
            Macro.assertFalse(false, "get short url failed:"..url)
            callback(url, false)
        end
    end)

    xhr:send()
end

--https://www.985.so/平台
function ns.doGet3(ourUrl, callback)
    local xhr = cc.XMLHttpRequest:new()
    local url = "http://api.c7.gg/api.php?format=json&url=%s&apikey=oJyitKW1WGF3sou6oZ@ddd"
    url = string.format( url, string.urlencode(ourUrl) )
    xhr.timeout = 3000
    xhr:open("get", url)

    xhr:registerScriptHandler(function()
        local obj = json.decode(xhr.response)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) and obj.error == "" then
            callback(obj.url, true)
        else
            Macro.assertFalse(false, "get short url failed:"..url)
            callback(url, false)
        end
    end)

    xhr:send()
end

-- https://0x3.me/ 平台
function ns.doGet4(ourUrl, callback)
    local url = "https://0x3.me/apis/urls/add"
    ourUrl = string.urlencode(ourUrl)
    -- access_token 过期时间为：2019.06.30
    local access_token = "kxFKSCbLic|1561876769|ed9d20c3092d0d7f39e0bb2a0d46047a"

    local xhr = cc.XMLHttpRequest:new()
    xhr.timeout = 3000
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr:setRequestHeader("Cache-Control", "no-cache")

    xhr:open("POST", url)

    xhr:registerScriptHandler(function()
        local errInfo
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207)   then
            local response = json.decode(xhr.response)
            if response.status == 1 then
                callback(response.data.short_url, true)
            else
                errInfo = response.info or "NO ERR_INFO"
            end
        else
            callback(url, false)
            errInfo = string.format("get short url failed = %s", ourUrl)
        end

        if errInfo then
            Logger.debug("%s error =%s", url, errInfo)
        end
    end)

    local str = ("%s=%s&%s=%s"):format("access_token", access_token, "longurl", ourUrl)
    xhr:send(str)
end

-- http://6du.in/
function ns.doGet5(ourUrl, callback)
    -- http://6du.in/?is_api=1&lurl=%s
    local xhr = cc.XMLHttpRequest:new()
    local secretkey = "e6b0ef073c270442ICAgICAb8f3495868abb7c0gMjUwOQ"
    local url = "http://xapi.in/urls/add?&secretkey=%s&lurl=%s"
    url = string.format( url, secretkey, string.urlencode(ourUrl))
    xhr.timeout = 3000
    xhr:open("get", url)

    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            callback(xhr.response, true)
        else
            Macro.assertFalse(false, "get short url failed:"..url)
            callback(url, false)
        end
    end)

    xhr:send()
end

-- http://mrw.so/api.html 平台
function ns.doGet7(ourUrl, callback)
    local xhr = cc.XMLHttpRequest:new()
    local secretkey = "5d2c51d5d3c381596ee5efb2@34670049d0f0b56a35b86ec5b7fdcc7b"
    local url = "http://mrw.so/api.php?format=json&url=%s&key=%s"
    url = string.format( url, string.urlencode(ourUrl), secretkey)
    xhr.timeout = 3000
    xhr:open("get", url)

    xhr:registerScriptHandler(function()
        local obj = json.decode(xhr.response)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            callback(obj.url, true)
        else
            Macro.assertFalse(false, "get short url failed:"..url)
            callback(url, false)
        end
    end)

    xhr:send()
end