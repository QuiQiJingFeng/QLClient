local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIMainRightListItem = class("UIMainRightListItem",UITableViewCell)
local UIManager = app.UIManager

function UIMainRightListItem:init()

end

function UIMainRightListItem:updateData(data)
    self:loadTextures(data.src,data.src,data.src)
end
 

return UIMainRightListItem