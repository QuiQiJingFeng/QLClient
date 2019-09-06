local csbPath = "ui/csb/UIShareReplayCode.csb"
local super = require("app.game.ui.UIBase")
local UIShareReplayCode= class("UIShareReplayCode", super, function()
    return kod.LoadCSBNode(csbPath)
end)

function UIShareReplayCode:ctor()
    self._roomText = seekNodeByName(self , "Text_ip", "ccui.Text")
    self._roomRoundText = seekNodeByName(self , "Text_ip_0", "ccui.Text")
    self._replayCodeText = seekNodeByName(self , "Text_id", "ccui.Text")
    self._textName = seekNodeByName(self , "Text_name", "ccui.Text")

    
end

function UIShareReplayCode:convertNumber(num)
    return config.CONVERT_NUM[num]
end

function UIShareReplayCode:getShareNode()
    return self:getChildByName("Panel_Playinfo2_0")
end

function UIShareReplayCode:onShow(roomId,replayCode,roundId,name)
    self._roomText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_1,tostring(roomId)))
    self._roomRoundText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_2,self:convertNumber(roundId)))
    self._replayCodeText:setString(string.format(config.STRING.UISHARE_REPLAY_STR_3,replayCode))
    self._textName:setString(name)
end

return UIShareReplayCode
