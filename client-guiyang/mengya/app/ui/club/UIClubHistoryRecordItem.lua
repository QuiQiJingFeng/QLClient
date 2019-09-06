local Util = app.Util

local UITableViewCell = app.UITableViewCell
local UIClubHistoryRecordItem = class("UIClubHistoryRecordItem",UITableViewCell)
local UIManager = app.UIManager
 
function UIClubHistoryRecordItem:init()

end

-- 整体设置数据
function UIClubHistoryRecordItem:updateData(data)
end
 

return UIClubHistoryRecordItem