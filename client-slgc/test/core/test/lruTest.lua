local super = require("core.TestCaseBase")
local cases = {}
local tlru = tlrucache(100)
cases["lru add Test"] = function ()
    for i = 1, 10 do
        tlru.add(i, i)
    end
    local correct = 0
    local iter2 = tlru.iterator(false)
    for i = 1, 10 do
        if tshould.equal('Value '.. i, iter2(), 11-i) then correct = correct+1 end
    end

    return correct == 10
end

cases["lru find Test"] = function ()
    local answer = {10,9,8,7,6}
    tlru.find(10)
    tlru.find(9)
    tlru.find(8)
    tlru.find(7)
    tlru.find(6)
    
    local correct = 0
    local iter2 = tlru.iterator(false)
    for i = 1, 5 do
        if tshould.equal('Value '.. i, iter2(), answer[6-i]) then correct = correct+1 end
    end

    return correct == 5
end

cases["lru over max Test"] = function ()
    local answer = 240
    for i = 10, answer do
        tlru.add(i, i)
    end
    local correct = 0
    local iter = tlru.iterator()
    for i = 1, tlru.size() do
        if tshould.equal('Value '.. i, iter(), answer) then correct = correct+1 end
        answer = answer - 1
    end
    if tshould.equalnil('value next', iter()) then correct = correct+1 end

    return correct == tlru.size() + 1
end

local LRUTest = class("LRUTest", super)

function LRUTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    self:sorted({
        "lru add Test",
        "lru find Test",
        "lru over max Test",
    })
end

return LRUTest

