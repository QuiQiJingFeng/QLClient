local CardDefines_Paodekuai = {}
function CardDefines_Paodekuai.getCards(str)
    local cards = {}
    for i = 1, #str do
        local cardValue = string.byte(str, i)
        table.insert(cards, cardValue)
    end
    return cards
end

CardDefines_Paodekuai.SUIT_COUNT = 4 -- 花色
CardDefines_Paodekuai.ONE_SUIT_COUNT = 13 -- 一组
CardDefines_Paodekuai.PACK_COUNT = 52 -- 一副

CardDefines_Paodekuai.ESuitType = {
    Invalid = -1,
    -- 黑桃
    Spade = 1,
    -- 红心
    Heart = 2,
    -- 梅花
    Club = 3,
    -- 方块
    Diamond = 4,
    Count = 4
}
local Spade = CardDefines_Paodekuai.ESuitType.Spade
local Heart = CardDefines_Paodekuai.ESuitType.Heart
local Club = CardDefines_Paodekuai.ESuitType.Club
local Diamond = CardDefines_Paodekuai.ESuitType.Diamond

CardDefines_Paodekuai.Map = {
    [255] = { type = 0, name = "牌背", resPath = "poker/surface/z_bg.png" }, -- 牌背
    [0] = { type = 0, name = "牌背", resPath = "poker/surface/z_bg.png" }, -- 牌背
    [-1] = { type = 0, name = "牌背", resPath = "poker/surface/z_bg.png" }, -- 牌背

    [1] = { type = Spade, name = "黑桃A", resPath = "poker/surface/s01.png", sortValue = 14 },
    [2] = { type = Spade, name = "黑桃2", resPath = "poker/surface/s02.png", sortValue = 16 },
    [3] = { type = Spade, name = "黑桃3", resPath = "poker/surface/s03.png", sortValue = 3 },
    [4] = { type = Spade, name = "黑桃4", resPath = "poker/surface/s04.png", sortValue = 4 },
    [5] = { type = Spade, name = "黑桃5", resPath = "poker/surface/s05.png", sortValue = 5 },
    [6] = { type = Spade, name = "黑桃6", resPath = "poker/surface/s06.png", sortValue = 6 },
    [7] = { type = Spade, name = "黑桃7", resPath = "poker/surface/s07.png", sortValue = 7 },
    [8] = { type = Spade, name = "黑桃8", resPath = "poker/surface/s08.png", sortValue = 8 },
    [9] = { type = Spade, name = "黑桃9", resPath = "poker/surface/s09.png", sortValue = 9 },
    [10] = { type = Spade, name = "黑桃10", resPath = "poker/surface/s10.png", sortValue = 10 },
    [11] = { type = Spade, name = "黑桃J", resPath = "poker/surface/s11.png", sortValue = 11 },
    [12] = { type = Spade, name = "黑桃Q", resPath = "poker/surface/s12.png", sortValue = 12 },
    [13] = { type = Spade, name = "黑桃K", resPath = "poker/surface/s13.png", sortValue = 13 },

    [14] = { type = Heart, name = "红心A", resPath = "poker/surface/h01.png", sortValue = 14 },
    [15] = { type = Heart, name = "红心2", resPath = "poker/surface/h02.png", sortValue = 16 },
    [16] = { type = Heart, name = "红心3", resPath = "poker/surface/h03.png", sortValue = 3 },
    [17] = { type = Heart, name = "红心4", resPath = "poker/surface/h04.png", sortValue = 4 },
    [18] = { type = Heart, name = "红心5", resPath = "poker/surface/h05.png", sortValue = 5 },
    [19] = { type = Heart, name = "红心6", resPath = "poker/surface/h06.png", sortValue = 6 },
    [20] = { type = Heart, name = "红心7", resPath = "poker/surface/h07.png", sortValue = 7 },
    [21] = { type = Heart, name = "红心8", resPath = "poker/surface/h08.png", sortValue = 8 },
    [22] = { type = Heart, name = "红心9", resPath = "poker/surface/h09.png", sortValue = 9 },
    [23] = { type = Heart, name = "红心10", resPath = "poker/surface/h10.png", sortValue = 10 },
    [24] = { type = Heart, name = "红心J", resPath = "poker/surface/h11.png", sortValue = 11 },
    [25] = { type = Heart, name = "红心Q", resPath = "poker/surface/h12.png", sortValue = 12 },
    [26] = { type = Heart, name = "红心K", resPath = "poker/surface/h13.png", sortValue = 13 },

    [27] = { type = Club, name = "梅花A", resPath = "poker/surface/c01.png", sortValue = 14 },
    [28] = { type = Club, name = "梅花2", resPath = "poker/surface/c02.png", sortValue = 16 },
    [29] = { type = Club, name = "梅花3", resPath = "poker/surface/c03.png", sortValue = 3 },
    [30] = { type = Club, name = "梅花4", resPath = "poker/surface/c04.png", sortValue = 4 },
    [31] = { type = Club, name = "梅花5", resPath = "poker/surface/c05.png", sortValue = 5 },
    [32] = { type = Club, name = "梅花6", resPath = "poker/surface/c06.png", sortValue = 6 },
    [33] = { type = Club, name = "梅花7", resPath = "poker/surface/c07.png", sortValue = 7 },
    [34] = { type = Club, name = "梅花8", resPath = "poker/surface/c08.png", sortValue = 8 },
    [35] = { type = Club, name = "梅花9", resPath = "poker/surface/c09.png", sortValue = 9 },
    [36] = { type = Club, name = "梅花10", resPath = "poker/surface/c10.png", sortValue = 10 },
    [37] = { type = Club, name = "梅花J", resPath = "poker/surface/c11.png", sortValue = 11 },
    [38] = { type = Club, name = "梅花Q", resPath = "poker/surface/c12.png", sortValue = 12 },
    [39] = { type = Club, name = "梅花K", resPath = "poker/surface/c13.png", sortValue = 13 },

    [40] = { type = Diamond, name = "方块A", resPath = "poker/surface/d01.png", sortValue = 14 },
    [41] = { type = Diamond, name = "方块2", resPath = "poker/surface/d02.png", sortValue = 16 },
    [42] = { type = Diamond, name = "方块3", resPath = "poker/surface/d03.png", sortValue = 3 },
    [43] = { type = Diamond, name = "方块4", resPath = "poker/surface/d04.png", sortValue = 4 },
    [44] = { type = Diamond, name = "方块5", resPath = "poker/surface/d05.png", sortValue = 5 },
    [45] = { type = Diamond, name = "方块6", resPath = "poker/surface/d06.png", sortValue = 6 },
    [46] = { type = Diamond, name = "方块7", resPath = "poker/surface/d07.png", sortValue = 7 },
    [47] = { type = Diamond, name = "方块8", resPath = "poker/surface/d08.png", sortValue = 8 },
    [48] = { type = Diamond, name = "方块9", resPath = "poker/surface/d09.png", sortValue = 9 },
    [49] = { type = Diamond, name = "方块10", resPath = "poker/surface/d10.png", sortValue = 10 },
    [50] = { type = Diamond, name = "方块J", resPath = "poker/surface/d11.png", sortValue = 11 },
    [51] = { type = Diamond, name = "方块Q", resPath = "poker/surface/d12.png", sortValue = 12 },
    [52] = { type = Diamond, name = "方块K", resPath = "poker/surface/d13.png", sortValue = 13 },

    [53] = { type = "Joker", name = "小王", resPath = "poker/surface/z_joker1.png" },
    [54] = { type = "Joker", name = "大王", resPath = "poker/surface/z_joker2.png" }
}

function CardDefines_Paodekuai.sort(values)
    -- values = values or {}
    Logger.debug("=====in " .. table.concat(CardDefines_Paodekuai.convertToSortValue(values), ","))
    -- 没有大小王
    table.sort(values, function(card1, card2)
        local v1 = CardDefines_Paodekuai.Map[card1].sortValue
        local v2 = CardDefines_Paodekuai.Map[card2].sortValue
        if v1 == v2 then
            return card1 > card2
        else
            return v1 > v2
        end
    end)
    Logger.debug("=====out " .. table.concat(CardDefines_Paodekuai.convertToSortValue(values), ","))
    return values
end

function CardDefines_Paodekuai.convertToSortValue(cards)
    assert(type(cards) == 'table', 'cards must be a table')
    local ret = {}
    for idx, value in pairs(cards) do
        ret[idx] = CardDefines_Paodekuai.Map[value].sortValue
    end
    return ret
end

function CardDefines_Paodekuai.getSortValue(value)
    if value then
        local cfg = CardDefines_Paodekuai.Map[value]
        if cfg and cfg.sortValue then
            return cfg.sortValue
        end
    end
    return nil
end

return CardDefines_Paodekuai