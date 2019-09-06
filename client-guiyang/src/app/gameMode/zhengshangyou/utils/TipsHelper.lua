--[[
    跑得快提示功能
    1、get 返回大过的牌， {} or nil
    2、getCardType 返回牌型
    TipsHelper2 是专门用来针对顺子、双顺而创建的
]]
local Constants = require("app.gameMode.zhengshangyou.core.Constants_ZhengShangYou")
local PlayType = Constants.PlayType
local CardDefines = require("app.gameMode.zhengshangyou.core.CardDefines_ZhengShangYou")
local TipsHelper2 = require("app.gameMode.zhengshangyou.utils.TipsHelper2")
local TipsHelper = {}

function TipsHelper:get(selfCards, lastCards, retryCounter)
    local cvt_selfCards = self:_convertAndSortValues(selfCards)
    local cvt_lastCards = self:_convertAndSortValues(lastCards)
    local cardType = self:getCardType(lastCards)
    cvt_lastCards = self:_filteA23Serial(cvt_lastCards)

    local s1, s2, s3, s4 = self:_analysis(cvt_selfCards)
    local o1, o2, o3, o4 = self:_analysis(cvt_lastCards)

    self._s1 = s1
    self._s2 = s2
    self._s3 = s3
    self._s4 = s4
    self._scount = #s1.values + #s2.values * 2 + #s3.values * 3 + #s4.values * 4
    

    self._o1 = o1
    self._o2 = o2
    self._o3 = o3
    self._o4 = o4
    self._ocount = #o1.values + #o2.values * 2 + #o3.values * 3 + #o4.values * 4

    local times
    local ret 
    -- if cardType == nil or cardType == false then 
    --     return 
    -- end

    if retryCounter then
        retryCounter.count = retryCounter.count + 1
        times = retryCounter.count
        ret = self:_start(s1, s2, s3, s4, o1, o2, o3, o4, cardType, retryCounter)
        -- if ret ~= nil and #ret ~= 0 and times == 1 then
        --     -- 保存第一次的
        --     retryCounter.firstTipsCards = {unpack(ret)}
        -- elseif ret == nil or #ret == 0 or times > 1 and self:isSampleArray(ret,retryCounter.firstTipsCards) then
        --     -- 若因为多次提示而导致没牌的，返回第一次的提示
        --     retryCounter.count = 0
        --     retryCounter.retrySplit2Counter = 0
        --     retryCounter.retrySplit3Counter = 0
        --     retryCounter.retrySplit4Counter = 0
        --     return retryCounter.firstTipsCards
        -- end
        if self:isSampleArray(retryCounter.lastTipsCards or { 2 }, ret or { 1 }) then
            retryCounter.count = 0
            retryCounter.retrySplit2Counter = 0
            retryCounter.retrySplit3Counter = 0
            retryCounter.retrySplit4Counter = 0
            retryCounter.retrySplit5Counter = 0
            retryCounter.lastTipsCards = nil
        else
            if ret ~= nil and #ret ~= 0 then
                retryCounter.lastTipsCards = unpack({ ret })
            else
                retryCounter.count = 0
                retryCounter.retrySplit2Counter = 0
                retryCounter.retrySplit3Counter = 0
                retryCounter.retrySplit4Counter = 0
                retryCounter.retrySplit5Counter = 0
                retryCounter.lastTipsCards = nil
            end
        end
        
    else
        ret = self:_start(s1, s2, s3, s4, o1, o2, o3, o4, cardType, retryCounter)
    end
    return ret, cardType
end

function TipsHelper:isSampleArray(arr1, arr2)
    if #arr1 ~= #arr2 then
        return false
    end
    for idx, value in ipairs(arr1) do
        if arr1[idx] ~= arr2[idx] then
            return false
        end
    end
    return true
end

function TipsHelper:getCardType(cards)
    if #cards == 0 then 
        return 
    end

    local cvt_cards = self:_convertAndSortValues(cards)

    -- 如果出的牌中，含有A，并且含有2，那么把A和2转为1, 2，而不是 14 15
    cvt_cards = self:_filteA23Serial(cvt_cards)

    local o1, o2, o3, o4 = self:_analysis(cvt_cards)
    local cardType = nil
    if #o4.values == 1 then
        cardType = PlayType.POKER_DISPLAY_PAI_ZHADAN  --炸弹
        if #o1.values == 1 then
            cardType = PlayType.POKER_DISPLAY_PAI_SI_DAI_1_ZHANG  --4带1
        end
    elseif #o3.values >= 2 then
        cardType = PlayType.POKER_DISPLAY_PAI_SAN_SHUNZI  --三顺
    elseif #o3.values == 1 then
        if #o1.values == 1 then
            cardType = PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG
        elseif #o2.values == 1 then
            cardType = PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_DUI
        else
            cardType = PlayType.POKER_DISPLAY_PAI_SAN_PAI
        end
    elseif #o2.values >= 2 then
        cardType = PlayType.POKER_DISPLAY_PAI_SHUANG_SHUNZI
    elseif #o1.values >= 3 then
        cardType = PlayType.POKER_DISPLAY_PAI_SHUNZI
    elseif #o2.values == 1 then
        cardType = PlayType.POKER_DISPLAY_PAI_DUI_PAI
    elseif #o1.values  == 1 then
        cardType = PlayType.POKER_DISPLAY_PAI_DAN_ZHANG
    else
        Logger.debug("cannot anaysis the card type, cards = " .. table.concat(cards or {} , ","))
        Macro.assertFalse(false, 'cannot analysis cards type CARDS = ' .. table.concat(cards or {} , ","))
    end
    return cardType
end

function TipsHelper:resetCounter()
    self._times = 0
end

