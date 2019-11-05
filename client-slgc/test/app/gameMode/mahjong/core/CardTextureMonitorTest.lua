local super = require("core.TestCaseBase")
local cases = {}
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
cases["Report Error Test"] = function ()
    
    local card1 = CardFactory:getInstance():createCard2(
        CardDefines.Chair.Down, CardDefines.CardState.Chupai, 12, nil, 1)
    local card2 = CardFactory:getInstance():createCard2(
        CardDefines.Chair.Down, CardDefines.CardState.Chupai, 12, nil, 1)
	local card3 = CardFactory:getInstance():createCard2(
        CardDefines.Chair.Down, CardDefines.CardState.Chupai, 12, nil, 1)
    local card4 = CardFactory:getInstance():createCard2(
        CardDefines.Chair.Down, CardDefines.CardState.Chupai, 12, nil, 1)

    return true
end

-- cases[""] = function ()
    
-- end

local UtilsTest = class("UtilsTest", super)

function UtilsTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UtilsTest