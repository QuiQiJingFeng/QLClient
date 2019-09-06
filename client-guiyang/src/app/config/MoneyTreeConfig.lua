local ns = namespace("config")

local MoneyTreeConfig = class("MoneyTreeConfig")

ns.MoneyTreeConfig = MoneyTreeConfig
--[[
    配置说明：
    现在name如果配置为数字，那么就会提示当前获取xx张房卡\
    字符串就显示 请截图联系客服领取

    plus:修改为根据地区配置摇钱树
]]

-- 默认的摇钱树config [num] 数组下标为对应地区的areaid
local config = {
    ["default"] = {
        --摇钱树奖励
        AWARD_LIST = 
        {
            {tree_img = "shop/icon_kouhong.png" , award_img = "shop/icon_kouhong.png", name = "恭喜您获得YSL口红套装（3支）奖励" },
            {tree_img = "shop/icon_shuibei.png" , award_img = "shop/icon_shuibei.png", name = "恭喜您获得熊本熊55℃杯奖励" },
            {tree_img = "shop/icon_lq30.png" , award_img = "shop/icon_lqx30.png", name = "恭喜您获得30礼券奖励" },
            {tree_img = "shop/icon_lq10.png" , award_img = "shop/icon_lqx10.png", name = "恭喜您获得10礼券奖励" },
            {tree_img = "shop/icon_fk1.png" , award_img = "shop/icon_fkx1.png" , name = config.STRING.MONEYTREECONFIG_STRING_100},
            {tree_img = "shop/icon_lq66.png" , award_img = "shop/icon_lqx66.png" , name = "恭喜您获得66礼券奖励"},
            {tree_img = "shop/icon_fk2.png" , award_img = "shop/icon_fkx2.png" , name = config.STRING.MONEYTREECONFIG_STRING_101},
            {tree_img = "shop/icon_fk5.png" , award_img = "shop/icon_fkx5.png" , name = config.STRING.MONEYTREECONFIG_STRING_102},
        },
        --谢谢参与的ID
        ENCOURAGE = 9,
        --活动规则
        ACTIVITY_INFO = [[
    活动期间，每天完成20局、50局、70局、100局游戏，或参与一次比赛场（每天仅限一次），均可获得一次抽奖机会。
    ]],
        TEXT_AWARD_NOTICE = {autoRewardSplitID = 4 , notice = config.STRING.MONEYTREECONFIG_STRING_103},
        TEXT_REAL_AWARD_NOTICE = "",
        TEXT_ACITVITY_DATE = "4月26日— 5月3日",
        ENCOURAGE_IMAGE_NUM = 3,
    },
}

-- 获取当前比赛对应的图标配置
MoneyTreeConfig.getConfig = function(id)
    if config[id] ~= nil then
        return config[id]
    else
        return config["default"]
    end
end

return MoneyTreeConfig


