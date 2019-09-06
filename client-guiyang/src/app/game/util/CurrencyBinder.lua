--[[0
    create date: 
        2018/07/23 
    features: 
        1、货币控件 数据绑定
        2、在提审情况下的控件的表现情况（参见 _onBindPost）
        3、可以根据地区不同，去屏蔽一些货币（暂未实现）
    example:
        -- 单例，并且存放到了 Helper 中， 也可以直接通过 CurrencyBinder.getInstance() 获取
        local binder = CurrencyHelper.getInstance():getBinder()
        -- layout 包含了以下控件 : {
            "Button_Add", -- 加号按钮
            "Text", -- 显示货币的文本
            "Icon" -- 货币的icon
        }
        local layout = seekNodeByName(self, "Card_Layout", "ccui.Layout")

        -- 绑定之后，text 与 button 会自动变化和自动加入事件监听
        local bindKey = binder:bind(CurrencyHelper.CURRENCY_TYPE.CARD, layout)
        -- 必须进行解绑，否则会当接收事件后，会报 cobj 非法
        binder:unbind(bindKey)

        -- 除了直接绑定一个Layout，也可以直接绑定一个Button 或者 Text
        local btn = self._btnAddCard
        local text = self._textCardCount

        -- 按钮比较特殊，可以不用解绑
        local btnKey = binder:bindAddButton(CurrencyHelper.CURRENCY_TYPE.CARD, btn)
        
        local textKey = binder:bindAmountText(CurrencyHelper.CURRENCY_TYPE.CARD, text)
        -- 通过何种方式绑定的，就要通过何种方式解绑
        binder:unbindAmountText(textKey)
    todos:
        1、通过 unbind 直接解绑任何的绑定
    changelogs:
]]
local CurrencyHelper = nil
---@class CurrencyBinder
local CurrencyBinder = class("CurrencyBinder")

local instance = nil
---@return CurrencyBinder
function CurrencyBinder.getInstance()
    -- 避免两个文件疯狂require
    if instance == nil then
        CurrencyHelper = require("app.game.util.CurrencyHelper")
        CurrencyBinder.CURRENCY_TYPE = CurrencyHelper.CURRENCY_TYPE
        instance = CurrencyBinder.new()
    end
    return instance
end

function CurrencyBinder:ctor()
    local service = game.service.LocalPlayerService.getInstance()
    local _handler = handler(self, self._onAmountChanged)
    service:addEventListener("EVENT_ROOM_CARD_COUNT_CHANGED", _handler, self)
    service:addEventListener("EVENT_GOLD_COUNT_CHANGED", _handler, self)
    service:addEventListener("EVENT_BEAN_COUNT_CHANGED", _handler, self)
    service:addEventListener("EVENT_COMPVOUCHER_COUNT_CHANGED", _handler, self)
    service:addEventListener("EVENT_GIFT_TICKET_COUNT_CHANGED", _handler, self)

    self._widgetMaps = self:_initWidgetMaps(CurrencyHelper.CURRENCY_TYPE)
    self._triggerActionFuncs = self:_initTriggerActionFuncMap(CurrencyHelper.CURRENCY_TYPE)
end

-- 避免多余的方法被创建
function CurrencyBinder:_initTriggerActionFuncMap(types)
    local actionMap = {}
    for key, value in pairs(types) do
        actionMap[key] = function()
            CurrencyHelper.getInstance():queryCurrency(key)
        end
    end
    return actionMap
end

function CurrencyBinder:_initWidgetMaps(types)
    local ret = {}
    for key, value in pairs(types) do
        ret[key] = {
            layouts = {},
            texts = {},
            buttons = {}
        }
    end
    return ret
end

function CurrencyBinder:bind(currencyType, layout)
    if not Macro.assertFalse(layout, 'bind failed! layout is a nil value') then
        return
    end

    if Macro.assertFalse(CurrencyHelper.getInstance():checkType(currencyType), 'illegal type: ' .. tostring(currencyType)) then
        local bindKeyMap = {
            btnKey = nil,
            textKey = nil,
            layoutKey = self:bindLayout(currencyType, layout)
        }

        local btnAdd = seekNodeByName(layout, "Button_Add", "ccui.Button")
        if btnAdd then
            bindKeyMap.btnKey = self:bindAddButton(currencyType, btnAdd)
        else
            Logger.debug("bind currency not find Button_Add, do you miss it? currency type is " .. currencyType)
        end

        local text = ccui.Helper:seekNodeByName(layout, "Text")
        if text then
            bindKeyMap.textKey = self:bindAmountText(currencyType, text)
        else
            Logger.debug("bind currency not find Text, do you miss it? currency type is " .. currencyType)
        end

        return bindKeyMap
    end
end

