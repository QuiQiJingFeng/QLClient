local csbPath = "ui/csb/UICreateRoom.csb"
local super   = require("app.game.ui.UIBase")

local UICreateRoom = class("UICreateRoom", super, function ()return kod.LoadCSBNode(csbPath) end )
local room        = require("app.game.ui.RoomSettingHelper")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

-----------------------GameTypeUI------------------------------
local GameTypeUI = class("GameTypeUI")
function GameTypeUI:ctor(gameType)
    self.gameType       = gameType
    self.gameTypeBtnOn  = nil
    self.gameTypeBtnOff = nil
    self.parentBox      = nil

    -- /**提审版需要隐藏钻石相关控件 */
    self.diamondRoot    = nil
    self.ruleCheckBoxes = {}
    -- /**限免标志 */
    self.freeFlag       = nil
    --是否亲友圈ID
    self._clubId = nil;
    -- 禁用标记
    self.subCheck = nil

    -- 大联盟玩法管理进入标记
    self._fromType = nil 
end

function GameTypeUI:unCheckAllBoxes()
    for k, v in pairs(self.ruleCheckBoxes) do
        v:setSelected(false)
    end
end

-------------------------UICreateRoom----------------------------
function UICreateRoom:ctor()
    self.gameTypeUIs  = {}
    self.btnOK        = nil
    self.btnFree      = nil
    self._forbidRuleNames = {};     -- 群主禁止选项
    self.modelNode    = nil
    self._panelEarly  = nil

    self._reverse = false
    self._reverseSelectInfo = {}
    
    self._isStencil = false -- 是否是模版创建
    self._roomSettings = {} -- 保存一下模版玩法
    self._presetGameplay = nil

    self.modelNode = seekNodeByName(self, "Panel_TYPE_BUTTON", "ccui.Layout")
    self.modelNode:removeFromParent(false)
    self:addChild(self.modelNode)
    self.modelNode:setVisible(false)

    game.service.LoginService.getInstance():addEventListener("EVENT_PLAYER_REGION_CHANGED", handler(self, self._onRegionChanged), self)
    game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_CLUB_PRESET_GAMEPLAY", handler(self, self.onBtnClose), self)
end

function UICreateRoom:needBlackMask()
    return true;
end

function UICreateRoom:init()
    self._classicCreateRoomLayout = seekNodeByName(self, "Panel_Classic_Create", "ccui.Layout")
    self.btnOK    = seekNodeByName(self._classicCreateRoomLayout, "Button_Creat_CreateRoom", "ccui.Button")
    self.btnFree  = seekNodeByName(self._classicCreateRoomLayout, "Button_Free_CreateRoom" , "ccui.Button")
    self.btnClose = seekNodeByName(self, "Button_X_CreateRoom"    , "ccui.Button")
    self.btnList  = seekNodeByName(self, "ListView_Game_Type_Btn", "ccui.ListView")
    
    self._panelEarly = seekNodeByName(self, "Panel_ztjr_CreatRoom"    , "ccui.Layout")
    self._panelEarly:setVisible(false)

    self._btnSure = seekNodeByName(self, "Button_diy_a_CreatRoom"    , "ccui.Button")
    self._btnDefault = seekNodeByName(self, "Button_diy_b_CreatRoom"    , "ccui.Button")
    self._titleSet = seekNodeByName(self, "BitmapFontLabel_20"    , "ccui.TextBMFont")
    self._titleCreate = seekNodeByName(self, "BitmapFontLabel_1"    , "ccui.TextBMFont")
    self._titleStencil = seekNodeByName(self, "BitmapFontLabel_1_0", "ccui.TextBMFont")
    self._btnAddGamePlay = seekNodeByName(self, "Button_add_gamePlay", "ccui.Button")
    self._btnDeleteGamePlay = seekNodeByName(self, "Button_delete_gamePlay", "ccui.Button")
    self._panleStencil = seekNodeByName(self, "Panel_Club_JLTJ", "ccui.Layout")
    self._btnHelp = seekNodeByName(self, "Button_add_wh", "ccui.Button")

    self._panelVoice = seekNodeByName(self, "Panel_talking_CreatRoom", "ccui.Layout")
    self._panelTing = seekNodeByName(self, "Panel_ting_CreatRoom", "ccui.Layout")   -- 听牌提示开关
    self._boxVoice = seekNodeByName(self, "CheckBox_rtVoice", "ccui.CheckBox")
    self._boxTingPrompt = seekNodeByName(self, "CheckBox_tingPrompt", "ccui.CheckBox")

    self._btnSaveGamePlay = seekNodeByName(self, "Button_save_gamePlay", "ccui.Button")

    self.btnList:setScrollBarEnabled(false)

    self._classicCreateRoomLayout:setVisible(true)
    self:_registerCallBack()
    
    self._sortNode = {self._panelTing, self._panelVoice}
end

function UICreateRoom:_registerCallBack()
    bindEventCallBack(self.btnOK, handler(self, self.onCreatRoomClick), ccui.TouchEventType.ended)
    bindEventCallBack(self.btnFree, handler(self, self.onCreatRoomClick), ccui.TouchEventType.ended)
    bindEventCallBack(self.btnClose, handler(self, self.onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSure, handler(self, self.onClickSure), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDefault, handler(self, self.onClickDefault), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnAddGamePlay, handler(self, self._onClickAddGamePlay), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDeleteGamePlay, handler(self, self._onClickDeleteGamePlay), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onBtnHelp), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSaveGamePlay, handler(self, self._onClickSaveGamePlay), ccui.TouchEventType.ended)
end

-- 切换游戏区域时调用的函数
function UICreateRoom:_onRegionChanged()
    UIManager:getInstance():destroy("UICreateRoom")
end

function UICreateRoom:onBtnClose()
    UIManager:getInstance():destroy("UICreateRoom")
end

function UICreateRoom:_getRoomSettings()
    local roomSetting = game.service.RoomCreatorService.getInstance():getLastCreateRoomSettings()
    -- 如果是从创建模版玩法进来的，默认先显示模版玩法
    if self._roomSettings then
        roomSetting._gameType = self._roomSettings._gameType
        roomSetting._ruleMap[self._roomSettings._gameType] = self._roomSettings._ruleMap[self._roomSettings._gameType]
    end
	return roomSetting
end

--[[/**
 * 初始化玩法相关控件
 */]]
function UICreateRoom:initGameTypeUI()	
    local _gameType = self:_getRoomSettings()._gameType
    local gameTypes, gameTypesConfig = room.RoomSettingHelper.getGameTypes()
    self.btnList:removeAllChildren()
    for _, gameTypeUI in pairs(self.gameTypeUIs) do
        UIManager:getInstance():hide("UI_"..gameTypeUI.gameType, true)
    end
    self.gameTypeUIs = {}

    gameTypes = self:_filterConflictGameType(gameTypes)
    for k, gameType in pairs(gameTypes) do
        local config = gameTypesConfig[gameType]
        -- 这里做初始化，如果没有选过，那么全部默认为不禁用
        -- 如果有选过的话，那么最好是从亲友圈中拿回数据
        -- 默认第一个数据是，是否开启，0禁用，1不禁用
        -- 不能每次都重新赋值
        self._reverseSelectInfo[gameType] = self._reverseSelectInfo[gameType] or self:_getDefaultSelectInfo(room.RoomSettingHelper.convert2OptionValue(gameType))
        while true do
            -- 如果当前玩法禁用了，并且不是在群主的禁用玩法设定界面，那么不再创建
            if self._reverseSelectInfo[gameType].isMainBanned and not self._reverse then
                break
            end

            local gameTypeUI                        = GameTypeUI.new(gameType)
            -- 保存玩法UI
            self.gameTypeUIs[#self.gameTypeUIs + 1] = gameTypeUI
            
		    local node = nil
		    node = self.modelNode:clone()
		    node:setName("GAME_TYPE_BUTTON_cloned")
            node:setVisible(true)
		    self.btnList:addChild(node)

            gameTypeUI.gameTypeBtnOff = seekNodeByName(node, "GAME_TYPE_BUTTON", "ccui.CheckBox")
            local gameTypeTxt = seekNodeByName(node, "GAME_TYPE_BUTTON_TXT", "ccui.TextBMFont")
			gameTypeTxt:setString(config.name)
            -- “新”的标识
            local newGameTypeImg = seekNodeByName(node, "GAME_TYPE_BUTTON_FREE_0", "ccui.ImageView")
            newGameTypeImg:setVisible(config.isNew)

            if Macro.assetTrue(#gameTypes > 1 and not gameTypeUI.gameTypeBtnOff, "Miss Button UI : "..gameType) then
                break
            end
            local selectCheck = seekNodeByName(node, "GAME_PLAY_x_TYPE_BUTTON", "ccui.CheckBox")
            selectCheck:setVisible(self._reverse)
            selectCheck:setSelected(self._reverseSelectInfo[gameType].isMainBanned)
            gameTypeUI.subCheck = selectCheck
            if gameTypeUI.gameTypeBtnOff then -- 左部玩法标签页按下状态
                -- 设置点击回调
                local isSelected = false
                gameTypeUI.gameTypeBtnOff:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        isSelected = gameTypeUI.gameTypeBtnOff:isSelected()
                    elseif eventType == ccui.TouchEventType.moved then
                    elseif eventType == ccui.TouchEventType.ended then
                        self:onGameTypeClicked(gameType)
                    elseif eventType == ccui.TouchEventType.canceled then
                        gameTypeUI.gameTypeBtnOff:setSelected(isSelected)
                    end
                end )

                local isSelected1 = false
                selectCheck:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        isSelected1 = selectCheck:isSelected()
                    elseif eventType == ccui.TouchEventType.moved then
                    elseif eventType == ccui.TouchEventType.ended then
                        -- self:onGameTypeClicked(gameType)
                        local disableNum = 0
                        for k,vv in pairs(self.gameTypeUIs) do
                            if vv.subCheck:isSelected() then
                                disableNum = disableNum + 1
                            end
                        end
                        if disableNum == #self.gameTypeUIs then
                            -- 全部禁用掉了玩法，这样是不充许的
                            -- 当前的不充许选中
                            game.ui.UIMessageTipsMgr.getInstance():showTips("至少要保留一个可玩的玩法！")
                            selectCheck:setSelected(false)
                        end
                        self._reverseSelectInfo[gameType].isMainBanned = selectCheck:isSelected()
                    elseif eventType == ccui.TouchEventType.canceled then
                        selectCheck:setSelected(isSelected1)
                    end
                end )
            end
            -- 获取指定玩法选项按钮的父节点
            _gameType = _gameType == "" and gameType or _gameType
            if _gameType == gameType then
                if gameTypeUI.parentBox == nil then
                    gameTypeUI.parentBox = UIManager.getInstance():show("UI_"..gameType)
                end
                self:initAllChlidCheckBox(gameTypeUI.parentBox, gameTypeUI);
                if Macro.assetTrue(not gameTypeUI.gameTypeBtnOff, "Miss Game Type UI : "..gameType) then
                    break
                end
                -- 初始化选项按钮
            end
            -- 获取宝石相关的控件的父节点， 用于审核版时隐藏宝石
            local diamondRoot = "DiamondRoot"

            -- 获取玩法的限免标志需要与parentBox平级
            gameTypeUI.freeFlag = seekNodeByName(node, "GAME_TYPE_BUTTON_FREE", "ccui.ImageView")
            if Macro.assetTrue(not gameTypeUI.freeFlag, "Miss FREE UI : "..gameType) then
                break
            end
            -- 默认不显示限免标识
            gameTypeUI.freeFlag:setVisible(false)
            break
        end
    end
end

-- 铜仁的麻将需要特殊处理下，避免模式相关没有选中
function UICreateRoom:_checkNoTrustOption(gameType, defaultrules)
    if gameType == "GAME_TYPE_PAODEKUAI" then 
        return 
    end 

    local selectIndex = nil  
    for i, v in pairs(defaultrules) do 
        if v == "GAME_PLAY_JI_SU" or v == "TRUSTEESHIP_60" or v == "TRUSTEESHIP_180" or v == "TRUSTEESHIP_300" then  
            selectIndex = i 
            break 
        end 
    end 

    -- 大联盟玩法管理进入页面类型： 1-- 从 玩法管理-编辑 进入  2 -- 从玩法管理-添加新玩法 进入
    -- 从添加新玩法中进入，其模式必须默认为：不托管
    if self._fromType and self._fromType == 2 then 
        if tonumber(selectIndex) then 
            table.remove(defaultrules, selectIndex)
            return "TRUSTEESHIP_NO"
        end 
    end

    if tonumber(selectIndex) then 
        return 
    end 

    return "TRUSTEESHIP_NO"
end 

