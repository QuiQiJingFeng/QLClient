
local encodeURL = function(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--[[
    @desc: 获取一个短链
    author:{author}
    time:2018-05-24 11:45:01
    --@enter: 入口
	--@channel: 渠道
    return
]]
local function _getShortUrl( enter, channel )

    -- 地区id
    local shortUrl = share.config.getShortUrl(enter, channel)

    return shortUrl
end

--[[
    @desc: 由链接获取一个被WeChatTools包装过的url
    author:{author}
    time:2018-05-24 11:45:21
    --@url: 链接(短链 is better)
	--@channelIdx: 渠道index
    return
]]
local function _getWechattoolsUrl(url, channelIdx)

    local area = game.service.LocalPlayerService:getInstance():getArea()

    -- 玩家显示id
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    -- 下载链接*地区ID*用户ID*按钮事件ID
    local state = string.format("%s*%d*%d*%d", url, area, roleId, channelIdx)

    -- 测试参数
    -- local wx_appid = "wx92cca06b0a446257"
    -- local redirect_uri = "http://test.agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"
    -- 正式参数
    -- FIXME: 把这个东西提取到globalconfig中
    local wx_appid = "wx4330c6dd6db846dc"
    local redirect_uri = "http://agtzf.gzgy.gymjnxa.com/wechattools/ordinary_share.do"

    local shareUrl = string.format("https://open.weixin.qq.com/connect/oauth2/authorize?appid=%s&redirect_uri=%s&response_type=code&scope=snsapi_userinfo&state=%s#wechat_redirect",
                                    wx_appid,
                                    encodeURL(redirect_uri),
                                    state)
    return shareUrl
end


return {
    getShortUrl = _getShortUrl,
    getWechattoolsUrl = _getWechattoolsUrl,
}