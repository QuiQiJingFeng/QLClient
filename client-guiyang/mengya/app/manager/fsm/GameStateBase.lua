---------------------
-- 游戏过程状态基类
---------------------
local GameStateBase = class("GameStateBase")

function GameStateBase:ctor(partent)
    self.parent = partent
end

function GameStateBase:getPartent()
    return self.partent
end

function GameStateBase:isGamingState()
    return true
end

function GameStateBase:isUpdateState()
	return false
end

function GameStateBase:create() end
function GameStateBase:dispose() end
function GameStateBase:prepareEnter() end
function GameStateBase:enter() end
function GameStateBase:afterEnter() end
function GameStateBase:prepareExit() end
function GameStateBase:exit() end
function GameStateBase:afterExit() end

return GameStateBase