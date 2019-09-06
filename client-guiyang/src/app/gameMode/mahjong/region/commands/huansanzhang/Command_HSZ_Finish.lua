local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require("app.gameMode.mahjong.core.Constants")
local Effect_Clockwise = "ui/csb/Effect/HuanSanZhang/Effect_HuanSanZhang_Rotate_Clockwise.csb"
local Effect_Anticlockwise = "ui/csb/Effect/HuanSanZhang/Effect_HuanSanZhang_Rotate_Anticlockwise.csb"
local Effect_Path = Effect_Clockwise
local UIAnimManager = require("app.manager.UIAnimManager").UIAnimManager
local HSZ_CHANGE_CARDS_ANIM_TIME = 1.5
local HSZ_INSERT_CARD_ANIM_TIME = 0.5
local OTHER_PLAYER_ISNERT_CARD_ANIM_FIXED_POSITIONS = { 2, 5, 10 }

local Command_HSZ_Finish = class("Command_HSZ_Finish", super)
function Command_HSZ_Finish:ctor(args)
    Command_HSZ_Finish.super.ctor(self, args)
end

-- 这里是换三张，下方得到的牌
function Command_HSZ_Finish:execute(args)
    -- 如果不是下方玩家，就播放动画了
    if self._processor:getRoomSeat():getChairType() ~= CardDefines.Chair.Down then
        return
    end

    local step = self._stepGroup[1]
    -- 关闭多选
    self._processor:getSeatUI():setMultiSelectedEnabled(false)
    -- 根据step设置动画文件路径
    self:setAnimPath(step)

    -- 动态设定时间
    local totalTime = 0
    totalTime = totalTime + HSZ_CHANGE_CARDS_ANIM_TIME + HSZ_INSERT_CARD_ANIM_TIME
    -- 1、播放换牌动画
    self:playFinishAnim()
    -- 2、播放插牌动画（因为Finish只会发给本客户端的当前玩家，所以要自行对其他的玩家进行操作）
    self:scheduleAllManInsertAnim(step:getCards())
    -- 3、关闭提示UI
    UIManager:getInstance():hide("UIHuanSanZhang")
    -- 4、延迟提示庄家出牌
    scheduleOnce(handler(self, self.onAnimCompleted), totalTime)
    self._processor:addNextIdleTime(totalTime)
end

function Command_HSZ_Finish:scheduleAllManInsertAnim(cardValues)
    scheduleOnce(function()
        local playerMap = game.service.RoomService:getInstance():getPlayerMap()
        local gameService = gameMode.mahjong.Context.getInstance():getGameService()
        for key, player in pairs(playerMap) do
            local processor = gameService:getPlayerProcessorByPlayerId(player.roleId)
            -- 如果牌数量过多就不插入了
            if #processor:getCardList().handCards < 13 then
                self:addHandCardByValuesWithInsertAnim(processor, cardValues)
            end
        end
    end, HSZ_CHANGE_CARDS_ANIM_TIME)
end

function Command_HSZ_Finish:playFinishAnim()
    -- 如果在这个定时的时候退出了房间呢？
    UIAnimManager:getInstance():onShow({
        _path = Effect_Path,
        _parent = UIManager:getInstance():getUI("app.gameMode.mahjong.ui.UIGameScene_Mahjong")
    })
end

function Command_HSZ_Finish:addHandCardByValuesWithInsertAnim(processor, cardValues)
    local isDownPlayer = processor:getRoomSeat():getChairType() == CardDefines.Chair.Down
    local seatUI = processor:getSeatUI()
    -- 不是下方玩家直接过滤掉
    if not isDownPlayer then
        return
    end
    local cardList = processor:getCardList()
    local insertedCards = {}

    for index, value in ipairs(cardValues) do
        local card_scale = seatUI:CARD_SCALE()
        if not config.getIs3D() and seatUI:getChairType() ~= CardDefines.Chair.Down and value ~= 255 then
            card_scale = seatUI:GROUP2_SCALE()
        end
        local card = seatUI:createCard(CardDefines.CardState.Shoupai, value, cardList:getCardCornerTypes(value), card_scale, index)
        if config.getIs3D() and seatUI._resizeCard then
            seatUI:_resizeCard(card, index - 1)
        end
        cardList:addHandCard(card)
        table.insert(insertedCards, card)
    end
    seatUI:ManageCardsPositions(cardList, seatUI:getCardLayout(), true)

    -- 若不是本地玩家，插入牌的动画的位置为固定值
    if not isDownPlayer then
        insertedCards = {}
        for _, pos in ipairs(OTHER_PLAYER_ISNERT_CARD_ANIM_FIXED_POSITIONS) do
            table.insert(insertedCards, cardList.handCards[pos])
        end
    end

    -- play insert animation
    local yOffset = isDownPlayer == true and 30 or 5
    for _, cardObject in ipairs(insertedCards) do
        local rawPosition = cc.p(cardObject:getPosition())
        local _pos = cc.pAdd(rawPosition, cc.p(0, yOffset))
        cardObject:setPosition(_pos)

        local action = cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.MoveTo:create(HSZ_INSERT_CARD_ANIM_TIME, rawPosition)
        )
        cardObject:stopAllActions()
        cardObject:runAction(action)
    end
end

function Command_HSZ_Finish:setAnimPath(step)
    local playType = step:getPlayType()
    local chairType = self._processor:getRoomSeat():getChairType()
    local cards = step:getCards()
    local animRotateDirection = step:getDatas()[1]
    if animRotateDirection == 0 then -- 顺时针
        Effect_Path = Effect_Clockwise
    elseif animRotateDirection == 1 then -- 逆时针
        Effect_Path = Effect_Anticlockwise
    end
end

function Command_HSZ_Finish:onAnimCompleted()
    -- 提示玩家如果是庄家则出牌， 并且要是最后一次换的时候才提示
    local currentChangeTime = self._stepGroup[1]:getDatas()[2] or 0
    local totalChangeTime = self._stepGroup[1]:getDatas()[3] or 0
    if self._processor:getRoomSeat():getPlayer():isBanker() and currentChangeTime == totalChangeTime then
        -- 没有或者隐藏则显示他
        local ui = UIManager:getInstance():getUI("UIHuanSanZhang")
        if ui == nil or not ui:isVisible() then
            ui = UIManager:getInstance():show("UIHuanSanZhang")
        end
        ui:showBankerDiscardTipsAndAutoHide()
    else
        -- 不是庄家直接关闭
        UIManager:getInstance():hide("UIHuanSanZhang")
    end
    
    local ui = UIManager.getInstance():getUI("app.gameMode.mahjong.ui.UIGameScene_Mahjong")
    if ui then
        local uiRoom = ui:getRoomUI()
        if uiRoom then
            uiRoom:doCountDown(CardDefines.Chair.Down)
        end
    end
end

return Command_HSZ_Finish