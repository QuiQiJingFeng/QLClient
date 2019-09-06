local super = require("app.game.ui.club.record.UIClubHistoryFilter")
local UIBigLeagueHistoryFilter = class("UIBigLeagueHistoryFilter", super)

function UIBigLeagueHistoryFilter:onHide()
    UIManager.getInstance():hide('UIBigLeagueDateSet')
end

function UIBigLeagueHistoryFilter:_onUIHide()
	UIManager.getInstance():hide('UIBigLeagueHistoryFilter')
end

function UIBigLeagueHistoryFilter:_onDateChange()
    -- 统计战绩页面更改条件弹窗更改日期按钮点击
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Zhanji_Change_riqi);

	UIManager.getInstance():show('UIBigLeagueDateSet',self._querytime)
end

function UIBigLeagueHistoryFilter:_onClickFilterChange()
    local time = self._textDate:getString()
    UIManager.getInstance():show('UIBigLeagueHistoryFilter', time)
end

return UIBigLeagueHistoryFilter