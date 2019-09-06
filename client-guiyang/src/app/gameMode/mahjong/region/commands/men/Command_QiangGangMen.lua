local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_QiangGangMen = class("Command_QiangGangMen", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_QiangGangMen:ctor( args )
    self.super:ctor(args)
end

function Command_QiangGangMen:execute( args )
    local step = self._stepGroup[1]

    self._processor:_doQiangGangHu(step._cards[1])
end

return Command_QiangGangMen