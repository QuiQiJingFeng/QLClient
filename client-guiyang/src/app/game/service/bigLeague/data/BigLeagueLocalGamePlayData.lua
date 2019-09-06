-------------------------------------------------
-- 玩家联盟玩法缓存数据
local BigLeagueGamePlayData = class("BigLeagueGamePlayData")

local LocalGamePlayData = class("LocalGamePlayData")
function LocalGamePlayData:ctor()
    self._gamePlay = {}  -- 玩家选择的玩法数据  [联盟ID] = 玩法保存数据
end

function BigLeagueGamePlayData:ctor()
    self._gamePlayList = {}
end

--加载玩法筛选
function BigLeagueGamePlayData:LoadLocalGamePlayStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    self._gamePlayList = manager.LocalStorage.getUserData(roleId, "BigLeagueGamePlay", LocalGamePlayData);
end

--保存玩法筛选
function BigLeagueGamePlayData:SaveLocalGamePlayStorage()
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
    manager.LocalStorage.setUserData(roleId, "BigLeagueGamePlay", self._gamePlayList)
end

--[[设置筛选玩法
1.每个小数据项：["id"] = {modifyTime = tbRule[nIdx].modifyTime【控制红点显示】, 
                        bSelected = 界面显示是否选中，【bSelected 为true 的时候，showRoomTime 一定> 0 】
                        showRoomTime = 需要显示的房间的modifyTiem，不需要显示的房间的数据为0，当玩家不点击保存的时候，showRoomTime应该不改变，这样才能筛选出旧房间，实际筛选房间用的是这个数据
                        bRed = 是否显示红点,主要用来处理修改后的玩法的红点问题，因为修改后bSelected为false,原‘选中且modifyTime不相等’的红点判断逻辑就不好用了}
2.增加数据配置的地方只有 BigLeagueData:getGamePlay(leagueID) 和 玩法筛选界面，点击去掉红点的时候
3.保存配置的地方： BigLeagueData:getGamePlay(leagueID) ；消除红点保存； 玩法改变，选中变未选中保存； 玩法筛选点击保存
]]
function BigLeagueGamePlayData:SetGamePlayData(leagueID,tbData)
    self._gamePlayList._gamePlay[tostring(leagueID)] = tbData
    self:SaveLocalGamePlayStorage()
    game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():filterRoomData()
    game.service.bigLeague.BigLeagueService:getInstance():dispatchEvent({ name = "EVENT_GAMEPLAY_FILTER" }) --筛选房间
end

--获取保存玩法
function BigLeagueGamePlayData:GetGamePlayData(leagueID)
    self:LoadLocalGamePlayStorage()
    return self._gamePlayList._gamePlay[tostring(leagueID)]
end

return BigLeagueGamePlayData