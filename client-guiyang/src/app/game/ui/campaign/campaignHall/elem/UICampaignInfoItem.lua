-- 报名按钮的图片样式
local BUTTON_COLOR = {
    NORMAL = "art/clubDesc/img_bscbm.png",
    NORMAL_PRESS = "art/clubDesc/img_bscbm1.png",
    CANCLE = "art/clubDesc/img_bscbm3.png",
    CANCLE_PRESS = "art/clubDesc/img_bscbm6.png",
    ING = "art/clubDesc/img_bscbm5.png",
    NOTOPEN = "art/clubDesc/img_bscbm2.png",
    JOIN = "art/clubDesc/img_bscbm4.png",
}

-- 报名费用的图片样式
local FEE_IMG = {
    FREE = "art/campaign/campaignIcon/small_free.png",
    [0x0F000002] = "art/campaign/campaignIcon/small_card.png",
    [0x0F000007] = "art/campaign/campaignIcon/small_ticket.png",
    [0x0F000001] = "art/campaign/campaignIcon/small_bean.png",
    [0x01000001] = "art/campaign/campaignIcon/small_mp50.png",
    [0x01000002] = "art/campaign/campaignIcon/small_mp25.png",
}

local UIElemCombobox = require("app.game.ui.element.UIElemCombobox")
-- 单条比赛显示item
----------------------------------------------------------------------
local UICampaignInfoItem = class("UICampaignInfoItem")

function UICampaignInfoItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UICampaignInfoItem)
    self:_initialize()
    -- self:retain()
    return self
end

