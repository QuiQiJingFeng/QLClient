-- 基本的常量，和其他玩法的Constant在游戏开始时会合并
local Constants_Base = {}


Constants_Base.GenderType = {
    InValid = 0,
    --男 */
    Male    = 1,
    --女 */
    Female  = 2,
}

Constants_Base.PlayerStatus = {
    DEFAULT        = bit.lshift(1, 0) , -- 默认状态
    READY          = bit.lshift(1, 1) , -- 是否准备好打牌
    HOST           = bit.lshift(1, 2) , -- 是房主
    START          = bit.lshift(1, 3), -- 炸金花房主开始游戏
    WAITING        = bit.lshift(1, 3) , -- 等待
    ZHUANGJIA      = bit.lshift(1, 8) , -- 庄家
    ONLINE         = bit.lshift(1, 13), -- 是否在线
    IGNORE_SAME_IP = bit.lshift(1, 15), -- 相同IP同意
}

--[[-- 比赛玩家状态常量
-- 同步于服务器的 PlayerStatus
--]]
Constants_Base.CampaignPlayerStatus = {
    SIGN_UP         = 0 , -- 报名
    WAITING         = 1 , -- 等待
    PLAYING         = 2 , -- 比赛中
    EXIT            = 3 , -- 淘汰
    STOP            = 4 , -- 比赛终止
    START           = 5 , -- 开始
}

--[[-- 比赛状态常量
-- 同步于服务器的 CampaignStatus
--]]
Constants_Base.CampaignStatus = {
    SIGN_UP         = 0 , -- 报名
    ONGOING         = 1 , -- 比赛中 
    END             = 2 , -- 比赛结束
    STOP            = 3 , -- 比赛中止
    BEFORE          = 4 , -- 未开启
    AFTER           = 5 , -- 已关闭
}

Constants_Base.ButtonConst = {
    CLUB_BTN                = bit.lshift(1, 0) ,    -- 亲友圈按钮
    SWITCH_REGION_BTN       = bit.lshift(1, 1) ,    -- 切换地区按钮
    CREATE_CLUB             = bit.lshift(1, 2),     -- 控制自主创建亲友圈按钮
    CAMPAIGN_BTN            = bit.lshift(1, 3),     -- 控制比赛场开关按钮
}

-- if you want get it, use metatable
Constants_Base.PlayType = {
    DISPLAY_FINISH_ALL_REPLAY = -2,
    DISPLAY_FINISH_ALL        = -1,
    Check = function(valueToBeChecked, match)
        return valueToBeChecked == match
    end
}

Constants_Base.GameUIType = {
    ["UI_GAME_SCENE"] = 'UI_GAME_SCENE'
}

return Constants_Base