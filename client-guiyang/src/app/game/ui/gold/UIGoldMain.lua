local GameplayNameConfig = {
    ['换三张两次'] = "art/gold/gameplay_name_1.png",
    ['急速玩法'] = "art/gold/gameplay_name_2.png",
    ['四人玩法'] = "art/gold/gameplay_name_3.png",
    ['三丁两房'] = "art/gold/gameplay_name_4.png",
    ['明牌加倍'] = "art/gold/gameplay_name_5.png",
    ['血流玩法'] = "art/gold/gameplay_name_6.png",
    ['癞子玩法'] = "art/gold/gameplay_name_7.png",
    ['换三张'] = "art/gold/gameplay_name_8.png",
    ['二人玩法'] = "art/gold/gameplay_name_11.png",
}
local UI_ANIM = require("app.manager.UIAnimManager")

-- 货币工具
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade

local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Gold/UIGoldMain.csb"
local UIGoldMain = class("UIGoldMain", super, function() return kod.LoadCSBNode(csbPath) end)


function UIGoldMain:ctor()
    super.ctor(self)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGoldMain:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UIGoldMain:init()

    self._btnClose = seekNodeByName(self, "btnReturn", "ccui.Button")
    self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")

    self._panelNode = seekNodeByName(self, "middle", "ccui.Layout")

    -- 进行匹配的不同节点组
    self._matchRoomNode = {
        [Enum_RoomGrade.FIRST] = seekNodeByName(self, "panelMatchGame1", "ccui.Layout"),
        [Enum_RoomGrade.SECOND] = seekNodeByName(self, "panelMatchGame2", "ccui.Layout"),
        [Enum_RoomGrade.THIRD] = seekNodeByName(self, "panelMatchGame3", "ccui.Layout"),
        [Enum_RoomGrade.FOUR] = seekNodeByName(self, "panelMatchGame4", "ccui.Layout"),
        [Enum_RoomGrade.QUICK] = seekNodeByName(self, "btnQucikMatch", "ccui.Button")
    }

    -- 将不同节点的需要改动的节点读出
    for k, v in pairs(self._matchRoomNode) do
        if k ~= Enum_RoomGrade.QUICK then
            v.baseScore = seekNodeByName(v, "baseScore", "ccui.TextBMFont")
            v.minGold = seekNodeByName(v, "minGold", "ccui.TextBMFont")
            v.peopleNum = seekNodeByName(v, "peopleNum", "ccui.Text")
            v.textGift = seekNodeByName(v, "textGiftInfo", "ccui.TextBMFont")
            v.textGift2 = seekNodeByName(v, "textGiftInfo2", "ccui.TextBMFont")
            v.reddot = seekNodeByName(v, "Image_Reddot", "ccui.ImageView")
            v.particle_double = seekNodeByName(v, "Particle_Double", "cc.ParticleSystemQuad")
            v.textGift2_double = seekNodeByName(v.particle_double, "BMFont", "ccui.TextBMFont")

            -- default invisible
            v.reddot:setVisible(false)
            v.particle_double:setVisible(false)
        end
        v:setVisible(false)
    end


    self._layoutGoldCurrency = seekNodeByName(self, "ImageView_Buy_Gold", "ccui.ImageView")   --购买金币
    self._layoutBeanCurrency = seekNodeByName(self, "ImageView_Buy_Bean", "ccui.ImageView")   --购买金豆
    self._btnGift = seekNodeByName(self, "btnGift", "ccui.Button")   --兑换礼券

    -- 玩法内容
    self._gameplayContainer = seekNodeByName(self, "Image_Gameplay", "ccui.ImageView")
    self._imgGameplayCategory = seekNodeByName(self._gameplayContainer, "Image_Category", "ccui.ImageView")
    self._imgGameplayName = seekNodeByName(self._gameplayContainer, "Image_Gameplay_Name", "ccui.ImageView")
    self._gameplayContainer:setVisible(false)
    self:_registerCallBack()
end

function UIGoldMain:_registerCallBack()
    --为不同的匹配节点增加点击事件
    for k, v in pairs(self._matchRoomNode) do
        if k == Enum_RoomGrade.QUICK then
            bindEventCallBack(v, function()
                self:_onStartMatchClick(k)
            end, ccui.TouchEventType.ended)
        else
            bindTouchEventWithEffect(v, function()
                self:_onStartMatchClick(k)
            end, 1.05)
        end
    end

    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onBtnHelpClick), ccui.TouchEventType.ended)


end

