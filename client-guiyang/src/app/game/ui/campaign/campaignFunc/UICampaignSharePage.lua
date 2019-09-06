-- 比赛分享出去的奖状
local csbPath = "ui/csb/Campaign/campaignUtils/UICampaignCertification.csb"
local super = require("app.game.ui.UIBase")

local PropTextConvertor = game.util.PropTextConvertor

local UICampaignSharePage = class("UICampaignSharePage", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignSharePage:ctor()
    super.ctor(self)
    self._icon = nil
    self._QRCode = nil
    self._throphy = nil
    self._rewardText = nil
    self._headImg = nil
    self._campaignName = nil
    self._playerName = nil

    self._data = {}
end

function UICampaignSharePage:init()
    self._icon = seekNodeByName(self, "appIcon", "ccui.ImageView")
    self._QRCode = seekNodeByName(self, "QRCode", "ccui.ImageView")
    self._throphy = seekNodeByName(self, "throphy", "ccui.ImageView")
    self._rewardText = seekNodeByName(self, "rewardText", "ccui.Text")
    self._headImg = seekNodeByName(self, "headIcon", "ccui.ImageView")
    self._campaignName = seekNodeByName(self, "campaignName", "ccui.TextBMFont")
    self._playerName = seekNodeByName(self, "playerName", "ccui.Text")
    self._rankThrophy = seekNodeByName(self, "throphy_rank", "ccui.ImageView")
    self._rankText = seekNodeByName(self, "BitmapFontLabel_1_0", "ccui.TextBMFont")
    self._root = seekNodeByName(self, "root", "ccui.Layout")
end

function UICampaignSharePage:onShow( ... )
    -- todo 根据地区配置控制二维码
    local args = { ... }
    self._data = args[1].result

    local name = kod.util.String.getMaxLenString(game.service.LocalPlayerService:getInstance():getName(), 8)
    local txt = PropTextConvertor.genItemsNameWithOperator(self._data.item)
    local rewardText = ""
    if #txt >0 then
        rewardText = "您获得" .. PropTextConvertor.genItemsNameWithOperator(self._data.item)
    else
        rewardText = "快来一起赢红包！"
    end
    local campaignName = self._data.name

    self._rewardText:setString(rewardText)
    game.util.PlayerHeadIconUtil.setIcon(self._headImg, game.service.LocalPlayerService.getInstance():getIconUrl());
    self._campaignName:setString("·" .. campaignName .. "·")
    self._playerName:setString(name)

    self._rankThrophy:setVisible(false)
    self._throphy:setVisible(false)

    local src = self:_getThrophyImg(self._data.rank)
    if src == "" then
        self._rankThrophy:setVisible(true)
        self._throphy:setVisible(false)
        self._rankText:setString(self._data.rank)
    else
        self._rankThrophy:setVisible(false)
        self._throphy:setVisible(true)
        self._throphy:loadTexture(src)
    end
end

-- 返回对应奖杯的路径
function UICampaignSharePage:_getThrophyImg(rank)
    local THROPHY = {
        [1] = "ui/art/campaign/Arena/icon_gj.png",
        [2] = "ui/art/campaign/Arena/icon_yj.png",
        [3] = "ui/art/campaign/Arena/icon_jj.png",
    }
    if THROPHY[rank] == nil then
        return ""
    else
        return THROPHY[rank]
    end
end

-- 生成获奖文字
function UICampaignSharePage:_generateRewardText()
    
end

function UICampaignSharePage:getRoot()
    return self._root
end

function UICampaignSharePage:onHide()
    
end

function UICampaignSharePage:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignSharePage