local UIConstant = {}

UIConstant.UILAYER_LEVEL = {
	BOTTOM_MOST = 1,
	BOTTOM = 2,
	NORMAL = 3,
	TOP = 4,
	TOP_MOST = 5
}

--大厅列表配置
local LOBBY_ITEM_TYPE = {
    LEAGUE = 1,
    GOLD_CAMPAIGN = 2,
    CAMPAIGN = 3,
}
UIConstant.LOBBY_RIGHT_ITEM_TYPE = LOBBY_ITEM_TYPE
UIConstant.LOBBY_RIGHT_LIST_CONFIG = {
    {id = LOBBY_ITEM_TYPE.LEAGUE, name = "大联盟",src = "art/main/Btn_lm_main.png"},
    {id = LOBBY_ITEM_TYPE.GOLD_CAMPAIGN,name = "金币场",src = "art/main/Btn_jbc_main.png"},
    {id = LOBBY_ITEM_TYPE.CAMPAIGN,name = "比赛场",src = "art/main/Btn_bsc_main.png"},
}

--金币场列表配置
local GOLD_COMPAIGN_TYPE = {
    NORMAL = 1,
    LUXURY = 2,
    HONORABLE = 3,
    SENIOR_MOST = 4,
}
UIConstant.GOLD_COMPAIGN_CONFIG = {
    {name = "普通场",type = GOLD_COMPAIGN_TYPE.NORMAL},
    {name = "豪华场",type = GOLD_COMPAIGN_TYPE.LUXURY},
    {name = "尊贵场",type = GOLD_COMPAIGN_TYPE.HONORABLE},
    {name = "雀神场",type = GOLD_COMPAIGN_TYPE.SENIOR_MOST}
}

--商店配置
local SHOP_ITEM_CONFIG = { 
    [2] = {
            name = "金豆商城",
            goodInfos = {
                {title = "10金豆", icon = "art/mall/goodIcon/icon_bean1_mall.png",cost = "1元"},
                {title = "60金豆", icon = "art/mall/goodIcon/icon_bean2_mall.png",cost = "6元"},
                {title = "120金豆", icon = "art/mall/goodIcon/icon_bean3_mall.png",cost = "12元"},
                {title = "300金豆", icon = "art/mall/goodIcon/icon_bean4_mall.png",cost = "30元"},
                {title = "600金豆", icon = "art/mall/goodIcon/icon_bean5_mall.png",cost = "60元"},
                {title = "1280金豆", icon = "art/mall/goodIcon/icon_bean6_mall.png",cost = "128元"},
                {title = "3280金豆", icon = "art/mall/goodIcon/icon_bean7_mall.png",cost = "328元"},
                {title = "6480金豆", icon = "art/mall/goodIcon/icon_bean8_mall.png",cost = "648元"},
            }
        },
    [3] = {
            name = "金币商城",
            goodInfos = {
                {title = "10000金币", icon = "art/mall/goodIcon/icon_gold1_mall.png",cost = "10金豆"},
                {title = "20000金币", icon = "art/mall/goodIcon/icon_gold2_mall.png",cost = "20金豆"},
                {title = "50000金币", icon = "art/mall/goodIcon/icon_gold3_mall.png",cost = "50金豆"},
                {title = "110000金币", icon = "art/mall/goodIcon/icon_gold4_mall.png",cost = "100金豆"},
                {title = "220000金币", icon = "art/mall/goodIcon/icon_gold5_mall.png",cost = "200金豆"},
                {title = "50000金币", icon = "art/mall/goodIcon/icon_gold6_mall.png",cost = "400金豆"},
                {title = "100000金币", icon = "art/mall/goodIcon/icon_gold7_mall.png",cost = "800金豆"},
                {title = "300000金币", icon = "art/mall/goodIcon/icon_gold8_mall.png",cost = "2000金豆"},
            }
        },
    [1] = {
            name = "房卡商城",
            goodInfos = {
                {title = "1房卡", icon = "art/mall/goodIcon/icon_fk1_mall.png",cost = "3元"},
                {title = "3房卡", icon = "art/mall/goodIcon/icon_fk2_mall.png",cost = "8元"},
                {title = "36房卡", icon = "art/mall/goodIcon/icon_fk3_mall.png",cost = "88元"},
                {title = "88房卡", icon = "art/mall/goodIcon/icon_fk4_mall.png",cost = "188元"},
            }
        }
}
UIConstant.SHOP_ITEM_CONFIG = SHOP_ITEM_CONFIG


--游戏类型
UIConstant.GAME_TYPES = {
    {
        id = 65537,
        name = "贵阳麻将"
    },
    {
        id = 65547,
        name = "两房麻将"
    },
    {
        id = 65548,
        name = "两丁一房"
    },
    {
        id = 65546,
        name = "铜仁麻将"
    },
    {
        id = 589825,
        name = "闷胡流血"
    },
    {
        id = 65538,
        name = "遵义麻将"
    },
    {
        id = 65539,
        name = "安顺麻将"
    },
    {
        id = 65545,
        name = "跑得快"
    }
}

UIConstant.DOWNLOAD_STATE = {
    WAITE = 1,
    STARTING = 2,
    STOPED = 3,
    FINISHED = 4,
}

return UIConstant