function UIGoldMain:onShow()
    self._panelNode:setOpacity(10)
    self._panelNode:runAction(cc.EaseOut:create(cc.FadeTo:create(0.5, 255), 1.5))

    local LocalPlayerService = game.service.LocalPlayerService.getInstance()

    local goldService = game.service.GoldService.getInstance()

    --监听金币场数据,用于设置金币场各房间的数据
    goldService:addEventListener("EVENT_GOLD_ROOM_INFO_RECEIVE", handler(self, self._setRoomInfo), self)
    --监听金币场人数数据,用于设置金币场各房间的人数数据
    -- goldService:addEventListener("EVENT_GOLD_PEOPLE_NUM_RECEIVE", handler(self, self._setPeopleInfo), self)
    -- self:_setRoomInfo()
    if goldService:checkIsNeedBrokeHelp() then
        UIManager.getInstance():show("UIGoldBrokeHelp")
    end

    self._bindKeys = {
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.GOLD, self._layoutGoldCurrency),
        CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.BEAN, self._layoutBeanCurrency),
    }
    -- 按钮不取消绑定也没关系
    CurrencyHelper.getInstance():getBinder():bindAddButton(CurrencyHelper.CURRENCY_TYPE.GOLD, self._btnGift)
end

function UIGoldMain:onHide()
    local goldService = game.service.GoldService.getInstance()
    goldService:removeEventListenersByTag(self)
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)

    for _, key in ipairs(self._bindKeys or {}) do
        CurrencyHelper.getInstance():getBinder():unbind(key)
    end
    self._bindKeys = {}
end

-- 设置每个房间的具体数据
function UIGoldMain:_setRoomInfo()
    local goldService = game.service.GoldService.getInstance()

    for _, v in pairs(goldService.dataRoomInfo.goldRooms) do
        local node = self._matchRoomNode[v.grade]
        node.baseScore:setString(string.format(v.bottomScore))
        -- gold范围显示
        local strMin = nil
        local strMax = kod.util.String.formatMoney(v.maxGold, 2)
        if (v.minGold < 10000) then
            strMin = (v.minGold / 1000) .. "千"
        else
            strMin = kod.util.String.formatMoney(v.minGold, 2)
        end
        if v.grade ~= 4 then
            node.minGold:setString(strMin .. "-" .. strMax)
        else
            node.minGold:setString(strMin .. "以上")
        end
        local battleForMallPointInfo = v.battleForMallPointInfo
        node.textGift:setString(string.format("%d局送", battleForMallPointInfo.needRoundForMallPoint))
        node.textGift2:setString(string.format("%s礼券", battleForMallPointInfo.isDoubleTime and "" or tostring(battleForMallPointInfo.rewardMallPoint)))
        node.textGift2_double:setString(tostring(battleForMallPointInfo.rewardMallPoint))

        node.textGift:setVisible(battleForMallPointInfo.rewardMallPoint ~= 0)
        node.textGift2:setVisible(battleForMallPointInfo.rewardMallPoint ~= 0)
        node.reddot:setVisible(battleForMallPointInfo.isDoubleTime)
        node.particle_double:setVisible(battleForMallPointInfo.isDoubleTime)
        node.textGift2_double:setVisible(battleForMallPointInfo.isDoubleTime)
        node:setVisible(true)
    end
    
    local quickMatchNode = self._matchRoomNode[Enum_RoomGrade.QUICK]
    if quickMatchNode then
        quickMatchNode:setVisible(true)
    end

    self:refreshGameplay()
end

-- 设置每个房间人数的数据
function UIGoldMain:_setPeopleInfo(event)
    for _, v in ipairs(event.protocol.roomInfos) do
        local node = self._matchRoomNode[v.grade]

        local currPlayerNum = v.currPlayerNum
        if (currPlayerNum >= 10000) then
            currPlayerNum = math.floor(currPlayerNum / 1000) / 10 .. "万"
        elseif currPlayerNum >= 1000 then
            currPlayerNum = math.floor(currPlayerNum / 100) / 10 .. "千"
        end

        node.peopleNum:setString(currPlayerNum .. "人")
    end
end


--  请求匹配
function UIGoldMain:_onStartMatchClick(grade)
    game.service.GoldService.getInstance():trySendCGoldMatchREQ(grade)
end

-- 点击帮助-问号
function UIGoldMain:_onBtnHelpClick(sender)
    UIManager.getInstance():show("UIGoldHelp")
end

-- 退出金币场
function UIGoldMain:_onBtnCloseClick(sender)
    GameFSM.getInstance():enterState("GameState_Lobby")
end

function UIGoldMain:destroy()
end

function UIGoldMain:refreshGameplay()
    local currentGameplay = game.service.GoldService.getInstance():getCurrentGameplay()
    local limitGameplay = game.service.GoldService.getInstance():getLimitGameplay()

    local isCurrentLimit = false
    if limitGameplay then
        isCurrentLimit = currentGameplay.id == limitGameplay.id
    end

    local categoryPNGPath
    local gameplayNamePNGPath = GameplayNameConfig[currentGameplay.title]
    if isCurrentLimit then
        categoryPNGPath = "art/gold/gameplay_special.png"
    else
        categoryPNGPath = "art/gold/gameplay_normal.png"
    end

    if categoryPNGPath and gameplayNamePNGPath then
        self._imgGameplayCategory:loadTexture(categoryPNGPath)
        self._imgGameplayName:loadTexture(gameplayNamePNGPath)
        self._gameplayContainer:setVisible(true)
    else
        self._gameplayContainer:setVisible(false)
    end
end



return UIGoldMain