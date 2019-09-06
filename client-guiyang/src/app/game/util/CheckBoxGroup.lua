--[[	CheckBoxGroup：用来控制多个CheckBox的工具类

	features：
		1、每个CheckBox都能做到按下时滑动取消的功能
		2、Group中只存在一个选中的情况
		3、new时，默认选中的为table中的第一个，可以通过setSelectedIndex来改变选中项(也会触发回调)

	todo：
		1、保证Group size 为 1 的情况的适用性， 推荐重载方法
		2、关于size的操作
		... 
	
	examples：
		1:
			local group = CheckBoxGroup.new({self._cbx1, self._cbx2}, function(group, index, token)
				print(group[index]:getName()) -- equals self._cbx1:getName()
				print(token) -- equals first
			end, "first")
			group:dispose()
		2:
			local fn = function(group, index , token)
				print(group[index]:getName())
				print("token = " .. token)
			end
			local group1 = CheckBoxGroup.new({self._cbx1, self._cbx2}, fn, "group1")
			local group2 = CheckBoxGroup.new({self._cbx3, self._cbx4}, fn, "group2")
			group1:dispose()
			group2:dispose()
			-- 这两个group使用了同一个监听函数，可以通过token来区别他们

		其他方法：
			group:setSelectedIndex(index)
			group:getSelectedIndex() -- return selected item index
	
	CHANGEDLOG:
        2017-11-20 避免在初始化控件的时候调用了回调，删除了new时去触发回调的逻辑
        2018-07-23 补日志：
            1、区分了 innercallback 与 outercallback
            2、添加了更改组勾选状态但是不触发回调的接口
            3、添加如下接口:
                setOuterCallbackEnable
                isOuterCallbackEnable
                setSelectedIndexWithoutCallback
            4、计划：计划重新做一个 Toggle 与 ToggleGroup，用来兼容单按钮的情况（抄Unity的API）
        2018-08-11 ：
            remove _isSelectedItemsCanTouch
            add _isSelectedCanSelectAgain

]]
local CheckBoxGroup = class("CheckBoxGroup")
function CheckBoxGroup:ctor(group, callback, token)
    self._token = token
    self._outercallback = callback
    self._group = group
    self._currentSelectedIndex = 1
    self._isOuterCallbackEnabled = true -- 外部回调是否可用
    self._isSelectedCanSelectAgain = true -- 被选中的项是否可以再次被点击

    for i, v in ipairs(group) do
        -- 默认将第一个配的改为打开时默认选择的
        v:setSelected(false)
        self:_registerTouchEvent(v, i)
    end
    if group[1] then
        group[1]:setSelected(true)
    end
end

function CheckBoxGroup:setSelectedIndex(index)
    Macro.assertTrue(index < 0 or index > #self._group, "index out of bounds")
    self:_callinnercallback(self._group[index], index, self._token)
end

function CheckBoxGroup:setOuterCallbackEnable(value)
    self._isOuterCallbackEnabled = value or false
end

function CheckBoxGroup:isOuterCallbackEnable()
    return self._isOuterCallbackEnabled
end

function CheckBoxGroup:setSelectedIndexWithoutCallback(index)
    self:setOuterCallbackEnable(false)
    self:setSelectedIndex(index)
    self:setOuterCallbackEnable(true)
end

function CheckBoxGroup:getSelectedIndex()
    Macro.assertTrue(self._currentSelectedIndex < 0 or self._currentSelectedIndex > #self._group)
    return self._currentSelectedIndex
end

function CheckBoxGroup:dispose()
    self._token = nil
    self._outercallback = nil
    self._group = nil
end

function CheckBoxGroup:_changeCheckBoxSelectedStatus(index)
    for i, v in ipairs(self._group) do
        v:setSelected(i == index)
    end
end

function CheckBoxGroup:_callinnercallback(selectedCheckBox, index, token)
    self:_changeCheckBoxSelectedStatus(index)
    self._currentSelectedIndex = index
    self:_calloutercallback()
end

function CheckBoxGroup:_calloutercallback()
    if self._outercallback ~= nil and self._isOuterCallbackEnabled then
        self._outercallback(self._group, self._currentSelectedIndex, self._token)
    end
end

function CheckBoxGroup:setSelectedCanSelectAgain(value)
    self._isSelectedCanSelectAgain = value or false
end

function CheckBoxGroup:getSelectedCanSelectAgain()
    return self._isSelectedCanSelectAgain
end

function CheckBoxGroup:_registerTouchEvent(cbox, index)
    local isSelected = false
    cbox:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = cbox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if self._currentSelectedIndex ~= index or self:getSelectedCanSelectAgain() then
                self:_callinnercallback(cbox, index)
            else
                cbox:setSelected(isSelected)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            cbox:setSelected(isSelected)
        end
    end)
end

function CheckBoxGroup:forEach(fn)
    for idx, item in ipairs(self._group) do
        fn(idx, item)
    end
end

function CheckBoxGroup:getGroups()
    return self._group
end

function CheckBoxGroup:getSelectedItemIndexes()
    local indexes = {}
    self:forEach(function(index, item)
        if item:isSelected() then
            table.insert(indexes, index)
        end
    end)
    return indexes
end

function CheckBoxGroup:getUnSelectedItemIndexes()
    local indexes = {}
    self:forEach(function(index, item)
        if not item:isSelected() then
            table.insert(indexes, index)
        end
    end)
    return indexes
end

function CheckBoxGroup:append(btn)
    if btn then
        btn:setSelected(false)
        table.insert(self._group, btn)
        self:_registerTouchEvent(btn, #self._group)
    end
end

return CheckBoxGroup