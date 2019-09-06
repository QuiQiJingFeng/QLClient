local csbPath = "ui/csb/Club/UIClubRewardInfo.csb"
local super = require("app.game.ui.UIBase")

local M = class("UIClubRewardInfo", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    排行榜俱乐部具体信息
]]

function M:ctor()
    
end

function M:init()
    self._textClubName = seekNodeByName(self, "Text_clubName", "ccui.Text") -- 俱乐部名称
    self._textClubId = seekNodeByName(self, "Text_clubId", "ccui.Text") -- 俱乐部Id
    self._textRank = seekNodeByName(self, "Text_rank", "ccui.Text") -- 昨日排名
    self._textIntegral = seekNodeByName(self, "Text_integral", "ccui.Text") -- 昨日积分
    self._textContribution = seekNodeByName(self, "Text_contribution", "ccui.Text") -- 我的贡献
    self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button") -- 取消
    self._btnShare = seekNodeByName(self, "Button_share", "ccui.Button") -- 分享
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
    self._imgPanel = seekNodeByName(self, "Image_panel", "ccui.ImageView")
    self._panelNode = seekNodeByName(self, "Panel_messagebox", "ccui.Layout")

    bindEventCallBack(self._btnCancel, handler(self, self._onBtnCancelClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onBtnShareClick), ccui.TouchEventType.ended)
end

function M:_onBtnCancelClick()
    UIManager:getInstance():hide("UIClubRewardInfo")
end

function M:_onBtnShareClick()
    self._imgPanel:setVisible(false)
    saveNodeToPng(self._panelNode, function(filePath)
        -- 如果是分享到系统的话，正常处理
        if Macro.assertFalse(cc.FileUtils:getInstance():isFileExist(filePath), filePath) then
            local data = 
            {
                res = filePath
            }
            share.ShareWTF.getInstance():share(share.constants.ENTER.LEADER_BOARD_SHARE, {data})
        end
        self._imgPanel:setVisible(true)
    end, "shareImg.jpg")
end

function M:onShow(data)
    self._imgPanel:setVisible(false)
    self._textClubName:setString(game.service.club.ClubService.getInstance():getShieldString(data.clubName))
    local clubId = game.service.club.ClubService.getInstance():getShieldString(tostring(data.clubId), 2, 2)
    self._textClubId:setString(string.format("%sID:%s", config.STRING.COMMON, clubId))
    self._textRank:setString(string.format("昨日排行:%s", data.yesterdayRank))
    self._textIntegral:setString(string.format("昨日积分:%s", data.yesterdayScore))
    self._textContribution:setString(string.format("我的贡献:%s", data.myContribution))
    self._imgHead:loadTexture(game.service.club.ClubService.getInstance():getClubIcon(data.clubIcon))
end

function M:onHide()
end

function M:needBlackMask()
    return true
end

function M:closeWhenClickMask()
    return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M