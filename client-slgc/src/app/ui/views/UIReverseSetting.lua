local UIRoomSetting = require("app.ui.views.UIRoomSetting")
local UIReverseSetting = class("UIReverseSetting",UIRoomSetting)

function UIReverseSetting:getStyleCIRCLE()
    return "REVERSE_CIRCLE"
end

function UIReverseSetting:getStyleSQUARE()
    return "REVERSE_SQUARE"
end

function UIReverseSetting:createCheckBoxGroup(info)
    local checkBoxs = self:createOptions(info,self:getStyleCIRCLE())
    local reverseGroup = checkBoxs
    for _, cbx in ipairs(reverseGroup) do
        cbx:setReverseGroup(reverseGroup)
    end
end

function UIReverseSetting:parseCondition(config)
    for _, info in ipairs(config) do
        if info.type == "forbid" then
            local condition = info.setting
            local iter = string.gmatch(condition,"(%d+)->(%l+){(.-)}")
            for setting,operate,effects in iter do
                setting = tonumber(setting)
                self._conditions[setting] = self._conditions[setting] or {}
                self._conditions[setting][operate] = self._conditions[setting][operate] or {}
                local iter2 = string.gmatch(effects,"(%d+)->(%l+)")
                for setting2,operate2 in iter2 do
                    local data = {setting = tonumber(setting2),operate = operate2}
                    table.insert(self._conditions[setting][operate],data)
                end
            end
        end
    end
end

return UIReverseSetting