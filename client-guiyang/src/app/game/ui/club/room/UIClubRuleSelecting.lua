local csbPath = "ui/csb/Club/UIClubRuleSelecting.csb"
local super = require("app.game.ui.UIBase")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    多玩法选择
]]

local UIClubRuleSelecting = class("UIClubRuleSelecting", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubRuleSelecting:ctor()
    self._clubId = 0
end

function UIClubRuleSelecting:init()
    self._listRule = seekNodeByName(self, "ListView_Rule", "ccui.ListView")
    self._listRule:setScrollBarEnabled(false)
    self._listViewItemBig = ccui.Helper:seekNodeByName(self._listRule, "Panel_RuleItem")
    self._listViewItemBig:removeFromParent(false)
    self:addChild(self._listViewItemBig)
    self._listViewItemBig:setVisible(false)
end

function UIClubRuleSelecting:onShow(clubId)
    self._clubId = clubId
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_CLUB_BAN_GAMEPLAY_CHANGED", function ()
        game.ui.UIMessageTipsMgr.getInstance():showTips("群主或者管理修改房间的规则!")
        self:_initRuleList()
    end, self)
    self:_initRuleList()
end

function UIClubRuleSelecting:_initRuleList()
    local clubService = game.service.club.ClubService.getInstance()
    local presetGamePlays = clubService:getPresetGameplays(self._clubId)
    self._listRule:setTouchEnabled(clubService:getMaxPresetGamePlay(self._clubId) > 3)
    self._listRule:removeAllChildren()
    for id, rule in ipairs(presetGamePlays) do
        if not rule.isInvalid then
            self:_initRuleItem(id, rule)
        end
    end

    -- 没有玩法就关闭此界面
    local count = #self._listRule:getItems()
    if count == 0 then
        UIManager:getInstance():hide("UIClubRuleSelecting")
        return
    end
    -- 设置位置
    if count == 1 then
        self._listRule:setPositionPercent(cc.p(0.81, 0.45))
    elseif count == 2 then
        self._listRule:setPositionPercent(cc.p(0.65, 0.45))
    else
        self._listRule:setPositionPercent(cc.p(0.5, 0.45))
    end
end

function UIClubRuleSelecting:_initRuleItem(id, rule)
    local node = self._listViewItemBig:clone()
    self._listRule:addChild(node)
    node:setVisible(true)
    local textTitle = ccui.Helper:seekNodeByName(node, "Text_str") -- 标题
    local textRule = ccui.Helper:seekNodeByName(node, "Text_rule") -- 玩法
    local textGamePlay = ccui.Helper:seekNodeByName(node, "Text_gamePlay") -- 规则
    local scrollView = ccui.Helper:seekNodeByName(node, "ScrollView_gamePlay") -- 滑动控件
    local btnCreateRoom = ccui.Helper:seekNodeByName(node, "Button_createRoom") -- 创建房间
    textTitle:setString(string.format("创建规则%d", id))
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

    bindEventCallBack(btnCreateRoom, function()
        self:_onCreateRoom(id, rule)
    end, ccui.TouchEventType.ended)
end

function UIClubRuleSelecting:_onCreateRoom(id, rule)
    -- 保存一下玩法id
    local clubService = game.service.club.ClubService.getInstance()
    local playerInfo = clubService:loadLocalStoragePlayerInfo()
    playerInfo:getClubInfo(self._clubId).presetGamePlayId = id
    clubService:saveLocalStoragePlayerInfo(playerInfo)

    local club = clubService:getClub(self._clubId)
    local managerId = club.info.managerId or 0
    -- 创建房间
    game.service.RoomCreatorService.getInstance():createClubRoomReq(0, rule.gameplays, rule.roundType,
    self._clubId, managerId, false, {}, ClubConstant:getCreateRoomType().CLUB_QUICK_CREATE, {})
end

function UIClubRuleSelecting:onHide()
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

function UIClubRuleSelecting:needBlackMask()
    return true
end

function UIClubRuleSelecting:closeWhenClickMask()
    return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRuleSelecting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom
end

return UIClubRuleSelecting