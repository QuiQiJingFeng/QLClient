local UISettingCheckBox = class("UISettingCheckBox",function() 
    return ccui.CheckBox:create()
end)

-- local FONT_NAME = "art/mengya/font/language.ttf"
local STYLE_TYPE = {
    ["CIRCLE"] = {
        bg = "img/Checkbox2_0.png",
        sel = "img/Checkbox2_1.png",
        dis = "img/Checkbox2_3.png",
    },
    ["SQUARE"] = {
        bg = "img/Checkbox1_0.png",
        sel = "img/Checkbox1_1.png",
        dis = "img/Checkbox1_3.png",
    },
    ["REVERSE_CIRCLE"] = {
        bg = "img/ck_xx2.png",
        sel = "img/ck_xx3.png",
        dis = "img/ck_xx3.png",
    },
    ["REVERSE_SQUARE"] = {
        bg = "img/ck_xx0.png",
        sel = "img/ck_xx1.png",
        dis = "img/ck_xx1.png",
    }
}

function UISettingCheckBox:ctor(clickCallBack)
    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0,0.1))
    self:onEvent(function(event)
        local cbx = event.target
        if event.name == "selected" then event.name = "select" end
        if event.name == "unselected" then event.name = "unselect" end
        cbx:setSelect(event.name == "select")
        clickCallBack(event.target,event.name)
    end)
end

function UISettingCheckBox:setStyle(style)
    local styleInfo = STYLE_TYPE[style]
    assert(styleInfo,"not exist style")
    self:loadTextureBackGround(styleInfo.bg)
    self:loadTextureBackGroundSelected(styleInfo.bg)
    self:loadTextureBackGroundDisabled(styleInfo.dis)
    self:loadTextureFrontCross(styleInfo.sel)
    self:loadTextureFrontCrossDisabled(styleInfo.dis)
end

function UISettingCheckBox:getContentSize()
    return self._contentSize
end

function UISettingCheckBox:setData(data,style)
    self._data = data
    self:setStyle(style)
    -- 假设checkbox宽搞为50/60
    local boxWith = 50
    local boxHeight = 60

    local textName = ccui.Text:create()
    -- textName:setFontName(FONT_NAME)
    textName:setFontSize(28)
    textName:setAnchorPoint(cc.p(0,-0.1))
    textName:setPosition(cc.p(boxWith,0))
    textName:setColor(cc.c3b(181,131,102))
    textName:setString(data.name)
    self:addChild(textName)

    local size = textName:getVirtualRendererSize()
    local width = size.width + boxWith
    local height = boxHeight

    if data.desc and data.desc ~= "" then
        local textDesc = ccui.Text:create()
        -- textDesc:setFontName(FONT_NAME)
        textDesc:setFontSize(20)
        textDesc:setAnchorPoint(cc.p(0,-0.4))
        textDesc:setPosition(cc.p(width + 10,0))
        textDesc:setColor(cc.c3b(208,121,97))
        textDesc:setString(data.desc)
        self:addChild(textDesc)
        local size = textDesc:getVirtualRendererSize()
        width = width + size.width
    end

    self._contentSize = cc.size(width,height)
end

function UISettingCheckBox:getSetting()
    if self:isEnabled() and self:isSelected() then
        return self._data.id
    end
    return false
end

--忽略判断条件获取设定ID
function UISettingCheckBox:getSettingWithOutCondition()
    return self._data.id
end

function UISettingCheckBox:setMutextGroup(group)
    self._mutextGroup = group
end

function UISettingCheckBox:setSelect(boolean)
    if self._mutextGroup then
        for _, cbx in ipairs(self._mutextGroup) do
            cbx:setSelected(self == cbx)
        end
    elseif self._reverseGroup and boolean then
        local hasNotSelect = false
        for _, cbx in ipairs(self._reverseGroup) do
            if self ~= cbx and not cbx:isSelected() then
                hasNotSelect = true
                break
            end
        end
        if hasNotSelect then
            self:setSelected(boolean)
        else
            self:setSelected(false)
            game.UITipManager.getInstance():show("多选一的选项至少要保留一个!")
        end
    else 
        self:setSelected(boolean)
    end
end

function UISettingCheckBox:setReverseGroup(group)
    self._reverseGroup = group
end


return UISettingCheckBox