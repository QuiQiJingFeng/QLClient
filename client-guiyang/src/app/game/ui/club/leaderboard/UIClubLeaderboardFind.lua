local csbPath = "ui/csb/Club/UIClubLeaderboardFind.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardFind = class("UIClubLeaderboardFind", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubLeaderboardFind:ctor()
    self._callback = nil
end

function UIClubLeaderboardFind:init()
    self._btnFind = seekNodeByName(self, "Button_find", "ccui.Button")
    self._btnPrevious = seekNodeByName(self, "Button_previous", "ccui.Button")
    self._textFieldScore = seekNodeByName(self, "TextField_Score", "ccui.TextField")
    self._textFieldScore:addEventListener(handler(self, self._onTextFieldChanged))
    self._textFieldScore:setTextColor(cc.c4b(151, 86, 31, 255))
    self._textFieldScore:setString("0")

    bindEventCallBack(self._btnFind, handler(self, self._onBtnFindClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPrevious, handler(self, self._onBtnPreviousClick), ccui.TouchEventType.ended)
end

function UIClubLeaderboardFind:_onTextFieldChanged(sender, eventType)
    if self._isTalkData == false then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leaderboard_Score)
        self._isTalkData = true
    end

    if eventType== 2 or eventType==3 then
        local str = sender:getString()
        str=string.trim(str)
        local sTable = kod.util.String.stringToTable(str)
        local number = ""
        for i=1,#sTable do
            if tonumber(sTable[i]) ~= nil then
                number = number .. sTable[i]
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips('只能输入数字')
            end
        end
        if number ~= "" and tonumber(number) >= 200 then
            number = 200
        end
        sender:setString(number)
    end
end

function UIClubLeaderboardFind:_onBtnFindClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leaderboard_Find)

    if tonumber(self._textFieldScore:getString()) ~= nil then
        if self._callback ~= nil then
            self._callback(self._textFieldScore:getString())
            UIManager:getInstance():hide("UIClubLeaderboardFind")
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的分数")
    end
end

function UIClubLeaderboardFind:_onBtnPreviousClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leaderboard_Previous)

    if UIManager:getInstance():getIsShowing("UIClubLeaderboardMain") then
        local ui = UIManager:getInstance():getUI("UIClubLeaderboardMain")
        ui:onClickInquire()
    end
    UIManager:getInstance():hide("UIClubLeaderboardFind")
end

function UIClubLeaderboardFind:onShow(callback)
    self._callback = callback
    self._isTalkData = false
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Leaderboard_Find_UI)
end

function UIClubLeaderboardFind:onHide()
    self._callback = nil
end

function UIClubLeaderboardFind:needBlackMask()
    return true
end

function UIClubLeaderboardFind:closeWhenClickMask()
    return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubLeaderboardFind:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubLeaderboardFind