local ConfigManager = app.ConfigManager
local UICheckBoxGroup = app.UICheckBoxGroup
local Util = app.Util
local UICreateRoomContent = class("UICreateRoomContent")
local START_FIX_Y = -50
local LINE_HEIGHT = 60
local BOX_WIDTH = 50
local LEVEL_POS = {
    [1] = 90,
    [2] = 350,
    [3] = 600
}
function UICreateRoomContent:ctor(scrollView)
    self._scrollView = scrollView
    scrollView:setLocalZOrder(10)
    self._contentSize = self._scrollView:getContentSize()
end

function UICreateRoomContent:clear()
    self._scrollView:removeAllChildren()
    self._scrollView:setInnerContainerSize(self._contentSize)
    self._currentPos = cc.p(LEVEL_POS[1],START_FIX_Y + self._contentSize.height)
    self._uiUsed = {}
    self._titleCache = {}
    self._conditions = {}
end

function UICreateRoomContent:createCheckBox(data,style2)
    local checkBox = ccui.CheckBox:create()
    checkBox:setTouchEnabled(true)
    local bg = "img/Checkbox2_0.png"
    local sel = "img/Checkbox2_1.png"
    local dis = "img/Checkbox2_3.png"
    if style2 then
        bg = "img/Checkbox1_0.png"
        sel = "img/Checkbox1_1.png"
        dis = "img/Checkbox1_3.png"
    end
    checkBox:loadTextureBackGround(bg)
    checkBox:loadTextureBackGroundSelected(bg)
    checkBox:loadTextureBackGroundDisabled(dis)
    checkBox:loadTextureFrontCross(sel)
    checkBox:loadTextureFrontCrossDisabled(dis)
    checkBox:setAnchorPoint(cc.p(0,0.1))
    self._scrollView:addChild(checkBox)
    
    local boxWith = BOX_WIDTH
    local boxHeight = LINE_HEIGHT
    local textName = ccui.Text:create()
    -- textName:setFontName("art/mengya/font/language.ttf")
    textName:setFontSize(28)
    textName:setAnchorPoint(cc.p(0,-0.1))
    textName:setPosition(cc.p(boxWith,0))
    textName:setColor(cc.c3b(181,131,102))
    textName:setString(data.name)
    checkBox:addChild(textName)

    local size = textName:getVirtualRendererSize()
    local width = size.width + boxWith
    local height = boxHeight

    if data.desc and data.desc ~= "" then
        local textDesc = ccui.Text:create()
        -- textDesc:setFontName("art/mengya/font/language.ttf")
        textDesc:setFontSize(20)
        textDesc:setAnchorPoint(cc.p(0,-0.4))
        textDesc:setPosition(cc.p(width + 10,0))
        textDesc:setColor(cc.c3b(208,121,97))
        textDesc:setString(data.desc)
        checkBox:addChild(textDesc)
        local size = textDesc:getVirtualRendererSize()
        width = width + size.width
    end

    
    return checkBox,cc.size(width,height)
end

function UICreateRoomContent:createCheckBoxGroup(info)
    local checkBoxs = self:createOptions(info)
    local cbxGroup = UICheckBoxGroup.new(checkBoxs,handler(self,self.onCheckBoxClick))
    cbxGroup:setSelectIdx(1)
    cbxGroup:setMark(info.id)
    table.insert(self._uiUsed,cbxGroup)
end

