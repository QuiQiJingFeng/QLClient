local CommandBase = require("app.manager.CommandBase")

local Command_PlayerProcessor_Base = class("Command_PlayerProcessor_Base", CommandBase)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 是否是断线重连
--       2.stepGroup 具体操作的step
--       3.scope 哪个processor调用的，用于调用processor的方法、成员、以及辨别东南西北
--@return 
--==============================--
function Command_PlayerProcessor_Base:ctor( args )
    self.super:ctor(args)
    self._recover = self.__args[1]          -- 是否复牌
    self._stepGroup = self.__args[2]        -- 操作的具体数据
    self._processor = self.__args[3]        -- 调用的processor
end


return Command_PlayerProcessor_Base