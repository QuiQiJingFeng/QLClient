--[[	使用了CheckBoxGroup
	MyCheckBoxGroup 重写了 CheckBoxGroup的方法 ， see at bottom
]]
local csbPath = "ui/csb/UISetting.csb"
local super = require("app.game.ui.UISetting")
local UISetting_chaoshan = class("UISetting_chaoshan", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local Constants = require("app.gameMode.mahjong.core.Constants")

-- overwrite
function UISetting_chaoshan:ctor()
    super.ctor(self)
end

-- 初始化所有的控件
-- overwrite
function UISetting_chaoshan:init()
    self.super.init(self)
    self._txtChatNormal = seekNodeByName(self, "Text_Language1", "ccui.Text")
    self._txtChatLocal = seekNodeByName(self, "Text_Language1_0", "ccui.Text")
    self._textvoice = seekNodeByName(self, "Text_1_0_0", "ccui.Text")  -- 语音文字
    self._txtChatNormal:setString("普通话")

    self._toggle_XieChaPai:setVisible(true)

    -- 这个cboxgroup虽然是UI名是方言，但实则是普通话。。。。 so 以后会到贵阳改
    self._cbxgLanguage = CheckBoxGroup.new({
        seekNodeByName(self, "CheckBox_Language_Mandarin", "ccui.CheckBox"),
        seekNodeByName(self, "CheckBox_Language_Dialect", "ccui.CheckBox")
    }, handler(self, self._onCheckBoxGroupLanguageClick), nil)
    self._cbxgLanguage:setSelectedCanSelectAgain(true)
end

-- overwrite
function UISetting_chaoshan:onShow(...)
    self.super.onShow(self, ...)

    -- self._3Dnotice:setVisible(self._inBattleScene or self._inCampaignScene)
    -- self._3Dnotice:setVisible(false)

    local globalSetting = game.service.GlobalSetting.getInstance()
    -- seekNodeByName(self, "Image_red_Update_3", "ccui.ImageView"):setVisible(globalSetting.isNew3D ~= false)
    -- 更新现在语音选择状态，显示的时候添加关注
    game.service.ChatService.getInstance():addEventListener("DIALECT_CHANGED", handler(self, self._onDialectChanged), self)
    self:_onDialectChanged()

    -- 是否要显示普通话
    local gameType = Constants.SpecialEvents.gameType
    if gameType == "GAME_TYPE_ZHENGSHANGYOU" and UIManager:getInstance():getIsShowing("UIGameScene_ZhengShangYou") then
        self:_hideVoicePanel()
    end
end

-- 不需要显示普通话等
function UISetting_chaoshan:_hideVoicePanel()
    self._cbx_mandarin:setVisible(false)
    self._cbx_dialect:setVisible(false)
    self._txtChatNormal:setVisible(false)
    self._txtChatLocal:setVisible(false)
    self._textvoice:setVisible(false)
end

-- overwrite
function UISetting_chaoshan:_saveValues()
    local gameType = Constants.SpecialEvents.gameType
    -- 争上游不需要保存语音设置信息
    if gameType == "GAME_TYPE_ZHENGSHANGYOU" then
        return
    end
    super._saveValues(self)
end

function UISetting_chaoshan:_onCheckBoxGroupLanguageClick(group, index)
    if index == 1 then
        self:_onMandarinSelected()
    elseif index == 2 then
        self:_onDialectSeleced()
    end
end

-- 点击普通话
function UISetting_chaoshan:_onMandarinSelected()
    local chatService = game.service.ChatService.getInstance()
    chatService:setDialect(config.ChatConfig.DialectType.NORMAL)
end

-- 点方言事件
function UISetting_chaoshan:_onDialectSeleced()
    local chatService = game.service.ChatService.getInstance()
    local localNames, localEnums = chatService:getLocalNames()
    if #localNames > 1 then
        self:hideSelf();
        UIManager:getInstance():show("UILanguage", localNames, localEnums)
    elseif #localNames == 1 then
        chatService:setDialect(localEnums[1])
    end
end

-- 方言更新
function UISetting_chaoshan:_onDialectChanged(...)
    local chatService = game.service.ChatService.getInstance()
    local dialectConfig = chatService:getDialectConfig(chatService:getDialect())
    -- 更新文字，如果当前选中的是普通话，这里显示的是方言，只有选择具体的语言后，才显示对应的名字
    local String = chatService:getDialect() == config.ChatConfig.DialectType.NORMAL and chatService:getDefaultDialectName() or dialectConfig.name
    if String == "争上游" then
        String = "方言"
    end
    self._txtChatLocal:setString(String)
    -- 更新当前按钮的显示状态
    if chatService:getDialect() == config.ChatConfig.DialectType.NORMAL then
        self._cbxgLanguage:setSelectedIndexWithoutCallback(1)
    elseif chatService:getDialect() == config.ChatConfig.DialectType.ZHENGSHANGYOU then
        -- 如果是争上游，就改为普通话
        self._cbxgLanguage:setSelectedIndexWithoutCallback(1)
    else
        self._cbxgLanguage:setSelectedIndexWithoutCallback(2)
    end
end

-- 不应该在onHide中去销毁UI -- onHide中不能去上报事件，因为整个游戏退出，会调用所有的onHide，那时系统参数已经清空了
-- overwrite
function UISetting_chaoshan:onHide()
    super.onHide(self)
    -- 界面关闭后，取消关注
    game.service.ChatService.getInstance():removeEventListenersByTag(self)
end



return UISetting_chaoshan