--[[    区域语音选择界面
--]]
local csbPath = "ui/csb/UILanguage.csb"
local super = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")

local UILanguage = class("UILanguage", super, function() return kod.LoadCSBNode(csbPath) end)

function UILanguage:ctor()
    self._listView = nil
    self._btnClose = nil
end

function UILanguage:init()
    self._listView = seekNodeByName(self, "ListView_Local", "ccui.ListView")
    self._btnClose = seekNodeByName(self, "Button_Close_language", "ccui.Button")

    self._checkBoxs = {}
    bindEventCallBack(self._btnClose,    handler(self, self._onBtnClose),    ccui.TouchEventType.ended);
end

function UILanguage:onShow(...)
    local args = { ... }
    -- 要显示的语音名
    local localNames = args[1]
    -- 语音名对应的地区枚举，用来处理点击完成后的语言切换
    local localEnums = args[2]

    self._languageCBoxGroup = self:_generateCheckBoxGroup(localNames)
    local defaultSelectedIndex = game.service.ChatService.getInstance():getDialect() or 1
    self._languageCBoxGroup:setSelectedIndexWithoutCallback(defaultSelectedIndex)
end

function UILanguage:onHide()
    self._listView:removeAllChildren()
end
-- 关闭的时候把设置弹窗显示出来
function UILanguage:_onBtnClose()
    UIManager:getInstance():destroy("UILanguage")
end

function UILanguage:needBlackMask()
    return true;
end

function UILanguage:closeWhenClickMask()
    return true
end

function UILanguage:_generateCheckBoxGroup(languageNames)
    local listItemTemplate = seekNodeByName(self._listView, "Panel_Local_Item", "ccui.Layout")
    listItemTemplate:retain()
    self._listView:removeAllChildren()

    local checkBoxes = {}
    local lineCount = math.ceil(#languageNames / 2)
    for i = 1, lineCount do
        local cloneObject = listItemTemplate:clone()
        self._listView:addChild(cloneObject)
        local panel1 = seekNodeByName(cloneObject, "Panel_Item1", "ccui.Layout")
        local panel2 = seekNodeByName(cloneObject, "Panel_Item2", "ccui.Layout")
        table.insert(checkBoxes, seekNodeByName(panel1, "CheckBox_item", "ccui.CheckBox"))
        table.insert(checkBoxes, seekNodeByName(panel2, "CheckBox_item", "ccui.CheckBox"))

        local text1 = seekNodeByName(panel1, "Text_item", "ccui.Text")
        local text2 = seekNodeByName(panel2, "Text_item", "ccui.Text")
        text1:setString(languageNames[i * 2 - 1])
        text2:setString(languageNames[i * 2])
        panel1:setVisible(languageNames[i * 2 - 1] ~= nil)
        panel2:setVisible(languageNames[i * 2] ~= nil)
    end
    listItemTemplate:release()
    Macro.assertFalse(#checkBoxes == lineCount * 2)
    return CheckBoxGroup.new(checkBoxes, handler(self, self._onLanguageCheckBoxGroupSelected))
end

function UILanguage:_onLanguageCheckBoxGroupSelected(group, index)
    game.service.ChatService.getInstance():setDialect(index)
end

return UILanguage