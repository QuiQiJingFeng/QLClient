local Util = app.Util
local UISteeringWheel = class("UISteeringWheel")

function UISteeringWheel:init()
    local spBottomLight = Util:seekNodeByName(self,"spBottomLight","cc.Sprite")
    local spTopLight = Util:seekNodeByName(self,"spTopLight","cc.Sprite")
    local spLeftLight = Util:seekNodeByName(self,"spLeftLight","cc.Sprite")
    local spRightLight = Util:seekNodeByName(self,"spRightLight","cc.Sprite")
    self._mutextGroupLight = {}
    self._mutextGroupLight["BOTTOM"] = spBottomLight
    self._mutextGroupLight["TOP"] = spTopLight
    self._mutextGroupLight["LEFT"] = spLeftLight
    self._mutextGroupLight["RIGHT"] = spRightLight


    self._txtBmfCounter = Util:seekNodeByName(self,"txtBmfCounter","ccui.TextBMFont")
end

function UISteeringWheel:setCurrentDirect(direct)
    for k, spLight in pairs(self._mutextGroupLight) do
        spLight:setVisible(k == direct)
    end
    self:startSchadue(10)
end

function UISteeringWheel:startSchadue(value)
    self._totalCount = value
    self._txtBmfCounter:setString(self._totalCount)
    self:stopSchadue()
    self._scheduleId = Util:scheduleUpdate(function()
        self._totalCount = self._totalCount - 1
        self._txtBmfCounter:setString(self._totalCount)
        if self._totalCount <= 0 then
            self:stopSchadue()
            --SHAKE 特效
        end
    end, 1)
end

function UISteeringWheel:stopSchadue()
    self._scheduleId = Util:unscheduleUpdate(self._scheduleId)
end

function UISteeringWheel:dispose()
    self:stopSchadue()
end

return UISteeringWheel