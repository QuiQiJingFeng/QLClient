local csbPath = "ui/csb/UILastCrads.csb"
local super = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

--[[
    剩余牌
]]

local UILastCrads= class("UILastCrads", super, function() return kod.LoadCSBNode(csbPath) end)

function UILastCrads:ctor()
    self._imgLastCard = nil             -- 剩余牌背景
    self._btnContinue = nil             -- 继续按钮
    self._btnLastCrad = nil             -- 剩余牌
    self._btnReportPage = nil           -- 返回结算
    self._btnClose = nil                -- 关闭
    self._panelLastCard = nil
    self._showCards = {}

    self._timeSchedule = nil
end

function UILastCrads:init()
    self._imgLastCard = seekNodeByName(self, "Image_db_ShengYuPai", "ccui.ImageView")
    self._btnLastCrad = seekNodeByName(self, "Button_lastCrad", "ccui.Button")
    self._btnReportPage = seekNodeByName(self, "Button_reportPage", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._panelLastCard = seekNodeByName(self, "Panel_lastCard", "ccui.Layout")
    self._panelLastCard:setTouchEnabled(false)
    self._panelLastCard:setVisible(false)
    self._btnContinue = seekNodeByName(self, "Button_continue", "ccui.Button")
    self._btnContinue:setVisible(false)

	-- 剩余牌池
    self._cardListView = seekNodeByName(self, "ListView_card", "ccui.ListView");
    self._cardListView:setScrollBarEnabled(false)
    self._remainCardNode = ccui.Helper:seekNodeByName(self._cardListView, "Panel_cardsInfo")
	self._remainCardNode:removeFromParent(false)
	self:addChild(self._remainCardNode)
    self._remainCardNode:setVisible(false)

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContinue, handler(self, self._onClickContinue), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLastCrad, handler(self, self._onClickLastCrad), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReportPage, handler(self, self._onClickReportPage), ccui.TouchEventType.ended)
    bindEventCallBack(self._panelLastCard,	handler(self, self._onTouchEvent),	ccui.TouchEventType.ended)
end

function UILastCrads:_onTouchEvent(sender, event)
    local location = sender:getTouchEndPosition()
    local point = self:convertToNodeSpace(location)
    if not cc.rectContainsPoint(self._imgLastCard:getBoundingBox(), location) then
        self:_onClickClose()
    end 
end 

function UILastCrads:hideForDistory()
    self._btnLastCrad:setVisible(false)
end

-- 继续游戏
function UILastCrads:_onClickContinue()
    -- 关闭定时器
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 
    -- 清空缓存UI
    game.service.LocalPlayerService:getInstance():clearToundReportPage()
    -- 关闭界面
    UIManager:getInstance():destroy("UILastCrads")
    UIManager:getInstance():destroy("UICardsInfo_new")
    UIManager:getInstance():destroy("UIRoundReportPage2")
    -- 开始游戏
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    gameService:prepareForNextRound()
end 

-- 关闭剩余牌
function UILastCrads:_onClickClose()
    for k,v in pairs(self._showCards) do
        CardFactory:getInstance():releaseCard(v);
    end
    self._showCards = {}
    self._cardListView:removeAllChildren()

    self._panelLastCard:setVisible(false)
end

-- 显示剩余牌
function UILastCrads:_onClickLastCrad()
    -- 统计剩余牌按钮点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Last_Cards)

    local lastCards = {}
    -- 回放时从战绩中剩余牌
    if self._ui == "UIPlayback" then
        local gameService = gameMode.mahjong.Context.getInstance():getGameService()
        local roomRecord = gameService:getRoomRecord()
        local idx = gameService:getRoundReportIndex()
        lastCards = roomRecord.roundReportRecords[idx].lastCards
    else
        lastCards = self._playerRecords.lastCards
    end

    if type(lastCards) ~= "table" then
        lastCards = clone(CardDefines.getCards(lastCards));
    end

    self._cardListView:removeAllChildren()
    self:_setRemainData(lastCards)

    self._panelLastCard:setVisible(true)
end

function UILastCrads:_onClickReportPage()
    -- 清空缓存UI
    game.service.LocalPlayerService:getInstance():clearToundReportPage()

    UIManager:getInstance():show(self._ui, self._players, self._playerRecords, self._from, self._huImg, self._eventData)
    self:_clear()
    UIManager:getInstance():destroy("UILastCrads")
end

