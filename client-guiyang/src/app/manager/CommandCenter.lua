---------------------
-- 命令中心
-- 注册、执行命令
---------------------
local ns = namespace("manager")

local CommandCenter = class("CommandCenter")
ns.CommandCenter = CommandCenter

local _instance = nil
function CommandCenter.getInstance()
	if not _instance then
		_instance = CommandCenter.new()
	end
	return _instance
end

function CommandCenter:ctor()
    self._commands = {}
    self:init();
end

function CommandCenter:init()
    -- 绑定事件，用于cmd操控ui
    cc.bind(self, 'event')
end

function CommandCenter:dispose()
    self._commands = {}
    cc.unbind(self, 'event')
end

--==============================--
--desc:注册cmd
--time:2017-08-28 09:04:40
--@key: cmd的key
--@command: cmd具体的类
--@return 
--==============================--
function CommandCenter:registCommand( key, command )
    self._commands[key] = command
end

-- 同上，传入cmd table
function CommandCenter:registCommands( commands )
    for key,command in pairs(commands) do
        self._commands[key] = command
    end
end

-- 取消某个cmd的注册
function CommandCenter:unregistCommand( key )
    self._commands[key] = nil
end

-- 取消所有cmd的注册
function CommandCenter:unregistAll()
    self._commands = {}
end

-- 执行cmd
function CommandCenter:executeCommand( key, args )
    local cmd = self._commands[key];
    if cmd == nil then
        return
    end
    -- 执行对应key的cmd todo: 考虑价格对象池？
    local instance = cmd.new(args)
    return instance:execute(args)
end

return CommandCenter