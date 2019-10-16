local ConfigManager = app.ConfigManager
local Util = app.Util
local UISettingCheckBox = app.UISettingCheckBox
local UIRoomSetting = class("UIRoomSetting")
local LINE_HEIGHT = 60
local TITLE_START_X = 20
local START_FIX_Y = -50
local LEVEL_POS = {
    [1] = 90,
    [2] = 350,
    [3] = 600
}
-----[title]  [cbx]  [cbx]  [cbx]
-----[title]  [cbx]  [cbx]  [cbx]
-----[title]  [cbx]  [cbx]  [cbx]
function UIRoomSetting:ctor(scrollView)
    self._scrollView = scrollView
    self._contentSize = self._scrollView:getContentSize()
end

function UIRoomSetting:clear()
    self._scrollView:removeAllChildren()
    self._scrollView:setInnerContainerSize(self._contentSize)
    self._currentPos = cc.p(LEVEL_POS[1],START_FIX_Y + self._contentSize.height)
    self._uiMap = {}
    self._titleCache = {}
    self._conditions = {}
end

function UIRoomSetting:getCurrentSettings()
    local settings = table.keys(self._uiMap)
    return settings
end

function UIRoomSetting:parseCondition(config)
    for _, info in ipairs(config) do
        if info.type == "condition" then
            local condition = info.setting
            local iter = string.gmatch(condition,"(%d+)->(%l+){(.-)}")
            for setting,operate,effects in iter do
                setting = tonumber(setting)
                self._conditions[setting] = self._conditions[setting] or {}
                self._conditions[setting][operate] = self._conditions[setting][operate] or {}
                local iter2 = string.gmatch(effects,"(%d+)->(%l+)")
                for setting2,operate2 in iter2 do
                    local data = {setting = tonumber(setting2),operate = operate2}
                    table.insert(self._conditions[setting][operate],data)
                end
            end
        end
    end
end

function UIRoomSetting:nextLine()
    self._currentPos.y = self._currentPos.y - LINE_HEIGHT
    self._currentPos.x = LEVEL_POS[1]
    
end

function UIRoomSetting:createLine(pos)
    local img = ccui.ImageView:create()
    img:setAnchorPoint(cc.p(0,0))
    img:loadTexture("art/main/img_fgf_main.png")
    img:setScaleX(6)
    img:setPosition(pos)
    self._scrollView:addChild(img)
end

function UIRoomSetting:createTitle(title)
    local hashCode = Util:hash(title)
    self._titleCache = self._titleCache or {}
    --如果该行已经有选项放置了,那么另起一行
    if self._currentPos.x > LEVEL_POS[1] then
        self:nextLine()
    end
    --如果是相同的标题,只显示一个就行
    if self._titleCache[hashCode] then
        return
    end
    self._titleCache[hashCode] = true
    local txtTitle = ccui.Text:create()
    txtTitle:setFontSize(28)
    txtTitle:setAnchorPoint(cc.p(0,0))
    txtTitle:setPosition(cc.p(TITLE_START_X,self._currentPos.y))
    txtTitle:setString(title)
    txtTitle:setColor(cc.c3b(181,131,102))
    self._scrollView:addChild(txtTitle)
    self:createLine(cc.p(30,self._currentPos.y + 45))
end

function UIRoomSetting:createOptions(info,style)
    local settings = string.split(info.setting,"|")
    local checkBoxs = {}
    for _, setting in ipairs(settings) do
        setting = tonumber(setting)
        local data = ConfigManager:getInstance():getRoomSettingConfig(setting)
        local cbx = UISettingCheckBox.new(handler(self,self.onCheckBoxClick))
        self._uiMap[setting] = cbx
        cbx:setData(data,style)
        table.insert(checkBoxs,cbx)
        cbx:setPosition(self._currentPos)
        self._scrollView:addChild(cbx)

        if self._forbidMap[setting] then
            cbx:setEnabled(false)
        end
        local size = cbx:getContentSize()
        local hasPlaceX = self._currentPos.x + size.width
        if hasPlaceX > LEVEL_POS[3] then
            self:nextLine() --移动到上面,给滑动区域最下面留一行位置添加提示语
            --超出最大可滑动区域了,扩大滑动区域
            if self._currentPos.y < 0 then
                local innerSize = self._scrollView:getInnerContainerSize()
                local deltHeight = math.abs(self._currentPos.y)
                self._scrollView:setInnerContainerSize(cc.size(self._contentSize.width, innerSize.height + deltHeight))
                local children = self._scrollView:getChildren()
                for i, child in ipairs(children) do
                    child:setPositionY(child:getPositionY() + deltHeight)
                end
                self._currentPos.y = 0
            end
        elseif hasPlaceX > LEVEL_POS[2] and hasPlaceX <= LEVEL_POS[3] then
            self._currentPos.x = LEVEL_POS[3]
        elseif hasPlaceX > LEVEL_POS[1] and hasPlaceX <= LEVEL_POS[2] then
            self._currentPos.x = LEVEL_POS[2]
        else
            assert(false)
        end
    end
    return checkBoxs
end

function UIRoomSetting:getStyleCIRCLE()
    return "CIRCLE"
end

function UIRoomSetting:getStyleSQUARE()
    return "SQUARE"
end

function UIRoomSetting:createCheckBoxGroup(info)
    local checkBoxs = self:createOptions(info,self:getStyleCIRCLE())
    local mutextGroup = checkBoxs
    local firstCanUsed = nil
    for _, cbx in ipairs(mutextGroup) do
        cbx:setMutextGroup(mutextGroup)
        local setting = cbx:getSettingWithOutCondition()
        if cbx:isEnabled() and not firstCanUsed then
            firstCanUsed = cbx
        end
    end
    --默认选中第一个,如果被禁用则依次往后移,但不能所有都禁用,至少要保留一个
    assert(firstCanUsed,"can't forbid all group option")
    firstCanUsed:setSelect(true)
end

--创建最后的提示语 注：房卡在开始游戏后第一局结算扣除，提前解散不扣除房卡
function UIRoomSetting:createLastTip()
    local txtTip = ccui.Text:create()
    txtTip:setFontSize(20)
    txtTip:setAnchorPoint(cc.p(0,0))
    txtTip:setPosition(cc.p(TITLE_START_X,15))
    txtTip:setString("注：房卡在开始游戏后第一局结算扣除，提前解散不扣除房卡")
    txtTip:setColor(cc.c3b(181,131,102))
    self._scrollView:addChild(txtTip)
end

function UIRoomSetting:parseConfig(gamePlayId,forbidMap)
    self._forbidMap = forbidMap or {}
    self:clear()
    local config = ConfigManager:getInstance():getGamePlayRuleById(gamePlayId)
    self:parseCondition(config)

    for _, info in ipairs(config) do
        if info.type == "group" or info.type == "option" then
            self:createTitle(info.name)
        end
        if info.type == "group" then
            self:createCheckBoxGroup(info)
        elseif info.type == "option" then
            self:createOptions(info,self:getStyleSQUARE())
        end
    end
    self:createLastTip()
    self:refreshAllConditions()
end


--筛选条件
function UIRoomSetting:onCheckBoxClick(cbx,operate)
    local setting = cbx:getSettingWithOutCondition()
    --如果该设定存在关联条件
    if self._conditions[setting] then
        local effects = self._conditions[setting][operate]
        if effects then
            self:updateConditions(effects)
        end
    end
end

function UIRoomSetting:updateConditions(effects)
    for _, info in ipairs(effects) do
        local cbx = self._uiMap[info.setting]
        if info.operate == "select" then
            cbx:setSelect(true)
        elseif info.operate == "unselect" then
            cbx:setSelect(false)
        elseif info.operate == "enable" then
            cbx:setEnabled(true)
        elseif info.operate == "unenable" then
            cbx:setEnabled(false)
        end
    end
end

function UIRoomSetting:refreshAllConditions()
    for setting, datas in pairs(self._conditions) do
        for operate, effects in pairs(datas) do
            local cbx = self._uiMap[setting]
            local conditionThrough = false
            if operate == "select" and cbx:isSelected() then
                conditionThrough = true
            elseif operate == "unselect" and not cbx:isSelected() then
                conditionThrough = true                
            elseif operate == "enable" and cbx:isEnabled() then
                conditionThrough = true
            elseif operate == "unenable" and not cbx:isEnabled() then
                conditionThrough = true
            end
            if conditionThrough then
                self:updateConditions(effects)
            end
        end
    end
end

return UIRoomSetting