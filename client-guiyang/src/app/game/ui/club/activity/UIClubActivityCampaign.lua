local csbPath = "ui/csb/Club/UIClubActivityCampaign.csb"
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants");
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local PropTextConvertor = game.util.PropTextConvertor

-- 每一个listView里panel的显示
local UICellModel = class( "UICellModel" ) 

function UICellModel:ctor( uiroot , data  , signIds )
    self._gameCode = seekNodeByName(uiroot , "BitmapFontLabel_11" , "ccui.TextBMFont")  -- 赛事码
    self._BtnText = seekNodeByName(uiroot, "BitmapFontLabel_40" ,"ccui.TextBMFont")
    self._BtnSignUp   = seekNodeByName(uiroot , "Button_An_FangKa" , "ccui.Button")  -- 右下角按钮，有【比赛中，已报名，报名几种状态】
    self._BtnGameResult = seekNodeByName(uiroot, "Button_An_FangKa_0" , "ccui.Button") --比赛结束
    self._gameName = seekNodeByName(uiroot , "Text_23" , "ccui.Text" )      -- 赛事名称
    self._numLimit = seekNodeByName(uiroot , "Text_24_0" , "ccui.Text" )      -- 人数限制
    self._leastLimit = seekNodeByName(uiroot, "Text_24" , "ccui.Text")      -- 最低开赛人数
    self._time     = seekNodeByName(uiroot , "Text_25" , "ccui.Text")       -- 时间
    self._gameCost = seekNodeByName(uiroot , "Text_22" , "ccui.Text")       -- 花费
    self._btnGameInfo = seekNodeByName(uiroot , "Panel_campaignItem", "ccui.Layout")    -- 详情按钮
    self._data = data
    self._uiroot = uiroot
    self._signIds = signIds
    self._countDownTime = 3600000    -- 显示倒计时时间
    self:setGameInfo(data)
    self:setStartTime()
    self:setBtnTextAndCallBack(signIds)
    
    
    bindEventCallBack(self._BtnGameResult, handler(self, self._onShowGameResult), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGameInfo, handler(self, self._onBtnGameInfoClick), ccui.TouchEventType.ended)
end

function UICellModel:setGameInfo(data)
    -- 数据填充
    self._gameCode:setString(data.code)
    self._gameName:setString(data.name)
    self._numLimit:setString("已报名" .. data.playerCount .. "人")
    self._gameCost:setString("报名费:" .. PropTextConvertor.generateFeeText(data.cost))
    self._leastLimit:setString("最低" .. data.leastCount .."人开赛")
end

-- 生成报名费显示
function UICellModel:_generateFee(items)
    local result = ""

    -- 取出优先级最高的
    table.sort(items, function (a,b)
        return a > b
    end)

    if #items == 0 then return config.STRING.UICLUBACTIVITYCAMPAIGN_STRING_100 end
    result = PropReader.generatePropTxt({items[1].item})
    return result
end


-- 设置每个赛事的状态（已报名，未报名）
-- ids  已报名ID
function UICellModel:setBtnTextAndCallBack(ids)
    self._BtnGameResult:setVisible(false)
    local btnText = ""
    if ids then
        if table.indexof(ids,self._data.id) then
            btnText = "取消报名"
            bindEventCallBack(self._BtnSignUp, handler(self, self._onbtnCancel), ccui.TouchEventType.ended)
        else
            btnText = "立即报名"
            bindEventCallBack(self._BtnSignUp, handler(self, self._onBtnSignUpClick), ccui.TouchEventType.ended)
        end
    else
        btnText = "立即报名"
        bindEventCallBack(self._BtnSignUp, handler(self, self._onBtnSignUpClick), ccui.TouchEventType.ended)
    end
    if self._data.status == config.CampaignConfig.CampaignStatus.END or self._data.status == config.CampaignConfig.CampaignStatus.STOP then
        self._time:setVisible(true)
        self._BtnGameResult:setVisible(true)
        self._BtnSignUp:setVisible(false)
    elseif self._data.status == config.CampaignConfig.CampaignStatus.ONGOING then
        btnText = "比赛中"
        self._time:setString("已于" .. self:_convertToDate(self._data.createTimestamp) .. "开赛")
        self._BtnSignUp:setTouchEnabled(false)
    end
    self._BtnText:setString(btnText)
end

function UICellModel:setStartTime()

    self._uiroot:stopAllActions()

    local timeInterval= self._data.createTimestamp - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    local isShowTickCount = timeInterval < self._countDownTime   -- 是否在一个小时以内

    if isShowTickCount  then
        if timeInterval > 0 then
            self._time:setString("")
            local seq = cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create(function()
                local timeInterval= self._data.createTimestamp - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
                if timeInterval > 0 then 
                    self._time:setString("还有 \n" .. self:_convertToTime(timeInterval) .. "开赛")
                end
            end)) 
            local  act = cc.RepeatForever:create(seq)
            self._uiroot:runAction(act)
        else
            self._time:setVisible(false)
            self._time:setString("已于" .. self:_convertToDate(self._data.endTime) .. "结束")
        end
    else
        self._time:setString(self:_convertToDate(self._data.createTimestamp) .. "开赛")
    end
end

function UICellModel:_convertToTime(stamp)
    return os.date("%M:%S",stamp/1000)
end

function UICellModel:_convertToDate(stamp)
    -- body
    return os.date("%m",stamp/1000).."月"..os.date("%d",stamp/1000).."日\n " .. os.date("%H",stamp/1000) .. ":" ..  os.date("%M",stamp/1000)
end

-- 报名按钮回调
function UICellModel:_onBtnSignUpClick()
    game.service.CampaignService.getInstance():sendCCASignUpREQ(self._data.id,self._data.configId,1)
end

function UICellModel:_onShowGameResult()
    game.service.CampaignService.getInstance():getSelfbuildService():onCampaignCreatePlayerREQ(self._data.id)
end

function UICellModel:_onBtnGameInfoClick()
    self._data._signIds = self._signIds
    UIManager:getInstance():show("UICampaignDetailPage_Club", self._data)
end

function UICellModel:_onbtnCancel()
    game.service.CampaignService.getInstance():sendCCASignUpCancelREQ(self._data.id) 
end

local UIClubActivityCampaign = class("UIClubActivityCampaign", super,function() return cc.CSLoader:createNode(csbPath) end)
function UIClubActivityCampaign:ctor(parent)
    self._parent = parent
    
    self._gameData = {}   -- 赛事列表数据
    self._nodeSubUIAnchor = nil         -- 子页面锚点

    self._btnCreate = seekNodeByName(self, "Button_cjbs" , "ccui.Button")           -- 创建按钮
    self._btnBack       = seekNodeByName(self, "Button_2_MaJiangSaiShi","ccui.Button") -- 返回按钮
    self._panelgame    = seekNodeByName(self, "Panel_dw_MaJiangSaiShi", "ccui.Layout")   -- 比赛列表panel
    self._panelModel    = seekNodeByName(self, "Panel_campaignItem", "ccui.Layout")   -- 列表参考Panel
    self._gameList      = seekNodeByName(self, "ListView_CampaignList", "ccui.ListView")  -- 滑动列表
    self._title       = seekNodeByName(self, "BitmapFontLabel_30", "ccui.TextBMFont")
    self._listContainer = seekNodeByName(self, "listContainer", "ccui.ListView")
    self._textNone = seekNodeByName(self, "textnone", "ccui.Text")

    self._isManager = false
    self._clubId = 0
    
    -- self._textCreateorJoin = seekNodeByName(self, "BitmapFontLabel_8", "ccui.TextBMFont")     -- 创建按钮上方文字（创建比赛/加入比赛）
    self._panelModel:retain()
    self._panelModel:removeFromParent()
    -- self._gameList:setScrollBarOpacity(0)
    self:_registerCallBack()
end

