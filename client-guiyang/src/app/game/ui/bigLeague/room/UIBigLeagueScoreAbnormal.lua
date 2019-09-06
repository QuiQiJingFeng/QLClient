local csbPath = "ui/csb/BigLeague/UIBigLeagueScoreAbnormal.csb"
local super = require("app.game.ui.UIBase")

local UIBigLeagueScoreAbnormal = class("UIBigLeagueScoreAbnormal", super, function() return kod.LoadCSBNode(csbPath) end)

--[[    
        分数不够解散原因详情
]]
function UIBigLeagueScoreAbnormal:ctor()
end

function UIBigLeagueScoreAbnormal:init()
   self._btnConfirm = seekNodeByName(self, "Button_Ok", "ccui.Button")
   self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
end

-- 点击事件注册
function UIBigLeagueScoreAbnormal:_registerCallBack()
    bindEventCallBack(self._btnConfirm,        handler(self, self._onBtnClose),        ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose,        handler(self, self._onBtnClose),        ccui.TouchEventType.ended)
end

function UIBigLeagueScoreAbnormal:onShow(infos)
    if not infos or not next(infos) then 
        Macro.assertTrue(true,"UIBigLeagueScoreAbnormal no infos!")
        return 
    end

    local info  = {}
    for nIdx,tbInfo in ipairs(infos) do 
        local tb = {
            id = tbInfo.role_id, 
            name = game.service.club.ClubService.getInstance():getInterceptString(tbInfo.role_name, 8),
            should = tbInfo.theory_score >= 0 and "+" .. tbInfo.theory_score or tbInfo.theory_score,
            actually = tbInfo.real_score >= 0 and "+" .. tbInfo.real_score or tbInfo.real_score,
        }
        table.insert(info, tb)
    end
    
    self:SetNodeHide()
    for nIdx = 1 , #info do 
        local ScoreNode = seekNodeByName(self, "Panel_Score" .. nIdx, "ccui.Layout")
        seekNodeByName(ScoreNode, "Text_name", "ccui.Text"):setString(info[nIdx].name)
        seekNodeByName(ScoreNode, "Text_should", "ccui.Text"):setString(info[nIdx].should)
        seekNodeByName(ScoreNode, "Text_actually", "ccui.Text"):setString(info[nIdx].actually)
        ScoreNode:setVisible(true)
    end

    self:_registerCallBack()
end

function UIBigLeagueScoreAbnormal:onHide()
    for nIdx = 1, 4 do 
        local ScoreNode = seekNodeByName(self, "Panel_Score" .. nIdx, "ccui.Layout")
        ScoreNode:setVisible(false)
    end
end

function UIBigLeagueScoreAbnormal:SetNodeHide()
    for nIdx = 1, 4 do 
        local ScoreNode = seekNodeByName(self, "Panel_Score" .. nIdx, "ccui.Layout")
        ScoreNode:setVisible(false)
    end
end

function UIBigLeagueScoreAbnormal:_onBtnClose()
    UIManager:getInstance():hide("UIBigLeagueScoreAbnormal")
end

function UIBigLeagueScoreAbnormal:needBlackMask()
    return true
end

return UIBigLeagueScoreAbnormal