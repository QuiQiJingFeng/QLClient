local LoginLogic = {}

function LoginLogic:startLogin(username, relogin, area)
    -- 开始认证
    if GameMain.getInstance():isReviewVersion() then
        -- 审核版
        self:setGuestAccount(self:getGuestAccount());
        self:_loginAuthWithUsername(relogin, area);
    elseif game.plugin.Runtime.isEnabled() then
        -- 正式版
        self:_loginPlatform(relogin, area);
    else
        -- 测试版
        self:setGuestAccount(username);
        self:_loginAuthWithUsername(relogin, area);
    end
end

-- 通过用户名登录入口服务器（测试渠道）
function LoginService:_loginAuthWithUsername(relogin, area)
    local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
    request:getProtocol():setData(config.GlobalConfig.getLoginChannel().test, self:getGuestAccount(), '', '', area);
    request.relogin = relogin or false
    game.util.RequestHelper.request(request);
end

-- 通过微信code登录入口服务器
-- @param code: string
function LoginService:loginAuthWithCode(channel, code, relogin, area)
    local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
    request:getProtocol():setData(channel, '', code, '', area);
    request.relogin = relogin or false
    game.util.RequestHelper.request(request);
end

return LoginLogic