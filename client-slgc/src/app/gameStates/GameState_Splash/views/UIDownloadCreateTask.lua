local csbPath = "ui/csb/mengya/UIDownloadCreateTask.csb"
local super = game.UIBase

local UIDownloadCreateTask = class("UIDownloadCreateTask", super, function () return game.Util:loadCSBNode(csbPath) end)

function UIDownloadCreateTask:ctor()
end

function UIDownloadCreateTask:needBlackMask()
    return true
end

function UIDownloadCreateTask:isFullScreen()
    return true
end

function UIDownloadCreateTask:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.NORMAL
end

function UIDownloadCreateTask:onShow()
    
end

return UIDownloadCreateTask