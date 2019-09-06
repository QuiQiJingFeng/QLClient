local csbPath = "ui/csb/Campaign/UIBattleWaitToStart.csb"
local super = require("app.game.ui.UIBase")

local UICampaignWaitToStart = class("UICampaignWaitToStart", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignWaitToStart:ctor()
end

function UICampaignWaitToStart:init()
end

function UICampaignWaitToStart:onShow( ... )
    -- body
end

function UICampaignWaitToStart:needBlackMask()
	return true;
end

function UICampaignWaitToStart:closeWhenClickMask()
	return false
end

return UICampaignWaitToStart