local csbPath = app.UILaunchCsb
local super = app.UIBase
local Util = app.Util
-- 更新状态文本
local STATE = {
    CHECK = "获取版本更新中...",
    UPDATE = "正在更新，请稍后...",
    FINISH = "更新完毕，祝您游戏愉快",
    LOAD = "资源加载中...",
}

local UILaunch = class("UILaunch", super, function() return app.Util:loadCSBNode(csbPath) end)

local BAR_GLOW_MARGIN_X = 8
function UILaunch:ctor()
    self._loadingBar = Util:seekNodeByName(self, "loadingBar", "ccui.LoadingBar")
    self._imgLaunchMark = Util:seekNodeByName(self, "imgLaunchMark", "ccui.ImageView")
    self._txtBmfState = Util:seekNodeByName(self,"txtBmfState","ccui.TextBMFont")
    self._txtBmfValue = Util:seekNodeByName(self,"txtBmfValue","ccui.TextBMFont")
end

function UILaunch:getGradeLayerId()
    return 2
end

function UILaunch:isFullScreen()
    return true
end

function UILaunch:onShow()


    Util:hide(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
    self._txtBmfState:setString(STATE.CHECK)
    ---[[TEST
        self._txtBmfState:setString(STATE.UPDATE)
        Util:show(self._loadingBar,self._imgLaunchMark,self._txtBmfValue)
        local progress = 0
        Util:scheduleUpdate(function(dt)
            progress = progress + 1
            self:setProgress(progress)
            if progress >= 100 then
                self._txtBmfState:setString(STATE.FINISH)
                app.GameFSM.getInstance():enterState("GameState_Login")
                return true
            end
        end, 0)
    --]]
end

function UILaunch:setProgress(percent)
    self._loadingBar:setPercent(percent)
    self._txtBmfValue:setString(string.format("%.1f%%", percent))
    local box = self._loadingBar:getBoundingBox()
    local posX = box.x + box.width * percent * 0.01
    self._imgLaunchMark:setPositionX(posX)
end

return UILaunch