local csbPath = "ui/csb/Club/UIClubLeaderboardWinner.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardWinner = class("UIClubLeaderboardWinner", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    大赢家次数
]]

function UIClubLeaderboardWinner:ctor(parent)
    self._parent = parent

    self._listWinCount = ListFactory.get(
        seekNodeByName(self, "ListView_winCount", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    self._btnPrompt = seekNodeByName(self, "Button_prompt", "ccui.Button")
    self._textInfo = seekNodeByName(self, "Text_info", "ccui.Text")

    bindEventCallBack(self._btnPrompt, handler(self, self._onBtnPromptClick), ccui.TouchEventType.ended)

    self._listWinCount:setScrollBarEnabled(false)
end

function UIClubLeaderboardWinner:_onBtnPromptClick()
    local content = "查询条件内增加分数条件，则可以显示总次数和超过分数的大赢家次数"
    --UIManager:getInstance():show("UIConnectionMessageBox", content, { "确定" }, function() end)
    game.ui.UIMessageBoxMgr.getInstance():show(content, {"确定"})
end

function UIClubLeaderboardWinner:show()
    self:setVisible(true)
    --self._btnPrompt:setVisible(false)
    --self._textInfo:setVisible(false)
    -- 清空列表
    self._listWinCount:deleteAllItems()
end

function UIClubLeaderboardWinner:onPlayerInfo(event)
    -- 清空列表
    self._listWinCount:deleteAllItems()

    for k, v in ipairs(event.rankInfos) do
        self._listWinCount:pushBackItem(v)
    end

    self._textInfo:setString(string.format("超过%s分额外记录\n大赢家总次数%s/%s", event.winnerInfo.winnerScore, event.winnerInfo.overWinnerCount, event.winnerInfo.totalWinnerCount))
end

function UIClubLeaderboardWinner:onPlayerDataInfo(event)
end

function UIClubLeaderboardWinner:hied()
    self._listWinCount:deleteAllItems()
    self:setVisible(false)
end

function UIClubLeaderboardWinner:_onListViewInit(listItem)
    listItem.name = seekNodeByName(listItem, "Text_name", "ccui.Text")
    listItem.id = seekNodeByName(listItem, "Text_id", "ccui.Text")
    listItem.roomCard = seekNodeByName(listItem, "Text_winCount", "ccui.Text")
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView")
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView")
end

function UIClubLeaderboardWinner:_onListViewSetData(listItem, data)
    listItem.name:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.id:setString(data.roleId)
    listItem.roomCard:setString(string.format("%s/%s", data.rankDatas[2], data.rankDatas[1]))
    --listItem.roomCard:setString(data.rankDatas[1])
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
end


return UIClubLeaderboardWinner