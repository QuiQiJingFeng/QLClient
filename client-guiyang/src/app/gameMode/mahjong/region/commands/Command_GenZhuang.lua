--跟庄动画
local CommandBase = require("app.manager.CommandBase")

local Command_GenZhuang = class("Command_GenZhuang", CommandBase)
local UI_ANIM = require("app.manager.UIAnimManager")

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_GenZhuang:ctor( args )
    self.super:ctor(args)
end

function Command_GenZhuang:execute( args )
    --跟庄动画
    local anim = UI_ANIM.UIAnimManager:getInstance():onShow(UI_ANIM.UIAnimConfig.new("ui/csb/Effect_gengzhuang.csb", function()
    end))
end

return Command_GenZhuang