function UICreateRoom:initAllChlidCheckBox(node, gameTypeUI)
    local gameType     = gameTypeUI.gameType
    local ruleSettings = room.RoomSettingHelper.getRuleSetting(gameType)

    local default_rules = self:_getRoomSettings()._ruleMap[gameTypeUI.gameType]
    local trust_optin = self:_checkNoTrustOption(gameType, default_rules)
    if trust_optin ~= nil and not table.keyof(default_rules, trust_optin) then 
        table.insert(default_rules, trust_optin)
    end 

    if Macro.assetTrue(not ruleSettings, "Miss UI : "..gameType) then
        return
    end

    -- 这个是禁用选择时加载的资源，这种状态下，所有选中的全部都是要禁用掉的，所以要替换一下资源
    local reverse_img_config = {
        {
            bg = "img/ck_xx0.png",
            sel = "img/ck_xx1.png",
            dis = "img/ck_xx0.png",
        },
        {
            bg = "img/ck_xx2.png",
            sel = "img/ck_xx3.png",
            dis = "img/ck_xx2.png",
        },
    }

    -- 正常的是有两种状态的，一种是圆点，一种是方框的
    local noraml_img_config = {
        {
            bg = "img/Checkbox2_0.png",
            sel = "img/Checkbox2_1.png",
            dis = "img/Checkbox2_3.png",
        },
        {
            bg = "img/Checkbox1_0.png",
            sel = "img/Checkbox1_1.png",
            dis = "img/Checkbox1_3.png",
        },
    }

    -- 根据配置查找控件
    for k, setting in pairs(ruleSettings) do
        for _, option in pairs(setting._group) do
            
            local cbox = seekNodeByName(node, option._option, "ccui.CheckBox")
            if cbox then
                -- 设置点击回调 从一而终，只有按下跟抬起都在框内才有效！
                local isSelected = false
   
                cbox:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        isSelected = cbox:isSelected()
                    elseif eventType == ccui.TouchEventType.moved then
                    elseif eventType == ccui.TouchEventType.ended then
                        self:onCheckBoxClicked(cbox)
                    elseif eventType == ccui.TouchEventType.canceled then
                        cbox:setSelected(isSelected)
                    end
                end )
                
                local item = room.RoomSettingHelper.getDeclareItem(self:getCurrentGameType(), option._option)
                local config = nil
                -- local voiceParent = seekNodeByName(node, "Panel_talking_CreatRoom", "ccui.Text")
                if self._reverse then
                    if #item._group > 1 then
                        config = reverse_img_config[2]
                    else
                        config = reverse_img_config[1]
                    end
                else
                    if #item._group > 1 then
                        -- 如果多选一，那么要用小圆点
                        config = noraml_img_config[1]
                    else
                        config = noraml_img_config[2]
                    end
                end
                -- TODO-NOTICE: 如果潮汕这类的有前置条件的，可能还要多再一步禁用图片的设置

                -- 根据当前的打开方式加载资源
                cbox:loadTextureBackGround(config.bg)
                cbox:loadTextureBackGroundSelected(config.bg)
                cbox:loadTextureBackGroundDisabled(config.dis)
                cbox:loadTextureFrontCross(config.sel)
                cbox:loadTextureFrontCrossDisabled(config.dis)

                -- 全部默认不选中，因为，在禁用模式的时候，roomsetting不能做有效性检查，会导致全选中的时候，显示的就是默认全部禁用掉了                    
                cbox:setSelected(false)                    
                -- 保存控件
                gameTypeUI.ruleCheckBoxes[option._option] = cbox
            end
        end
    end
end

-- 多地区检查是否关闭语音选项
function UICreateRoom:mutiAreaHideVoice()
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
	if areaId == 10004 then		-- 安顺
        return true
    end
    return false
end

--[[/**
 * 显示制定gameType的切页
 */]]
function UICreateRoom:showGameType(gameType)
    -- // 选择切页
    for _, gameTypeUI in pairs(self.gameTypeUIs) do
        if gameTypeUI.parentBox == nil and gameTypeUI.gameType == gameType then
            gameTypeUI.parentBox = UIManager.getInstance():show("UI_"..gameType)
            self:initAllChlidCheckBox(gameTypeUI.parentBox, gameTypeUI);
        end
        if gameTypeUI.parentBox then
            if gameTypeUI.gameType == gameType then
                UIManager.getInstance():show("UI_"..gameType)
                self._txtUseCardTips = seekNodeByName(gameTypeUI.parentBox, "Text_Tips", "ccui.Text")
                self._txtStencil = seekNodeByName(gameTypeUI.parentBox, "Text_Club_JLTJ", "ccui.Text")
                self:_refreshPerOpen()
            else
                UIManager.getInstance():hideUI(gameTypeUI.parentBox);
            end
        end

        if gameTypeUI.gameTypeBtnOff then
            gameTypeUI.gameTypeBtnOff:setTouchEnabled(self._reverse or not self._reverseSelectInfo[gameTypeUI.gameType].isMainBanned)
            -- 禁用选择，拿来当状态使用
            gameTypeUI.subCheck:setVisible(self._reverse or self._reverseSelectInfo[gameTypeUI.gameType].isMainBanned)
            gameTypeUI.subCheck:setSelected(self._reverseSelectInfo[gameTypeUI.gameType].isMainBanned)
            gameTypeUI.subCheck:setTouchEnabled(self._reverse or not self._reverseSelectInfo[gameTypeUI.gameType].isMainBanned)
            gameTypeUI.gameTypeBtnOff:setSelected(gameTypeUI.gameType == gameType)
            gameTypeUI.gameTypeBtnOff:setTouchEnabled(not gameTypeUI.gameTypeBtnOff:isSelected())
        end

        if self._reverseSelectInfo[gameType] ~= nil then
            local disableTing = false
            table.foreach(self._reverseSelectInfo[gameType].banGameplays,function (k,v)
                if room.RoomSettingHelper.convert2OptionString(v) == "GAME_PLAY_COMMON_TING_TIPS_OPEN" then
                    disableTing = true
                end
            end)
            
            self._boxTingPrompt:setEnabled(not disableTing or self._reverse)
        end
    end
    
    -- //刷新限免按钮
    self:_refreshFreeBtn();
    -- // 设置控件状态
    local tb = self:_getRoomSettings()._ruleMap[gameType]
    if self._clubId or self._reverse  then
        -- 如果是亲友圈，需要考虑，禁用选项，可以是禁用显示，也可以带禁用的创建亲友圈创建房间
        local info = self._reverseSelectInfo[gameType] or {}
        local options = {}
        if info.banGameplays then
            options = clone(info.banGameplays)
        end
        options = room.RoomSettingHelper.convert2OptionTypes(options)
        -- 添加局数
        -- TODO-NOTICE 如果是内蒙的圈，这里的false需要改动一下
        for i,v in ipairs(info.banRoundTypes or {}) do
            local roomSetting = room.RoomSettingHelper.getRoomRoundSetting(false, v)
            if roomSetting then
                table.insert( options, 1 ,roomSetting._type )
            end
        end
        -- 将当前对应的禁用选项处理
        if self._reverse then
            tb = options
            self._forbidRuleNames = {}
        else
            self._forbidRuleNames = options
        end
    end

    -- 修改听牌提示的显示与关闭
    local _, gameTypesConfig = room.RoomSettingHelper.getGameTypes()
    local _config = gameTypesConfig[gameType]
    local isOpenTingTips = _config and _config.isOpenTingTips == true
    self._panelTing:setVisible(isOpenTingTips)
    self:refreshCheckBoxState(gameType, tb);

    self:sortExRulePanel()
