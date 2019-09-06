local csbPath = "ui/csb/Campaign/UIBattleRoundDetail.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")
--在战绩页获取文本颜色值,在战绩列表中设置颜色值(避免在每一个战绩列表项都获取颜色值)
local CList
local super = require("app.game.ui.UIBase")

-- 单条比赛战绩显示
----------------------------------------------------------------------
local UICampaignRoundDetailItem = class("UICampaignRoundDetailItem")

function UICampaignRoundDetailItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UICampaignRoundDetailItem)
    self:_initialize()
    return self
end

function UICampaignRoundDetailItem:_initialize()
    self.time =  seekNodeByName(self, "Text_z1_0_6_UIBattleBLXQ", "ccui.Text")                  -- 时间
    self.dieScore =  seekNodeByName(self, "Text_z2_0_6_UIBattleBLXQ", "ccui.Text")              -- 淘汰线
    self.scoreTimes =  seekNodeByName(self, "Text_z3_0_6_UIBattleBLXQ", "ccui.Text")            -- 积分倍数
    self.backGround = seekNodeByName(self, "background", "ccui.ImageView")             -- 背景强调
    self.currentTag = seekNodeByName(self, "currentTag", "ccui.ImageView")             -- 背景强调
end

function UICampaignRoundDetailItem:getData()
    return self._data
end

-- 整体设置数据
function UICampaignRoundDetailItem:setData (applicationInfo)
    self.time:setString(applicationInfo.timeRange)
    self.dieScore:setString(applicationInfo.score)
    self.scoreTimes:setString(applicationInfo.multiple)
    self.currentTag:setVisible(applicationInfo.isCurrent)
    self.backGround:setVisible(applicationInfo.isCurrent)
    if applicationInfo.isCurrent then
        self.time:setTextColor(cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255))
        self.dieScore:setTextColor(cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255))
        self.scoreTimes:setTextColor(cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255))
    else
        self.time:setTextColor(cc.c4b(0,44,92,255))
        self.dieScore:setTextColor(cc.c4b(0,44,92,255))
        self.scoreTimes:setTextColor(cc.c4b(0,44,92,255))
    end
end

----------------------------------------------------------------------
local UICampaignRoundDetail = class("UICampaignRoundDetail", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignRoundDetail:ctor()
    self._reusedDetailList = UIItemReusedListView.extend(seekNodeByName(self, "ListView_6_UIBattleBLXQ", "ccui.ListView"), UICampaignRoundDetailItem)
    self._reusedDetailList:setScrollBarEnabled(false)

    self._checkboxGroup = {}
end

function UICampaignRoundDetail:init()
    self.title = seekNodeByName(self, "BitmapFontLabel_6", "ccui.TextBMFont")
    
    -- 本轮详情(打立)
    self.detailPannel = seekNodeByName(self, "detailPannel",  "ccui.Layout")
    self.currentPoint = seekNodeByName(self, "currentPointTxt",  "ccui.Text")
    self.currentRank = seekNodeByName(self, "currentRankTxt",  "ccui.Text")
    self.currentTime = seekNodeByName(self, "currentTimeTxt",  "ccui.Text")
    self.currentNumPerson = seekNodeByName(self, "currentTimeNumPerson",  "ccui.Text")
    self.topLineDali = seekNodeByName(self, "listTopline",  "ccui.Layout")
    self.daliText = seekNodeByName(self, "Text_1_UIBattleBLXQ_2",  "ccui.Text")

    -- 本轮详情(普通)
    self.normalPoint = seekNodeByName(self,"normalPoint", "ccui.Text")
    self.normalRank = seekNodeByName(self,"normalRank", "ccui.Text")
    self.topLineNormal = seekNodeByName(self, "listTopline_normal",  "ccui.Layout")

    -- 赛制简介
    self.rulePannel = seekNodeByName(self, "rule",  "ccui.Layout")
    self.ruleText = seekNodeByName(self, "ruleText",  "ccui.Text")
    self.scrollViewInfo = seekNodeByName(self, "ruleTextScroll", "ccui.ScrollView")

    -- 奖励方案
    self.rewardPannel = seekNodeByName(self, "rewardPannel",  "ccui.Layout")
    self.rewardTxt = seekNodeByName(self, "rewardText",  "ccui.Text")

    self._btnDetail = seekNodeByName(self, "CheckBox_Detail",  "ccui.CheckBox")
    self._btnInfo = seekNodeByName(self, "CheckBox_Info",  "ccui.CheckBox")
    self._btnAward = seekNodeByName(self, "CheckBox_Reward",  "ccui.CheckBox")

    self._checkBoxGroup = CheckBoxGroup.new({
        self._btnDetail,
        self._btnInfo,
        self._btnAward
    },handler(self, self._onCheckBoxGroupClick))

    self.btnClose = seekNodeByName(self, "Button_X",  "ccui.Button")
    --读取颜色值
	CList = GainLabelColorUtil.new(self , 1) 

    self:_registerCallBack()
end

function UICampaignRoundDetail:_registerCallBack()
    bindEventCallBack(self.btnClose,        handler(self, self.onBtnClose),    ccui.TouchEventType.ended);
end
function UICampaignRoundDetail:onShow( ... )
    local args = {...}

    local data = args[1]
    -- 本轮详情初始化
    local CampaignService = game.service.CampaignService.getInstance()
    local campainData = CampaignService:getCampaignData()
    local totalPoint = campainData:getTotalPoint()
    local rank = campainData:getRank()
    self.currentPoint:setString("当前积分:" .. totalPoint)
    self.currentRank:setString("当前排名:" .. rank)
    self.currentTime:setString("当前时间:" .. self:_convertTime(data.time))
    self.currentNumPerson:setString("晋级人数:" .. data.nextPlayerCount )
    self.normalPoint:setString("当前积分:" .. totalPoint)
    self.normalRank:setString("当前排名:" .. rank)

    local flag = data.daLiFlag
    self.normalRank:setVisible(not flag)
    self.normalPoint:setVisible(not flag)
    self.currentRank:setVisible(flag)
    self.currentPoint:setVisible(flag)
    self.topLineDali:setVisible(flag)
    self.currentTime:setVisible(flag)    
    self.currentNumPerson:setVisible(flag)
    self.topLineNormal:setVisible(not flag)
    self.daliText:setVisible(flag)

    if flag then
        self.title:setString("打立淘汰赛")
        --TD统计
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Detail_Desktop_Dali);
    else
        self.title:setString("积分排名赛")
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Detail_Desktop_Rank);
    end

    -- 更新List中的数据
    self._reusedDetailList:deleteAllItems()
    -- 添加数据

    local linesDetail
    if flag then
        linesDetail = data.level
        -- 生成时间间隔
        local lastSpan = 0
        for idx,member in ipairs(linesDetail) do
            member.isCurrent = false
            local sec = data.time/1000
            if linesDetail[idx+1] ~= nil then
                if lastSpan < sec and sec < linesDetail[idx+1].time then
                    member.isCurrent = true
                end
            else
                if lastSpan < sec then
                    member.isCurrent = true
                end
            end
            
            if linesDetail[idx+1] ~= nil then
                member.timeRange = lastSpan .. "-" .. linesDetail[idx+1].time .. "秒"
                lastSpan = linesDetail[idx+1].time
            else
                member.timeRange = member.time .. "秒后"
                lastSpan = member.time
            end            
        end
    else
        linesDetail = data.rounds
        -- 此处为了让定居积分赛时和打立赛列表UI复用，将定居积分数据转换为打立赛列表可用的格式
        for idx,member in ipairs(linesDetail) do
            member.isCurrent = false
            if member.count == data.round then
                member.isCurrent = true
            end
            member.timeRange = member.count
            if member.nextPlayerCount == 0 then
                member.score = "结束"
            else
                member.score = member.nextPlayerCount
            end            
        end
    end    

    for idx,member in ipairs(linesDetail) do
        self._reusedDetailList:pushBackItem(member)
    end

    -- 赛制简介初始化
    local text = string.gsub(data.instructions,"\\n","\n")
    self.ruleText:setString(text)
    
    -- 奖励方案初始化
    local scrollViewSize = self.scrollViewInfo:getContentSize()
    self.ruleText:setTextAreaSize(cc.size(scrollViewSize.width, 0))

    self.ruleText:setString(text)

    local s = self.ruleText:getVirtualRendererSize()	
    self.ruleText:setAnchorPoint(cc.p(0.5,1.0))
	self.ruleText:setContentSize(cc.size(s.width, s.height))
	self.ruleText:setPositionY(scrollViewSize.height > s.height and scrollViewSize.height or s.height)
	self.scrollViewInfo:setInnerContainerSize(cc.size(scrollViewSize.width, s.height))

    self.rewardTxt:setString(self:generateRewardName(data.rewardList))
    if #data.rewardList == 0 then
        self.rewardTxt:setString("暂无奖励，请咨询群主")
    end
    
    -- 页签初始化
    self._btnDetail:setSelected(true)
    self.detailPannel:setVisible(true)
    self.rulePannel:setVisible(false)
    self.rewardPannel:setVisible(false)
end

function UICampaignRoundDetail:_convertTime( t )
    local min = math.floor (t / 60000)
    local sec = math.floor ((t % 60000)/1000)
    return min .. "分" .. sec .. "秒"
end

function UICampaignRoundDetail:_onCheckBoxGroupClick(group, index)
    self.rewardPannel:setVisible(false)
    self.detailPannel:setVisible(false)
    self.rulePannel:setVisible(false)

    if group[index] == self._btnAward then
        self.rewardPannel:setVisible(true)
    elseif group[index] == self._btnDetail then
        self.detailPannel:setVisible(true)
    elseif group[index] == self._btnInfo then
        self.rulePannel:setVisible(true)
    end
end

function UICampaignRoundDetail:onHide()

end

function UICampaignRoundDetail:onBtnClose( )    
    UIManager:getInstance():destroy("UICampaignRoundDetail")
end

function UICampaignRoundDetail:generateRewardName(list)
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
            table.insert( result, {rank = low, item = val[1].item ,value = low .. "-" .. high})
        else
            table.insert( result, {rank = low, item = val[1].item ,value = low})
        end
    end)
    table.sort( result, function ( a,b ) 
        return a.rank<b.rank
    end )

    local stringResult = ""
    table.foreach(result,function (k,v)
        stringResult = stringResult .. "第" .. v.value .. "名：" .. self:generateReward(v) .. "\n"
    end)

    return stringResult
end

function UICampaignRoundDetail:generateReward(param)
    local rewardTxt = ""

    if param.item ~= "" then
        rewardTxt = rewardTxt .. PropReader.generatePropTxt(param.item)
    end

    return rewardTxt
end

function UICampaignRoundDetail:needBlackMask()
	return true;
end

function UICampaignRoundDetail:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignRoundDetail:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignRoundDetail;
