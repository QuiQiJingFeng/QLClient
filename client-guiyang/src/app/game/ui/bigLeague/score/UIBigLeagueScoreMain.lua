--[[
    积分界面入口
]]
local csbPath = "ui/csb/BigLeague/UIBigLeagueScoreMain.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueScoreMain:UIBase
local UIBigLeagueScoreMain = super.buildUIClass("UIBigLeagueScoreMain", csbPath)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local images ={
    "art/bigLeague/img_title1_dlm.png",
    "art/bigLeague/img_title2_dlm.png",
    "art/bigLeague/img_title3_dlm.png",
    "art/bigLeague/img_title4_dlm.png",
    "art/bigLeague/img_title5_dlm.png",
    "art/bigLeague/img_title6_dlm.png",
    "art/bigLeague/img_title8_dlm.png",
    "art/bigLeague/img_title9_dlm.png",
    "art/bigLeague/img_title7_dlm.png",
}

function UIBigLeagueScoreMain:ctor()

end

function UIBigLeagueScoreMain:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭

    self._imgLeftScore = seekNodeByName(self, "Image_LeftScore", "ccui.ImageView")
 
    self._btnLeftScore = seekNodeByName(self, "Button_LeftScore", "ccui.Button")
    self._BMLeftScore = seekNodeByName(self, "BM_LeftScore", "ccui.TextBMFont")

    self._imgFireScore = seekNodeByName(self, "Image_FireScore", "ccui.ImageView")
    self._btnFireScore = seekNodeByName(self, "Button_FireScore", "ccui.Button")
    self._BMFireScore = seekNodeByName(self, "BM_FireScore", "ccui.TextBMFont")
    self._btnExchange = seekNodeByName(self, "Button_Exchange", "ccui.Button")
    self._btnFireScore2 = seekNodeByName(self, "Button_FireScore2", "ccui.Button")
    self._btnFireScore2:setVisible(false)

    self._imgTotalScore = seekNodeByName(self, "Image_TotalScore", "ccui.ImageView")
    self._btnTotalScore = seekNodeByName(self, "Button_TotalScore", "ccui.Button")
    self._BMTotalScore = seekNodeByName(self, "BM_TotalScore", "ccui.TextBMFont")

    self._panelLeagueName = seekNodeByName(self, "Panel_22", "ccui.Layout")
    self._textLeagueInfo = seekNodeByName(self, "Text_LeagueInfo", "ccui.Text")
    self._textHostName = seekNodeByName(self, "Text_HostName", "ccui.Text")

    self._BMTitle = seekNodeByName(self, "BitmapFontLabel_6", "ccui.TextBMFont")
    self._BMTitleScore = seekNodeByName(self, "BitmapFontLabel_2", "ccui.TextBMFont")
    self._titleScoreBg = seekNodeByName(self, "Image_22", "ccui.ImageView")

    self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button")
end

function UIBigLeagueScoreMain:_onBtnClose()
    self:hideSelf()
end

function UIBigLeagueScoreMain:_registerCallBack()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLeftScore,        handler(self, self._onBtnLeftScore),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFireScore,        handler(self, self._onBtnFireScore),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnFireScore2,        handler(self, self._onBtnFireScore),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnTotalScore,       handler(self, self._onBtnTotalScore),       ccui.TouchEventType.ended)
    bindEventCallBack(self._btnExchange,        handler(self, self._onBtnExchange),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp,            handler(self, self._onBtnHelp),             ccui.TouchEventType.ended)
end
--
--nType:1表示联盟积分状况(A的入口),这个时候不用传clubId
--2表示俱乐部积分状况(B的入口)，clubId在这个时候必须传
--
--
function UIBigLeagueScoreMain:onShow(nType, clubId, partnerId)
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    self._nType = nType
    self._partnerId = partnerId or 0
    self._clubId = clubId and clubId or self._bigLeagueService:getLeagueData():getClubId()
    
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_SCORE", handler(self, self._updateLeagueScore), self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_INFO", handler(self, self._updateScores), self)
    print("UIBigLeagueScoreMain~~~~~~~~",self._clubId)

    self._bigLeagueService:sendCCLQueryLeagueScoreREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._clubId, self._partnerId, self._nType)
    self:updateImage()
    self:_registerCallBack()
end

function UIBigLeagueScoreMain:updateImage()
    self._imgLeftScore:ignoreContentAdaptWithSize(true)
    self._imgFireScore:ignoreContentAdaptWithSize(true)
    self._imgTotalScore:ignoreContentAdaptWithSize(true)
    if self._nType == 1 then
        self._imgLeftScore:loadTexture(images[1])
        self._imgFireScore:loadTexture(images[2])
        self._imgTotalScore:loadTexture(images[3])
        self._BMTitleScore:setVisible(false)
        self._titleScoreBg:setVisible(false)
        self._btnFireScore:setVisible(true)
        self._btnExchange:setVisible(true)
        self._btnFireScore2:setVisible( false)
        self._BMTitle:setString("赛事明细")
    elseif self._nType == 2 then
        self._imgLeftScore:loadTexture(images[4])
        self._imgFireScore:loadTexture(images[5])
        self._imgTotalScore:loadTexture(images[6])
        self._BMTitleScore:setVisible(true)
        self._titleScoreBg:setVisible(true)
        local isSuperLeader =  self._bigLeagueService:getIsSuperLeague() 
        self._btnFireScore:setVisible(not isSuperLeader)
        self._btnExchange:setVisible(not isSuperLeader)
        self._btnFireScore2:setVisible( isSuperLeader)
        self._BMTitle:setString("团队赛事分概况")
    else
        self._imgLeftScore:loadTexture(images[7])
        self._imgFireScore:loadTexture(images[8])
        self._imgTotalScore:loadTexture(images[9])
        self._BMTitleScore:setVisible(true)
        local isPartner =  self._bigLeagueService:getLeagueData():isPartner() 
        self._btnFireScore:setVisible(isPartner)
        self._btnExchange:setVisible(isPartner)
        self._btnFireScore2:setVisible(not isPartner)
        self._BMTitle:setString("搭档赛事分概况")
    end
   
