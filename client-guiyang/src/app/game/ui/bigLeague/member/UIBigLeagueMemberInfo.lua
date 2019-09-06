local csbPath = "ui/csb/BigLeague/UIBigLeagueMemberInfo.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMemberInfo:UIBase
local UIBigLeagueMemberInfo = super.buildUIClass("UIBigLeagueMemberInfo", csbPath)

--[[
    成员个人信息界面
]]

function UIBigLeagueMemberInfo:ctor()

end

function UIBigLeagueMemberInfo:init()
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
    self._textPlayInfo = seekNodeByName(self, "Text_playerInfo", "ccui.Text") -- 玩家信息
    self._textCardCountInfo = seekNodeByName(self, "Text_cardCountInfo", "ccui.Text") -- 牌局信息
    self._imgRealNameAuth = seekNodeByName(self, "Image_RealNameAuth", "ccui.ImageView") -- 实名认证
    self._btnRecord = seekNodeByName(self, "btnRecord", "ccui.Button") -- 个人战绩

    bindEventCallBack(self._btnRecord,handler(self, self._onBtnRecordClick), ccui.TouchEventType.ended);
end

function UIBigLeagueMemberInfo:onShow(data)
    self._data = data
    local name = game.service.club.ClubService.getInstance():getInterceptString(self._data.nickname, 8)
    self._textPlayInfo:setString(string.format("%s\n\n%s", name, self._data.roleId))
    self._textCardCountInfo:setString(string.format("昨日场次:%s  昨日抽奖次数:%s\n累计场次:%s  累计抽奖:%s\n加入%s时间:%s",
            self._data.yesterdayRoomCount,
            self._data.yesterdayLotteryCount,
            self._data.allRoomCount,
            self._data.allLotteryCount,
            config.STRING.COMMON,
            os.date("%Y-%m-%d", self._data.joinClubTime / 1000)
    ))

    self._imgRealNameAuth:setVisible(self._data.isRealNameAuth or false)
    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, self._data.headUrl)
    game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, PropReader.getIconById(self._data.headFrameId), 0.95)
end

--点击个人战绩
function UIBigLeagueMemberInfo:_onBtnRecordClick()
    --TODO 等待服务器协议弄好后处理
    local eventKey = game.globalConst.StatisticNames.Individual_Record_Click
    game.service.DataEyeService.getInstance():onEvent(eventKey)

    UIManager:getInstance():show("UIBigLeagueHistory",self._data.roleId)
    UIManager:getInstance():hide("UIBigLeagueMemberInfo")
end

function UIBigLeagueMemberInfo:onHide()

end

function UIBigLeagueMemberInfo:needBlackMask()
    return true
end

function UIBigLeagueMemberInfo:closeWhenClickMask()
    return true
end

function UIBigLeagueMemberInfo:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

return UIBigLeagueMemberInfo