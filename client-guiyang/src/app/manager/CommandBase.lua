---------------------
-- 命令基类
---------------------

local CommandBase = class("CommandBase")

function CommandBase:ctor( args )
    self.__args = args
end

function CommandBase:execute( args )
end

-- 发出事件
-- command-> commandCenter -> listener
function CommandBase:trigger( event, args )
    args['name'] = event
	manager.CommandCenter.getInstance():dispatchEvent(args);
end


return CommandBase