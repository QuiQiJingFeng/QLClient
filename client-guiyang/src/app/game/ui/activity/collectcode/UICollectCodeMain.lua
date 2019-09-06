local CommentConfig = {
    -- [20001] = "注：开奖前一小时将关闭抽取和任务功能",
    -- [10002] = "注：开奖前半小时将关闭抽取和任务功能",
    [0] = "注：开奖前半小时将关闭抽取和任务功能",
}
local getCommentString = function()
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    return CommentConfig[areaId] or CommentConfig[0]
end

local TaskTypeConfig = {
    [1] = { title = "去分享", desc = "分享%s次游戏", gotoCallback = function()
        -- 告知服务器分享了
        local shareCallback = function()
            local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
            if service then
                service:sendCACCollectCodeShareREQ()
                service:openActivityMainPage()
            end
        end

        local data = {
            enter = share.constants.ENTER.COLLECT_SHARE,
            res = "art/activity/CollectCode/share.png"
        }
        share.ShareWTF.getInstance():share(data.enter, { data, data, data }, shareCallback)
    end },
    [2] = { title = "去" .. config.STRING.COMMON, desc = "在" .. config.STRING.COMMON .. "中完成%s局", gotoCallback = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
    end },
    [3] = { title = "去邀请", desc = "邀请%s个新玩家登陆游戏", gotoCallback = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.mainSceneShare)
    end },
    [4] = { title = "去" .. config.STRING.COMMON, desc = "在" .. config.STRING.COMMON .. "中获胜%s局", gotoCallback = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
    end },
    [5] = { title = "去比赛场", desc = "在比赛场中获得%s次冠军", gotoCallback = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    end },
    [6] = { title = "去打牌", desc = "完成%s局好友桌牌局", gotoCallback = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
    end },
}

local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeMain.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local bindClick = UtilsFunctions.bindClick
local Machine = require("app.game.ui.activity.collectcode.Machine")
local UICollectCodeMain = super.buildUIClass("UICollectCodeMain", csbPath)
function UICollectCodeMain:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)

    self._btnClose = seekButton(self, "Button_Back", handler(self, self._onBtnCloseClick))
    self._btnHelp = seekButton(self, "Button_Help", handler(self, self._onBtnHelpClick))
    -- self._btnMyCode = seekButton(self, "Button_My_Code", handler(self, self._onBtnMyCodeClick))
    self._btnMyCode = bindTouchEventWithEffect(seekNodeByName(self, "Button_My_Code", "ccui.Button"), handler(self, self._onBtnMyCodeClick), 0.70)
    self._btnMyRedpack = seekButton(self, "Button_Red_Pack", handler(self, self._onBtnMyRedpackClick))
    self._btnMyRedpack.reddot = seekNodeByName(self._btnMyRedpack, "RedDot", "ccui.ImageView")
    self._btnMyRedpack.reddot:hide()
    self._btnCodeRecord = seekButton(self, "Button_Code_Record", handler(self, self._onBtnCodeRecordClick))
    self._taskList = ReusedListViewFactory.get(seekNodeByName(self, "ListView_Task", "ccui.ListView"),
    handler(self, self._onTaskListItemInit),
    handler(self, self._onTaskListItemSetData))

    -- 开奖时间
    self._textOpenCodeTime = seekNodeByName(self, "Text_Open_Code_Time", "ccui.Text")
    self._textStatus = seekNodeByName(self, "Text_Code_Status", "ccui.Text")
    self._textCurrentPeriod = seekNodeByName(self, "Text_Current_Period", "ccui.Text")
    self._textCurrentPeriod:setString("第" .. self._service:getCollectCodeInfo().period + 1 .. "期")
    -- 抽奖摇杆
    self._joy = seekNodeByName(self, "Layout_Joy", "ccui.Layout")
    bindEventCallBack(self._joy, handler(self, self._onStartJoyClick), ccui.TouchEventType.ended)

    -- 抽奖机
    self._machine = Machine.new()
    seekNodeByName(self, "Node_Machine_Container", "cc.Node"):addChild(self._machine)
    self._machine:resetCodePosition()
    self._machine:setPosition(cc.p(0, 0))

    -- 触摸遮罩层，防止重复抽奖
    self._touchMask = ccui.Layout:create()
    self._touchMask:setContentSize(self:getContentSize())
    self._touchMask:setTouchEnabled(true)
    self._touchMask:setBackGroundColor(cc.c3b(255, 0, 0))
    self._touchMask:hide()
    self:addChild(self._touchMask)

    self._txtComment = seekNodeByName(self, "Text_Comment", "ccui.Text")
    self._txtComment:setString(getCommentString())

    local eventHandler = handler(self, self._onEvent)
    self._service:addEventListener("EVENT_COLLECT_CODE_GET_CODE_RES", eventHandler, self)
    self._service:addEventListener("EVENT_COLLECT_CODE_HISTORY_CODE_RES", eventHandler, self)
    self:_chageLightSpeed(false)