function UIClubActivityCampaign:_registerCallBack()
    bindEventCallBack(self._parent._btnHelp, handler(self, self._onBtnHelpClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate, handler(self, self._onBtnCreateClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._parent._btnRewards, handler(self, self._onBtnRecordClick), ccui.TouchEventType.ended)
end

function UIClubActivityCampaign:show()
    local campaignService = game.service.CampaignService.getInstance();
    campaignService:addEventListener("EVENT_CAMPAIGN_HISTORY_RECEIVED",    handler(self, self._showCampaignHistory), self)
    campaignService:addEventListener("EVENT_CLUBCAMPAIGN_REFRESH",    handler(self, self._onCampaignDataRefresh), self)
    self:setVisible(true)
    self._parent._btnHelp:setVisible(true)
    self._parent._btnRewards:setVisible(true)
    self._parent._cardPanel:setVisible(true)

    -- 请求列表刷新
    local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
    game.service.CampaignService.getInstance():getSelfbuildService():onCampaignCreateListREQ(clubID)

    -- 如果是经理，才显示创建比赛
    local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
	local clubId = localStorageClubInfo:getClubId()
    local club = game.service.club.ClubService.getInstance():getClub(clubId)
    local managerId = club.data.managerId
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    self._isManager = club:isManager(roleId)
    self._clubId = clubId

    if not self._isManager then
        self._btnCreate:setVisible(false)
        self._btnCreate:removeFromParent()
    end
end

function UIClubActivityCampaign:_showCampaignHistory(event)
    local info = event.data
    
    --  需要排序为升序,有物品没领取的放前面
    table.sort( info, function ( a,b ) 
        return a.createTimestamp>b.createTimestamp
    end )
    
    UIManager:getInstance():show("UICampaignHistory_Club",info)    
end

function UIClubActivityCampaign:_onBtnRecordClick()
    game.service.CampaignService.getInstance():getCampaignFunctionService():onCCACampaignHistoryREQ(self._clubId)
end

function UIClubActivityCampaign:_onCampaignDataRefresh(event)
    self._gameData = event.data.campaigns
    self._textNone:setVisible(#self._gameData == 0)
    self._gameData.signIds = #event.data.campaignId > 0 and event.data.campaignId or nil
    self:insertData(self._gameData)
end

function UIClubActivityCampaign:_onBtnHelpClick()
    UIManager:getInstance():show("UICampaignCreateDesc_Club")
end


function UIClubActivityCampaign:insertData(data)
    -- 列表数据升序排列
    table.sort(self._gameData, function(a, b) 
        if a then
            return a.id > b.id 
        end
    end)
    table.sort(self._gameData, function(a, b) 
        if a then
            return a.status < b.status 
        end
    end)

    self._gameList:removeAllItems()
    for i=1,#data do
        local item = self._panelModel:clone()
        data[i].code = data[i].code
        local cell = UICellModel.new(item , data[i] ,self._gameData.signIds)
        self._gameList:addChild(item)
    end    

    local s = self._gameList:getContentSize()
    local height = self._panelModel:getContentSize().height * #data
    self._gameList:setInnerContainerSize(cc.size(s.width, height))
    self._gameList:setScrollBarEnabled(false)
end

function UIClubActivityCampaign:_onBtnCreateClick()
    if self._isManager then
        local areaId = game.service.LocalPlayerService:getInstance():getArea()
        game.service.CampaignService:getInstance():getSelfbuildService():onCampaignConfigREQ(areaId)
    else
        local cantTips = "只有群主才能创建比赛！"    -- 非经理自建赛创建 tips提示
        game.ui.UIMessageTipsMgr:getInstance():showTips( cantTips )
    end
end

function UIClubActivityCampaign:hide()
    self:setVisible(false)
    self._parent._btnHelp:setVisible(false)
    self._parent._btnRewards:setVisible(false)
    self._parent._cardPanel:setVisible(false)

    -- 取消事件监听
    game.service.CampaignService.getInstance():removeEventListenersByTag(self)
end

function UIClubActivityCampaign:dispose()
    self._panelModel:release()
    self._panelModel = nil
end

return UIClubActivityCampaign