function CurrencyBinder:bindAddButton(currencyType, button)
    if Macro.assertFalse(CurrencyHelper.getInstance():checkType(currencyType), 'illegal type: ' .. tostring(currencyType)) then
        if Macro.assertFalse(button, 'bind failed! button is a nil value') then
            table.insert(self._widgetMaps[currencyType].buttons, button)
            button:setTouchEnabled(true)
            bindEventCallBack(button, self._triggerActionFuncs[currencyType], ccui.TouchEventType.ended)
            Logger.debug("bindAddButton type = " .. currencyType)
            return { type = currencyType, index = #self._widgetMaps[currencyType].buttons }
        end
    end
end

function CurrencyBinder:bindAmountText(currencyType, text)
    if Macro.assertFalse(CurrencyHelper.getInstance():checkType(currencyType), 'illegal type: ' .. tostring(currencyType)) then
        if Macro.assertFalse(text, 'bind failed! text is a nil value') then
            table.insert(self._widgetMaps[currencyType].texts, text)
            Logger.debug("bindAmountText type = " .. currencyType)
            self:_setAmountTextDefaultValue(currencyType, text)
            return { type = currencyType, index = #self._widgetMaps[currencyType].texts }
        end
    end
end

function CurrencyBinder:bindLayout(currencyType, layout)
    if Macro.assertFalse(CurrencyHelper.getInstance():checkType(currencyType), 'illegal type: ' .. tostring(currencyType)) then
        if Macro.assertFalse(layout, 'bind failed! layout is a nil value') then
            table.insert(self._widgetMaps[currencyType].layouts, layout)
            Logger.debug("bindLayout type = " .. currencyType)
            layout:setTouchEnabled(true)
            bindEventCallBack(layout, self._triggerActionFuncs[currencyType], ccui.TouchEventType.ended)
            self:_onBindPost(currencyType, layout)
            return { type = currencyType, index = #self._widgetMaps[currencyType].layouts }
        end
    end
end

function CurrencyBinder:_setAmountTextDefaultValue(currencyType, text)
    local count = CurrencyHelper.getInstance():getCurrencyCount(currencyType)
    local decimalCount = 2
    if count >= 1000000 and count < 10000000 then 
        -- 百万之间，保留小数位数为1
        decimalCount = 1
    elseif count >= 10000000 and count < 100000000 then 
        -- 千万之间，不保留小数位数
        decimalCount = 0
    end 
    text:setString(kod.util.String.formatMoney(count, decimalCount))
end

function CurrencyBinder:unbind(bindKeyMap)
    if Macro.assertFalse(bindKeyMap, "bind key map is a nil value") then
        self:unbindLayout(bindKeyMap.layoutKey)
        self:unbindAddButton(bindKeyMap.btnAddKey)
        self:unbindAmountText(bindKeyMap.textKey)
    end
end

function CurrencyBinder:unbindLayout(key)
    if key then
        self._widgetMaps[key.type].layouts[key.index] = nil
    end
end

function CurrencyBinder:unbindAddButton(key)
    if key then
        self._widgetMaps[key.type].buttons[key.index] = nil
    end
end

function CurrencyBinder:unbindAmountText(key)
    if key then
        self._widgetMaps[key.type].texts[key.index] = nil
    end
end

function CurrencyBinder:_onAmountChanged(event)

    local type = nil
    if "EVENT_ROOM_CARD_COUNT_CHANGED" == event.name then
        type = CurrencyHelper.CURRENCY_TYPE.CARD
    elseif "EVENT_GOLD_COUNT_CHANGED" == event.name then
        type = CurrencyHelper.CURRENCY_TYPE.GOLD
    elseif "EVENT_BEAN_COUNT_CHANGED" == event.name then
        type = CurrencyHelper.CURRENCY_TYPE.BEAN
    elseif "EVENT_COMPVOUCHER_COUNT_CHANGED" == event.name then
        type = CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET
    elseif "EVENT_GIFT_TICKET_COUNT_CHANGED" == event.name then
        type = CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET
    end

    if type then
        for _, text in pairs(self._widgetMaps[type].texts) do
            if text.setString then
                local decimalCount = 2
                local count = event.value
                if count >= 1000000 and count < 10000000 then 
                    -- 百万之间，保留小数位数为1
                    decimalCount = 1
                elseif count >= 10000000 and count < 100000000 then 
                    -- 千万之间，不保留小数位数
                    decimalCount = 0
                end 
                text:setString(kod.util.String.formatMoney(count, decimalCount))
            end
        end
    end
end


function CurrencyBinder:_onBindPost(currencyType, widget)
    -- 处理提审逻辑
    if GameMain.getInstance():isReviewVersion() then
        if currencyType == CurrencyBinder.CURRENCY_TYPE.GOLD then
            widget:setVisible(false)
        end

        if device.platform == 'android' then
            if currencyType == CurrencyBinder.CURRENCY_TYPE.CARD then
                widget:setVisible(false)
            end
        end
    end
end

return CurrencyBinder