end

-- 对玩法外的房间选项排序
function UICreateRoom:sortExRulePanel()
    local startPosX = 143
    local space = 225
    local index = 0
    for k,v in ipairs(self._sortNode) do
        if v:isVisible() then
            v:setPositionX(startPosX + index * space)
            index = index + 1
        end
    end
end

--[[/**
 * 获取制定玩法的ui配置
 */]]
function UICreateRoom:getGameTypeUI(gameType)
    for _, ui in pairs(self.gameTypeUIs) do
        if ui.gameType == gameType then
            return ui;
        end
    end
    return nil;
end

--[[/**
 * 获取当前选中的玩法类型
 */]]
function UICreateRoom:getCurrentGameType()
    for _, ui in pairs(self.gameTypeUIs) do
        if ui.parentBox and ui.parentBox:isVisible() then
            return ui.gameType
        end
    end
    return nil
end

--[[/**
 * 根据界面表现获取当前有效设置
 */]]
function UICreateRoom:getCurrentOptions()
    local options         = {}
    local currentGameType = self:getCurrentGameType()
    local gameTypeUI      = self:getGameTypeUI(currentGameType)
    local ruleSetting     = room.RoomSettingHelper.getRuleSetting(currentGameType)
    if not gameTypeUI and not ruleSetting then
        Macro.assetTrue(not gameTypeUI)
        Macro.assetTrue(not ruleSetting)
        return nil
    end

    -- 检测UI选项是否选中并有效
    for key, _ in pairs(gameTypeUI.ruleCheckBoxes) do
        local cbBox = gameTypeUI.ruleCheckBoxes[key]
        if cbBox:isSelected() then
            -- 提审实时语音,默认关闭
            local ruleName = cbBox:getName()
            options[#options + 1] = ruleName
        end
    end

    -- 把实时语音CB的状态给他加进去
    if not self._reverse then
        if not self._boxVoice:isSelected() or GameMain.getInstance():isReviewVersion() or (not game.service.RT_VoiceService.getInstance():isSupported() or self._isStenci) then
            options[#options + 1] = "GAME_PLAY_COMMON_VOICE_CLOSE"
        else
            options[#options + 1] = "GAME_PLAY_COMMON_VOICE_OPEN"
        end
        -- 听牌提示加进去
        if self._boxTingPrompt:isSelected() and self._boxTingPrompt:isVisible() == true then
            options[#options + 1] = "GAME_PLAY_COMMON_TING_TIPS_OPEN"
        else
            options[#options + 1] = "GAME_PLAY_COMMON_TING_TIPS_CLOSE"
        end
    end

    -- 更细选项，如果是禁用模式的话，那么需要的判断是更正常模式不同的，如果要是写的完美一些的话，应该写入判断
    -- 组选一，且必选中的情况下，至少要留一个不是选中状态的
    return room.RoomSettingHelper.processOptions(currentGameType, options, self._reverse, self._forbidRuleNames)
end

--[[/**
 * 根据当前选中状态,更新设置选项状态
 */]]
function UICreateRoom:refreshCheckBoxState(gameType, options)
    local gameTypeUI = self:getGameTypeUI(gameType)
    if gameTypeUI == nil then
        Logger.error('cant find ui game type ' ..  gameType or 'unknow ')
        return 
    end
    gameTypeUI:unCheckAllBoxes()
    local recursively = false
    -- 如果当前默认选中的选项，在玩法中禁用了，需要再重新找一个没有被禁用的
    local reSlecet = false
    for key, _ in pairs(gameTypeUI.ruleCheckBoxes) do
        local cbox = gameTypeUI.ruleCheckBoxes[key]
        -- 为避免RoomSettingHelper 中知道过多联系不紧密的数据，特加入一个isManagerForbid方法，辅助判断新加的限制需求
        local isSetEnable = room.RoomSettingHelper.isSettingEnabled(gameTypeUI.gameType, key, options, self._reverse);
        local isManageEnable = not self:isManagerForbid(key);
        -- 设置每个子规则控件状态
        cbox:setSelected(table.indexof(options, key) ~= false and isManageEnable); 
        cbox:setEnabled(isSetEnable and isManageEnable)
        local item = room.RoomSettingHelper.getDeclareItem(self:getCurrentGameType(), cbox:getName())
        if not reSlecet then
            reSlecet = table.indexof(options, key) ~= false and not isManageEnable and item._mustSelected
        end
        if not cbox:isEnabled() and cbox:isSelected() then
            cbox:setSelected(false)
            recursively = true 
        end            
    end

    -- 原来这里这么写是不是有风险?死循环？
    if recursively or reSlecet then
        self:refreshCheckBoxState(gameType, self:getCurrentOptions())
    end
    -- 检查充分条件
    self:checkSufficient(gameType, options);
end

-- 检查充分条件，如果充分条件满足，这个box必须选中
function UICreateRoom:checkSufficient(gameType,options)
    local gameTypeUI = self:getGameTypeUI(gameType)
    for key, _ in pairs(gameTypeUI.ruleCheckBoxes) do
        local cbox = gameTypeUI.ruleCheckBoxes[key]
        local isSetEnable = room.RoomSettingHelper.isSufficientEnabled(gameTypeUI.gameType, key, options);
        -- 设置每个子规则控件状态
        if isSetEnable then
            cbox:setSelected(isSetEnable); 
            cbox:setEnabled(isSetEnable);
        end
    end
end

-- 是否是群主的禁止的选项
function UICreateRoom:isManagerForbid(key)
    if self._forbidRuleNames == nil or # self._forbidRuleNames == 0 then
        return false;
    end
    local index = table.indexof(self._forbidRuleNames,key);
    return index ~= false;
end

-- /**刷新免费按钮 */
function UICreateRoom:_refreshFreeBtn()
     -- 亲友圈无限免
    if self._clubId ~= nil then
        return
    end

    -- 如果是禁用模式，那么不更新
    if self._reverse then
        return
    end

    local gameTypeUI = self:getGameTypeUI(self:getCurrentGameType())

    if gameTypeUI == nil then
        self.btnFree:setVisible(false)
        self.btnOK:setVisible(true)
    else
        local activeList = game.service.FreePlayService:getInstance():getActiveData()
        local find       = false
        for i = 1, #activeList do
            if room.RoomSettingHelper.convert2OptionType(activeList[i].roomType) == self:getCurrentGameType() then
                find = true
                break
            end
        end
        self.btnFree:setVisible(find)
        self.btnOK:setVisible(not find)
    end
end

--[[/**
 * 获取对应枚举值的玩法
 */]]
function UICreateRoom:getGameTypeUIFromEnum(roomType)
	local areaId = game.service.LocalPlayerService:getInstance():getArea();
    local ruleType = MultiArea.getRuleType(areaId)
    for _, ui in pairs(self.gameTypeUIs) do
        if ruleType[1][ui.gameType][1] == roomType then
            return ui
        end
    end
    return nil
end

-- /**刷新各玩法的限免标志 */
function UICreateRoom:refreshRoomSettingForFree()
    -- 亲友圈无限免
    if self._clubId ~= nil then
        return
    end

    for _, gameTypeUI in pairs(self.gameTypeUIs) do
        if gameTypeUI.freeFlag then
            gameTypeUI.freeFlag:setVisible(false)
        end
    end
    local activeList = game.service.FreePlayService:getInstance():getActiveData()
    table.foreach(activeList, function (key, data)
        local gameTypeUI = self:getGameTypeUIFromEnum(data.roomType)
        if Macro.assetTrue(room.RoomSettingHelper.convert2OptionType(data.roomType) == nil, "限免活动房间类型错误 :"..data.roomType) then
            return
        end
        if gameTypeUI.freeFlag ~= nil then
            gameTypeUI.freeFlag:setVisible(true)
        end
    end )

    self:_refreshFreeBtn();
end

--[[/**
 * 初始化默认选项
 */]]
function UICreateRoom:initSelection()
    local defaultShowGameType = self:_getRoomSettings()._gameType
    local isNotEnableToBan = self:_isConflitGamType(defaultShowGameType)
    self._reverseSelectInfo = self:_filterConflictInfo(self._reverseSelectInfo)
    if (self._reverse or self._isStencil) and isNotEnableToBan then
        defaultShowGameType = self.gameTypeUIs[1].gameType
    end

    -- // 显示默认切页
    if not isNotEnableToBan and self._reverseSelectInfo[defaultShowGameType].isMainBanned then
        -- 当前页禁用掉了，那么找一个可以选择的页
        for _, gameTypeUI in pairs(self.gameTypeUIs) do
            if not self._reverseSelectInfo[gameTypeUI.gameType].isMainBanned then
                self:showGameType(gameTypeUI.gameType)
                break
            end
        end
    else
        self:showGameType(defaultShowGameType)
    end

    -- -- 听牌提示开关
    local rule =  room.RoomSettingHelper.convert2OptionValue("GAME_PLAY_COMMON_TING_TIPS_OPEN")

    local flag = false
    for k,v in pairs(self._reverseSelectInfo) do
        table.foreach(v.banGameplays,function (k,v)
            if v == rule then
                flag = true
            end
        end)
    end
    if self._reverse then
        -- 初始化听牌提示是否勾选
        self._boxTingPrompt:setSelected(flag)
    else
        local options = self:_getRoomSettings()._ruleMap[defaultShowGameType]
        table.foreach(options, function (k,v)
            if v == "GAME_PLAY_COMMON_TING_TIPS_OPEN" then
                local isEnabled = self._boxTingPrompt:isEnabled()
                self._boxTingPrompt:setSelected((true or not flag) and isEnabled)
            end
        end)
    end
end

function UICreateRoom:onGameTypeClicked(gameTypes)
    -- 先保存当前页的，再切换其它页面
    self:_getReverseSelection()
    
    self:showGameType(gameTypes);
end

-- 点击可选项
function UICreateRoom:onCheckBoxClicked(cbox)
    local item          = room.RoomSettingHelper.getDeclareItem(self:getCurrentGameType(), cbox:getName())
    local cboxes        = {}
    local allCheckBoxes = self:getGameTypeUI(self:getCurrentGameType()).ruleCheckBoxes
    for key, _ in pairs(allCheckBoxes) do
        if item:getOption(key) ~= nil then
            cboxes[#cboxes + 1] = allCheckBoxes[key]
        end
    end

    -- 必须且只能选择一项
    if item._mustSelected then
        if self._reverse then
            -- 在禁用模式的时候，多选一，且必选的就，就得变成，必留一个
            local remainNum = 0
            for _, cb in pairs(cboxes) do
                if not cb:isSelected() then
                    remainNum = remainNum + 1
                end
            end
            -- 至少也要留一个，如果全部禁用了，那么，取消
            if remainNum == 0 then
                cbox:setSelected(false)
                game.ui.UIMessageTipsMgr.getInstance():showTips("多选一的选项至少要保留一个！")
            end
        else
            for _, cb in pairs(cboxes) do
                cb:setSelected(cb == cbox)
            end
        end
    else
        -- 非必选的，如果有组的话，在禁用的时候，是不能控制其它的
        if not self._reverse then
            -- 只能选一个，但是可以一个都不选。
            if cbox:isSelected() then
                for _, cb in pairs(cboxes) do
                    cb:setSelected(cb == cbox)
                end
            end
        end
    end

    self:refreshCheckBoxState(self:getCurrentGameType(), self:getCurrentOptions())

    --[[ 
        在禁用模式下
        刷新之后，取到所有被禁用的选项
        遍历, 把所有选项中的前置条件为该选禁用项的，禁用或者取消勾选掉
    ]]
    if not self._reverse then
        return
    end
    
    local banKeys = {}
    local needToBanKeys = {}
    for _, cbox in pairs(allCheckBoxes) do
        if cbox:isSelected() then
            local key = cbox:getName()
            table.insert(banKeys, key)
        end
    end
    -- local isSelected = allCheckBoxes["GAME_PLAY_QUAN_GUAN_JIA_BEI"]:isSelected()
    local ruleSettings = room.RoomSettingHelper.getRuleSetting(self:getCurrentGameType())
    for idx, ruleSetting in pairs(ruleSettings) do
        for _, rule in pairs(ruleSetting._group) do
            -- 这里的 condition 只支持写一个纯cboxName 后续优化吧
            local isToBan = table.indexof(banKeys, rule._condition) ~= false
            if isToBan then
                table.insert(needToBanKeys, rule._option)
            end
        end
    end
    
    for _, banKey in ipairs(needToBanKeys) do
        allCheckBoxes[banKey]:setEnabled(true)
        allCheckBoxes[banKey]:setSelected(true)
        -- printf("set %s BANED", banKey)
    end
end

--[[/**
 * 点击创建房间的回调
 */]]
function UICreateRoom:onCreatRoomClick(sender)
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        return
    end

    -- 获取并保存当前选项
    local currentGameType   = self:getCurrentGameType();
    local currentRules      = self:getCurrentOptions();

    local roundSetting 		= room.RoomSettingHelper.getRoomRoundSettings(currentRules)
    if not roundSetting then
        return
    end
    local freeActivityId  = -1
    local currentRoomType = room.RoomSettingHelper.convert2OptionValue(currentGameType);
    freeActivityId        = game.service.FreePlayService:getInstance():getActivityId(currentRoomType);

    -- 发送服务器
    local settings = room.RoomSettingHelper.convert2ServerGameOptions(currentGameType, currentRules);

    if self._clubId then
        --创建亲友圈房间
        local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
        local managerId = club.info.managerId or 0
        game.service.RoomCreatorService.getInstance():createClubRoomReq(0, settings, roundSetting._value, self._clubId, managerId, false, {}, ClubConstant:getCreateRoomType().CLUB_CREATE, {})
        -- 保存一下玩法
        if self._playerInfo then
            game.service.club.ClubService.getInstance():saveLocalStoragePlayerInfo(self._playerInfo)
        end
    else
        --创建普通房间
        local friendIds = game.service.friend.FriendService.getInstance():getFriendData():getFriendIds()
        local createRoomType = #friendIds == 0 and ClubConstant:getCreateRoomType().LOBBY_CREATE or ClubConstant:getCreateRoomType().FRIEND_QUICK_CREATE
        game.service.RoomCreatorService.getInstance():createRoomReq(0, roundSetting._value, settings, freeActivityId, createRoomType, friendIds);
    end
end

-- 确认提交当前的变更选项
function UICreateRoom:onClickSure()
    self:_getReverseSelection()
    Logger.dump(self._reverseSelectInfo, "SelectInfo ===>", 10)
    local clubserver = game.service.club.ClubService:getInstance():getClubManagerService()
    local CommonAreaId = 0
    local gameplays = {}
    local commonPlay = {}

    -- 添加通用玩法禁用,在bangameplays里将所有玩法都添加/删除通用玩法
    local rule =  room.RoomSettingHelper.convert2OptionValue("GAME_PLAY_COMMON_TING_TIPS_OPEN")

    for k,v in pairs(self._reverseSelectInfo) do
        if self._boxTingPrompt:isSelected() then
            table.insert(v.banGameplays, rule)
        else
            local newList = {}
            table.foreach(v.banGameplays,function (k,v)
                if v ~= rule then
                    table.insert(newList, v)
                end                
            end)
            v.banGameplays = newList
        end
        table.insert(gameplays, v)
    end

    clubserver:sendCCLClubBanGameplayREQ(self._clubId, CommonAreaId, gameplays)
end

-- 统一创建 默认选项的接口
function UICreateRoom:_getDefaultSelectInfo(id)
    return {
        -- 构造一个默认的数据结构
        mainRuleId = id,
        isMainBanned = false,
        banRoundTypes = {},
        banGameplays = {}, 
    }
end

-- 恢复默认
function UICreateRoom:onClickDefault()
    for k,v in pairs(self._reverseSelectInfo) do
        self._reverseSelectInfo[k] = self:_getDefaultSelectInfo(v.mainRuleId)
    end
    self:showGameType(self:getCurrentGameType())
end

-- 保存，在点击切页，在单击确定的时候都需要保存一下
function UICreateRoom:_getReverseSelection()
    if not self._reverse then return end

    local currentGameType   = self:getCurrentGameType();
    local currentRules      = self:getCurrentOptions();
    local roundSetting 		= room.RoomSettingHelper.getRoomRoundSettings(currentRules)
    local banGameCounts = {}
    while roundSetting do
        -- 如果局数选择种类大于3种的时候，可以禁用复数个的选项
        table.insert(banGameCounts, roundSetting._value)
        local idx = table.indexof(currentRules, roundSetting._type)
        if idx ~= false then
            table.remove(currentRules, idx)
            roundSetting = room.RoomSettingHelper.getRoomRoundSettings(currentRules)
        else
            break
        end
    end
    local settings = clone(room.RoomSettingHelper.convert2ServerGameOptions(currentGameType, currentRules))
    -- 将第一个值，保存，这个代表的是当前是否禁用
    -- 保存的结构
    --{ mainRuleId, mainRuleBan, gameCounts, gameplays}
    -- 删除第一个玩法选项
    table.remove(settings, 1)
    local banGameplays = settings
    self._reverseSelectInfo[currentGameType].banGameplays = settings
    self._reverseSelectInfo[currentGameType].banRoundTypes = banGameCounts
end

--[[
    参数说明
    1.亲友圈Id
    2.界面类型（禁用、模版、创建）
    3.亲友圈禁用玩法
    4.模版玩法
]]

function UICreateRoom:onShow(...)
    local args = {...};

    self._boxVoice:setSelected(false)

    self._boxTingPrompt:setSelected(false)

    self._clubId = args[1]

    self._playerInfo = game.service.club.ClubService.getInstance():loadLocalStoragePlayerInfo()

    if args[2] then
        self._reverse = args[2] == ClubConstant:getGamePlayType().reverse
        self._isStencil = args[2] == ClubConstant:getGamePlayType().stencil
        self._isSuperLeague = args[2] == ClubConstant:getGamePlayType().superLeague
        self._isLeague = args[2] == ClubConstant:getGamePlayType().league
    else
        self._reverse = false
        self._isStencil = false
        self._isSuperLeague = false
        self._isLeague = false
    end

    -- 联盟玩法隐藏实时语音
    self._panelVoice:setVisible(not self._isSuperLeague and not self._isLeague)

    -- 控制下方通用玩法禁用图标
    local darkTingPrompt = seekNodeByName(self, "CheckBox_tingPromptDark", "ccui.CheckBox")
    darkTingPrompt:setVisible(self._reverse)
    if self._reverse then
        self._boxTingPrompt:setVisible(false)
        darkTingPrompt:setVisible(true)
        self._boxTingPrompt = darkTingPrompt
    else
        darkTingPrompt:setVisible(false)
    end

    -- 如果是提审， 版本不符， 模板创建， 则关闭声音显示
    if GameMain.getInstance():isReviewVersion() or              --审核
        not game.service.RT_VoiceService.getInstance():isSupported() or --版本不支持
        self._reverse or --禁用
        self._isStencil or --模板
        self:mutiAreaHideVoice() then --区域不支持
        --Panel_talking_CreatRoom
        self._panelVoice:setVisible(false)
    end

    local gameplays = args[3] or {}

    self._callBack = args[5] or nil
    self._fromType = args[6] or nil 

    self:_initGamePlay(args[4])

    -- 如果有禁用玩法选项，转换，如果没有的话，会在使用的时候创建默认不禁用选项
    if #gameplays > 0 then
        if #gameplays == 1 and gameplays[1].mainRuleId == 0 then
            -- 旧版本兼容
            local gameTypes, gameTypesConfig = room.RoomSettingHelper.getGameTypes()
            for k, gameType in pairs(gameTypes) do
                self._reverseSelectInfo[gameType] = self:_getDefaultSelectInfo(room.RoomSettingHelper.convert2OptionValue(gameType))
                self._reverseSelectInfo[gameType].banGameplays = clone(gameplays[1].banGameplays)
            end
        else
            -- 转换为当前要使用的结构
            for i,v in ipairs(gameplays) do
                local gametype = room.RoomSettingHelper.convert2OptionType(v.mainRuleId)
                if gametype then
                    self._reverseSelectInfo[gametype] = {
                        -- 构造一个默认的数据结构
                        mainRuleId = v.mainRuleId,
                        isMainBanned = v.isMainBanned,
                        banRoundTypes = clone(v.banRoundTypes),
                        banGameplays = clone(v.banGameplays), 
                    }
                end
            end
        end
    end

    self:initGameTypeUI();

    if args[1] then
        --是创建亲友圈房间
        if config.GlobalConfig.OPEN_CLUB_EARLY then
            self:_showEarly()
        end
    else
        self._clubId = nil;
        self:refreshRoomSettingForFree();
    end

    -- // 初始化选中状态
    self:initSelection();
    self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
    bindEventCallBack(self._mask, handler(self, self.onBtnClose), ccui.TouchEventType.ended)

    -- 听牌提示位置
    if self._reverse then
        local text = self._panelTing:getChildByName("Text_tingTips")
        self._boxTingPrompt:setPosition(text:getPosition())
        text:setPosition(cc.p( self._boxTingPrompt:getPositionX() + self._boxTingPrompt:getContentSize().width + 10 , text:getPositionY()))
    end

    -- 显示的时候，需要处理当前的显示模式，如果禁用处理的时候，跟正常的显示是不一样的
    -- 这时显示的按钮，跟显示的checkbox的都是不同的
    self:_refreshPerOpen()
end

 -- 初始化预选玩法
function UICreateRoom:_initGamePlay(data)
    self._roomSettings = nil
    if data and #data > 0 then
        self._presetGameplay = data[1]
        self._roomSettings = RoomSetting.CreateRoomSettingsClass.new()
        local localGamePlays = room.RoomSettingHelper.convert2ClientGameOptions(false, data[1].roundType, data[1].gameplays)
        self._roomSettings._gameType = room.RoomSettingHelper.getGameTypeFromOptions(localGamePlays)
        -- 将玩法类型移除
        table.remove(localGamePlays, 1)
        self._roomSettings._ruleMap[self._roomSettings._gameType] = localGamePlays
    end
end

function UICreateRoom:onHide()
    for _, gameTypeUI in pairs(self.gameTypeUIs) do
        UIManager:getInstance():hide("UI_"..gameTypeUI.gameType, true)
    end

    game.service.friend.FriendService.getInstance():getFriendData():setFriendIds({})
end

-- 更新按钮的显示
function UICreateRoom:_refreshPerOpen()
    self._btnSure:setVisible(self._reverse)
    self._btnDefault:setVisible(self._reverse)

    self._titleSet:setVisible(self._reverse)
    self._titleCreate:setVisible(not self._reverse and not self._isStencil and not self._isSuperLeague and not self._isLeague)
    self._titleStencil:setVisible(self._isStencil or self._isSuperLeague or self._isLeague)
    self._titleStencil:setString(self._isStencil and "创建房间模板" or "玩法模板")
    
    self.btnOK:setVisible(not self._reverse and not self._isStencil and not self._isSuperLeague and not self._isLeague)
    self.btnFree:setVisible(not self._reverse and not self._isStencil and not self._isSuperLeague and not self._isLeague)
    self._txtUseCardTips:setVisible(not self._reverse and not self._isStencil)
    self._classicCreateRoomLayout:setVisible(not self._reverse and not self._isStencil)

    self._panleStencil:setVisible(self._isStencil)
    self._txtStencil:setVisible(self._isStencil)
    self._btnAddGamePlay:setVisible(self._isStencil)
    self._btnDeleteGamePlay:setVisible(self._isStencil and self._presetGameplay ~= nil)

    self._btnSaveGamePlay:setVisible(self._isSuperLeague and not self._isLeague)
    self.btnClose:setVisible(true)
    if self._isLeague then
        -- UIManager:getInstance():show("UIBigLeagueMask", function ()
        --     self:onBtnClose()
        -- end)

        self:_setToLeagueState()
    end

    if self._isStencil or self._reverse then
        self._btnHelp:setPositionX(480)
    else
        self._btnHelp:setPositionX(650)
    end

    -- if self._isStencil then
    --     if self._presetGameplay then
    --         self._btnAddGamePlay:setPositionX(397)
    --     else
    --         self._btnAddGamePlay:setPositionX(550)
    --     end
    -- end
    -- android提审（应用宝）
	if device.platform == "android" and GameMain.getInstance():isReviewVersion() then
        self._txtUseCardTips:setVisible(false)
    end
    
    if not self._reverse and not self._isStencilthen then
        self:_refreshFreeBtn()
    end
end

function UICreateRoom:_setToLeagueState()
    local defaultShowGameType = self:_getRoomSettings()._gameType
    

    --重新构造左侧的按钮列表
    local _gameType = self:_getRoomSettings()._gameType
    local gameTypes, gameTypesConfig = room.RoomSettingHelper.getGameTypes()
    self.btnList:removeAllChildren()
    gameTypes = self:_filterConflictGameType(gameTypes)
    for k, gameType in pairs(gameTypes) do
        if gameType == defaultShowGameType then
            local config = gameTypesConfig[gameType]
 
            self._reverseSelectInfo[gameType] = self._reverseSelectInfo[gameType] or self:_getDefaultSelectInfo(room.RoomSettingHelper.convert2OptionValue(gameType))

           
            local node = nil
            node = self.modelNode:clone()
            node:setName("GAME_TYPE_BUTTON_cloned")
            node:setVisible(true)
            self.btnList:addChild(node)

            seekNodeByName(node, "GAME_TYPE_BUTTON", "ccui.CheckBox"):setTouchEnabled(false)

            local gameTypeTxt = seekNodeByName(node, "GAME_TYPE_BUTTON_TXT", "ccui.TextBMFont")
            gameTypeTxt:setString(config.name)

            -- “新”的标识
            local newGameTypeImg = seekNodeByName(node, "GAME_TYPE_BUTTON_FREE_0", "ccui.ImageView")
            newGameTypeImg:setVisible(config.isNew)


            local selectCheck = seekNodeByName(node, "GAME_PLAY_x_TYPE_BUTTON", "ccui.CheckBox")
            selectCheck:setVisible(self._reverse)
            selectCheck:setSelected(self._reverseSelectInfo[gameType].isMainBanned)

            seekNodeByName(node, "GAME_TYPE_BUTTON_FREE", "ccui.ImageView"):setVisible(false)
        end
    end






    --将右侧各玩法选项全部关闭触摸
    local node = UIManager:getInstance():getUI("UI_"..defaultShowGameType)
    local ruleSettings = room.RoomSettingHelper.getRuleSetting(defaultShowGameType)

    local default_rules = self:_getRoomSettings()._ruleMap[defaultShowGameType]

    -- 根据配置查找控件
    for k, setting in pairs(ruleSettings) do
        for _, option in pairs(setting._group) do
            
            local cbox = seekNodeByName(node, option._option, "ccui.CheckBox")
            if cbox then
                -- 设置点击回调 从一而终，只有按下跟抬起都在框内才有效！
                cbox:setTouchEnabled(false)
            end
        end
    end
    self._boxTingPrompt:setTouchEnabled(false)
    self._boxVoice:setTouchEnabled(false)
end

function UICreateRoom:destroy()
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
end

-- 显示提前开局提示
function UICreateRoom:_showEarly()
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    if club.data ~= nil then
        -- 只有白名单中的亲友圈才能显示
        local clubWhiteList = bit.band(club.data.clubWhiteList, ClubConstant:getWhiteListType().RECOMMEND) > 0

        self._panelEarly:setVisible(clubWhiteList)

        if clubWhiteList then
            local off = seekNodeByName(self._panelEarly, "Image_0_ztjr_CreatRoom", "ccui.ImageView")
            local open = seekNodeByName(self._panelEarly, "Image_1_ztjr_CreatRoom", "ccui.ImageView")
            off:setVisible(false)
            open:setVisible(false)
        end
    end
end

-- 修改模板玩法
function UICreateRoom:_onClickAddGamePlay()
    -- 统计添加模版玩法按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Stencil_Add);


    local currentGameType   = self:getCurrentGameType()
    local currentRules      = self:getCurrentOptions()
    local roundSetting 		= room.RoomSettingHelper.getRoomRoundSettings(currentRules)
    if not roundSetting then
        return
    end
    
    local settings = room.RoomSettingHelper.convert2ServerGameOptions(currentGameType, currentRules)
    -- 跟服务器统一数据结构
    local presetGameplay =
    {
        index = self._presetGameplay and self._presetGameplay.index or 0, -- 玩法序号(从0开始)
        roomType = 0,			                    -- 房间类型
        roundType = roundSetting._value;			-- 房间圈/局规则
        gameplays = settings,			            -- 玩法规则
    }
    
    game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubPresetGameplaysREQ(
        self._clubId,
        self._presetGameplay and ClubConstant:getOperationType().alter or ClubConstant:getOperationType().add,
        presetGameplay
    )
end

-- 删除模板玩法
function UICreateRoom:_onClickDeleteGamePlay()
    -- 统计删除模版玩法按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Stencil_Delete);

    if self._presetGameplay then
        game.service.club.ClubService.getInstance():getClubManagerService():sendCCLModifyClubPresetGameplaysREQ(self._clubId,
            ClubConstant:getOperationType().delete,
            self._presetGameplay)
    end
end

-- 点击帮助
function UICreateRoom:_onBtnHelp()
    UIManager:getInstance():show("UIHelp", self:getCurrentGameType())
end

--[[
    过滤一些在亲友圈玩法禁用中不想被禁用的玩家
    todo 做一个数组
]]
local CONFLICT_GAME_TYPES = {
    "GAME_TYPE_PAODEKUAI",
    -- "GAME_TYPE_R_GUIYANG"
}


function UICreateRoom:_filterConflictInfo(reverseInfo)
    for _, hideType in ipairs(CONFLICT_GAME_TYPES or {})  do
        local info = reverseInfo[hideType]
        if info then
            info.banGameplays = {}
        end 
    end
    return reverseInfo
end

function UICreateRoom:_filterConflictGameType(gameTypes)
    if self._reverse or self._isStencil then
        for _, hideType in ipairs(CONFLICT_GAME_TYPES or  {}) do
            local index = table.indexof(gameTypes, hideType)
            if index then
                table.remove(gameTypes, index)
            end
        end
    end
    return gameTypes
end

function UICreateRoom:_isConflitGamType(gameType)
    if table.indexof(CONFLICT_GAME_TYPES or {}, gameType) then
        return true
    end
    return false
end

function UICreateRoom:_onClickSaveGamePlay()
    if self._callBack then
        local currentGameType   = self:getCurrentGameType()
        local currentRules      = self:getCurrentOptions()
        local roundSetting 		= room.RoomSettingHelper.getRoomRoundSettings(currentRules)
        if not roundSetting then
            return
        end

        local settings = room.RoomSettingHelper.convert2ServerGameOptions(currentGameType, currentRules)
        
        ---------------------- 检测数据是否发生改变 ----------------------
        if self._presetGameplay ~= nil then 
            local oldRoundType, curRoundType = self._presetGameplay.roundType or nil, roundSetting._value
            if curRoundType ~= oldRoundType then 
                game.ui.UIMessageTipsMgr.getInstance():showTips("保存设置成功")
            end 
            
            local oldsettings = self._presetGameplay.gameplays or {}
            
            if #settings ~= #oldsettings then 
                game.ui.UIMessageTipsMgr.getInstance():showTips("保存设置成功")
            else 
                -- 判定两个table表是否相同
                for i, v in pairs(settings) do 
                    if not table.keyof(oldsettings, v) then 
                        game.ui.UIMessageTipsMgr.getInstance():showTips("保存设置成功")
                        break 
                    end 
                end 
            end 
        else 
            game.ui.UIMessageTipsMgr.getInstance():showTips("保存设置成功")
        end 

        ---------------------- 跟服务器统一数据结构 ----------------------
        local presetGameplay =
        {
            index = self._presetGameplay and self._presetGameplay.index or 0, -- 玩法序号(从0开始)
            roomType = 0,			                    -- 房间类型
            roundType = roundSetting._value;			-- 房间圈/局规则
            gameplays = settings,			            -- 玩法规则
        }
        self._callBack(presetGameplay)
        
        UIManager:getInstance():destroy("UICreateRoom")
    end
end

return UICreateRoom;