--[[ 
    找单个大于o.values中的
    o.values的长度应该是1
]]
function TipsHelper:_cmp(s, o, retryCounter)
    if #o.values == 0 then return end
    if #s.values == 0 then return end
    Macro.assertFalse(#o.values == 1)

    local times = 1
    if s.type == o.type then
        if retryCounter then
            times = retryCounter.count
        end
    else
        if retryCounter then
            if retryCounter.retrySplit5Counter > 0 then
                times = retryCounter.retrySplit5Counter        
            elseif retryCounter.retrySplit4Counter > 0 then
                times = retryCounter.retrySplit4Counter 
            elseif retryCounter.retrySplit3Counter > 0 then
                times = retryCounter.retrySplit3Counter
            elseif retryCounter.retrySplit2Counter > 0 then
                times = retryCounter.retrySplit2Counter
            else
                times = retryCounter.count
            end
        end
    end

    local bigNums = {}
    for idx, value in ipairs(s.values) do
        if value > o.values[1] then
            table.insert(bigNums, value)
        end
        
    end
    local selectValue = bigNums[times]
    return selectValue
end

function TipsHelper:_cmp1(s1, o1, retryCounter, callfrom1)
    if callfrom1 then return end

    local ret = self:_cmp(s1, o1, retryCounter)
    if ret then
        return ret, 1
    else
        if retryCounter then
            -- 从对子中拆
            if retryCounter.retrySplit2Counter < #self._s2.values then
                retryCounter.retrySplit2Counter = retryCounter.retrySplit2Counter + 1
                ret = self:_cmp2(self._s2, o1, retryCounter, callfrom1)
            elseif retryCounter.retrySplit3Counter < #self._s3.values then
                retryCounter.retrySplit3Counter = retryCounter.retrySplit3Counter + 1
                ret = self:_cmp3(self._s3, o1, retryCounter, callfrom1)
            elseif retryCounter.retrySplit4Counter < #self._s4.values then
                retryCounter.retrySplit4Counter = retryCounter.retrySplit4Counter + 1
                ret = self:_cmp4(self._s4, o1, retryCounter, callfrom1)
            end
        else
            ret = self:_cmp2(self._s2, o1, nil, callfrom1)
        end
        return ret, 1
    end
end

function TipsHelper:_cmp2(s2, o2, retryCounter, callfrom1)
    local ret = self:_cmp(s2, o2, retryCounter, callfrom1)
    if ret then
        return ret, 2
    end
    -- return self:_cmp3(self._s3, o2, times, callfrom1)
    if retryCounter then
        if retryCounter.retrySplit3Counter < #self._s3.values then
            retryCounter.retrySplit3Counter = retryCounter.retrySplit3Counter + 1
            ret = self:_cmp3(self._s3, o2, retryCounter, callfrom1)
        elseif retryCounter.retrySplit4Counter < #self._s4.values then
            retryCounter.retrySplit4Counter = retryCounter.retrySplit4Counter + 1
            ret = self:_cmp4(self._s4, o2, retryCounter, callfrom1)
        end
    else
        ret = self:_cmp3(self._s3, o2, nil, callfrom1)
    end
    return ret
end

function TipsHelper:_cmp3(s3, o3, retryCounter, callfrom1)
    local ret = self:_cmp(s3, o3, retryCounter, callfrom1)
    if ret then
        return ret, 3
    end

    if retryCounter then
        if retryCounter.retrySplit4Counter < #self._s4.values then
            retryCounter.retrySplit4Counter = retryCounter.retrySplit4Counter + 1
            ret = self:_cmp4(self._s4, o3, retryCounter, callfrom1)
        end
    else
        ret = self:_cmp4(self._s4, o3, nil, callfrom1)
    end
    return ret
end

function TipsHelper:_cmp4(s4, o4, retryCounter, callfrom1)
    local ret =  self:_cmp(s4, o4, retryCounter, callfrom1)
    return ret, 4
end

function TipsHelper:_analysis(values)
    local _1 ={ type = 1, values = {} }
    local _2 ={ type = 2, values = {} }
    local _3 ={ type = 3, values = {} } 
    local _4 ={ type = 4, values = {} } 

    local cur = values[1]
    local cnt = 0
    for i = 1, #values do
        local value = values[i]
        if cur == value then
            cnt = cnt + 1
        else
            if cnt == 1 then
                table.insert(_1.values, cur)
            elseif cnt == 2 then
                table.insert(_2.values, cur)
            elseif cnt == 3 then
                table.insert(_3.values, cur)
            elseif cnt == 4 then
                table.insert(_4.values, cur)
            end
            cnt = 1
            cur = values[i]
        end
    end
    if cnt == 1 then
        table.insert(_1.values, cur)
    elseif cnt == 2 then
        table.insert(_2.values, cur)
    elseif cnt == 3 then
        table.insert(_3.values, cur)
    elseif cnt == 4 then
        table.insert(_4.values, cur)
    end
    return _1, _2, _3, _4
end

--[[
        1、是否个数够
        2、连续的个数是否够
        3、返回满足startvalue的连续片段
        values:
        count：取的个数
        startValue:开始值
        times：次数
    ]]
function TipsHelper:_getSerials(values, count, startValue, retryCounter)
    if #values < count then 
        return
    end
    local times
    if retryCounter then
        times = retryCounter.count
    else
        times = 1
    end

    local serials = {} -- 存储values中连续的， 以table的方式存入 startIndex + endIndex
    local counter = 1
    local startIndex = 1
    -- 得到连续段下标
    for idx = 1, #values - 1 do
        if values[idx] + 1 == values[idx + 1] then
            counter = counter + 1
        else
            -- 符合长度才插入
            if counter >= count then
                table.insert(serials, {startIndex = startIndex, endIndex = idx})
            end
            counter = 1
            startIndex = idx + 1
        end
    end

    if counter >= count then
        table.insert(serials, {startIndex = startIndex, endIndex = #values})
    end

    -- 遍历所有的连续片段，找到符合的连续片段
    for idx, apart in ipairs(serials) do
        -- 个数必须大于等于，起始值必须大于等于（外部已经 +1 了)
        local _count = apart.endIndex - apart.startIndex + 1
        local _start = values[apart.startIndex]
        -- 1、个数与起始值符合  
        if _count >= count and _start >= startValue then
            local tryStartIndex = apart.startIndex + times - 1
            if tryStartIndex + count - 1 <= apart.endIndex then
                local ret = { unpack(values, tryStartIndex, count + tryStartIndex - 1) }
                return ret
            end
        elseif (_count - count >= startValue - _start) then
            -- 2、个数相差大于起始值相差
            local tryStartIndex = apart.startIndex + times - 1 + startValue - _start
            if tryStartIndex + count - 1 <= apart.endIndex then
                local ret = { unpack(values, tryStartIndex, count + tryStartIndex - 1) }
                return ret
            end
        end

        --[[
            起始值小 用偏移量测量 startValue - _start <= _count - count
        ]]
    end

    return nil

    -- local serialFirstValue = values[startIndex]
    -- if counter < count or serialFirstValue < startValue then
    --     return
    -- end
    -- -- 加上尝试次数的
    -- local retryStartIndex = startIndex + times - 1
    -- local retryFirstValue = values[retryStartIndex]

    -- local retStartIndex = retryStartIndex
    -- if values[retStartIndex + count - 1] == nil then
    --     return nil
    -- end

    -- return {unpack(values, retStartIndex, retStartIndex + count - 1)}
end

function TipsHelper:_getRepeat(value, times)
    local ret = {}
    if type(value) == 'number' then
        for i = 1, times do
            ret[#ret + 1] = value
        end
    elseif type(value) == 'table' then
        local t = value
        for i, v in ipairs(t) do
            for i = 1, times do
                ret[#ret + 1] = v
            end
        end
    end
    return ret
end

function TipsHelper:_start(s1, s2, s3, s4, o1, o2, o3, o4, lastCardType, retryCounter)
    local ret
    if lastCardType == PlayType.POKER_DISPLAY_PAI_DAN_ZHANG then
    -- if lastCardType == 'danzhang' then
        local value = self:_cmp1(s1, o1, retryCounter)
        if value then
            ret = { value }
        end
        -- ret = 'danzhang ' .. (ret or 'none')
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_DUI_PAI then
    -- elseif lastCardType == 'duizi' then
        local value = self:_cmp2(s2, o2, retryCounter)
        -- ret = 'duizi ' .. (ret or 'none')
        if value then
            ret = {value, value}
        end
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SAN_PAI then
    -- elseif lastCardType == 'sanzhang' then
        local value = self:_cmp3(s3, o3, retryCounter)
        if value then
            ret = {value, value, value}
        end
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG then
    -- elseif lastCardType == 'sanzhang-1' then
        local value = self:_cmp3(s3, o3, retryCounter)
        if value then
            local _value1 = self:_cmp1(s1, {values = {0}}) -- 随便拿一张单张的
            if _value1 ~= value then
                ret = {value, value, value, _value1}
            end
        end
        -- return {sanzhang = ret, dai = _ret}
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_DUI then
    -- elseif lastCardType == 'sanzhang-2' then
        local value = self:_cmp(s3, o3, retryCounter)
        local _value2 = self:_cmp2(s2, {values = {0}}) -- 随便拿一双对子的
        if value and _value2 and value ~= _value2 then
            ret =  {value, value, value, _value2, _value2}
        end
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SHUNZI then
    -- elseif lastCardType == 'sunzi-1' then
        -- 123456
        -- ret = self:_getSerials(s1.values, #o1.values, o1.values[1] + 1, times)
        -- if ret == nil then
        --     ret = self:_getSerials(s2.values, #o1.values, o1.values[1] + 1, times)
        -- end
        -- if ret == nil then
        --     ret = self:_getSerials(s3.values, #o1.values, o1.values[1] + 1, times)
        -- end
        -- if ret == nil then
        --     ret = self:_getSerials(s4.values, #o1.values, o1.values[1] + 1, times)
        -- end
        ret = TipsHelper2.get(self, lastCardType, retryCounter)
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SHUANG_SHUNZI then
    -- elseif lastCardType == 'sunzi-2' then
        -- 22334455  3344
        -- ret = self:_getSerials(s2.values, #o2.values, o2.values[1] + 1, times)
        -- if ret == nil then
        --     ret = self:_getSerials(s3.values, #o2.values, o2.values[1] + 1, times)
        -- end
        -- if ret == nil then
        --     ret = self:_getSerials(s4.values, #o2.values, o2.values[1] + 1, times)
        -- end
        -- if ret  then
        --     ret = self:_getRepeat(ret, 2)
        -- end
        ret = TipsHelper2.get(self, lastCardType, retryCounter)
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_SAN_SHUNZI and self._scount >= self._ocount then
        --三顺
        ret = TipsHelper2.get(self, lastCardType, retryCounter)
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG and self._scount >= self._ocount then
        -- 飞机有 33344456 3334445566 3334445566，并且牌数要够
        if #o3.values > 0 then
            -- 如果是普通的飞机
            ret = self:_getSerials(s3.values, #o3.values, o3.values[1] + 1, retryCounter)
        end
        if ret == nil and #s4.values > 0 then
            ret = self:_getSerials(s4.values, #o3.values, o3.values[1] + 1, retryCounter)
        end
        if ret then
            ret = self:_getRepeat(ret, 3)
            local wing, count
            -- 翅膀也要对上
            if #o2.values > 0 then
                -- 翅膀是对子
                count = #o2.values
                wing = self:_getRandomDuizi(count, ret)
                if wing then
                    wing = self:_getRepeat(wing, 2)
                end
            else
                -- 翅膀是单张
                count = #o1.values
                wing = self:_getRandomDanzhang(count, ret)
            end
            if wing == nil then
                ret = nil
            else
                table.insertto(ret, wing, #ret + 1)
            end
        end
    elseif lastCardType == POKER_DISPLAY_PAI_SI_DAI_1_ZHANG then
        local value = self:_cmp4(s4, o4, retryCounter)
        if value then
            local _value1 = self:_cmp1(s1, {values = {0}}) -- 随便拿一张单张的
            if _value1 ~= value then
                ret = {value, value, value, value, _value1}
            end
        end
    elseif lastCardType == PlayType.POKER_DISPLAY_PAI_ZHADAN then
    -- elseif lastCardType == 'zhadan' then
        
        ret = self:_cmp4(s4, o4, retryCounter)
        return { ret, ret, ret, ret }
    end

    if (ret == nil or #ret == 0) and lastCardType ~= PlayType.POKER_DISPLAY_PAI_ZHADAN then
        if #s4.values > 0 then
            -- retryCounter.count = 1
            if retryCounter.retrySplit5Counter > #self._s4.values then
                retryCounter.retrySplit5Counter = 0
            end
            retryCounter.retrySplit5Counter =  retryCounter.retrySplit5Counter + 1
            ret = self:_cmp4(s4, {type = 5, values = {0}},retryCounter)
            ret = {ret, ret, ret, ret}
            Logger.debug("use zhadan")
        end
    end

    if ret == nil then
        ret = {}
    end
    Macro.assertFalse(type(ret) == 'table', dump(ret))
    return ret
end

-- 随便获得对子，会从三个、四张中拆
-- banValues: 对子的值不能是其中的任意一个
-- return nil or {}
function TipsHelper:_getRandomDuizi(count, banValues)
    local ret = {}
    for idx, value in ipairs(self._s2.values) do
        if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
            table.insert(ret, value)
        end
    end
    -- 如果对子遍历完了还不够，则从三张中找
    if #ret < count then
        for idx, value in ipairs(self._s3.values) do
            if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
                table.insert(ret, value)
            end
        end
    end

    -- 从四个中找
    if #ret < count then
        for idx, value in ipairs(self._s4.values) do
            if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
                table.insert(ret, value)
            end
        end
    end

    if #ret < count then
        return nil
    else
        return { unpack(ret, 1, count) }
    end
end

function TipsHelper:_getRandomDanzhang(count, banValues)
    local ret = {}
    for idx, value in ipairs(self._s1.values) do
        if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
            table.insert(ret, value)
        end
    end

    for idx, value in ipairs(self._s2.values) do
        if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
            table.insert(ret, value)
        end
    end
    -- 如果对子遍历完了还不够，则从三张中找
    if #ret < count then
        for idx, value in ipairs(self._s3.values) do
            if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
                table.insert(ret, value)
            end
        end
    end

    -- 从四个中找
    if #ret < count then
        for idx, value in ipairs(self._s4.values) do
            if table.indexof(ret, value) == false and table.indexof(banValues, value) == false then
                table.insert(ret, value)
            end
        end
    end

    if #ret < count then
        return nil
    else
        return { unpack(ret, 1, count) }
    end
end

function TipsHelper:_convertAndSortValues(values)
    values = CardDefines.convertToSortValue(values)
    table.sort(values, function(v1, v2) return v1 < v2 end)
    return values
end

function TipsHelper:_filteA23Serial(cvt_cards)
    local isContainsA = table.indexof(cvt_cards, 14) ~= false
    local isContains2 = table.indexof(cvt_cards, 16) ~= false
    local isContains3 = table.indexof(cvt_cards, 3) ~= false

    local ret = { unpack(cvt_cards) }
    -- 14 -> 1  15 -> 2
    if isContains2 and isContainsA and isContains3 then
        for idx, value in ipairs(cvt_cards) do
            if value == 14 then
                ret[idx] = 1
            elseif value == 16 then
                ret[idx] = 2
            else
                ret[idx] = value
            end
        end
        table.sort(ret, function(v1, v2) return v1 < v2 end)
    end
    return ret
end

return TipsHelper