local Util = game.Util
local UITableViewCell = game.UITableViewCell
local UILobbyRightItem = class("UILobbyRightItem",UITableViewCell)
local UIManager = game.UIManager

function UILobbyRightItem:init()
    --克隆出来的按钮缩放效果没了，这里重新设置
    self:setPressedActionEnabled(true)
    --这里的zoomSclae是在原来的基础上加上一个缩放效果,originSclae + zoomScale
    self:setZoomScale(-0.1)
end

function UILobbyRightItem:updateData(data)
    self:loadTextures(data.src,data.src,data.src)
end

--重写设置选择状态的方法,setBright的处理会导致按钮缩放有问题
function UILobbyRightItem:setSelectState(boolean)

end
 

return UILobbyRightItem