end

function UICollectCodeMain:onDestroy()
    self._service:removeEventListenersByTag(self)
end

function UICollectCodeMain:onShow(buffer)
    self._service:destroyAllActivityUIWithout(self.class.__cname)
    self:_checkNeedGuide()

    self:_updateLotteryTimes()
    self._buffer = buffer
    self._machine:setCharPool(self._service:convertToCodeArray(buffer.codes))
    self._touchMask:hide()
    self._taskList:deleteAllItems()
    local realTasks = {}
    for k, task in ipairs(buffer.task) do
        for idx, item in ipairs(task.progress) do
            table.insert(realTasks, {
                taskType = task.taskType, -- 任务类型
                totalTimes = item.times, -- 任务需要完成总次数
                completeTimes = task.completeTimes, -- 任务已完成的次数
                isRecved = bit.band(task.status, bit.lshift(1, idx - 1)) > 0
                or (task.completeTimes >= item.times and item.reward.count == 0), -- 是否领取, 完成进度以上面的参数判断
                reward = item.reward, -- 奖励列表
                progressIndex = idx - 1, -- 进度下标
            })
        end
    end
    -- 这样要对任务进行分割, 如果 #task.progress是大于1的话， 看作多个任务
    for k, v in ipairs(realTasks) do
        self._taskList:pushBackItem(v)
    end
    self._textOpenCodeTime:setString("开奖时间: " .. self._service:getCurrentOpenCodeTime(true))
    -- 非第一期才显示
    local isFirstPeriod = buffer.period == 0
    self._btnMyRedpack:setVisible(not isFirstPeriod)
    self._btnCodeRecord:setVisible(not isFirstPeriod)

    -- 如果并非第一期，查询我的红包，有红包未领取则提示飘窗
    if not isFirstPeriod then
        self._service:sendCACCollectCodeQueryHistoryCodeREQ({
            justQuery = true
        })
    end
end

function UICollectCodeMain:onHide()
end

function UICollectCodeMain:_onBtnCloseClick()
    self:hideSelf()
    self._service:resetCache()
end

-- 点击帮助
function UICollectCodeMain:_onBtnHelpClick()
    UIManager:getInstance():show("UICollectCodeHelp")
end

-- 点击我的幸运码
function UICollectCodeMain:_onBtnMyCodeClick()
    self._service:sendCACCollectCodeQueryCodeREQ()
end

-- 点击我的红包
function UICollectCodeMain:_onBtnMyRedpackClick()
    self._service:sendCACCollectCodeQueryHistoryCodeREQ()
    self._btnMyRedpack.reddot:hide()
end

-- 点击往期瓜分
function UICollectCodeMain:_onBtnCodeRecordClick()
    self._service:sendCACCollectCodeHistoryLuckyRecordREQ()
end

-- 点击摇杆
function UICollectCodeMain:_onStartJoyClick()
    if self._machine:isScrolling() then
        return
    end

    -- 是否有次数去抽奖
    if self._buffer.lotteryTimes > 0 then
        self._touchMask:show()
        manager.AudioManager.getInstance():playEffect("sound/SFX/Activity/CollectCode/joy.mp3")
        self:playAnimation(csbPath, "Animation_Joy", false)
        self._service:sendCACCollectCodeLotteryREQ()
    else
        UIManager:getInstance():show("UICollectCodeGetCodeTips")
    end
end

-- 当任务列表初始化
function UICollectCodeMain:_onTaskListItemInit(listItem)
    listItem.txtDesc = seekNodeByName(listItem, "Text_Desc", "ccui.Text")
    listItem.txtReward = seekNodeByName(listItem, "Text_Reward", "ccui.Text")
    listItem.btnRecv = seekNodeByName(listItem, "Button_Recv", "ccui.Button")
    listItem.btnGoto = seekNodeByName(listItem, "Button_Goto", "ccui.Button")
    listItem.btnGoto.text = seekNodeByName(listItem.btnGoto, "Text_", "ccui.Text")
    listItem.imageDone = seekNodeByName(listItem, "Image_Done", "ccui.ImageView")
    bindClick(listItem.btnGoto, function()
        TaskTypeConfig[listItem.taskType].gotoCallback()
    end)
end

-- 当任务列表赋值
function UICollectCodeMain:_onTaskListItemSetData(listItem, data)
    if data.completeTimes > data.totalTimes then
        data.completeTimes = data.totalTimes
    end
    local isRecved = data.isRecved
    local isDone = not isRecved and data.completeTimes >= data.totalTimes
    local isDoing = not isDone and not isRecved

    local cfg = TaskTypeConfig[data.taskType]
    listItem.taskType = data.taskType
    listItem.imageDone:setVisible(isRecved)
    listItem.btnGoto:setVisible(isDoing)
    listItem.btnGoto.text:setString(cfg.title)
    listItem.btnRecv:setVisible(isDone)
    local title = cfg.desc:format(data.totalTimes)
    local status = ("  (%s/%s)"):format(data.completeTimes, data.totalTimes)
    listItem.txtDesc:setString(title .. status)
    local rewardStr = "奖励：集码次数x1"
    if data.reward ~= nil and tonumber(data.reward.count) > 0 then
        local str = PropReader.generatePropTxt({ data.reward }, "x", "、")
        if str ~= nil and str ~= "" then
            rewardStr = rewardStr .. "、" .. str
        end
    end
    listItem.txtReward:setString(rewardStr)

    bindClick(listItem.btnRecv, function()
        if self._service and listItem.taskType then
            self._service:sendCACCollectCodeReceiveTaskRewardREQ({
                taskType = listItem.taskType,
                index = data.progressIndex,
            })
            data.isRecved = true
            listItem.imageDone:show()
            listItem.btnRecv:hide()
            game.ui.UIMessageBoxMgr.getInstance():show("恭喜完成任务，获得" .. listItem.txtReward:getString(), { "确定" })
        end
    end)
end

-- 播放实际摇奖的动画 
function UICollectCodeMain:playGetCodeAnimation(codeArray)
    self:_chageLightSpeed(true)
    self._machine:startScroll(function()
        scheduleOnce(function()
            manager.AudioManager.getInstance():playEffect("sound/SFX/Activity/CollectCode/opencode.mp3")
            self:_chageLightSpeed(false)
            self._touchMask:hide()
            UIManager:getInstance():show("UICollectCodeGetCodeResult", codeArray)
            self:_updateLotteryTimes()
        end, 0.5, self)
    end, true)
    self._machine:setResultCode(codeArray)
end

function UICollectCodeMain:_onEvent(event)
    if event.name == "EVENT_COLLECT_CODE_GET_CODE_RES" then
        local resp = event.data
        if resp:isSuccessful() then
            local codeArray = self._service:convertToCodeArray(resp:getBuffer().code)
            self:playGetCodeAnimation(codeArray)
        else
            self._touchMask:hide()
        end
    elseif event.name == "EVENT_COLLECT_CODE_HISTORY_CODE_RES" then
        local info = self._service:getMyHistoryCodeInfo()
        local hasRedpack = false
        for idx, periodInfo in ipairs(info.record) do
            if hasRedpack == true then
                break
            end
            for _, codeInfo in ipairs(periodInfo.codes) do
                if codeInfo.status ~= 3 and tonumber(codeInfo.count) > 0 then
                    hasRedpack = true
                    break
                end
            end
        end
        self._btnMyRedpack.reddot:setVisible(hasRedpack)
    end
end

function UICollectCodeMain:_updateLotteryTimes()
    self._textStatus:setVisible(self._service ~= nil)
    if self._service then
        self._textStatus:setString(string.format("获得%s组幸运码，还可集码%s次", self._service:getCodeCount(), self._service:getLotteryTimes()))
    end
end

function UICollectCodeMain:_chageLightSpeed(isFast)
    if self._animLight == nil then
        self._animLight = self:playAnimation(csbPath, "Animation_Light", true)
    end
    if self._animLightFast == nil then
        self._animLightFast = self:playAnimation(csbPath, "Animation_Light_Fast", true)
    end

    if isFast then
        self._animLight:stop()
        self._animLightFast:play("Animation_Light_Fast", true)
    else
        self._animLightFast:stop()
        local t = tolua.type(self._animLight)
        self._animLight:play("Animation_Light", true)
    end
end

function UICollectCodeMain:_checkNeedGuide()
    local key = "Guide_" .. self.class.__cname
    local service = game.service.ActivityService.getInstance()
    service:loadLocalStorage()
    local data = service.activeCache
    if data then
        if data[key] == nil or data[key] == false then
            -- if true then
            UIManager:getInstance():show("UICollectCodeGuide", {
                seekNodeByName(self, "Layout_Task", "ccui.Layout"),
                seekNodeByName(self, "Layout_Machine_Guide_Mask", "ccui.Layout"),
            },
            { "新手教程：\n完成任务获得集码机会", "新手教程：\n点击摇杆获取幸运码" })
            data[key] = true
            service:saveData()
        end
    end
end

function UICollectCodeMain:needBlackMask() return true end

return UICollectCodeMain