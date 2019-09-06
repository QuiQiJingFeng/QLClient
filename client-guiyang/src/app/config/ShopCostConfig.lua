local ShopCostConfig = {}

-- payType 付款方式  1.支付宝 2.微信 3.苹果
-- osType 系统类型:1-applestore 2-android  3-越狱, 4-手机网页端,5 -电脑网页端
-- deviceType 
local configs = {
    -- 贵阳
    [100000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    [110000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    [110100] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [110001] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 3,
    },
    -- 贵阳
    [120000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [120900] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [120800] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [121000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [120325] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 1,
    },
    -- 贵阳
    [220000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 铜仁安卓
    [220025] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 铜仁ios
    [120125] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 贵阳
    [200000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    [210000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 贵阳
    [210001] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 贵阳
    [230000] = {
        items = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
        },
        payType = 2,
        osType = 2,
    },
    -- 贵阳
    [100013] = {
        { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
        { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
        { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
        { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
        -- bean
        { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
        { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
        { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
        { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
        { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
        { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
        { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
        { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
        { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
        { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
    },
    -- 贵阳
    [110013] = {
            { cost = 3, productId = "mahjong.billing.guiyang001", count = 1 },
            { cost = 8, productId = "mahjong.billing.guiyang003", count = 3 },
            { cost = 88, productId = "mahjong.billing.guiyang030", count = 36 },
            { cost = 188, productId = "mahjong.billing.guiyang088", count = 88 },
            -- bean
            { cost = 1, productId = "mahjong.currency.guiyang001", count = 10 },
            { cost = 6, productId = "mahjong.currency.guiyang006", count = 60 },
            { cost = 8, productId = "mahjong.currency.guiyang008", count = 80 },
            { cost = 12, productId = "mahjong.currency.guiyang012", count = 120 },
            { cost = 18, productId = "mahjong.currency.guiyang018", count = 180 },
            { cost = 30, productId = "mahjong.currency.guiyang030", count = 300 },
            { cost = 60, productId = "mahjong.currency.guiyang060", count = 600 },
            { cost = 128, productId = "mahjong.currency.guiyang128", count = 1280 },
            { cost = 328, productId = "mahjong.currency.guiyang328", count = 3280 },
            { cost = 648, productId = "mahjong.currency.guiyang648", count = 6480 },
    },
    -- 潮汕
    [100002] = {
        items = {
            { cost = 3, productId = "mahjong.billing.chaoshan001", count = 1 },
            { cost = 8, productId = "mahjong.billing.chaoshan003", count = 3 },
            { cost = 88, productId = "mahjong.billing.chaoshan030", count = 30 },
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
        },
        payType = 2,
        osType = 3,
    },
    -- 潮汕
    [110002] = {
		items = {
            { cost = 3, productId = "mahjong.billing.chaoshan001", count = 1 },
            { cost = 8, productId = "mahjong.billing.chaoshan003", count = 3 },
            { cost = 88, productId = "mahjong.billing.chaoshan030", count = 30 },
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
		},
        payType = 2,
        osType = 3,
    },
    -- 潮汕
    [120002] = {
        items = {
            { cost = 3, productId = "mahjong.billing.chaoshan001", count = 1 },
            { cost = 8, productId = "mahjong.billing.chaoshan003", count = 3 },
            { cost = 88, productId = "mahjong.billing.chaoshan030", count = 30 },
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
        },
        payType = 2,
        osType = 3,
    },
    -- 潮汕
    [200002] = {
		items = {
            {},
            {},
            {},
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
		},
		payType = 2,
		osType = 2,
    },
    -- 潮汕
    [110102] = {
        items = {
            { cost = 3, productId = "mahjong.billing.chaoshan001", count = 1 },
            { cost = 8, productId = "mahjong.billing.chaoshan003", count = 3 },
            { cost = 88, productId = "mahjong.billing.chaoshan030", count = 30 },
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
        },
        payType = 2,
        osType = 3,
    },
    -- 潮汕
    [210102] = {
        items = {
            {},
            {},
            {},
            { cost = 6, productId = "mahjong.currency.chaoshan60", count = 6 },
            { cost = 30, productId = "mahjong.currency.chaoshan300", count = 300 },
            { cost = 128, productId = "mahjong.currency.chaoshan1280", count = 1280 },
        },
        payType = 2,
        osType = 2,
    },
}

function ShopCostConfig.getConfig(channel)
    -- 这里的key是number
    if Macro.assertTrue(type(channel) ~= "number") then
        return nil
    end
    return configs[channel]
end

--[[0
    为了不影响配置的整体性（其实就应该去影响）
    通过 productId 的前缀去判断是哪种货币
]] 
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local PRODUCT_PREFIX = {
    [CurrencyHelper.CURRENCY_TYPE.BEAN] = "mahjong.currency",
    [CurrencyHelper.CURRENCY_TYPE.CARD] = "mahjong.billing",
}

function ShopCostConfig.filterItemsByChargeCount(chargeCount, items)
    local ret = {}
    for _, item in ipairs(items) do
        if item.count == chargeCount then
            table.insert(ret, item)
        end
    end
    return ret
end

function ShopCostConfig.filterItemsByCurrencyType(currencyType, items)
    local ret = {}
    local prefix = PRODUCT_PREFIX[currencyType]

    if not prefix then
        return ret 
    end

    for _, item in ipairs(items) do
        if string.find(item.productId, prefix) then
            table.insert(ret, item)
        end
    end

    return ret
end

function ShopCostConfig.filterItemsByCost(cost, items)
    local ret = {}
    for _, item in ipairs(items) do
        if item.cost == cost then
            table.insert(ret, item)
        end
    end
    return ret
end

--[[计算出所需能买得起的最近的货币商品，购买推荐使用该函数
    type:货币种类，即是shopconfig中的productid内该货币的关键字
    cost:商品价格
]]--
function ShopCostConfig.calcCurrencyItNeeds( type, cost)
    local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
    
    local goods = ShopCostConfig.getConfig(channelId).items

    local goodResult = {}

    -- 获得productId包含type的货币
    local items = ShopCostConfig.filterItemsByCurrencyType(CurrencyHelper.CURRENCY_TYPE.BEAN, goods)

    table.sort(items, function (a,b)
        return a.cost < b.cost
    end)
    -- 获得大于cost且最接近的货币
    local result = ""
    local count = 0
    table.foreach(items, function (k,v)
        if v.count >= cost and result == "" then
            result = v
            return
        end
    end)

    -- 如果没有买得起的就让他买最贵的。。
    if result == "" then
        result = items[#items]
    end

    return result
end

return ShopCostConfig