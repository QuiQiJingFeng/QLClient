-- node分享，node的生成器
local ShareNode = require("app.game.share.behavior.base.UIShareNode")

-- url 相关操作
local getShortUrl = require("app.game.share.behavior.base.ShareSpecialURL").getShortUrl
local getWechattoolsUrl = require("app.game.share.behavior.base.ShareSpecialURL").getWechattoolsUrl

--[[
    分享形式的封装
    用闭包的形式，向上层渠道提供几种分享形式的封装
    @param shareUrlFunc     sdk分享url的封装方法
    @param sharePicFunc     sdk分享图片的封装方法
    @param channel          渠道，由上层渠道指定
    @param channelidx       渠道的idx -- 理论上可以不传
    
]]
local forms = function ( shareUrlFunc, sharePicFunc, channel, channelidx )

    -- 分享一个url
    -- @param url 具体的url
    local _URL = function ( data )
        Macro.assertTrue(data.url == nil, "URL params error: url is nil")
        return function ()
            shareUrlFunc(data.url, data.shareInfo, data.shareContent, data.shareIcon)
        end
    end
    
    -- 分享一个短链
    -- @param enter 入口，短链都是走配置的，所以入口配置对了就可以
    local _SHORT_URL = function ( data )
        Macro.assertTrue(data.enter == nil, "SHORT_URL params error: enter is nil")
        return function ()
            local shortUrl = getShortUrl(data.enter, channel)
            shareUrlFunc(shortUrl, data.shareInfo, data.shareContent, data.shareIcon)
        end
    end
    
    -- 分享特殊连接（WeChatTools包装过的，可以用于统计）
    -- @param enter 入口，短链都是走配置的，所以入口配置对了就可以
    local _SPECIAL_URL = function (data)
        Macro.assertTrue(data.enter == nil, "SPECIAL_URL params error: enter is nil")
        return function ()
            local shortUrl = getShortUrl(data.enter, channel)
            local wtUrl = getWechattoolsUrl(shortUrl, channelidx);
            shareUrlFunc(wtUrl, data.shareInfo, data.shareContent, data.shareIcon)
        end
    end
    
    -- 分享屏幕截图
    -- 利用cocos提供回调
    local _SCREEN_SHOT = function (data)
        data = data or {}
        return function ()
            cc.utils:captureScreen(function(succeed, outputFile)
                if succeed == false then return end
                sharePicFunc(outputFile, data.shareInfo, data)
            end, "ScreenShot.jpg")
        end
    end
    
    -- 分享带二维码的截图
    -- 原理同上，多加了一层二维码图层
    local _SCREEN_SHOT_WITH_LOGO = function (data)
        data = data or {}
        return function ()
            -- 分享指定图片
            captureScreenWithLogo(function(succeed, outputFile)
                if succeed == false then return end
                sharePicFunc(outputFile, data.shareInfo)
            end)
        end
    end

    -- 分享一个node
    -- @param data node由UIShareNode提供，里面需要的各种数据
    --          data里需要包含enter，算是封装的问题吧。。找不到合适的地方传，因为只能传一个data，所以只能把enter添加到data里了
    local _NODE = function (data)
        Macro.assertTrue(data == nil, "NODE params error: data is nil")
        return function ()
			local node = ShareNode:getShareNode(channel, data)
            -- 分享指定图片
			saveNodeToPng(node, function(filePath)
				-- 如果是分享到系统的话，正常处理
				if Macro.assertFalse(cc.FileUtils:getInstance():isFileExist(filePath), filePath) then
					sharePicFunc(filePath, data.shareInfo, data)
				end
			end, "shareImg.jpg")
        end
    end

    -- 分享一个带二维码的图片， 使用请参考 ActivityShareHelper 的 test
    local _NODE_WITH_QRCODE = function(data)
        return function()
            local sourcePath = data.sourcePath
            local wxInfo = data.wxInfo
            local createdCallback = function(imageWithLogo)
                -- 分享指定图片
                saveNodeToPng(imageWithLogo, function(filePath)
                    -- 如果是分享到系统的话，正常处理
                    if Macro.assertFalse(cc.FileUtils:getInstance():isFileExist(filePath), filePath) then
                        sharePicFunc(filePath, data.shareInfo)
                    end
                end, "shareImg.jpg")
            end
            require("app.game.util.ActivityShareHelper").createShareImageWithLogo(sourcePath, wxInfo, createdCallback, data)
        end
    end

    -- 由闭包的形式向上层暴露出去接口
    return {
        URL = _URL,
        SHORT_URL = _SHORT_URL,
        SPECIAL_URL = _SPECIAL_URL,
        SCREEN_SHOT = _SCREEN_SHOT,
        SCREEN_SHOT_WITH_LOGO = _SCREEN_SHOT_WITH_LOGO,
        NODE = _NODE,
        NODE_WITH_QRCODE = _NODE_WITH_QRCODE,
    }
end

return forms