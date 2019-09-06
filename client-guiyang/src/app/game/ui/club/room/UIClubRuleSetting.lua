local csbPath = "ui/csb/Club/UIClubRuleSetting.csb"
local super = require("app.game.ui.UIBase")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    多玩法设置
]]

local UIClubRuleSetting = class("UIClubRuleSetting", super, function() return kod.LoadCSBNode(csbPath) end)


function UIClubRuleSetting:ctor()
    self._clubId = 0
end

function UIClubRuleSetting:init()
    self._btnHelp = seekNodeByName(self, "Button_help", "ccui.Button") -- 帮助
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button") -- 退出
    -- 玩法list
    self._listRule = seekNodeByName(self, "ListView_Rule", "ccui.ListView")
    self._listRule:setScrollBarEnabled(false)
    self._listViewItemBig = ccui.Helper:seekNodeByName(self._listRule, "Panel_RuleItem")
    self._listViewItemBig:removeFromParent(false)
    self:addChild(self._listViewItemBig)
    self._listViewItemBig:setVisible(false)

    self._btnHelp:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onQuitClick), ccui.TouchEventType.ended)
end

function UIClubRuleSetting:_onQuitClick()
    UIManager:getInstance():hide("UIClubRuleSetting")
end

function UIClubRuleSetting:onShow(clubId)
    self._clubId = clubId
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_CLUB_BAN_GAMEPLAY_CHANGED", function()
        game.ui.UIMessageTipsMgr.getInstance():showTips("操作成功!")
        self:_initRuleList()
    end, self)
    self:_initRuleList()
end

function UIClubRuleSetting:_initRuleList()
    -- 获取预设玩法
    local clubService = game.service.club.ClubService.getInstance()
    local presetGamePlays = clubService:getPresetGameplays(self._clubId)
    local maxPresetGamePlay = clubService:getMaxPresetGamePlay(self._clubId)
    self._listRule:setTouchEnabled(maxPresetGamePlay > 3)
    self._listRule:removeAllChildren()
    for id, rule in ipairs(presetGamePlays) do
        self:_initRuleItem(id, rule)
    end

    -- 少于配置的玩法个数默认添加一个addItem
    local count = #self._listRule:getItems()
    if count < maxPresetGamePlay then
        self:_initRuleItem(count + 1)
    end

    self._listRule:requestDoLayout()
    self._listRule:doLayout()
end

function UIClubRuleSetting:_initRuleItem(id, rule)
    local node = self._listViewItemBig:clone()
    self._listRule:addChild(node)
    node:setVisible(true)
    local textTitle = ccui.Helper:seekNodeByName(node, "Text_str") -- 标题
    local textRule = ccui.Helper:seekNodeByName(node, "Text_rule") -- 玩法
    local textGamePlay = ccui.Helper:seekNodeByName(node, "Text_gamePlay") -- 规则
    local scrollView = ccui.Helper:seekNodeByName(node, "ScrollView_gamePlay") -- 滑动控件
    local btnDelete = ccui.Helper:seekNodeByName(node, "Button_delete") -- 删除
    local btnModify = ccui.Helper:seekNodeByName(node, "Button_modify") -- 修改
    local btnAdd = ccui.Helper:seekNodeByName(node, "Button_add") -- 添加
    local panelGamePlay = ccui.Helper:seekNodeByName(node, "Panel_gamePlay") -- 玩法panel
    local panelAdd = ccui.Helper:seekNodeByName(node, "Panel_setting") -- 添加的panel
    textTitle:setString(string.format("创建规则%d", id))
    -- 如果没有玩法或者该玩法已经失效就默认显示addItem
    if rule == nil or rule.isInvalid then
        panelGamePlay:setVisible(false)
        panelAdd:setVisible(true)
        bindEventCallBack(btnAdd, function ()
            local banGamePlays = game.service.club.ClubService.getInstance():getBanGameplays(self._clubId)
            UIManager:getInstance():show("UICreateRoom", self._clubId, ClubConstant:getGamePlayType().stencil, banGamePlays, {rule} or {})
        end, ccui.TouchEventType.ended)
        return
    end
    panelGamePlay:setVisible(true)
    panelAdd:setVisible(false)
    local gamePlay = RoomSettingInfo.new(rule.gameplays, rule.roundType):getZHArray()
    textRule:setString(gamePlay[1])
    
    textGamePlay:setString(table.concat(gamePlay, " ", 2))
    textGamePlay:setTextAreaSize(cc.size(textGamePlay:getContentSize().width, 0))
    local textSize = textGamePlay:getVirtualRendererSize()
    local scrollViewSize = scrollView:getContentSize()
    local size = textGamePlay:getVirtualRendererSize()
    local scrollViewSize = scrollView:getContentSize()
	textGamePlay:setContentSize(size)
	scrollView:setInnerContainerSize(size)
	textGamePlay:setPositionY(scrollViewSize.height > size.height and scrollViewSize.height or size.height)

    bindEventCallBack(btnModify, function ()
        local banGamePlays = game.service.club.ClubService.getInstance():getBanGameplays(self._clubId)
        UIManager:getInstance():show("UICreateRoom", self._clubId, ClubConstant:getGamePlayType().stencil, banGamePlays, {rule})
    end, ccui.TouchEventType.ended)
    bindEventCallBack(btnDelete, function ()
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubPresetGameplaysREQ(self._clubId, ClubConstant:getOperationType().delete, rule)
    end, ccui.TouchEventType.ended)
end

function UIClubRuleSetting:onHide()
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRuleSetting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom
end

return UIClubRuleSetting