local csbPath = "ui/csb/mengya/UISplash.csb"
local super = game.UIBase

local UISplash = class("UISplash", super, function () return game.Util:loadCSBNode(csbPath) end)

function UISplash:ctor()
end

function UISplash:needBlackMask()
    return false
end

function UISplash:isFullScreen()
    return true
end

function UISplash:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UISplash:onShow(...)
    -- self:playAnimation(csbPath,"splash",handler(self,self._enterUpdateState))
 
end

function UISplash:_enterUpdateState()
    game.GameFSM:getInstance():enterState("GameState_Update")
end

return UISplash