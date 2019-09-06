--[[
比赛详情文字界面
--]]
local csbPath = "ui/csb/Campaign/campaignUtils/elem/UIDetailRuleElem.csb"
local super = require("app.game.ui.UIBase")
local UIElemCampaignRule = class("UIElemCampaignRewards", super, function () return cc.CSLoader:createNode(csbPath) end)

function UIElemCampaignRule:ctor(parent)
    self._parent = parent;
    self._txt =  seekNodeByName(self, "Text_26", "ccui.Text")    
    self.scrollViewInfo = seekNodeByName(self, "ScrollView_1", "ccui.ScrollView")
end

function UIElemCampaignRule:show(data)
    self:setVisible(true)
    local scrollViewSize = self.scrollViewInfo:getContentSize()
	self._txt:setTextAreaSize(cc.size(scrollViewSize.width, 0))

    local text = string.gsub(data.instructions ,"\\n","\n")
    self._txt:setString(text)
	local s = self._txt:getVirtualRendererSize()

    self._txt:setContentSize(cc.size(s.width, s.height))
	self._txt:setPositionY(scrollViewSize.height > s.height and scrollViewSize.height or s.height)
    self.scrollViewInfo:setInnerContainerSize(cc.size(scrollViewSize.width, s.height))
    self.scrollViewInfo:setScrollBarEnabled(false)
end

function UIElemCampaignRule:hide()
    self:setVisible(false)
end

return UIElemCampaignRule;