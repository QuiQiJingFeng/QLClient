local MainScene = class("MainScene", function() return cc.Scene:create() end)

local _instance = nil;
function MainScene:ctor()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end)    
end

function MainScene:getInstance()
	if nil == _instance then
		_instance = MainScene:new():create();
	end
	return _instance;
end

function MainScene:onEnter()
    
end

function MainScene:onExit()
    
end

function MainScene:onStart()

end

return MainScene
