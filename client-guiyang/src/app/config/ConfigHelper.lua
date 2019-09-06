--[[
    通过百度获取链接，通过callback返回
    参数两个：第二个表示成功还是失败，如果成功则第一个参数是超短链接，如果失败则第一个参数是原长链接
    调用方式举例:kod.getShortUrl.doGet("http://www.baidu.com",callback)
    参考链接：https://dwz.cn/#/apidoc?_k=uww4ta
]]
require("app.game.util.FileHelper")
require("app.config.H5GameConfig")
local ns = namespace("config")
local configHelper = class("configHelper")
ns.configHelper = configHelper

local configTypes = {
    -- "PropConfig",
    "QrcodeConfig",
    "H5GameConfig",
}

function configHelper.loadPropConfig()
    local str = kod.util.FileHelper.readFile("PropConfig")
    if str ~= "" then
        local obj = json.decode(str)
        config.PropConfig = obj
        PropReader.loadAreaConfig(game.service.LocalPlayerService.getInstance():getArea())
    end
end

function configHelper.loadQrcodeConfig()
    local str = kod.util.FileHelper.readFile("QrcodeConfig")
    if str ~= "" then
        local obj = json.decode(str)
        share.config.url_QRCode = obj
        -- PropReader.loadAreaConfig(game.service.LocalPlayerService.getInstance():getArea())
        share.config.getAllQRCodeImages()
    end
end

function configHelper:loadH5GameConfig()
    local str = kod.util.FileHelper.readFile("H5GameConfig")
    if str ~= "" then
        local obj = json.decode(str)
        config.H5GameConfig:setH5GameConfig(obj)
    end
end

--从本地加载所有配置
function configHelper.loadAllConfigs()
    table.foreach(configTypes, function(k,v)
        local func = "load"..v
        configHelper[func]()
    end)
end

--向服务器请求，刷新所有配置
function configHelper.refreshAllConfigs()
    table.foreach(configTypes, function(k,v)
        configHelper.doGet(v)
    end)
end

function configHelper.saveConfig(configName, str)
    kod.util.FileHelper.writeFile(configName, str)

    local fun = "load"..configName
    configHelper[fun]()
end

local function getCallBack(response,state, status, configName)
    if state == 4 and (status >= 200 and status < 207) and response ~= nil then
        local obj = json.decode(response)    
        if obj.status == 0 then
            local data = json.decode(obj.data.value)
            configHelper.saveConfig(configName, obj.data.value)           
        end
    end
    local func = "load"..configName
    configHelper[func]()
end

-- local function sendRequest(url, params, callback)
--     local xhr = cc.XMLHttpRequest:new()

--     xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
--     xhr.timeout = 3000
--     xhr:open("POST", url)
--     xhr:setRequestHeader("Content-Type", "application/json");
--     xhr:setRequestHeader("Token", "57e1a562a8d59b717ac186e3dd1e4aa4");
--     local formdata = json.encode(params)

--     xhr:registerScriptHandler(function()
--         getCallBack(xhr.response, xhr.readyState, xhr.status, callback)
--     end)
--     -- print(formdata)
--     xhr:send(formdata)
-- end

function configHelper.doGet(configName)
    local obj = {}
    obj.areaId = game.service.LocalPlayerService.getInstance():getArea()
    obj.configName = configName
    obj.version = kod.util.FileHelper.getFileMd5(configName)
    local timestamp = kod.util.Time.nowMilliseconds()
    local sign = loho.md5(obj.areaId..obj.configName..obj.version..timestamp)
    local url = config.UrlConfig.getConfigServer()
    url = string.format( url, obj.areaId, obj.configName, obj.version )
    -- sendRequest(url, obj, callback)    


    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 3000
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", cc.XMLHTTPREQUEST_RESPONSE_STRING);
    xhr:setRequestHeader("TIMESTAMP", timestamp);
    xhr:setRequestHeader("SIGN", sign)
    -- local formdata = json.encode(obj)

    xhr:registerScriptHandler(function()
        --Logger.debug(("url:%s, configName:%s, code:%s response:%s"):format(url, configName, xhr.status, xhr.response))
        getCallBack(xhr.response, xhr.readyState, xhr.status, configName)
    end)
    -- print(formdata)
    xhr:send("")
end