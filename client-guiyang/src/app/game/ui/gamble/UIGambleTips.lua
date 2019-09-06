local csbPath = "ui/csb/Gamble/UIGambleTips.csb"
local super = require("app.game.ui.UIBase")

local UIGambleTips = class("UIGambleTips", super, function() return kod.LoadCSBNode(csbPath) end)

local stakeTeamType = net.protocol.stakeTeamType

function UIGambleTips:ctor()
	
end

function UIGambleTips:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._btnOk = seekNodeByName(self, "btnOk", "ccui.Button")
	
	--比赛信息
	self._textTeamInfo = seekNodeByName(self, "textTeamInfo", "ccui.Text")
	--赔率信息
	self._textOddInfo = seekNodeByName(self, "textOddInfo", "ccui.Text")
	--押注信息
	self._textStakeInfo = seekNodeByName(self, "textStakeInfo", "ccui.Text")
	
	
	self:_registerCallBack()
end

function UIGambleTips:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnOk, handler(self, self._onClose), ccui.TouchEventType.ended);
end

function UIGambleTips:onShow(gameId, stakeTeam, stakeMoney)
	local gambleConfig = game.service.GambleService.getInstance().commonConfig
	local gameInfo = gambleConfig.games[gameId]
	local stakeOdds = 0
	self._textTeamInfo:setString(gameInfo.homeTeam .. "VS" .. gameInfo.visitingTeam)
	local oddInfo = ""
	if stakeTeam == stakeTeamType.home then
		oddInfo = gameInfo.homeTeam .. "  胜   " .. gameInfo.homeOdds
		stakeOdds = tonumber(gameInfo.homeOdds)
	elseif stakeTeam == stakeTeamType.away then
		oddInfo = gameInfo.visitingTeam .. "  胜   " .. gameInfo.visitingOdds
		stakeOdds = tonumber(gameInfo.visitingOdds)
	else
		oddInfo = "平局   " .. gameInfo.dogFall
		stakeOdds = tonumber(gameInfo.dogFall)
	end
	self._textOddInfo:setString(oddInfo)
	
	local winReward = stakeMoney * stakeOdds - stakeMoney *(stakeOdds - 1) * gambleConfig.serviceCharge
	self._textStakeInfo:setString(string.format("参与金额:%d  猜中返还:%d", stakeMoney, math.floor(winReward)))
	
end

function UIGambleTips:needBlackMask()
	return true
end


function UIGambleTips:_onClose()
	UIManager.getInstance():hide("UIGambleTips")
end

return UIGambleTips 