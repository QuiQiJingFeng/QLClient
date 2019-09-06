--[[
    @desc: 新版比赛报名页面
    author:{贺逸}
    time:2018-06-12
    return
]]
local csbPath = "ui/csb/Campaign/campaignHall/UICampaignCreate.csb"
local super = require("app.game.ui.UIBase")
local UIElemCombobox = require("app.game.ui.element.UIElemCombobox")
local PropTextConvertor = game.util.PropTextConvertor
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local UIRichTextEx = require("app.game.util.UIRichTextEx")

local rewardMap = {
    [0x0F000002] = "art/mall/goodIcon/icon_fk_mall.png",
    [0x0F000007] = "art/mall/goodIcon/icon_sq_mall.png",
    [0x0F000005] = "art/mall/goodIcon/icon_lq_mall.png",
    [0x0F000004] = "art/mall/goodIcon/icon_hb_mall.png",
    [0x0F000003] = "art/mall/goodIcon/icon_gold_mall.png",
    [0x04000003] = "art/campaign/campaignIcon/icon_mate20p.png",
    [0x01000002] = "art/mall/goodIcon/icon_mp25_mall.png"
}

local UICampaignCreate = class("UICampaignCreate", super, function () return kod.LoadCSBNode(csbPath) end)

function UICampaignCreate:ctor()
    self._title = nil
    self._startConditionTxt = nil
    self._signupFeeList = nil

    -- 奖励相关
    self._1stMedal = nil
    self._2ndMedal = nil
    self._3rdMedal = nil

    self._btnMoreRewards = nil -- 左侧查看规则按钮
    self._btnRules = nil -- 右边查看规则按钮
    self._btnSignup = nil -- 报名按钮
    self._playerNumText = nil -- arena专用 人数
    self._playerText = nil -- 普通比赛显示人数的字体

    -- 放奖品列表的list
    self._rewardList = nil

    self._signupCombo = nil
    self._signupComboText = nil

    -- others
    self._btnClose = nil
    self._rewardListItem = nil
    self._currentSelect = 1

    self._datas = {}
    -- 人数翻转动画
    self._timeTask = nil
    self._playerNums = 0
end

function UICampaignCreate:init()
    self._title = seekNodeByName(self, "campaignTitle",  "ccui.TextBMFont")
    self._startConditionTxt = seekNodeByName(self, "startConditionText",  "ccui.Text")
    self._signupCombo = seekNodeByName(self, "SignupCombo",  "ccui.Button")
    self._signupFeeImg = seekNodeByName(self, "itemIcon", "ccui.ImageView")

    self._1stMedal = seekNodeByName(self, "1stMedal",  "ccui.ImageView")
    self._2ndMedal = seekNodeByName(self, "2ndMedal",  "ccui.ImageView")
    self._3rdMedal = seekNodeByName(self, "3rdMedal",  "ccui.ImageView")

    self._btnMoreRewards = seekNodeByName(self, "Button_MoreReward", "ccui.Button")
    self._btnRules = seekNodeByName(self, "Button_CheckRule", "ccui.Button")

    self._btnSignup = seekNodeByName(self, "Button_Signup",  "ccui.TextBMFont")
    self._playerNumText = seekNodeByName(self, "playerNum", "ccui.TextBMFont")
    self._playerText = seekNodeByName(self, "playerNumNormal", "ccui.TextBMFont")
    self._normalNumsNode = seekNodeByName(self, "normalNumsNode", "cc.Node")

    -- 奖品list
    self._rewardList = seekNodeByName(self, "ListView_Reward", "ccui.ListView")
    self._rewardList:setScrollBarEnabled(false)

    --others
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._rewardListItem = self._rewardList:getChildByName("listRewardItem")
    self._rewardListItem:removeFromParent(false)
    self:addChild(self._rewardListItem)
    self._rewardListItem:setVisible(false)
    -- combos
    self._signupComboText = seekNodeByName(self, "comboText", "ccui.TextBMFont")

    self._signupCombo = UIElemCombobox.new(self._signupCombo, 
    -- 点击回调
    function (index, str)
        self._signupComboText:setString(str)
        self._currentSelect = self._fees[index] == nil and 1 or self._fees[index].key
        local b = config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png"
        self._signupFeeImg:loadTexture( config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png")
    end, 
    -- 创建列表回调
    function (index)
        local panel = ccui.Layout:create()
        panel:setContentSize(cc.size(220,38))
        local item = ccui.TextBMFont:create()
        item:setName("text")
        item:setFntFile("art/font/font_Button1.fnt")
        item:setScale(0.67)
        item:setAnchorPoint(cc.p(0,0))
        item:setPosition(cc.p(50,5))

        local img = ccui.Layout:create()
        img:setName("icon")        
        img:setAnchorPoint(cc.p(0,0))
        img:setPosition(cc.p(-40,-5))
        img:setScale(1.8)
        img:setContentSize(cc.size(46,46))
        img:setBackGroundImageScale9Enabled(true)
        
        panel:addChild(item)
        panel:addChild(img)
        return panel
    end, 
    -- 更新回调
    function (wdt, index)
        if self._signupCombo._textArray[index] then
            local text = wdt:getChildByName("text")
            local icon = wdt:getChildByName("icon")
            icon:setBackGroundImage( config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png")
            icon:setBackGroundImageCapInsets(cc.rect(0, 0, 50, 50))
            text:setString(self._signupCombo._textArray[index])
        end
    end)
    self._signupCombo:setDir(UIElemCombobox.DIR.DOWN)

    -- 添加事件
    local campaignService = game.service.CampaignService.getInstance()
    campaignService:addEventListener("EVENT_CAMPAIGN_DATA_RECEIVED",    handler(self, self._onDataChanged), self)
    campaignService:addEventListener("EVENT_CAMPAIGN_DATA_CHANGED",     handler(self, self._onDataChanged), self)

    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMoreRewards, handler(self, self._onBtnRewards), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRules, handler(self, self._onBtnRules), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSignup, handler(self, self._onBtnSignUp), ccui.TouchEventType.ended)
end

function UICampaignCreate:onShow(...)
    local args = {...}
    self._datas = args[1]
    -- 本地保存一下报名费
    self._signupFee = {}
    self._fees = {}
    
    self:_updateView()
end

-- 根据数据刷新视图,如果选择了报名费则不刷新报名费
function UICampaignCreate:_updateView(notAnim)
    self._title:setString(self._datas.name)
    
    -- 冠亚季军的领奖台。。。。。。。
    self:_setMedals(self._1stMedal,self._datas.rewardList[1])
    self:_setMedals(self._2ndMedal,self._datas.rewardList[2])
    self:_setMedals(self._3rdMedal,self._datas.rewardList[3])

    -- 其他名次奖品
    self:_initRewardList(self._datas.rewardList)

    -- 报名费
    if self._currentSelect == 1 then
        self:_initCostFee(self:filtBean(self._datas.cost))
    end
    self:_setSignUpBtn()

    -- 报名条件
    if self._datas.isMtt == true then
        self._startConditionTxt:setString(os.date("%m-%d %H:%M", self._datas.createTimestamp / 1000).."开启")     
    else
        self._startConditionTxt:setString("开赛条件: 满" .. self._datas.maxPlayerCount .. "人" .. "开赛")        
    end
    if not notAnim then
        self:_updatePlayerNums(self._datas.playerCount)
    end
end

function UICampaignCreate:_setSignUpBtn()
    local signupText = self._btnSignup:getChildByName("signupBtnText")
    if self._datas.signUp == true then
        signupText:setString("取消报名")
    else
        signupText:setString("报名")
    end

    local campaignList = game.service.CampaignService.getInstance():getCampaignList()
    local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    if self._datas.enterTime ~= 0 and self._datas.enterTime > currentTime then
        local list = campaignList:getSignUpCampaignList()
        local flag = false
        table.foreach(list, function (k,v)
            if v == self._datas.configId then
                flag = true
            end
        end)
        if flag == false then
            signupText:setString("加入")
        else
            self._datas.status = config.CampaignConfig.CampaignStatus.HASSIGNUP
        end
    end

    self:setCampaignStatus(self._datas.status,self._datas.signUp)
end

function UICampaignCreate:setCampaignStatus(status, signUp)
    local signupText = self._btnSignup:getChildByName("signupBtnText")
    local currentTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    self._btnSignup:setEnabled(false)   
    -- 若报名后停赛需要让玩家够先取消报名
    if status == config.CampaignConfig.CampaignStatus.AFTER then
        signupText:setString("已结束")        
    elseif status == config.CampaignConfig.CampaignStatus.BEFORE then
        signupText:setString("未开赛")         
    elseif status == config.CampaignConfig.CampaignStatus.ONGOING and (self._datas.enterTime == 0 or self._datas.enterTime < currentTime) then
        signupText:setString("比赛中")              
    else
        self._btnSignup:setEnabled(true)   
    end

    if status == config.CampaignConfig.CampaignStatus.HASSIGNUP then
        signupText:setString("比赛中")        
        self._btnSignup:setEnabled(false)   
    end
end

function UICampaignCreate:_updatePlayerNums(playerNum)
    self._playerNums = playerNum
    if self._datas.isMtt then  
        self._playerText:setString(playerNum .. "人已报名")
    else
        self._playerText:setString("已有" .. playerNum .. "/" .. self._datas.maxPlayerCount .. "位玩家")
    end
    if self._datas.id == config.CampaignConfig.ARENA_ID then
        self._playerNumText:setVisible(true)
        self._playerText:setString("玩家正在激战中")
        if playerNum > 50  then
            self._playerNumText:setString(playerNum - 50)
        else
            self._playerNumText:setString(playerNum)
        end
        self:_playerIncreaseAnim(playerNum)
    else
        self._playerNumText:setVisible(false)
        self._playerText:setPosition(self._normalNumsNode:getPosition())
    end
end

function UICampaignCreate:_setMedals( node, reward)
    local medalName = node:getChildByName("medalNameText")
    local icon = node:getChildByName("medalIcon")
    if reward == nil then
        medalName:setString("无")
        icon:loadTexture("art/campaign/Arena/img_dw0.png")
    else
        icon:loadTexture(rewardMap[reward.item[1].id] or "")
        -- icon:loadTexture(PropReader.getIconById(reward.item[1].id))
        -- icon:ignoreContentAdaptWithSize(true)
        medalName:setString(PropTextConvertor.genItemsNameWithOperator(reward.item, '\n'))
    end
end

-- 初始化报名费combox
function UICampaignCreate:_initCostFee(fees)
    -- 如果没有 则是免费报名
    if #fees == 0 or self._datas.freeTimes > 0 then
        self._signupCombo:setTextArray({"免费报名"})       
        self._signupComboText:setString("免费报名") 
    else
        -- 构建数组
        local feesList = {}
        table.foreach(fees, function (k,v)
            if PropReader.getTypeById(v.item.id) == "Ticket" then
                table.insert( feesList, "门票X" .. v.item.count)
            else
                table.insert( feesList, PropReader.generatePropTxt({v.item}))
            end
            table.insert( self._signupFee, v.item.id)
            table.insert( self._fees, v)         
        end)
        self._signupCombo:setTextArray(feesList)
        self._signupComboText:setString(feesList[1])
    end
    local resName = config.CampaignConfig.FeeIconMap[self._signupFee[1]] or "art/campaign/campaignIcon/small_free.png"
    self._signupFeeImg:loadTexture(resName)    
end

function UICampaignCreate:filtBean(fees)
    local result = {}
    local CurrencyHelper = require("app.game.util.CurrencyHelper")
    table.foreach(fees,function (k,v)
        local type = CurrencyHelper.getInstance():getCurrencyTypeByPropId(v.item.id)
        if type ~= "BEAN" then
            table.insert(result, v)
        end
    end)
    return result
end

-- 初始化奖品列表
function UICampaignCreate:_initRewardList(datas)
    -- 去掉前3个
    local tmpDatas = {}
    
    for idx,reward in ipairs(datas) do
        if reward.rank > 3 then
            table.insert(tmpDatas,reward)
        end
    end

    table.sort(tmpDatas,function (a,b)
        return a.rank < b.rank
    end)

    local list = PropTextConvertor.convertCampaignRewards(tmpDatas)
    self._rewardList:removeAllChildren(false)
    -- 如果没有内容 则显示暂无更多
    if #list == 0 then
        local item = self._rewardListItem:clone()
        self._rewardList:addChild(item)
        item:setVisible(true)

        item:setString("暂无更多")
    end
    
    table.foreach(list, function (k,v)
        local item = self._rewardListItem:clone()
        self._rewardList:addChild(item)
        item:setVisible(true)

        local reward = PropTextConvertor.genItemsNameWithOperator(v.item," + ")
        local innerText = string.format("%s%-".. (15 - string.len(v.value)) .."s%s", v.value, "名", reward)
        item:setString(innerText)
    end)    
end

function UICampaignCreate:_onBtnRewards()
    UIManager:getInstance():show("UICampaignDetail", self._datas, "rewards") 
end

function UICampaignCreate:_onBtnRules()
    UIManager:getInstance():show("UICampaignDetail", self._datas, "rules")
end

function UICampaignCreate:_onBtnSignUp()
    if self._datas.signUp == false then
        if self:_getIsCampaignNeedShared() == true then
            -- 分享链接
            -- if game.service.WeChatService.getInstance():sendLinkURL(
            -- 	config.GlobalConfig.getShareUrl(),
            -- 	"tagName", 
            -- 	config.GlobalConfig.getShareInfo()[1], 
            -- 	config.GlobalConfig.getShareInfo()[2],
            -- 	config.GlobalConfig.DEFAULT_ICON,
            -- 	game.service.WeChatService.WXScene.WXSceneTimeline) then
            -- -- 	-- 记录分享渠道
            --     game.service.CampaignService.getInstance():setShareCampaignId(self._data.id)
            -- end
        
            -- 分享图片
            -- 分享图片的时候需要新建一个不可见的node对分享出去的图片进行渲染。。
            local shareImg = ccui.ImageView:create(config.CampaignConfig.ShareImagePath)
            shareImg:setVisible(false)    
            local shareImgPath = saveNodeToPng(shareImg, function(filePath)
                game.service.CampaignService.getInstance():setShareCampaignId(self._datas.id)
                scheduleOnce(function()
                    if game.service.WeChatService.getInstance():sendImageData(
                        filePath, 
                        "tagName", 
                        config.GlobalConfig.getShareInfo()[1], 
                        "",
                        filePath, 
                        game.service.WeChatService.WXScene.WXSceneSession) then
                            game.service.CampaignService.getInstance():setShareCampaignId(self._datas.id)
                        end
                end, 0.5)  
            end,"campaignShareImg.png")
        
                
            -- 分享图片初始化载入
            -- 分享图片的时候需要新建一个不可见的node对分享出去的图片进行渲染。。暂时先放在这里让它只需渲染一次
        
        
            -- 在PC上的时候临时处理一下
            -- game.service.WeChatService.getInstance():dispatchEvent({ 
            --     name = "EVENT_SEND_RESP",
            --     errCode = 0,
            -- });	
        else
            game.service.CampaignService.getInstance():sendCCASignUpREQ(self._datas.id,self._datas.configId, self._currentSelect) 
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_JoinFrom_Detail);
        end
        
        UIManager:getInstance():destroy("UICampaignCreate")
    else
        game.service.CampaignService.getInstance():sendCCASignUpCancelREQ(self._datas.id)
    end
end

function UICampaignCreate:_getIsCampaignNeedShared()
    local freeRecord = game.service.CampaignService.getInstance():getCampaignShareFreeRecord(self._datas.id)
    return self._datas.shareFree == config.CampaignConfig.ShareFreeType.ON and not freeRecord and self._datas.freeTimes >= 1;
end

function UICampaignCreate:_onBtnClose()
    UIManager:getInstance():destroy("UICampaignCreate")
end

function UICampaignCreate:_onDataChanged( event)
    local campaignList = game.service.CampaignService.getInstance():getCampaignList()
    -- 拿出自己的数据，如果没有则返回，否则就改变视图内对应的内容
    local result = campaignList:getCampaignByConfigId(self._datas.configId)
    if result == nil then
        return
    end
    self._datas = result
    self:_updateView(true)
end

--[[
    参赛人数动画
    target:
    from:默认0，从from 到target的数字变动动画
]]
function UICampaignCreate:_playerIncreaseAnim(target)
    -- 先解除注册
    if self._timerTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerTask);
        self._timerTask = nil;
    end
    self._timerTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateTime), 0.05, false)
end

function UICampaignCreate:_updateTime()
    local num = tonumber(self._playerNumText:getString())
    if num and num + 12 < self._playerNums then
        self._playerNumText:setString(num + 12)
    else
        self._playerNumText:setString(self._playerNums)
        if self._timerTask ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerTask);
            self._timerTask = nil;
        end
    end
end

function UICampaignCreate:needBlackMask()
	return true;
end

function UICampaignCreate:closeWhenClickMask()
	return true
end

function UICampaignCreate:onHide()
    if self._timerTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerTask);
        self._timerTask = nil;
    end
    game.service.CampaignService.getInstance():removeEventListenersByTag(self);
end

function UICampaignCreate:dispose()
    if self._rewardListItem ~= nil then
        self._rewardListItem:release()
        self._rewardListItem = nil
    end    
end

return UICampaignCreate
