local csbPath = "ui/csb/UIReportLED.csb"
local super = require("app.game.ui.UIBase")

local UIReportLED = class("UIReportLED", super, function () return kod.LoadCSBNode(csbPath) end)

--[[
    封号跑马灯
]]

function UIReportLED:ctor()
	self._animAction = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._animAction)
end

function UIReportLED:init()
    self._panelLED = seekNodeByName(self, "Panel_led", "ccui.Layout")
    self._textLED = seekNodeByName(self, "Text_led", "ccui.Text")

    self._x = self._panelLED:getContentSize().width + 300
end

local _getLEDText = function()
    local i = 0
    return function()
        i = i + 1
       local  id = 
       {
           309262389,301600478,302452888,20725213,70634682,218274316,311790305,
           93190358,313066467,302654832,302166654,302265234,219224766,228674548,
           300526482,301756248,301135245,254142702
       }

       if i > 18 then i = 1 end 
       return string.format("ID:%d 永久封号", id[i])
    end
end

function UIReportLED:onShow()
    self._animAction:play("animation0", false)
    self._getLEDText = _getLEDText()
    self:_initLED()
end

function UIReportLED:_initLED()
    local act1 = cc.CallFunc:create(function()
        self._textLED:setString(self._getLEDText())
        self._textLED:setPositionX(self._x)
    end)

	local act2 = cc.MoveBy:create(8.0, cc.p(-self._x * 1.4 , 0))

	local act3 = cc.Sequence:create(act1, act2)
	self._textLED:runAction(cc.RepeatForever:create(act3))

    for i = 1 , 3 do
        local textLED2 = self._textLED:clone()
        textLED2:setString("")
        self._panelLED:addChild(textLED2)

        textLED2:runAction(cc.Sequence:create(
            cc.DelayTime:create(i * 2), cc.CallFunc:create(
                function()
                    local act4 = cc.CallFunc:create(function()
                        textLED2:setString(self._getLEDText())
                        textLED2:setPositionX(self._x)
                    end)
                    local act5 = cc.MoveBy:create(8.0, cc.p(-self._x * 1.4, 0))
                    local act6 = cc.Sequence:create(act4, act5)
                    textLED2:runAction(cc.RepeatForever:create(act6))
                end)
            )
        )
    end
end

function UIReportLED:onHide()
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIReportLED:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIReportLED