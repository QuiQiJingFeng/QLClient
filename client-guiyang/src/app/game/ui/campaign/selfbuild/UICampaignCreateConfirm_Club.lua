local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleCreateInfo.csb"
--[[
    麻将馆创建赛事信息确认页面
--]]
local super = require("app.game.ui.UIBase")
local Constants = require("app.gameMode.mahjong.core.Constants")

local UICampaignCreateConfirm_Club = class("UICampaignCreateConfirm_Club", super, function() return kod.LoadCSBNode(csbPath) end)

function UICampaignCreateConfirm_Club:ctor()
    self._gamedata = {}
end

function UICampaignCreateConfirm_Club:init( )
    self._btnclose = seekNodeByName(self, "Button_x_FangKaSaiShi" , "ccui.Button")
    self._btnCreate = seekNodeByName(self, "Button_An_FangKaSaiShi", "ccui.Button")
    self._gameName = seekNodeByName(self, "Text_11", "ccui.Text")
    self._gameTime = seekNodeByName(self, "Text_13", "ccui.Text")
    self._gameSetting = seekNodeByName(self, "Text_15", "ccui.Text")
    self._gameReward = seekNodeByName(self, "Text_18", "ccui.Text")
    self._panel = seekNodeByName(self, "Panel_Wz_FangKaSaiShi", "ccui.Layout")
    self._list = seekNodeByName(self, "ScrollView_1" , "ccui.ListView")

    -- self._list:setScrollBarOpacity(0)
    self:_registerCallBack()
end

function UICampaignCreateConfirm_Club:_registerCallBack()
    bindEventCallBack(self._btnclose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCreate, handler(self, self._onBtnCreateClick), ccui.TouchEventType.ended)
end

function UICampaignCreateConfirm_Club:onShow( data )
    self._gamedata = data
    self._gameName:setString(data.name)
    self._gameTime:setString(data.time)
    self:showSelectedGameInfo(data)
    self:showSelectedGameReward(data)
end

function UICampaignCreateConfirm_Club:_onBtnCloseClick()
    UIManager:getInstance():destroy("UICampaignCreateConfirm_Club")
end

function UICampaignCreateConfirm_Club:showSelectedGameInfo( data )
    local string = self:_generateCost({data.createCost}) .. config.STRING.UICAMPAIGNCREATECONFIRM_CLUB_STRING_100 .. self:_generateFee(data.cost)  .. "  最低" .. data.leastCount .. "人"
    self._gameSetting:setString(string)
end

-- 生成消耗房卡数
function UICampaignCreateConfirm_Club:_generateCost(items)
    local result = ""

    -- 取出所有道具信息
    local costInfo = {}
    table.foreach(items, function (k,v)
        table.insert(costInfo, v)
    end)

    result = PropReader.generatePropTxt(costInfo)
    return result
end

function UICampaignCreateConfirm_Club:_generateFee(items)
    local result = ""

    -- 取出优先级最高的
    table.sort(items, function (a,b)
        return a > b
    end)

    if #items == 0 then return config.STRING.UICAMPAIGNCREATECONFIRM_CLUB_STRING_101 end
    result = PropReader.generatePropTxt({items[1].item}) .. "/人 "
    return result
end

function UICampaignCreateConfirm_Club:showSelectedGameReward(data)
    local rewardTbl = self:generateRewardName(data.rewardList)
    local rewardTxt = ""
    
    if rewardTbl ~= "" then
        rewardTxt = rewardTxt .. PropReader.generatePropTxt(rewardTbl)
    end

    if rewardTxt == "" then
        rewardTxt = "具体奖励由群主向参赛玩家进行说明"
    end

    self._gameReward:setString(rewardTxt)
    local size = self._gameReward:getFontSize() * 8
    local textSize = self._gameReward:getVirtualRendererSize()
    local listSize = self._list:getContentSize()
    local change = size + textSize.height - listSize.height
    change = change > 0 and change or 0      -- 判断是否需要改变text所在Layout位置
    self._panel:setPositionY(change)
    self._list:setInnerContainerSize(cc.size(listSize.width,(size + textSize.height )))
end

function UICampaignCreateConfirm_Club:_onBtnCreateClick(  )
    -- 如果当前大于5个比赛则不能创建
    local selfCampaignData = game.service.CampaignService:getInstance():getSelfbuildService():getGameCreatedData()
    local count = 0
    table.foreach(selfCampaignData, function (k,v)
        if v.status == config.CampaignConfig.CampaignStatus.SIGN_UP then
            count = count + 1
        end
    end)
    if count > 4 then 
        game.ui.UIMessageTipsMgr.getInstance():showTips("最多同时创建5个比赛")
        return
    end

    local clubID = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
    game.service.CampaignService:getInstance():getSelfbuildService():onCampaignCreateREQ(self._gamedata.id,self._gamedata.name,
                self._gamedata.timeStamp*1000,clubID)
    UIManager:getInstance():destroy("UICampaignCreate_Club")
end

--  生成奖品统计list
function UICampaignCreateConfirm_Club:generateRewardName(list)
    local map = {}
    local result = {}
    -- 生成每种奖品的map 键为 "奖励房卡&奖励礼券",把所有相同奖励的都放在一起
    table.foreach(list, function(key, val)
        if map[PropReader.generatePropTxt(val.item)] == nil then
            map[PropReader.generatePropTxt(val.item)] = {}
        end
        table.insert(map[PropReader.generatePropTxt(val.item)], { rank = val.rank, item = val.item})
    end)

    -- 根据奖品map所需要的最低排名进行排序 获得相同奖励情况下，最低的排名，和最高的排名
    table.foreach(map, function(key, val)
        local low = val[1].rank
        local high = val[1].rank
        table.foreach(val, function( key2,val2 )
            if val2.rank < low then
                low = val2.rank
            end
            if val2.rank>high then 
                high = val2.rank
            end
        end
        )
        if #val > 1 then
            table.insert( result, {rank = low ,item = PropReader.generatePropTxt(val[1].item) ,value = low .. "-" .. high})
        else
            table.insert( result, {rank = low ,item = PropReader.generatePropTxt(val[1].item) ,value = low})
        end
    end)
    table.sort( result, function ( a,b ) 
        return a.rank<b.rank
    end )
    return result
end 

function UICampaignCreateConfirm_Club:hide()
    self:setVisible(false)
end

function UICampaignCreateConfirm_Club:needBlackMask()
	return true;
end

function UICampaignCreateConfirm_Club:closeWhenClickMask()
	return false
end

function UICampaignCreateConfirm_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignCreateConfirm_Club