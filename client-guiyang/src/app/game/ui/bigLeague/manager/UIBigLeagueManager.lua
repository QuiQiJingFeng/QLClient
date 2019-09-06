local csbPath = "ui/csb/BigLeague/UIBigLeagueManager.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local Click = {}

local UIBigLeagueManager = super.buildUIClass("UIBigLeagueManager", csbPath)
function UIBigLeagueManager:ctor()
end

function UIBigLeagueManager:init()
    self._imgMask = seekNodeByName(self, "Image_mask", "ccui.ImageView")
    self._panelManager = seekNodeByName(self, "Panel_3", "ccui.Layout")
    self._imgMask:setVisible(false)
    self._beginX = self._panelManager:getPositionX()

    self._listType = ListFactory.get(
            seekNodeByName(self, "ListView_clubManager", "ccui.ListView"),
            handler(self, self._onListViewInit),
            handler(self, self._onListViewSetData)
    )
end

function UIBigLeagueManager:_onListViewInit(listItem)
    listItem.textIntroduction = seekNodeByName(listItem, "Text_introduction", "ccui.Text")
    listItem.textName = seekNodeByName(listItem, "BitmapFontLabel_typeName", "ccui.TextBMFont")
    listItem.checkBoxOperating = seekNodeByName(listItem, "CheckBox_operating", "ccui.CheckBox")
end

function UIBigLeagueManager:_onListViewSetData(listItem, data)
    listItem.textIntroduction:setString(data.text)
    listItem.textName:setString(data.name)
    listItem.checkBoxOperating:setVisible(data.isCheckBox)
    if data.isCheckBox then
         --checkBox 特殊处理一下
        if data.click == "ShowOpenTable" then
            listItem.checkBoxOperating:setSelected(game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getIsRoomOpening())
        end

        bindEventCallBack(listItem.checkBoxOperating, function(sender)
            local func = Click[data.click]
            func(sender)
        end, ccui.TouchEventType.ended)
    else
        -- click 不能点击
        if data.click == "" then
            return
        end
        -- 自己做一个点击效果
        listItem:addTouchEventListener(function(sender, event)
            if event == ccui.TouchEventType.ended then
                local func = Click[data.click]
                if data.click == "RapidRoomSetting" then
                    self:_hide()
                end
                func()
                sender:setScale(1)
            elseif event == ccui.TouchEventType.canceled then
                sender:setScale(1)
            elseif event == ccui.TouchEventType.began then
                sender:setScale(0.97)
            end
        end)
    end
end

function UIBigLeagueManager:onShow()
    self._listType:deleteAllItems()

    local goldNum = tonumber(game.service.LocalPlayerService:getInstance():getGoldAmount()) or 0
    local leagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local clubService = game.service.club.ClubService.getInstance()
    local isSuper = leagueService:getIsSuperLeague()
    local isManager = leagueService:getLeagueData():isManager()

    local OPERATING_TYPE = {}
    if isSuper then 
        -- A相关
        local leagueName = leagueService:getLeagueData():getLeagueName()
        OPERATING_TYPE = {
            -- name:名称 text:介绍 click:回调方法 isCheckBox:是否显示chechBox isShow:是否显示改类型
            {name = "金币", text = kod.util.String.formatMoney(goldNum, 2), click = "", isCheckBox = false, isShow = true},
            {name = "修改比赛名", text = leagueName, click = "ReviseGameName", isCheckBox = false, isShow = true},
            {name = "显示已开局牌桌", text = "", click = "ShowOpenTable", isCheckBox = true, isShow = true},
            {name = "打烊", text = "", click = "Snoring", isCheckBox = false, isShow = false},
        }
    elseif isManager then 
        -- B相关
        local clubId = leagueService:getLeagueData():getClubId()
        local clubName = clubService:getClubName(clubId)
        OPERATING_TYPE = {
            {name = "修改比赛名", text = clubName, click = "ModifierClubName", isCheckBox = false, isShow = true},
            {name = "编辑公告", text = "", click = "EditNotice", isCheckBox = false, isShow = true},
            {name = "显示已开局牌桌", text = "", click = "ShowClubOpenTable", isCheckBox = true, isShow = true},
        }
    end 

    for k, v in ipairs(OPERATING_TYPE) do
        if v.isShow then
            self._listType:pushBackItem(v)
        end
    end

    self._panelManager:setPositionX(self._beginX)
    self._panelManager:stopAllActions();

    local action1 = cc.EaseBackOut:create(cc.MoveBy:create(0.6,cc.p(-self._panelManager:getContentSize().width,0)))

    self._panelManager:runAction(action1)

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    if self._mask then
        self._mask:setOpacity(170)
    end

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    self._mask:setVisible(true)
    bindEventCallBack(self._mask, handler(self, self._hide), ccui.TouchEventType.ended)

    leagueService:addEventListener("EVENT_LEAGUE_NAME_CHANGE", handler(self, self._hide), self)
    leagueService:addEventListener("EVENT_LEAGUE_CHANGE_B", handler(self, self._hide), self)
