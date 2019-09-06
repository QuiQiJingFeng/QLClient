local STATIC_HELP_TEXT =
[[三丁两房玩法，“条”和“筒”共72张麻将牌。
人数：3人
一、【基本规则】：
1、可碰牌，不可吃；
2、黄庄：所有牌摸完、打完， 无人胡牌。

二、【牌型算分】：
平胡，1倍底分；
自摸，1倍底分；
热炮，1倍底分；
明豆：收取杠者3倍底分；（明杠）
转弯豆：每人3倍底分；（补杠）
闷豆：每人3倍底分；（暗杠）
大对子，5倍底分；（由4个刻子和1个对子组成）
七对，10倍底分；（由7个对子组成）
清一色，10倍底分；（胡牌时，所有牌均为同一种花色）
单吊，10倍底分；（只立着一张牌，胡这张）
清单吊，20倍底分；（只立着一张牌，胡这张）
龙七对，20倍底分；（成牌时由5个对子和4个相同的牌组成，且胡的牌张为4张一样的那张牌）
清大对，15倍底分；（由大对子和清一色叠加而成）
清七对，20倍底分；（由七对和清一色叠加而成）
青龙背，30倍底分；（由龙七对和清一色叠加而成）
地龙，10倍底分；（自己碰了一对，手上剩下的全是对子，胡碰牌的第四张）
清地龙，20倍底分。

三、【鸡牌算分】：
冲锋鸡，2倍底分。
责任鸡，1倍底分。
普通鸡，1倍底分。
乌骨鸡，2倍底分。
翻牌鸡，1倍底分。
金鸡，2倍底分。
摇摆鸡，1倍底分。
本鸡，1倍底分。
星期鸡，1倍底分。
首圈鸡，3倍底分。
注：黄庄时，不计算各种豆和鸡的分数。
]]
local csbPath = "ui/csb/Gold/UIGoldhelp.csb"
local super = require("app.game.ui.UIBase")
local UIGoldHelp = class("UIGoldHelp", super, function() return kod.LoadCSBNode(csbPath) end)
local Enum_RoomGrade = net.protocol.CGoldMatchREQ.Enum_RoomGrade
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local ScrollText = require("app.game.util.ScrollText")

function UIGoldHelp:ctor()

end

function UIGoldHelp:init()
    self._txtContent = ScrollText.new(seekNodeByName(self, "Text_z_Goldhelp", "ccui.Text"), 24, true)
    self._btnOk = seekNodeByName(self, "Button_btn_Goldhelp", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_x_Goldhelp", "ccui.Button")

    self:_registerCallBack()

    self._content = self:_generateHelpText()
end

function UIGoldHelp:_generateHelpText()
    --local gameplayStrTitle = '暂无'
    --local gameplayStrArray = { '暂无' }
    --local limitGameplay = game.service.GoldService.getInstance():getLimitGameplay()
    --local appendStr = ''
    --if limitGameplay then
    --    gameplayStrTitle = limitGameplay.title
    --    gameplayStrArray = RoomSettingInfo.new(limitGameplay.gamePlays):getZHArray()
    --    appendStr = table.concat(gameplayStrArray, '、') .. '\n' .. limitGameplay.description
    --else
    --    appendStr = table.concat(gameplayStrArray, '、')
    --end
    --return string.format(config.STRING.UIGOLD_HELP_TEXT_STRING_100, gameplayStrTitle, appendStr)
    return STATIC_HELP_TEXT
end



function UIGoldHelp:onShow()
    self._txtContent:setString(self._content or '')
end

function UIGoldHelp:onHide()

end

function UIGoldHelp:_registerCallBack()
    bindEventCallBack(self._btnOk, handler(self, self._onBtnOkClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnOkClick), ccui.TouchEventType.ended)
end

function UIGoldHelp:_onBtnOkClick(sender)
    UIManager.getInstance():hide("UIGoldHelp")
end

function UIGoldHelp:needBlackMask()
    return true
end

return UIGoldHelp