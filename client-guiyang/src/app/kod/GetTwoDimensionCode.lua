local ns = namespace("kod.getTwoDemensionCode")

local function getCallBack(response,state, status)
    if state == 4 and (status >= 200 and status < 207) and  string.len(response) > 1000 then
        -- print("response length:"..string.len(response))
        local imgPath = cc.FileUtils:getInstance():getAppDataPath().."dimpump.png"
        local file = io.open(imgPath, "wb")
        file:write(response)
        file:close()
        return true
    else
        Macro.assertFalse(false, "get TwoDimensionCode failed")
        return false
    end
end
-- local function genUrl(source)
--     --测试参数
--     -- local REDIRECT_URI = "http://test.agtzf.gzgy.gymjnxa.com/wechattools/bind_invite.do"
--     -- local WX_APPID = "wx92cca06b0a446257"
--     --正式参数
--     local REDIRECT_URI = "http://agtzf.gzgy.gymjnxa.com/wechattools/bind_invite.do"
--     local WX_APPID = "wx4330c6dd6db846dc" 
--     local State = game.service.LocalPlayerService:getInstance():getArea().."*"..game.service.LocalPlayerService:getInstance():getRoleId().."*"..source

--     local urlPath = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s"

--     local url= string.format( urlPath, WX_APPID, REDIRECT_URI, State)

--     return url
-- end

local function sendRequest(url, params, callback)
    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 3000
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", "application/json");
    local formdata = json.encode(params)

    xhr:registerScriptHandler(function()
        if getCallBack(xhr.response, xhr.readyState, xhr.status)   then
            callback()
        end
    end)
    -- print(formdata)
    xhr:send(formdata)
end

function ns.doGet(source, callback)
    local obj = {}
    -- "https://open.weixin.qq.com/connect/oauth2/authorize?appid=WX_APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=snsapi_userinfo&state=STATE"
    obj.url = config.UrlConfig.getTwoDimensionUrl(source)
    obj.width = 250
    obj.format = "PNG"
    obj.logo = "http://home.gzgy.gymjnxa.com/download/file/guiyang_logo.png"
    obj.areaId = game.service.LocalPlayerService.getInstance():getArea()
    obj.stime = math.floor(kod.util.Time.now() * 1000)
    obj.sign = loho.md5(loho.md5(obj.areaId.. obj.format..obj.logo .. obj.url .. obj.width) .. obj.stime)

    --测试url
    -- local url = "http://test.outside.qrcodeserver.majiang01.com/barcode/v1/add"
    -- local url = "http://172.16.2.125:9955/barcode/v1/add"

    --正式url
    local url = "http://outside.qrcodeserver.majiang01.com/barcode/v1/add"
    sendRequest(url, obj, callback)    
end