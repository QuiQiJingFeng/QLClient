local Constants = require("app.gameMode.zhengshangyou.core.Constants_ZhengShangYou")

local super = require("app.game.ui.UIBase")
local UITableOptions_ZhengShangYou = class("UITableOptions_ZhengShangYou", super)
UITableOptions_ZhengShangYou.sort = {
    pass = 1, -- 小值在左
    tips = 2,
    discard = 3,
}
function UITableOptions_ZhengShangYou:ctor(root, cardList, processor)
    self._root = root
    self._processor = processor
    self._cardList = cardList
    self._values = {}
    Macro.assertFalse(self._root ~= nil and self._processor ~= nil and self._cardList ~= nil, 'got a nil param')

    self:_init()
end

function UITableOptions_ZhengShangYou:_init()
    self._btns = {
        pass = seekNodeByName(self._root, "Button_Pass", "ccui.Button"),
        tips = seekNodeByName(self._root, "Button_Tips", "ccui.Button"),
        discard = seekNodeByName(self._root, "Button_Discard", "ccui.Button"),
    }

    self:_registeCallback()
    -- self._usedBtnIndexes = {}
    self._usedBtnKeyArray = {}
    self:cleanUp()
end

function UITableOptions_ZhengShangYou:_registeCallback()
    bindEventCallBack(self._btns.pass, handler(self, self._onBtnPassClicked), ccui.TouchEventType.ended)
    bindEventCallBack(self._btns.tips, handler(self, self._onBtnTipsClicked), ccui.TouchEventType.ended)
    bindEventCallBack(self._btns.discard, handler(self, self._onBtnDiscardClicked), ccui.TouchEventType.ended)
end

function UITableOptions_ZhengShangYou:addValue(str)
    local btn = self._btns[str]
    if Macro.assertFalse(btn, "unknow controll key " .. tostring(str or 'none')) then
        table.insert(self._usedBtnKeyArray, str)
        btn:setVisible(true)
    end
    self:_refresh()
end

function UITableOptions_ZhengShangYou:setEnable(value)
    self._root:setVisible(value or false)
end

function UITableOptions_ZhengShangYou:cleanUp()
    self._usedBtnKeyArray = {}
    self:_refresh()
end

local BTN_WIDTH = 158
local BTN_MARGIN = 100
function UITableOptions_ZhengShangYou:_refresh()
    for tag, btn in pairs(self._btns) do
        btn:setVisible(false)
    end

    Macro.assertFalse(#self._usedBtnKeyArray <= 3, "usedButtonKeys size too big")
    table.sort(self._usedBtnKeyArray, function(key1, key2)
        local v1 = UITableOptions_ZhengShangYou.sort[key1] or -1
        local v2 = UITableOptions_ZhengShangYou.sort[key2] or -1
        return v1 < v2
    end)

    local count = table.nums(self._usedBtnKeyArray)
    local totalWidth = count * (BTN_WIDTH + BTN_MARGIN) - BTN_MARGIN
    local startX = -totalWidth * 0.5 + BTN_WIDTH * 0.5
    local y = 0
    local idx = 1
    for _, str in pairs(self._usedBtnKeyArray) do
        local btn = self._btns[str]
        local posX = startX + (BTN_MARGIN + BTN_WIDTH) * (idx - 1)
        btn:setPosition(posX, y)
        Logger.debug(string.format('posX = %s, name = %s', posX, btn:getName()))
        btn:setVisible(true)
        idx = idx + 1
    end
end

function UITableOptions_ZhengShangYou:_onBtnPassClicked(sender)
    Logger.debug("_onBtnPassClicked")
    local playType = Constants.PlayType.POKER_OPERATE_PASS
    self:_sendPlayType(playType)

    -- TODO 放下已抬起的牌
    if self._passCallback then
        self._passCallback()
    end
end

function UITableOptions_ZhengShangYou:_onBtnTipsClicked(sender)
    Logger.debug("_onBtnTipsClicked")
    if self._tipsCallbak then
        self._tipsCallbak()
    end
end

function UITableOptions_ZhengShangYou:setTipsHandler(callback)
    self._tipsCallbak = callback
end

function UITableOptions_ZhengShangYou:_onBtnDiscardClicked(sender)
    Logger.debug("_onBtnDiscardClicked")
    local cards = self._cardList:getSelectedCardValues() or {}
    local playType = Constants.PlayType.POKER_OPERATE_PLAY_A_CARD
    local datas = {}
    if #cards > 0 then
        self:_sendPlayType(playType, cards, datas)
        self:cleanUp()
    end
end

function UITableOptions_ZhengShangYou:_sendPlayType(playType, cards, datas)
    cards = cards or {}
    datas = datas or {}
    local keyName = table.keyof(Constants.PlayType, playType)
    Logger.info(string.format("tableOption send Type = %s, cards = %s, datas = %s", keyName, table.concat(cards, '|'), table.concat(datas, "|")))

    local gameServie = gameMode.mahjong.Context.getInstance():getGameService()
    gameServie:sendPlayStep(playType, cards or {}, datas or {})
end

function UITableOptions_ZhengShangYou:prepareForNextRound()
    self:cleanUp()
end

function UITableOptions_ZhengShangYou:dispose()
    self._tipsCallbak = nil
    self._passCallback = nil
end

return UITableOptions_ZhengShangYou