local ns = namespace("share.constants")

--[[
    这个是每个地区的分享行为的配置
        第一级是地区，有个default默认
            第二级是入口，哪里调起的分享
                第三季是行为数组，告诉在这个入口里，包含几个分享行为
                每个行为是由渠道+形式组成的
]]
local behavior = {
    ["Test"] = {
        HALL = { -- key = 入口 ， value = behavior数组
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SPECIAL_URL), -- 渠道+形式，中间由|||分隔
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SPECIAL_URL),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.NODE),
        },
        ROOM_INFO = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SHORT_URL),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SHORT_URL),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.NODE),
        },
        OFFLINE_ROOM_INFO =
        {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SHORT_URL),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SHORT_URL),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.NODE),
        },
        FINAL_REPORT = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SCREEN_SHOT),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        TIMEOUT = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SCREEN_SHOT),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        REPLAY = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.URL),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.URL),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.URL)
        },
        CAMPAIGN = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.NODE),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.NODE),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.NODE),
        },
        CLUB_RED_ACTIVITY = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT_WITH_LOGO),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SCREEN_SHOT_WITH_LOGO),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT_WITH_LOGO),
        },
        CLUB_REWARD_ACTIVITY = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT_WITH_LOGO),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.SCREEN_SHOT_WITH_LOGO),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT_WITH_LOGO),
        },
        SHARE_RECALL = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.URL),
            string.format("%s|||%s", ns.CHANNEL.MOMENTS, ns.FORM.URL),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.URL)
        },
        MONEY_TREE = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        DAILY_SHARE = {
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        TestCase_Single_System_ScreenShot = {
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        TestCase_System_ScreenShot = {
            string.format("%s|||%s", ns.CHANNEL.FRIENDS, ns.FORM.SCREEN_SHOT_WITH_LOGO),
            string.format("%s|||%s", ns.CHANNEL.SYSTEM, ns.FORM.SCREEN_SHOT),
        },
        -- 目前ui的形式不支持特殊的分享传入多个
        -- 但是牛逼在我可以传入ui。。。
        TestCase_Special_1 = {
            string.format("%s|||%s", "TEST", "WO_SHI_CESHI_FENXIANG"),
            string.format("%s|||%s", "TEST", "I_AM_TEST_SHARE")
        },
        TestCase_Special_2 = {
            string.format("%s|||%s", "TEST", "I_AM_TEST_SHARE")
        }
    }
}

local ns_config = namespace("share.config")
-- 根据入口判断分享的具体行为
ns_config.getBehavior = function ( enter )
    -- if Macro.assertTrue(table.keyof(ns.ENTER, enter) == nil) then
    --     -- 入口没找到分享个寂寞
    --     return nil
    -- end
    -- 获取地区id，有些奇奇怪怪的地区总喜欢干奇奇怪怪的事情！！！！！
    local areaId = game.service.LocalPlayerService:getInstance():getArea();

    -- 先找到对应的cfg，找不到就default
    local _cfg = behavior[areaId] or behavior['Test']

    -- 再找具体行为，如果在自己的地区找不到，就去default里找
    local result = _cfg[enter] or behavior['Test'][enter]
    return result
end