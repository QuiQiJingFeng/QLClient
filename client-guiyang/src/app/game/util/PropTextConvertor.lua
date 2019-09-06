--[[
    PropTextConvertor
    Create by: heyi 2018/06/14

    将多个道具转换为不同所需要的文本格式的工具

    使得在使用相关功能时可以使用该工具，避免过多的冗余代码
]]

local ns = namespace("game.util")

local PropTextConvertor = class("PropTextConvertor")
ns.PropTextConvertor = PropTextConvertor

--[[
    传入items的列表 输出 带单位 且每个物品用字符串分隔
]]
function PropTextConvertor.genItemsNameWithOperator( param, operator)
    operator = operator or ""
    local result = {}
    table.foreach(param,function(key,value)
        local item = ""
        local units = ""
        if PropReader.getTypeById(value.id) == "RedPackage" then
            units = "元"
        end
        if PropReader.getTypeById(value.id) == "RealItem" then
            item = PropReader.getNameById(value.id)
        else
            item = PropReader.getNameById(value.id) .. "X" ..value.count .. units
        end
        table.insert( result, item)
    end)

    local s =""
    table.foreach(result, function (k,v)
        if next(result, k) ~= nil then
            s = s .. v .. operator
        else
            s = s .. v
        end
    end)
    return s
end


------------------------
-- 比赛场使用


--[[
    比赛场 传入奖励列表，生成分类好的奖励列表 类似于
    1-3名 IPHONE X
]]

function PropTextConvertor.convertCampaignRewards( list)
    local map = {}
    local result = {}
    -- 生成每种奖品的map 键为 "奖励房卡&奖励礼券",把所有相同奖励的都放在一起
    table.foreach(list, function(key, val)
        if map[PropReader.generatePropTxt(val.item)] == nil then
            map[PropReader.generatePropTxt(val.item)] = {}
        end
        table.insert(map[PropReader.generatePropTxt(val.item)], { rank = val.rank, item = val.item})
    end)

    -- 根据奖品map所需要的最低排名进行排序 获得相同奖励情况下，最低的排名，和最高的排名
    table.foreach(map, function(key, val)
        local low = val[1].rank
        local high = val[1].rank
        table.foreach(val, function( key2,val2 )
            if val2.rank < low then
                low = val2.rank
            end
            if val2.rank>high then 
                high = val2.rank
            end
        end
        )
        if #val > 1 then
            table.insert( result, {rank = low, item = val[1].item ,value = low .. "-" .. high})
        else
            table.insert( result, {rank = low, item = val[1].item ,value = low})
        end
    end)
    table.sort( result, function ( a,b ) 
        return a.rank<b.rank
    end )
    return result
end

-- 比赛场 生成报名费
function PropTextConvertor.generateFeeText(items)
    local result = ""

    -- 取出优先级最高的
    table.sort(items, function (a,b)
        return a > b
    end)

    if #items == 0 then return config.STRING.UICLUBACTIVITYCAMPAIGN_STRING_100 end
    result = PropReader.generatePropTxt({items[1].item})
    return result
end