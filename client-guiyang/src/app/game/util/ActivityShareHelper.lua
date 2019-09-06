local QRCodeFileName = "dimpump.png"
-- logo的地址
local LogoURLs = {
    [10002] = "http://home.gzgy.gymjnxa.com/download/file/guiyang_logo.png",
    [20001] = "http://home.gdcs.nqcdmj.com/download/file/chaoshan_logo.png"
}

local M = {}

-- 把二维码写入到本地
function M.writeQRCode(xhr, okCallback)
    local response = xhr.response
    local readyState = xhr.readyState
    local status = xhr.status
    if readyState == 4 and (status >= 200 and status < 207) and string.len(response) > 1000 then
        local imgPath = cc.FileUtils:getInstance():getAppDataPath() .. QRCodeFileName
        local file = io.open(imgPath, "wb")
        file:write(response)
        file:close()
        return true
    else
        Macro.assertFalse(false, "write QR code failed! response is " .. tostring(response))
        return false
    end
end

-- 将 URL 转为二维码
function M.convertURL2QRCode(url, okCallback)
    if url == "" or url == nil then
        return false
    end

    local obj = {}
    local areaId = game.service.LocalPlayerService.getInstance():getArea()
    obj.url = url
    obj.width = 250
    obj.format = "PNG"
    obj.logo = LogoURLs[areaId]
    obj.areaId = areaId
    obj.stime = math.floor(kod.util.Time.now() * 1000)
    obj.sign = loho.md5(loho.md5(obj.areaId .. obj.format .. obj.logo .. obj.url .. obj.width) .. obj.stime)
    Logger.debug("=========================================发出去的各种信息==============================")
    Logger.dump(obj)

    --测试url
    -- local url = "http://test.outside.qrcodeserver.majiang01.com/barcode/v1/add"
    -- local url = "http://172.16.2.125:9955/barcode/v1/add"
    --正式url
    local url = "http://outside.qrcodeserver.majiang01.com/barcode/v1/add"
    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 0
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-Type", "application/json");
    local formData = json.encode(obj)
    xhr:registerScriptHandler(function()
        if M.writeQRCode(xhr) and okCallback then
            okCallback()
        end
    end)
    -- print(formData)
    xhr:send(formData)
end

--[[0
    wxInfo : {
        appId
        redirectUrl
        state
    }
]]
-- 构建分享的URL， 因为活动不同的 redirectUrl 和 stateInfo 有比较大的差别
---@param wxInfo table
function M.buildWxShareURL(wxInfo)
    local url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" .. wxInfo.appId ..
    "&redirect_uri=" .. wxInfo.redirectUrl .. "&response_type=code&scope=snsapi_userinfo&state=" .. wxInfo.state
    return url
end

-- 这里就不先考虑二维码的位置了吧
function M.createShareImageWithLogo(sourceImagePath, wxInfo, createdCallback, data)
    local shareURL = M.buildWxShareURL(wxInfo)
    M.convertURL2QRCode(shareURL, function()
        local bg = ccui.ImageView:create(sourceImagePath)
        local qrCode =  ccui.ImageView:create(cc.FileUtils:getInstance():getAppDataPath() .. QRCodeFileName)
        qrCode:setAnchorPoint(cc.p(0.5, 0.5))
        if data.wxInfo ~= nil and data.wxInfo.pos ~= nil then
            local posInfo = data.wxInfo.pos
            Logger.dump(posInfo)
            qrCode:setPosition(cc.p(posInfo.x, posInfo.y))
            qrCode:setScale(posInfo.scale)
        else
            qrCode:setPosition(cc.p(bg:getContentSize().width / 2 - 2, 604))
        end
        bg:addChild(qrCode)
        -- 把创建好的带二维码的图片传入到callback中
        createdCallback(bg)
    end)
end


-- 测试
function M.test()
    -- local data =
	-- {
	-- 	enter = share.constants.ENTER.COMEBACK,
    --     wxInfo = {
    --         appId = "testAppId",
    --         redirectUrl = "www.baidu.com",
    --         state = "A*B*C",
    --     },
    --     sourcePath = "art/newshare/share_1.jpg"
	-- }
    -- share.ShareWTF.getInstance():share(data.enter, {data}, function()
    --  print("Share Done")
    -- end)
end

return M