function UILastCrads:onShow(...)
    local args = {...}
    self._players = args[1]
    self._playerRecords = args[2]    
    self._from = args[3] or ""
    self._ui = args[4] or ""
    self._huImg = args[5] or {}
    self._eventData = args[6] or {}

    -- 战绩不显示返回战绩按钮
    self._btnReportPage:setVisible(self._from ~= "historyDetail") 

    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    self._mask:setTouchEnabled(self._from ~= "historyDetail")
    self._mask:setOpacity(0)

    -- 初始化定时器相关
    self:_initTimeSchedule()

    -- 牌桌界面隐藏设置按钮
    game.service.LocalPlayerService:getInstance():dispatchEvent({name = "EVENT_ROOMCARD_HIDESETTIN", isVisible = false})
    
    self:_refreshed()
end

function UILastCrads:_initTimeSchedule()
    if self._from == "historyDetail" then 
        return 
    end 
    
    local roomService = game.service.RoomService:getInstance()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if not roomService or not gameService then 
        return 
    end

    -- 检测玩家是否在大联盟牌局结算中且不为最后一局
    if not roomService:isBigLeagueReport() then 
        return 
    end 

    -- 判定剩余时间是否为0
    local retainTime = roomService:getBattleEndRetainTime()
    if retainTime <= 0 then 
        return 
    end

    -- 隐藏返回结算
    self._btnReportPage:setVisible(false)
    -- 隐藏关闭按钮
    self._btnClose:setVisible(false)
    self._panelLastCard:setTouchEnabled(true)
    self._btnContinue:setVisible(true)

    -- 开始倒计时...
    local titleText = self._btnContinue:getChildByName("BitmapFontLabel_1")
    titleText:setString(string.format("继续(%dS)", retainTime))
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 
    self._btnContinue:setVisible(true)

    local function _update(dt)
        retainTime = retainTime - 1 
        titleText:setString(string.format("继续(%dS)", retainTime))
        if retainTime <= 0 then 
            -- 关闭定时器
            if self._timeSchedule ~= nil then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
                self._timeSchedule = nil
            end 
            self:_onClickContinue()
        end 
    end 
    self._timeSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_update, 1, false)
end 

-- 处理断线重连逻辑
function UILastCrads:_refreshed()
    if self._ui == "UIPlayback" then
        return
    end
    local data = game.service.LocalPlayerService:getInstance():loadLocalRoundReportPage()
    data:setIsVisible(self._ui == "UICardsInfo_new" and true or false, true)
    game.service.LocalPlayerService:getInstance():saveLocalRoundReportPage(data)
end

--设置牌局余牌
function UILastCrads:_setRemainData(remainData)
    --没有余牌(黄庄)，不显示余排区域
    if #remainData == 0 then
        return;
    end

    local node = self._remainCardNode:clone()
    node:setVisible(true)
    self._cardListView:addChild(node)

    local colNum = 21
    --根据行数动态设置背景层大小
    node:setContentSize(cc.size(node:getContentSize().width
        , node:getContentSize().height * math.ceil(#remainData / colNum)))

    local yupaiY = node:getContentSize().height - 28
    local yupaiX = 20
    local tempYupaiX = yupaiX
    local floor = 0;

    for i, cardValue in ipairs(remainData) do
        local cardInfo = self:_addOneCard(node, cardValue, yupaiX, yupaiY)
        cardInfo:setScale(0.7)
        cardInfo:setPositionX(yupaiX);
        cardInfo:setPositionY(yupaiY -  (cardInfo:getContentSize().height * 0.5 + 12) * floor )
        yupaiX = yupaiX + cardInfo:getContentSize().width * cardInfo:getScale()

        if i % colNum == 0 then
            floor = floor + 1;
            yupaiX = tempYupaiX;
        end
    end
end

-- 创建牌
function UILastCrads:_addOneCard(box, cardValue, x, y, zOrder, playtype)
    if type(cardValue) ~= "number" then
        return
    end

    local cardInfo = CardFactory:getInstance():CreateCard({ chair = CardDefines.Chair.Down, state = playtype or CardDefines.CardState.Chupai, cardValue = cardValue});
    table.insert(self._showCards,cardInfo);
    zOrder = zOrder or 0
    box:addChild(cardInfo, zOrder)
    cardInfo:setPositionX(x);
    cardInfo:setPositionY(y - 13);
    cardInfo:setScale(1.5)

    return cardInfo;
end

function UILastCrads:_clear()
    game.service.LocalPlayerService:getInstance():dispatchEvent({name = "EVENT_ROOMCARD_HIDESETTIN", isVisible = true})
end

function UILastCrads:onHide()
    if self._timeSchedule ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeSchedule)
        self._timeSchedule = nil
    end 
    -- 再运行次，避免牌局自动开始，缓存数据没有及时清空
    self:_onClickClose()
end

function UILastCrads:needBlackMask()
	return true
end

function UILastCrads:closeWhenClickMask()
	return false
end


return UILastCrads