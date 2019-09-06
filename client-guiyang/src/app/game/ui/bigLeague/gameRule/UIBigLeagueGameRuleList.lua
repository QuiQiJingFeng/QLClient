local csbPath = "ui/csb/BigLeague/UIBigLeagueGameRuleList.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueGameRuleList:UIBase
local UIBigLeagueGameRuleList = super.buildUIClass("UIBigLeagueGameRuleList", csbPath)

local RoomSettingInfo = require("app.game.RoomSettingInfo")
--local ScrollText = require("app.game.util.ScrollText")

--[[
    玩法列表界面
        用于A添加修改删除玩法，B、C查看玩法详细内容
]]

function UIBigLeagueGameRuleList:ctor()

end

function UIBigLeagueGameRuleList:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)

    self._listviewGameRule = seekNodeByName(self, "ListView_GameRule", "ccui.ListView")
    -- 不显示滚动条, 无法在编辑器设置
    self._listviewGameRule:setScrollBarEnabled(false)
    -- 玩法item
    self._listviewItemGameRule = ccui.Helper:seekNodeByName(self._listviewGameRule, "Panel_GameRule")
    self._listviewItemGameRule:removeFromParent(false)
    self:addChild(self._listviewItemGameRule)
    self._listviewItemGameRule:setVisible(false)
    -- 添加玩法item
    self._listviewItemAddGameRule = ccui.Helper:seekNodeByName(self._listviewGameRule, "Panel_AddGameRule")
    self._listviewItemAddGameRule:removeFromParent(false)
    self:addChild(self._listviewItemAddGameRule)
    self._listviewItemAddGameRule:setVisible(false)

    --GPS监测开关
    self._cbxGpsEnable = seekNodeByName(self,"cbxGpsEnable","ccui.CheckBox")
    self._cbxGpsEnable:setVisible(false)
    self._cbxGpsEnable:onEvent(handler(self,self._onCheckBoxGpsChange))

     --玩法统计
     self._btnPlayStatistics = seekNodeByName(self, "Button_PlayStatistics", "ccui.Button")
     bindEventCallBack(self._btnPlayStatistics, handler(self, self._onClickPlayStatistics), ccui.TouchEventType.ended)
end

function UIBigLeagueGameRuleList:_onCheckBoxGpsChange(event)
    local isOpenGps = false
    if event.name == "selected" then
        isOpenGps = true
    end

    local leagueId = self._bigLeagueService:getLeagueData():getLeagueId()
    self._bigLeagueService:sendModifyLeagueGpsRuleREQ(leagueId,isOpenGps)
end

function UIBigLeagueGameRuleList:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueGameRuleList:onShow()
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    local superLeague = self._bigLeagueService:getIsSuperLeague()
    self._cbxGpsEnable:setVisible(superLeague and true or false)
    if self._bigLeagueService:getIsSuperLeague() then 
        self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId())
    else 
        self._bigLeagueService:sendCCLQueryLeagueGameplayREQ(self._bigLeagueService:getLeagueData():getLeagueId(),self._bigLeagueService:getLeagueData():getClubId())
    end 
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_GAMEPLAY", handler(self, self._upadtaListView), self)
    self._bigLeagueService:addEventListener("EVENT_GPS_STATE_FAILED", handler(self, self._gpsStateChangeFaild), self)

      --玩法统计按钮 只对盟主显示
    self._btnPlayStatistics:setVisible(superLeague)
    
end

function UIBigLeagueGameRuleList:_gpsStateChangeFaild()
    local isOpenGps = self._bigLeagueService:isOpenGps()
    self._cbxGpsEnable:setEnabled(false)
    self._cbxGpsEnable:setSelected(isOpenGps)
    self._cbxGpsEnable:setEnabled(true)
end

