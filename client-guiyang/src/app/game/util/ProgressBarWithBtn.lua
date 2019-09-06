--[[
    progressbar 用来调节数量的，有加减按钮以及显示当前选择的数量
    实例化之后必须setrange
]]

local ProgressBarWithBtn = class("ProgressBarWithBtn")

function ProgressBarWithBtn:ctor(scrollBar,numText,btnAdd,btnMinus)
    self._scrollBar = scrollBar
    self._numText = numText
    self._btnAdd = btnAdd
    self._btnMinus = btnMinus
end

-- 设置进度条range,grit:每个粒度
function ProgressBarWithBtn:setRange(begin,ends,grit)
    self._beginNum = begin
    self._endsNum = ends
    
    self._scrollBar:addEventListener(handler(self,self._onProgressChanged))
end

-- 返回当前设置的值
function ProgressBarWithBtn:getValue()
    
end

function ProgressBarWithBtn:_onProgressChanged(sender, eventType)
    if eventType == ccui.SliderEventType.percentChanged  then

    end
end

return ProgressBarWithBtn