function UICreateRoomContent:createOptions(info,style2)
    local settings = string.split(info.setting,"|")
    local checkBoxs = {}
    for _, setting in ipairs(settings) do
        local data = ConfigManager:getInstance():getRoomSettingConfig(tonumber(setting))

        local cbx,size = self:createCheckBox(data,style2)
        cbx:setTag(setting)
        table.insert(checkBoxs,cbx)
        cbx:setPosition(cc.p(self._currentPos.x,self._currentPos.y))
 
        local hasPlaceX = self._currentPos.x + size.width
        if hasPlaceX > LEVEL_POS[3] then
            if self._currentPos.y < 0 then
                local innerSize = self._scrollView:getInnerContainerSize()
                self._scrollView:setInnerContainerSize(cc.size(self._contentSize.width, innerSize.height + math.abs(self._currentPos.y)))
                local children = self._scrollView:getChildren()
                for i, child in ipairs(children) do
                    child:setPositionY(child:getPositionY() + math.abs(self._currentPos.y))
                end
                self._currentPos.y = 0
            end
            self._currentPos.y = self._currentPos.y - size.height
            
            self._currentPos.x = LEVEL_POS[1]
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

function UICreateRoomContent:updateConditions(effects)
    for _, info in ipairs(effects) do
        local child = self._scrollView:getChildByTag(info.setting)
        if info.operate == "select" then
            child:setSelected(true)
        elseif info.operate == "unselect" then
            child:setSelected(false)
        elseif info.operate == "enable" then
            child:setEnabled(true)
        elseif info.operate == "unenable" then
            child:setEnabled(false)
        end
    end
end

function UICreateRoomContent:checkConditions()
    for setting, datas in pairs(self._conditions) do
        for operate, effects in pairs(datas) do
            local child = self._scrollView:getChildByTag(setting)
            local conditionThrough = false
            if operate == "select" and child:isSelected() then
                conditionThrough = true
            elseif operate == "unselect" and not child:isSelected() then
                conditionThrough = true                
            elseif operate == "enable" and child:isEnabled() then
                conditionThrough = true
            elseif operate == "unenable" and not child:isEnabled() then
                conditionThrough = true
            end
            if conditionThrough then
                self:updateConditions(effects)
            end
        end
    end
end

function UICreateRoomContent:onCheckBoxClick(cbx)
    local setting = tonumber(cbx:getTag())
    if self._conditions[setting] then
        local operate = cbx:isSelected() and "select" or "unselect"
        local effects = self._conditions[setting][operate]
        if effects then
            self:updateConditions(effects)
        end
    end
end

function UICreateRoomContent:createTitle(title)
    local hashCode = Util:hash(title)
    self._titleCache = self._titleCache or {}
    if self._titleCache[hashCode] then
        local x,y = 20,self._currentPos.y
        if self._currentPos.x > LEVEL_POS[1] then
            y = self._currentPos.y - LINE_HEIGHT
            self._currentPos.y = y
            self._currentPos.x = LEVEL_POS[1]
        end
        return
    end
    self._titleCache[hashCode] = true
    local x,y = 20,self._currentPos.y
    if self._currentPos.x > LEVEL_POS[1] then
        y = self._currentPos.y - LINE_HEIGHT
        self._currentPos.y = y
        self._currentPos.x = LEVEL_POS[1]
    end
    local txtTitle = ccui.Text:create()
    -- txtTitle:setFontName("art/mengya/font/language.ttf")
    txtTitle:setFontSize(28)
    txtTitle:setAnchorPoint(cc.p(0,0))
    txtTitle:setPosition(cc.p(x,y))
    txtTitle:setString(title)
    txtTitle:setColor(cc.c3b(181,131,102))
    self._scrollView:addChild(txtTitle)
end

function UICreateRoomContent:refresh(data)
    self:clear()
    
    for _, info in ipairs(data) do
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

    for _, info in ipairs(data) do
        if info.type == "group" then
            self:createTitle(info.name)
            self:createCheckBoxGroup(info)
        elseif info.type == "option" then
            self:createTitle(info.name)
            local cbxs = self:createOptions(info,true)
            for i, cbx in ipairs(cbxs) do
                table.insert(self._uiUsed, cbx)
                cbx:setTouchEnabled(true)
                cbx:addEventListener(function(cbx,eventType)
                    self:onCheckBoxClick(cbx)
                end)
            end
        end
    end

    self:checkConditions()
end

return UICreateRoomContent