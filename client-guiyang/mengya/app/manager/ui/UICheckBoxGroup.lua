local Util = app.Util
local UICheckBoxGroup = class("UICheckBoxGroup")

function UICheckBoxGroup:ctor(mutextGroup,callBack)
    self._mutextGroup = mutextGroup
    self._callBack = callBack
    self:registerEvent()
end

function UICheckBoxGroup:setMark(mark)
    self._mark = mark
end

function UICheckBoxGroup:getMark()
    return self._mark
end

function UICheckBoxGroup:onItemSelected(idx,cbx, eventType)
    if not cbx:isTouchEnabled() then
        return
    end
    if eventType ~= ccui.TouchEventType.began then
        return
    end
    
    for _, cbxOther in ipairs(self._mutextGroup) do
        if cbxOther ~= cbx then
            cbxOther:setSelected(false)
            cbxOther:setTouchEnabled(true)
        else
            cbxOther:setSelected(true)
            cbxOther:setTouchEnabled(false)
        end
    end
    if self._callBack then
        --如果选中了,那么就不能再点击改复选框了
        self._callBack(cbx,idx)
    end
    self._currentIndex = idx
end

function UICheckBoxGroup:setSelectIdx(idx)
    local cbx = self._mutextGroup[idx]
    self:onItemSelected(idx,cbx,ccui.TouchEventType.began)
end

function UICheckBoxGroup:getSelectIdx()
    return self._currentIndex or -1
end

function UICheckBoxGroup:registerEvent()
    for idx, cbx in ipairs(self._mutextGroup) do
        cbx:setTouchEnabled(true)
        cbx:addEventListener(handlerFix(self,self.onItemSelected,idx))
    end
end

return UICheckBoxGroup