local super = require("core.TestCaseBase")
local cases = {}

cases["example! hide btn Test"] = function ()
   if UIManager:getInstance():getIsShowing("UIPlayerScene_btns") == false then
        return false
    end
    local ui = UIManager.getInstance():getUI('UIPlayerScene_btns')

    ui._uiRTVoiceCmp._btnMicOn:setVisible(false)
    ui._uiRTVoiceCmp._btnMicOff:setVisible(false)
    ui._uiRTVoiceCmp._btnSpeakerOn:setVisible(false)
    ui._uiRTVoiceCmp._btnSpeakerOff:setVisible(false)
    Logger.error("example! hide btn Test")
end

cases["example! show btn Test"] = function ()
   if UIManager:getInstance():getIsShowing("UIPlayerScene_btns") == false then
        return false
    end
    local ui = UIManager.getInstance():getUI('UIPlayerScene_btns')

    ui._uiRTVoiceCmp._btnMicOn:setVisible(true)
    ui._uiRTVoiceCmp._btnMicOff:setVisible(true)
    ui._uiRTVoiceCmp._btnSpeakerOn:setVisible(true)
    ui._uiRTVoiceCmp._btnSpeakerOff:setVisible(true)
    Logger.error("example! hide btn Test")
end


local UIRTVoiceComponentTest = class("UIRTVoiceComponentTest", super)

function UIRTVoiceComponentTest:_init()
    for k, v in pairs(cases) do
        self._cases[k] = v
    end
end

return UIRTVoiceComponentTest