function UICampaignInfoItem:_initialize()
    -- body
    self._rewardsIcon = seekNodeByName(self, "rewardsIcon", "ccui.ImageView")          -- 奖品Icon
    self._campaignName   = seekNodeByName(self, "campaignName", "ccui.Text")             -- 奖品Icon
    self._signupFeeText   = seekNodeByName(self, "signupFeeText", "ccui.Text")             -- 报名费用
    self._signupNum   = seekNodeByName(self, "signupNum", "ccui.Text")                -- 开赛信息
    self._campaignTimeTxt   = seekNodeByName(self, "campaign_Time", "ccui.Text")                -- 开赛信息
    
    self._btnSignup   = seekNodeByName(self, "btnSignup", "ccui.Button")              -- 报名按钮
    self._btnCampaignPanel = seekNodeByName(self, "Panel_1", "ccui.Layout")         -- 比赛详情
    self._btnSignupText = seekNodeByName(self, "BitmapFontLabel_4", "ccui.TextBMFont")         -- 比赛报名按钮文字

    self._panelTickCount = seekNodeByName(self, "Panel_daojishi", "ccui.Layout")
    self._tickCountMinText = seekNodeByName(self, "BitmapFontLabel_20", "ccui.TextBMFont")
    self._tickCountSecText = seekNodeByName(self, "BitmapFontLabel_20_0", "ccui.TextBMFont")
    self._costFeeImg = seekNodeByName(self, "Image_43_0", "ccui.ImageView")

    self._imageHuobao = seekNodeByName(self, "Image_2", "ccui.ImageView")

    self._selectPanel = seekNodeByName(self, "Panel_Select", "ccui.ImageView")
    self._signupCombo = seekNodeByName(self, "SignupCombo", "ccui.Button")
    self._signupComboBtn = seekNodeByName(self, "SignupCombo", "ccui.Button")
    self._signupComboText = seekNodeByName(self, "Text_SignupFee", "ccui.Text")
    self._signupFeeImg = seekNodeByName(self, "signupFeeImg", "ccui.ImageView")
    self._signupFee = {}
    self._fees = {}
    self._currentSelect = 1
    
    self._signupCombo = UIElemCombobox.new(self._signupCombo, 
    -- 点击回调
    function (index, str)
        self._signupComboText:setString(str)
        self._currentSelect = self._fees[index] == nil and 1 or self._fees[index].key
        self._signupComboBtn:setScaleY(1)
        local b =config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png"
        self._signupFeeImg:loadTexture( config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png")
    end, 
    -- 创建列表回调
    function (index)
        local panel = ccui.Layout:create()
        panel:setContentSize(cc.size(220,49))
        panel:setAnchorPoint(cc.p(0,0))
        local item = ccui.Text:create()
        item:setFontSize(25)
        item:setName("text")
        item:setTextColor(cc.c3b(151,86, 31))
        item:setAnchorPoint(cc.p(0,0))
        item:setPosition(cc.p(75,5))

        local img = ccui.Layout:create()
        img:setName("icon")        
        img:setAnchorPoint(cc.p(0,0))
        img:setPosition(cc.p(6,1))
        img:setContentSize(cc.size(50,50))
        img:setBackGroundImageScale9Enabled(true)

        local bg = ccui.Layout:create()
        bg:setName("bg")       
        bg:setBackGroundImage("art/campaign/campaignSelectbg1.png")

        bg:setContentSize(cc.size(167,51.5))
        bg:setBackGroundImageScale9Enabled(true)
        bg:setBackGroundImageCapInsets(cc.rect(11, 11, 162, 37))

        bg:setAnchorPoint(cc.p(0,1))
        bg:setPosition(cc.p(3,48))
        
        panel:addChild(bg)
        panel:addChild(item)
        panel:addChild(img)

        self._signupComboBtn:setScaleY(-1)

        return panel
    end, 
    -- 更新回调
    function (wdt, index)
        if self._signupCombo._textArray[index] then
            local text = wdt:getChildByName("text")
            local icon = wdt:getChildByName("icon")
            local bg = wdt:getChildByName("bg")
            icon:setBackGroundImage( config.CampaignConfig.FeeIconMap[self._signupFee[index]] or "art/campaign/campaignIcon/small_free.png")
            icon:setBackGroundImageCapInsets(cc.rect(0, 0, 50, 50))
            text:setString(self._signupCombo._textArray[index])
        end
    end, "art/campaign/campaignSelectbg.png")
    self._signupCombo:setDir(UIElemCombobox.DIR.DOWN)
    self._signupCombo:setAutoHideCallback(function ()
        self._signupComboBtn:setScaleY(1)
    end)
end 

-- 初始化报名费combox
function UICampaignInfoItem:_initCostFee(fees)
    -- 如果没有 则是免费报名
    if #fees == 0 or self._data.freeTimes > 0 then
        self._signupCombo:setTextArray({"免费报名"})       
        self._signupComboText:setString("免费报名") 
    else
        -- 构建数组
        local feesList = {}
        table.foreach(fees, function (k,v)
            table.insert( feesList, "X" .. v.item.count)
            table.insert( self._signupFee, v.item.id)
            table.insert( self._fees, v)          
        end)
        self._signupCombo:setTextArray(feesList)
        self._signupComboText:setString(feesList[self._currentSelect or 1])              
    end  
    self._signupFeeImg:loadTexture( config.CampaignConfig.FeeIconMap[self._signupFee[self._currentSelect] or 1 ] or "art/campaign/campaignIcon/small_free.png")    
end

function UICampaignInfoItem:getData()
    return self._data
end

-- 整体设置数据
function UICampaignInfoItem:setData (applicationInfo)
    self._data = applicationInfo

    self._signupFee = {}
    self._fees = {}
    
    local campaignList = game.service.CampaignService.getInstance():getCampaignList()

    -- 该比赛需要花费的道具
    local costString = campaignList:getFeeName(applicationInfo.cost)

    self._rewardsIcon:loadTexture(config.CampaignConfig.getIconConfig(applicationInfo.image))
    self._campaignName:setString(applicationInfo.name)

    --火爆图标，居然告诉我写死。。。
    self._imageHuobao:setVisible( applicationInfo.configId == 1007)

    local afterFilterCost = self:filtBean(applicationInfo.cost)
    if #afterFilterCost > 1 then
        self:_initCostFee(afterFilterCost)
        self._costFeeImg:setVisible(false)
        self._signupFeeText:setVisible(false)
        self._selectPanel:setVisible(true)
    else
        self._selectPanel:setVisible(false)

        self._costFeeImg:setVisible(true)
        self._signupFeeText:setVisible(true)
    end
    
    self._btnSignupText:setString("立即报名")
    if applicationInfo.freeTimes > 0 then
        self._signupFeeText:setString("X"..applicationInfo.freeTimes)
        self._costFeeImg:loadTexture(FEE_IMG.FREE)
        self._btnSignupText:setString("免费报名")
    elseif costString ~= "" then
        self._signupFeeText:setString("X" .. self:getFirstFeeNum(applicationInfo.cost))
        self._costFeeImg:loadTexture(self:getFirstFeeImg(applicationInfo.cost))
    elseif costString == "" then
        self._costFeeImg:loadTexture(FEE_IMG.FREE)
        self._signupFeeText:setString("X1")
        self._btnSignupText:setString("免费报名")
    end

    if self:_getIsCampaignNeedShared() == true then
        self._btnSignupText:setString("分享报名")  
    end

    if self:_getIsCampaignNeedShared() == false and self._data.shareFree == config.CampaignConfig.ShareFreeType.ON and applicationInfo.freeTimes > 0 then
        self._costFeeImg:loadTexture(FEE_IMG.FREE)
        self._signupFeeText:setString("X1")
        self._btnSignupText:setString("免费报名")
    end

    -- 停止这个item之前使用的action
    self:stopAllActions()
    self._campaignTimeTxt:setString(string.sub(applicationInfo.startTime, 1, -4) .. "-" .. string.sub(applicationInfo.endTime, 1, -4))

    local signUp = false   
    local rewardTxt = ""

    -- MTT比赛处理(倒计时在一小时之内开赛显示)
    self._campaignTimeTxt:setVisible(true)
    self._panelTickCount:setVisible(false)
    if applicationInfo.isMtt then
        -- 一些显示处理
        self._signupNum:setString(applicationInfo.playerCount .. "人已报名")       
        rewardTxt = self:getFirstReward(applicationInfo)

        local campaignService = game.service.CampaignService.getInstance()

        signUp = applicationInfo.signUp

        self:handleMttListView(applicationInfo)
    else
        signUp = applicationInfo.signUp
        rewardTxt = self:getFirstReward(applicationInfo)
        self._signupNum:setString(applicationInfo.playerCount .. "/" .. applicationInfo.maxPlayerCount) 
        self._campaignTimeTxt:setString("坐满即开")
    end

    -- arena处理
    if applicationInfo.id == config.CampaignConfig.ARENA_ID then
        self._signupNum:setString(applicationInfo.playerCount .. "人正在激战")
        self._campaignTimeTxt:setString("满"..applicationInfo.maxPlayerCount.."人开赛")
    end

    self:setCampaignStatus(applicationInfo.status,signUp)

    bindEventCallBack(self._btnSignup, handler(self, self._onBtnSignUp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCampaignPanel, handler(self, self._showDetail), ccui.TouchEventType.ended)    
end

-- 过滤掉金豆
function UICampaignInfoItem:filtBean(fees)
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


function UICampaignInfoItem:setCampaignStatus(status, signUp)
    -- 若报名后停赛需要让玩家够先取消报名
    self._btnSignup:setEnabled(true)
    local campaignList = game.service.CampaignService.getInstance():getCampaignList()
    
    if signUp == true then
        self._btnSignupText:setString("取消报名")
        self._btnSignup:loadTextureNormal(BUTTON_COLOR.CANCLE)
        self._btnSignup:loadTexturePressed(BUTTON_COLOR.CANCLE_PRESS)
    else
        self._btnSignup:loadTextureNormal(BUTTON_COLOR.NORMAL)
        self._btnSignup:loadTexturePressed(BUTTON_COLOR.NORMAL_PRESS)
    end
    if status == config.CampaignConfig.CampaignStatus.AFTER then
        self._btnSignupText:setString("已结束")   
        self._btnSignup:setEnabled(false)
        self._btnSignup:loadTextureDisabled(BUTTON_COLOR.NOTOPEN)
    elseif status == config.CampaignConfig.CampaignStatus.BEFORE then
        self._btnSignupText:setString("暂未开放")   
        self._btnSignup:setEnabled(false)     
        self._btnSignup:loadTextureDisabled(BUTTON_COLOR.NOTOPEN)
    elseif status == config.CampaignConfig.CampaignStatus.ONGOING and (self._data.enterTime == 0 or self._data.enterTime < game.service.TimeService:getInstance():getCurrentTimeInMSeconds()) then
        self._btnSignupText:setString("比赛中")  
        self._btnSignup:setEnabled(false)           
        self._btnSignup:loadTextureDisabled(BUTTON_COLOR.ING)
    end

    if status == config.CampaignConfig.CampaignStatus.ONGOING then 
        if self._data.nextStartTime and self._data.nextStartTime > game.service.TimeService:getInstance():getCurrentTimeInMSeconds() then
            self._campaignTimeTxt:setString("下场比赛" .. os.date("%m-%d \n%H:%M", self._data.nextStartTime / 1000))
        end
    end

    if self._data.enterTime ~= 0 and self._data.enterTime > game.service.TimeService:getInstance():getCurrentTimeInMSeconds() then
        local list = campaignList:getSignUpCampaignList()
        local flag = false
        table.foreach(list, function (k,v)
            if v == self._data.configId then
                flag = true
            end
        end)
        if flag == false then
            self._btnSignupText:setString("加入")
            self._btnSignup:loadTextureNormal(BUTTON_COLOR.JOIN)
            self._btnSignup:loadTexturePressed(BUTTON_COLOR.NORMAL_PRESS)
        else
            self._data.status = config.CampaignConfig.CampaignStatus.HASSIGNUP
        end
    end

    if status == config.CampaignConfig.CampaignStatus.HASSIGNUP then
        self._btnSignupText:setString("比赛中")  
        self._btnSignup:setEnabled(false)
    end
end

-- 提取报名费图片
function UICampaignInfoItem:getFirstFeeImg(cost)
    local result = ""
    table.foreach(cost, function (k,v)
        if v.key == 1 and v.item ~= nil then
            local src = FEE_IMG[v.item.id]
            if result ~= nil then
                result = src
            end
        end
    end)
    return result
end

-- 提取报名费个数
function UICampaignInfoItem:getFirstFeeNum(cost)
    local result = ""
    table.foreach(cost, function (k,v)
        if v.key == 1 and v.item ~= nil then
            result = v.item.count
        end
    end)
    return result
end

-- 提取第一名奖励
function UICampaignInfoItem:getFirstReward(applicationInfo)
    local rewardList = applicationInfo.rewardList
    local result = ""
    table.foreach(rewardList, function ( k, v)
        if v.rank == 1 then
            result = result .. PropReader.generatePropTxt(v.item)            
        end
    end)
    return result
end

function UICampaignInfoItem:_showDetail()
    UIManager:getInstance():show("UICampaignCreate", self._data)
end

function UICampaignInfoItem:_onBtnSignUp()
    if self._data.signUp == false then
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
                game.service.CampaignService.getInstance():setShareCampaignId(self._data.id)
                scheduleOnce(function()
                    if game.service.WeChatService.getInstance():sendImageData(
                        filePath, 
                        "tagName", 
                        config.GlobalConfig.getShareInfo()[1], 
                        "",
                        filePath, 
                        game.service.WeChatService.WXScene.WXSceneSession) then
                            game.service.CampaignService.getInstance():setShareCampaignId(self._data.id)
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
            game.service.CampaignService.getInstance():sendCCASignUpREQ(self._data.id,self._data.configId, self._currentSelect) 
        end
    else
        game.service.CampaignService.getInstance():sendCCASignUpCancelREQ(self._data.id)
    end
end

-- 处理mtt比赛显示
function UICampaignInfoItem:handleMttListView(applicationInfo)
    local hasBegan = applicationInfo.createTimestamp > game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
    local notStart = applicationInfo.status == config.CampaignConfig.CampaignStatus.BEFORE or applicationInfo.status == config.CampaignConfig.CampaignStatus.SIGN_UP
    if hasBegan == false then
        if applicationInfo.showStartTime ~= "" and notStart then
            self._campaignTimeTxt:setString(applicationInfo.showStartTime .. "开始报名")
        else
            self._campaignTimeTxt:setString( "已结束")
        end
        return        
    end

    self._campaignTimeTxt:setString(os.date("%m-%d \n%H:%M", applicationInfo.createTimestamp / 1000).."开启")

    -- 开始先让他刷新一下
    local timeInterval= applicationInfo.createTimestamp - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()

    -- 一小时之内才显示倒计时
    local isShowTickCount = timeInterval < 15 * 60 * 1000
    
    if isShowTickCount and timeInterval > 0 then      
        self._campaignTimeTxt:setVisible(false)
        self._panelTickCount:setVisible(true)
        self._tickCountMinText:setString(os.date("%M",timeInterval/1000))
        self._tickCountSecText:setString(os.date("%S",timeInterval/1000))
        
        -- 建立一个action绑定在ui上执行倒计时动画
        local  seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            local timeInterval= applicationInfo.createTimestamp - game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
            if timeInterval > 0 then 
                self._tickCountMinText:setString(os.date("%M",timeInterval/1000))
                self._tickCountSecText:setString(os.date("%S",timeInterval/1000))
            end
        end))
        local  act = cc.RepeatForever:create(seq)
        self:runAction(act)        
    end
end

-- 判断比赛当前是否需要显示分享
function UICampaignInfoItem:_getIsCampaignNeedShared()
    return self._data.shareFree == config.CampaignConfig.ShareFreeType.ON and not game.service.CampaignService.getInstance():getCampaignShareFreeRecord(self._data.id) and self._data.freeTimes >= 1;
end

function UICampaignInfoItem:_convertToTime(stamp)
    return os.date("%M:%S",stamp/1000)
end

function UICampaignInfoItem:_getIsCampaignNeedShared()
    return self._data.shareFree == config.CampaignConfig.ShareFreeType.ON and not game.service.CampaignService.getInstance():getCampaignShareFreeRecord(self._data.id) and self._data.freeTimes >= 1;
end

return UICampaignInfoItem