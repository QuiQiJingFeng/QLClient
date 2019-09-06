local csbPath = "ui/csb/BigLeague/UIBigLeagueGameInfoDetail.csb"
local super = require("app.game.ui.UIBase")
local UIBigLeagueGameInfoDetail = class("UIBigLeagueGameInfoDetail",super,function() return kod.LoadCSBNode(csbPath) end)
local UIRichTextEx = require("app.game.util.UIRichTextEx")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local RoomSetting = config.GlobalConfig.getRoomSetting()

function UIBigLeagueGameInfoDetail:ctor()

end

function UIBigLeagueGameInfoDetail:init()
    self._btnClose = seekNodeByName(self,"Button_Close","ccui.Button")
    self._btnDetail = seekNodeByName(self,"Button_Detail","ccui.Button")
    self._btnDetail:setLocalZOrder(1)

    self._listViewInfo = seekNodeByName(self,"ListView_Detail","ccui.ListView")
    self._panelInfo = seekNodeByName(self,"Panel_Info","ccui.Layout")

    self._panelBase = seekNodeByName(self,"Panel_Base","ccui.Layout")
    self._ruleName = seekNodeByName(self,"Text_Name","ccui.Text") 
    self._joinThreshold = seekNodeByName(self,"Text_joinThreshold", "ccui.Text")
    self._scoreCoefficient = seekNodeByName(self,"Text_ScoreRate","ccui.Text")
    self._finishScore = seekNodeByName(self,"Text_finishScore","ccui.Text")
    self._canNegtive = seekNodeByName(self,"Text_canNegtive","ccui.Text")

    self._panelGame = seekNodeByName(self,"Panel_GamePlay","ccui.Layout")
    self._textGameInfo = seekNodeByName(self,"Text_GameInfo","ccui.Text")
    self._textGameInfo:ignoreContentAdaptWithSize(true)
    self._textGameInfo:setTextAreaSize(cc.size(self._panelGame:getContentSize().width - 30,0))

    self._panelLottery = seekNodeByName(self,"Panel_Lottery","ccui.Layout")

    self._lotteryInfo = seekNodeByName( self,"ListView_lotteryinfo", "ccui.ListView")
    self._lotteryTemp = seekNodeByName( self,"Panel_DrawSettings", "ccui.Layout")
    self._lotteryTemp:setVisible(false)
    self._lotteryTemp:removeFromParent(false)
    self._lotteryTemp:retain()
    self._lotteryGold = seekNodeByName( self,"Text_lotterygold", "ccui.Text")

    self:registerCallBack()
end

function UIBigLeagueGameInfoDetail:registerCallBack()
    bindEventCallBack(self._btnClose,handler(self,self._onClose) , ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDetail,handler(self,self._onShowHelp) , ccui.TouchEventType.ended)
end

function UIBigLeagueGameInfoDetail:onShow(data)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self:_setBase(data)
    self:_setGamePlayInfo(data)
    self:_setLotteryInfo(data) 
end

--设置基础信息
function UIBigLeagueGameInfoDetail:_setBase(data)
    self._ruleName:setString(data.name)
    self._joinThreshold:setString(data.joinThreshold)
    self._scoreCoefficient:setString(data.scoreCoefficient)
    self._finishScore:setString(data.finishScore)
    local negStr = "不允许负分"
    if data.canNegative then
        negStr = "允许负分"
    end
    self._canNegtive:setString(negStr)
end

--设置玩法详情
function UIBigLeagueGameInfoDetail:_setGamePlayInfo(data)
    local str = ""
    local roomSettingInfo = RoomSettingInfo.new(data.gameplays, data.roundType)
    local tbZHArray = roomSettingInfo:getZHArray()
    for nIdx = 1,#tbZHArray do 
        str = str .. tbZHArray[nIdx]
        if nIdx ~= #tbZHArray then 
            str = str .. ","
        end
    end

    self._textGameInfo:setString(str)
end

--设置抽奖信息
function UIBigLeagueGameInfoDetail:_setLotteryInfo(data)
    self._lotteryInfo:removeAllChildren()
    local nHeight = #data.lotteryProperty * self._lotteryTemp:getContentSize().height
    local bVis = self._bigLeagueService:getIsSuperLeague() or self._bigLeagueService:getLeagueData():isManager()
    for nIdx = 1 , #data.lotteryProperty do 
        local tbLotteryInfo = data.lotteryProperty[nIdx]
        local node = self._lotteryTemp:clone()
        self._lotteryInfo:pushBackCustomItem(node)
        node:setVisible(true)
        node:setName("Panel_Lotterytemp_cloned")
        local loStr = "大赢家抽奖分:" .. tbLotteryInfo.startScore .. "-" .. tbLotteryInfo.endScore .. "  抽奖消耗赛事分:" .. tbLotteryInfo.lotteryCost
        if bVis then 
            loStr = loStr .. "  团队活跃值赠送:" .. tbLotteryInfo.clubFireScore
        end
        seekNodeByName(node,"Text_Draw", "ccui.Text"):setString(loStr)
        node:setPositionY(self._lotteryTemp:getPositionY() - (nIdx -1) * self._lotteryTemp:getContentSize().height )
    end
    self._lotteryGold:setString("抽奖配置:" .. data.lotteryMin .. " - " .. data.lotteryMax)
    self._lotteryInfo:setContentSize(cc.size(self._lotteryInfo:getContentSize().width, nHeight) )
    
    local originHight = 50
    local delt = nHeight - originHight
    local children = self._lotteryInfo:getChildren()
    for i, child in ipairs(children) do
        child:setPositionY(child:getPositionY() + delt)
    end
end

function UIBigLeagueGameInfoDetail:onHide()

end

function UIBigLeagueGameInfoDetail:dispose()
    self._lotteryTemp:release()
    self._lotteryTemp = nil
end

function UIBigLeagueGameInfoDetail:_onClose()
    UIManager:getInstance():destroy("UIBigLeagueGameInfoDetail")
end

function UIBigLeagueGameInfoDetail:_onShowHelp()
    -- 帮助界面
    local str =
    [[
1.参赛分门槛：玩家参赛分高于参赛门槛分可参加比赛；
2.允许负分：牌局中是否可以出现负分情况；
3.自动解散门槛：牌局中某位玩家赛事分不高于此门槛时，系统自动解散房间；
4.抽奖门槛：每场比赛赢家分数超过该门槛即可获得抽奖机会；
5.抽奖消耗：赢家获得抽奖机会，消耗参赛分即可获得由赛事提供的奖励，该消耗分值会为团体产生一定活跃值；
6.抽奖奖励：赛事奖励优秀牌局，为优秀选手提供奖励。
    ]]
    UIManager:getInstance():show("UIBigLeagueGameHelp", str)
end

return UIBigLeagueGameInfoDetail