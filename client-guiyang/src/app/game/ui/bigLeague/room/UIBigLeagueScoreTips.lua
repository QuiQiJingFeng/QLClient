local csbPath = "ui/csb/BigLeague/UIBigLeagueScoreTips.csb"
local super = require("app.game.ui.UIBase")

local UIBigLeagueScoreTips = class("UIBigLeagueScoreTips", super, function() return kod.LoadCSBNode(csbPath) end)

--[[    
        总局结算分数不够提示
]]
function UIBigLeagueScoreTips:ctor()
end

function UIBigLeagueScoreTips:init()
   self._textdetail = seekNodeByName(self, "Text_detail", "ccui.Text")
   self._btnConfirm = seekNodeByName(self, "Button_Ok", "ccui.Button")
   self._btnClose = seekNodeByName(self, "Button_1", "ccui.Button") 
end

-- 点击事件注册
function UIBigLeagueScoreTips:_registerCallBack()
    bindEventCallBack(self._btnConfirm,        handler(self, self._onBtnConfirm),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose,        handler(self, self._onBtnConfirm),        ccui.TouchEventType.ended)
end

function UIBigLeagueScoreTips:onShow(info , pCloseFunc)
    self._info = info
    self._textdetail:setString("")
    if not self._info or not next(self._info) then 
        return 
    end
    local str = ""
    for nIdx, message in ipairs(self._info) do 
        local sep = nIdx == #self._info and "" or "\n\n"
        str = str .. game.service.club.ClubService.getInstance():getInterceptString(message.name, 8) .. "   ID:" .. message.ID .. sep
    end

    self._textdetail:setString(str)
    self._pCloseFunc = pCloseFunc
    self:_registerCallBack()
end

function UIBigLeagueScoreTips:onHide()
    self._textdetail:setString("")
    self._pCloseFunc = nil
    self._info = {}
end

function UIBigLeagueScoreTips:_onBtnConfirm()
    if self._pCloseFunc and "function" == type(self._pCloseFunc) then 
        self:_pCloseFunc()
    end
    UIManager:getInstance():hide("UIBigLeagueScoreTips")
end

function UIBigLeagueScoreTips:needBlackMask()
    return true
end

--层级大点
function UIBigLeagueScoreTips:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIBigLeagueScoreTips