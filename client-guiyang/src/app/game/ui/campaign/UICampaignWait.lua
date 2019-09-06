local csbPath = "ui/csb/Campaign/UIBattleWait.csb"
local super = require("app.game.ui.UIBase")

local UICampaignWait = class("UICampaignWait", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignWait:ctor()
    self.btnQuit = nil
    self.waitText = nil
    self.rankText = nil
    self.roundText = nil
    self.totalCountTxt = nil
    self.nextPlayerCountTxt = nil
    self.pointText = nil
end

function UICampaignWait:init()
    self.btnQuit = seekNodeByName(self, "Button_qx2_BattleReady_0",  "ccui.Button")
    self.waitText = seekNodeByName(self, "waitText",  "ccui.Text")
    self.rankText = seekNodeByName(self, "rankText",  "ccui.TextBMFont")
    self.roundText = seekNodeByName(self, "roundText",  "ccui.TextBMFont")
    self.nextPlayerCountTxt = seekNodeByName(self, "nextPlayerCountTxt",  "ccui.TextBMFont")
    self.pointText = seekNodeByName(self, "pointText",  "ccui.TextBMFont")
    self.desktop = seekNodeByName(self, "desktopSkin",  "cc.Sprite")

    self:_registerCallBack()
end

function UICampaignWait:_registerCallBack()
    bindEventCallBack(self.btnQuit,    handler(self, self.onBtnQuitClick),    ccui.TouchEventType.ended);
end
function UICampaignWait:onShow()
    self:onChangeDestop(game.service.LocalPlayerSettingService:getInstance():getTableBackgound())
    self:onCampaignRankChange()
      
    local campaignService = game.service.CampaignService.getInstance();
    if campaignService:getCampaignData():getDaLiFlag() == config.CampaignConfig.DaLiFlag.UNKNOW then
        self.waitText:setString("正在为您匹配牌桌")
        self.btnQuit:setVisible(false)
    end
    
    campaignService:dispatchEvent({name = "EVENT_CAMPAIGN_RANK_HIDE"})

	game.service.CampaignService.getInstance():addEventListener("EVENT_CAMPAIGN_RANK_CHANGED",    handler(self, self.onCampaignRankChange), self)
end

function UICampaignWait:onChangeDestop(id)
    local skin = config.UIDestops[id]
    if config.getIs3D() then
        skin = config.UIDestops["3D"]
    end
	if skin then
		self.desktop:setTexture(skin)
	end
end

function UICampaignWait:onHide()
	-- 界面关闭后，取消关注
	game.service.CampaignService.getInstance():removeEventListenersByTag(self)
end


function UICampaignWait:onCampaignRankChange()
    local campaignService = game.service.CampaignService.getInstance()
    local daliFlag = campaignService:getCampaignData():getDaLiFlag()
    local rank  = campaignService:getCampaignData():getRank()
    local point = campaignService:getCampaignData():getTotalPoint()
    local round = campaignService:getCampaignData():getRound()
    local nextPlayerCount = campaignService:getCampaignData():getNextPlayerCount()
    local roomCount = campaignService:getCampaignData():getRoomCount()
    local thisPlayerCount = campaignService:getCampaignData():getThisPlayerCount()
    
    self.rankText:setString("当前排名:第" ..rank.. "名")
    self.pointText:setString(point)
    self.nextPlayerCountTxt:setString(thisPlayerCount .."进".. nextPlayerCount)

    if daliFlag == config.CampaignConfig.DaLiFlag.TRUE then 
        self.roundText:setString("打立赛:第"..round.."轮")
        self.waitText:setString("正在为您匹配牌桌")

        -- 应该是显示实际人数晋级
        self.nextPlayerCountTxt:setString(campaignService:getCampaignData():getPlayerCount() .."进".. nextPlayerCount)
        self.btnQuit:setVisible(false)
    else
        self.roundText:setString("第"..round.."轮比赛")
        self.waitText:setString("正在等待其他桌 当前剩余"..roomCount.."桌")
        self.btnQuit:setVisible(true)
    end
end

function UICampaignWait:onBtnQuitClick( )    
    game.ui.UIMessageBoxMgr.getInstance():show("放弃等待将退出本次比赛", {"再等一会","我要退出"},function()
			--退赛
			return
		end,function ()
            game.service.CampaignService.getInstance():sendCCAGiveUpREQ()
        end,true)
end

function UICampaignWait:needBlackMask()
	return true;
end

function UICampaignWait:closeWhenClickMask()
	return false
end

return UICampaignWait;