function UIBigLeagueGameRuleList:_upadtaListView()
    local data = self._bigLeagueService:getLeagueData()
    local isOpenGps = self._bigLeagueService:isOpenGps()
    self._cbxGpsEnable:setEnabled(false)
    self._cbxGpsEnable:setSelected(isOpenGps)
    self._cbxGpsEnable:setEnabled(true)

    self._listviewGameRule:removeAllChildren()
    for i, gamePlay in ipairs(self._bigLeagueService:getLeagueData():getGameRules()) do
        local gameRuleNode = self._listviewItemGameRule:clone()
        self._listviewGameRule:addChild(gameRuleNode)
        gameRuleNode:setVisible(true)

        local textRuleId = seekNodeByName(gameRuleNode, "BitmapFontLabel_RuleId", "ccui.TextBMFont") -- 玩法id
        local textRuleName = seekNodeByName(gameRuleNode, "Text_RuleName", "ccui.Text") -- 玩法名称
        --local textRuleContent = ScrollText.new(seekNodeByName(gameRuleNode, "Text_RuleContent", "ccui.Text"), 26, true) -- 规则内容
        local textRuleContent = seekNodeByName(gameRuleNode, "Text_RuleContent", "ccui.Text")
        local btnEdit = seekNodeByName(gameRuleNode, "Button_Edit", "ccui.Button") -- 编辑
        local btnDetails = seekNodeByName(gameRuleNode, "Button_Details", "ccui.Button") -- 详情

        textRuleId:setString(i)
        textRuleName:setString(gamePlay.name)
        local roomSettingInfo = RoomSettingInfo.new(gamePlay.gameplays, gamePlay.roundType)

        local modeText = roomSettingInfo:getModeText()
        if modeText ~= nil then 
            local str = string.format("玩法:%s,%s,%s,%s\n赛事分系数:%s 赛事分不低于:%s\n自动解散门槛分:%s 是否允许负分:%s",
                roomSettingInfo:getZHArray()[1],
                roomSettingInfo:getZHArray()[2],
                roomSettingInfo:getZHArray()[3],
                modeText,
                gamePlay.scoreCoefficient,
                gamePlay.joinThreshold,
                gamePlay.finishScore,
                gamePlay.canNegative and "是" or "否"
            )
            textRuleContent:setString(str)
        else 
            local str = string.format("玩法:%s,%s,%s\n赛事分系数:%s 赛事分不低于:%s\n自动解散门槛分:%s 是否允许负分:%s",
                roomSettingInfo:getZHArray()[1],
                roomSettingInfo:getZHArray()[2],
                roomSettingInfo:getZHArray()[3],
                gamePlay.scoreCoefficient,
                gamePlay.joinThreshold,
                gamePlay.finishScore,
                gamePlay.canNegative and "是" or "否",t
            )
            textRuleContent:setString(str)
        end 

        btnEdit:setVisible(self._bigLeagueService:getIsSuperLeague())
        btnDetails:setVisible(not self._bigLeagueService:getIsSuperLeague())

        bindEventCallBack(btnEdit, function ()
            UIManager:getInstance():show("UIBigLeagueGameRuleEdit", gamePlay)
        end, ccui.TouchEventType.ended)

        bindEventCallBack(btnDetails, function ()
            UIManager:getInstance():show("UIBigLeagueGameRuleEdit", gamePlay)
        end, ccui.TouchEventType.ended)

    end

    if self._bigLeagueService:getIsSuperLeague() then
        local addGameRuleNode = self._listviewItemAddGameRule:clone()
        self._listviewGameRule:addChild(addGameRuleNode)
        addGameRuleNode:setVisible(true)
        bindEventCallBack(addGameRuleNode, function ()
            UIManager:getInstance():show("UIBigLeagueGameRuleEdit")
        end, ccui.TouchEventType.ended)
    end

    self._listviewGameRule:forceDoLayout()
end

--玩法统计
function UIBigLeagueGameRuleList:_onClickPlayStatistics()
    UIManager:getInstance():show("UIBigLeagueGamePlayStatistics")

end

function UIBigLeagueGameRuleList:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

return UIBigLeagueGameRuleList