end

-- 刷新俱乐部设置状态
function UIBigLeagueManager:_refreshClubSetting(event)
    -- 只更新带有checkBox的item
    for idx, item in ipairs(self._listType:getItemDatas()) do
        if item.isCheckBox then
            self._listType:updateItem(idx, item)
        end
    end
end 

Click.ReviseGameName = function()
    UIManager:getInstance():show("UIBigLeagueNameSetting", "修改比赛名称", "请输入新的比赛名称", 12, function (name)
        local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
        bigLeagueService:sendCCLModifyLeagueNameREQ(bigLeagueService:getLeagueData():getLeagueId(), name)
    end)
end

Click.Snoring = function()

end

Click.ShowOpenTable = function(sender)
    local isSelected = sender:isSelected()
    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    bigLeagueService:sendCCLShowStartTableREQ(bigLeagueService:getLeagueData():getLeagueId() ,isSelected)
end

-- 修改俱乐部名称
Click.ModifierClubName = function()
    UIManager:getInstance():show("UIBigLeagueNameSetting", "修改比赛名", "请输入新的比赛名称", 12, function(name)
        local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
        local clubService = game.service.club.ClubService.getInstance()
        local clubId = bigLeagueService:getLeagueData():getClubId()
        local iconName = clubService:getClubIconName(clubId)
        clubService:getClubManagerService():sendCCLModifyClubInfoREQ(clubId, name, iconName)
    end)    
end

-- 编译公告
Click.EditNotice = function()
    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local clubService = game.service.club.ClubService.getInstance()
    local clubId = bigLeagueService:getLeagueData():getClubId()
    local club = clubService:getClub(clubId)
    local content = ""
    if club ~= nil and club.data ~= nil then 
        content = club.data.clubNotice 
    else 
        content = "群主和管理暂未发布通知"
    end 
    UIManager:getInstance():show("UIBigleagueEditNotice", clubId, content)
end

-- 俱乐部已开牌桌
Click.ShowClubOpenTable = function(sender)
    local bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local clubService = game.service.club.ClubService.getInstance()
    local clubId = bigLeagueService:getLeagueData():getClubId()
    local switchType = ClubConstant:getClubSwitchType().FULL_PLAYER_ROOM
    local isSelected = sender:isSelected()
    clubService:getClubManagerService():sendCCLModifyClubSwitchREQ(clubId,switchType, isSelected)
end

function UIBigLeagueManager:_hide()
    self._mask:setVisible(false)
    self._panelManager:stopAllActions();
    self._panelManager:setPositionX(display.width);
    local act1 = cc.MoveBy:create(0.3, cc.p(self._panelManager:getContentSize().width,0))
    local act2 = cc.CallFunc:create(function()
        UIManager:getInstance():hide("UIBigLeagueManager")
    end)
    self._panelManager:runAction(cc.Sequence:create(act1,act2))
end

function UIBigLeagueManager:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    self._listType:deleteAllItems()
end

function UIBigLeagueManager:needBlackMask()
    return true
end

function UIBigLeagueManager:closeWhenClickMask()
    return false
end

return UIBigLeagueManager