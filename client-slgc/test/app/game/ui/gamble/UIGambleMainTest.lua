local super = require("core.TestCaseBase")
local cases = {}

cases["addlistItem"] = function ()
    if UIManager:getInstance():getIsShowing("UIGambleMain") == false then
        return false
    end
    local ui = UIManager.getInstance():getUI('UIGambleMain')
    local gambleList = ui._gambleList
    local event = {}
    event.protocol = {}
    event.protocol.games = {}
    for i=1,10 do
        table.insert( event.protocol.games , {
            id = i,
            homeTeam = "中国",
            visitingTeam = "巴西",
            homeOdds = 200,
            dogFall = 100,
            visitingOdds = 1.1,
            peopleOfBet = 87654321,
            moneyOfBet  = 987654321,
            time = 1527579006000,
            name = "不可能的战斗"
        } )
    end
    gambleList:_setAllGamblesInfo(event)
    return tshould.equalnil("listitem add success")
end


local UIGambleMainTest = class("UIGambleMainTest", super)

function UIGambleMainTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
    -- self:sorted({
    --     "example! hide btn Test",
    --     "example! show btn Test",
    -- })
end

return UIGambleMainTest
