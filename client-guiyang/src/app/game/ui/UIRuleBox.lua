-- 此类有Component触发添加到指定的Node中
local csbPath = "ui/csb/UIRoomRule.csb"
local super = require("app.game.ui.UIBase")
local ScrollText = require("app.game.util.ScrollText")
local room = require("app.game.ui.RoomSettingHelper")

local UIRuleBox = class("UIRuleBox", super, function() return kod.LoadCSBNode(csbPath) end)

function UIRuleBox:ctor()
end

function UIRuleBox:init()
    -- self._btnClose    = seekNodeByName(self,"Button_close_RoomRule",    "ccui.Button");
    self._imgHead = seekNodeByName(self, "Image_face_RoomRule", "ccui.ImageView");
    self._txtHostPlayerName = seekNodeByName(self, "Text_name_RoomRule", "ccui.Text");
    self._txtHostPlayerID = seekNodeByName(self, "Text_ID_RoomRule", "ccui.Text");
    self._txtRegion = seekNodeByName(self, "Text_rule_Title", "ccui.Text");

    self._textContent = ScrollText.new(seekNodeByName(self, "Text_rule_content", "ccui.Text"), 28, true)
end

function UIRuleBox:addCallBack()
    -- bindEventCallBack(self._btnClose,    handler(self, self.onBtnCloseClick),    ccui.TouchEventType.ended);
end

function UIRuleBox:onShow(...)
    local args = { ... }
    self:showFormRoom(args)
end

function UIRuleBox:needBlackMask()
    return true;
end

function UIRuleBox:closeWhenClickMask()
    return true
end

function UIRuleBox:onBtnCloseClick(sender)
    UIManager:getInstance():destroy("UIRuleBox")
end

function UIRuleBox:showFormRoom(args)
    local ruleValues = args[1]
    local creatorId = args[2]
    local nickname = args[3]

    nickname = string.sub(nickname, 1, 12) .. "(房主)"
    local headimgurl = args[4]

    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, headimgurl)
    self._txtHostPlayerName:setString(nickname)
    self._txtHostPlayerID:setString("ID:" .. creatorId)

    -- 玩法
    local gameType = nil;
    local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)[1]
    if ruleValues._gameType ~= nil then
        gameType = ruleType[ruleValues._gameType][2];
    end

    self:showRules(ruleValues._gameType, ruleValues._ruleMap);
end


function UIRuleBox:showRules(gameType, gamePlays)
    if gameType == nil or gamePlays == nil then
        return;
    end
    local rules = room.RoomSettingHelper.getOptionsDescs(gameType, gamePlays[gameType]);
    if rules == nil then
        return;
    end

    self._txtRegion:setString(rules[1]);
    local str = table.concat(rules, ',', 2, #rules)
    self._textContent:setString(str)
end

return UIRuleBox;