end

function UIBigLeagueScoreMain:onHide()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIBigLeagueScoreMain:needBlackMask()
    return true
end

function UIBigLeagueScoreMain:closeWhenClickMask()
    return false
end

function UIBigLeagueScoreMain:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeagueScoreMain:_onBtnLeftScore()
    print("_onBtnLeftScore~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    UIManager:getInstance():show("UIBigLeagueScoreDetail", self._nType, 1, self._clubId, self._partnerId)
end

function UIBigLeagueScoreMain:_onBtnFireScore()
    UIManager:getInstance():show("UIBigLeagueScoreDetail", self._nType, 2, self._clubId, self._partnerId)
end

function UIBigLeagueScoreMain:_onBtnTotalScore()
    if self._nType == 1 then
        UIManager:getInstance():show("UIBigLeagueTeamScore")
    elseif self._nType == 4 then
        UIManager:getInstance():show("UIBigLeaguePartnerScore",self._nType, self._clubId, self._partnerId)
    else
        UIManager:getInstance():show("UIBigLeagueClubScore",self._nType, self._clubId)
    end
end

function UIBigLeagueScoreMain:_updateLeagueScore()
    local curScore, fireScore, totalScore, managerId, managerName,fireScoreRate = self._bigLeagueService:getLeagueData():getLeagueScore()
    self._BMLeftScore:setString( math.round( curScore * 100 ) / 100)
    self._BMFireScore:setString( math.round( fireScore * 100 ) / 100)
    self._BMTotalScore:setString( math.round( totalScore * 100 ) / 100)
    -- print("_updateLeagueScore~~~~~~~~~~~~", self._nType, self._bigLeagueService:getIsSuperLeague())
    if self._nType == 2 and self._bigLeagueService:getIsSuperLeague() then
        self._panelLeagueName:setVisible(true)
        local memberInfo = self._bigLeagueService:getLeagueData():getMemberRecordByClubId(self._clubId)
        if memberInfo == nil then
            memberInfo = self._bigLeagueService:getLeagueData():getLeagueByClubId(self._clubId)
        end
        if memberInfo == nil then
            self._panelLeagueName:setVisible(false)
        else
            local str = "亲友圈:"..memberInfo.clubName.."  id:"..memberInfo.clubId
            self._textLeagueInfo:setString(str)
            
        end
    elseif self._nType == 1 then
        local str = "赛事:"..self._bigLeagueService:getLeagueData():getLeagueName().."  id:"..self._bigLeagueService:getLeagueData():getLeagueId()
        self._textLeagueInfo:setString(str)
    elseif self._nType == 4 then
        local str = "搭档:".. managerName .. "  id:"..managerId
        self._textLeagueInfo:setString(str)
    else
        local clubService = game.service.club.ClubService.getInstance()
        local clubName = clubService:getInterceptString(clubService:getClubName(self._bigLeagueService:getLeagueData():getClubId()))
        local clubId = self._bigLeagueService:getLeagueData():getClubId()
        local str = "亲友圈:"..clubName.."  id:"..clubId
        self._textLeagueInfo:setString(str)
    end
    self._textHostName:setVisible(false)
    
    self._BMTitleScore:setString("团队总分数："..math.round((curScore + fireScore + totalScore) * 100) / 100)
    if self._nType == 4 then
        self._BMTitleScore:setString("搭档总分数："..math.round((curScore + fireScore + totalScore) * 100) / 100)
    end
end

function UIBigLeagueScoreMain:_onBtnExchange()
    --game.ui.UIMessageTipsMgr.getInstance():showTips("兑换功能暂不可用")
     local curScore, fireScore, totalScore, managerId, managerName = self._bigLeagueService:getLeagueData():getLeagueScore()
     if fireScore == 0 then
         game.ui.UIMessageBoxMgr.getInstance():show("您目前没有可转换的活跃值", {"确定"})
     else
         game.ui.UIMessageBoxMgr.getInstance():show(string.format("您当前剩余活跃值为:%.2f\n是否全部转化为赛事分", math.round(fireScore* 100)/100), {"确定","取消"},
         function()
             self._bigLeagueService:sendCCLConversionScoreREQ(self._bigLeagueService:getLeagueData():getLeagueId(), self._clubId, self._partnerId)
         end,
         function()

         end)
     end
end
function UIBigLeagueScoreMain:_updateScores()
    local leftScore = self._bigLeagueService:getLeagueData():getTeamScore()
    local fireScore = self._bigLeagueService:getLeagueData():getFireScore()
    self._BMLeftScore:setString( math.round(leftScore * 100) / 100 )
    self._BMFireScore:setString("0")
end

function UIBigLeagueScoreMain:_onBtnHelp()

end
return UIBigLeagueScoreMain