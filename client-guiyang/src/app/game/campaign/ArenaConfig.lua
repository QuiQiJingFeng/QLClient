-- arena配置文件，配置arena比赛对应显示的图标
--[[
    1元话费赛：最后一轮（话费）
快速房卡赛：第五轮（房卡）、第六轮（房卡）
50元红包赛：第三轮（金币）、第四轮（金币）、第五轮（参赛券） 第六轮（红包）
25元红包赛：第四轮（金币）、第五轮（金币）、第六轮（金币）、第七轮（金币）、第八轮（参赛券）、第九轮（红包）
5元红包赛：第四轮（金币）、第五轮（金币）、第六轮（金币）、第七轮（金币）、第八轮（参赛券）、第九轮（红包）
]]
local ArenaConfig = {
    [2] = {
        [5] = "art/mall/goodIcon/icon_fk_mall.png",
        [6] = "art/mall/goodIcon/icon_fk_mall.png",
    },
    [3] = {
        [9] = "art/mall/goodIcon/icon_hf_mall.png",
    },
    [4] = {
        [4] = "art/mall/goodIcon/icon_gold_mall.png",
        [5] = "art/mall/goodIcon/icon_gold_mall.png",
        [6] = "art/mall/goodIcon/icon_gold_mall.png",
        [7] = "art/mall/goodIcon/icon_gold_mall.png",
        [8] = "art/mall/goodIcon/icon_sq_mall.png",
        [9] = "art/mall/goodIcon/icon_hb_mall.png",
    },
    [1006] = {
        [4] = "art/mall/goodIcon/icon_gold_mall.png",
        [5] = "art/mall/goodIcon/icon_gold_mall.png",
        [6] = "art/mall/goodIcon/icon_gold_mall.png",
        [7] = "art/mall/goodIcon/icon_gold_mall.png",
        [8] = "art/mall/goodIcon/icon_sq_mall.png",
        [9] = "art/mall/goodIcon/icon_hb_mall.png",
    },
    [1005] = {
        [3] = "art/mall/goodIcon/icon_gold_mall.png",
        [4] = "art/mall/goodIcon/icon_gold_mall.png",
        [5] = "art/mall/goodIcon/icon_sq_mall.png",
        [6] = "art/mall/goodIcon/icon_hb_mall.png",
    },
    [1007] = {
        [3] = "art/mall/goodIcon/icon_gold_mall.png",
        [4] = "art/mall/goodIcon/icon_gold_mall.png",
        [5] = "art/mall/goodIcon/icon_sq_mall.png",
        [6] = "art/mall/goodIcon/icon_hb_mall.png",
    },
}
return ArenaConfig