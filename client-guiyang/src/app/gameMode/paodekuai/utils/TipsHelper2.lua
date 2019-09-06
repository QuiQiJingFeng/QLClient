local PlayType = require("app.gameMode.paodekuai.core.Constants_Paodekuai").PlayType
local TipsHelper2 = {}

function TipsHelper2.get(helper, cardType, retryCounter)
    if cardType == PlayType.POKER_DISPLAY_PAI_SHUNZI then
        local ret = TipsHelper2._getShunzi(helper, retryCounter)
        return ret
    elseif cardType == PlayType.POKER_DISPLAY_PAI_SHUANG_SHUNZI then
        local ret = TipsHelper2._getShuangShunzi(helper, retryCounter)
        if ret then
            ret = helper:_getRepeat(ret, 2)
        end
        return ret
    end
end

function TipsHelper2._getShunzi(helper, retryCounter)
    local ret
    -- 纯单张能不能
    ret = helper:_getSerials(helper._s1.values, #helper._o1.values, helper._o1.values[1] + 1, retryCounter)
    if ret ~= nil then
        return ret
    end

    -- 纯单张不行，找单张缺少的
    local minValue = helper._o1.values[1] + 1
    local count = #helper._o1.values
    local apart = {}
    for idx, value in ipairs(helper._s1.values) do
        if value >= minValue then
            table.insert(apart, value)
        end
    end

    -- 从对子中找缺失的
    local attach = {}
    for idx, value in ipairs(helper._s2.values) do
        if value >= minValue then
            table.insert(attach, value)
            print("got a value in duizi " .. value)
        end
    end

    -- 从三个中找缺失的
    for idx, value in ipairs(helper._s3.values) do
        if value >= minValue then
            table.insert(attach, value)
            print("got a value in sanzhang " .. value)
        end
    end

    -- 依然找不到就直接让外部用炸弹
    if #attach == 0 then
        return
    else
        -- 找到了，插入到apart中
        table.insertto(apart, attach)
        table.sort(apart, function(v1, v2) return v1 < v2 end)
        -- 再次检查是否符合连续规则
        ret = helper:_getSerials(apart, #helper._o1.values, helper._o1.values[1] + 1, retryCounter)
        return ret
    end
end

function TipsHelper2._getShuangShunzi(helper, retryCounter)
    local ret
    --[[        1、纯对子能不能大过（包含了纯拆三张）
        2、对子 + 拆三张能不能大过
        3、有没有炸弹
    ]]
    -- 1、纯对子能不能大过
    ret = helper:_getSerials(helper._s2.values, #helper._o2.values, helper._o2.values[1] + 1, retryCounter)
    if ret ~= nil then
        return ret
    end

    -- 2、对子 + 拆三张
    -- 找对子缺失的
    local minValue = helper._o2.values[1] + 1
    local count = #helper._o2.values
    local apart = {}
    for idx, value in ipairs(helper._s2.values) do
        if value >= minValue then
            table.insert(apart, value)
        end
    end

    -- 从三个中找缺失的
    local attach = {}
    for idx, value in ipairs(helper._s3.values) do
        -- 找到了就插入到apart中
        if value >= minValue then
            table.insert(attach, value)
            print("got a value in duizi " .. value)
        end
    end

    -- 依然找不到就直接让外部用炸弹
    if #attach == 0 then
        return
    else
        -- 找到了，插入到apart中
        table.insertto(apart, attach)
        table.sort(apart, function(v1, v2) return v1 < v2 end)
        -- 再次检查是否符合连续规则
        ret = helper:_getSerials(apart, #helper._o2.values, helper._o2.values[1] + 1, retryCounter)
        return ret
    end

end

return TipsHelper2