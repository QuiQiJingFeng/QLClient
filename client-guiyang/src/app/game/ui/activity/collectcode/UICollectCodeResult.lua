--[[0
    包含两个界面
    1： 中了至少一个码的界面
    2： 一个码都没有中的界面
]]
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeResult.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local Machine = require("app.game.ui.activity.collectcode.Machine")
local seekButton = UtilsFunctions.seekButton
local UICollectCodeResult = super.buildUIClass("UICollectCodeResult", csbPath)
function UICollectCodeResult:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
    super.playAnimation(self, csbPath, nil, true)

    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnHelp = seekButton(self, "Button_Help", handler(self, self._onBtnHelpClick))

    self._textEndTime = seekNodeByName(self, "Text_End_Time", "ccui.Text")
    self._textCurrentPeriod = seekNodeByName(self, "Text_Current_Period", "ccui.Text")
    self._textCurrentPeriod:setString("第" .. self._service:getCollectCodeInfo().period + 1 .. "期")

    self._particleSystem_Money = seekNodeByName(self, "Particle_Money", "cc.ParticleSystemQuad")
    self._particleSystem_Money:hide()

    -- 中了至少一个码
    self._layoutResultHasCode = seekNodeByName(self, "Layout_Result_HasCode", "ccui.Layout")
    -- 一个也没中
    self._layoutResultNoCode = seekNodeByName(self, "Layout_Result_NoCode", "ccui.Layout")

    local layout1 = self._layoutResultHasCode
    seekButton(layout1, "Button_Share", handler(self, self._onBtnShareClick))
    seekButton(layout1, "Button_Detail", handler(self, self._onBtnDetailClick))
    seekButton(layout1, "Button_Recv_Red_Pack", handler(self, self._onBtnRecvRedpackClick))
    layout1.txtDesc = seekNodeByName(layout1, "Text_Desc", "ccui.Text")
    layout1.txtStatus = seekNodeByName(layout1, "Text_Status", "ccui.Text")

    local layout2 = self._layoutResultNoCode
    -- seekButton(layout2, "Button_New_Round", handler(self, self._onBtnNewRoundClick))
    seekButton(layout2, "Button_Detail", handler(self, self._onBtnDetailClick))
    seekButton(layout2, "Button_My_Code", handler(self, self._onBtnMyCodeClick))
    layout2.txtDesc = seekNodeByName(layout2, "Text_Desc", "ccui.Text")
    layout2.txtStatus = seekNodeByName(layout2, "Text_Status", "ccui.Text")

    -- 加入抽奖机
    self._machine = Machine.new()
    seekNodeByName(self, "Node_Machine_Position", "cc.Node"):addChild(self._machine)
    self._machine:setPosition(cc.p(0, 0))
    self._machine:resetCodePosition()

    -- 如果结束时间到了，就重新请求活动信息
    local endTime = self._service:getCollectCodeInfo().endTime
    local now = game.service.TimeService.getInstance():getCurrentTimeInMSeconds()
    local diff = (endTime - now) * 0.001
    if diff > 0 then
        scheduleOnce(function()
            if self and self:isVisible() and self._service then
                self._service:openActivityMainPage()
            end
        end, diff, self)
    end
end

function UICollectCodeResult:onShow()
    self._service:destroyAllActivityUIWithout(self.class.__cname)

    self._textEndTime:setString("下期开始时间：" .. kod.util.Time.dateWithFormat(nil, self._service:getCollectCodeInfo().endTime * 0.001))
    self._machine:resetToResultPosition()
    self._machine:setCharPool(self._service:convertToCodeArray(self._service:getCollectCodeInfo().codes))
    self._machine:startScroll(handler(self, self._onMachineStop))
    self._machine:setResultCode(self._service:convertToCodeArray(self._service:getCollectCodeInfo().luckyCode))

    self._layoutResultHasCode:hide()
    self._layoutResultNoCode:hide()
end

function UICollectCodeResult:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeResult:_onBtnHelpClick(sender)
    UIManager:getInstance():show("UICollectCodeHelp")
end

function UICollectCodeResult:_onBtnShareClick(sender)
    self._service:collectCodeShare()
end

function UICollectCodeResult:_onBtnDetailClick(sender)
    self._service:sendCACCollectCodeLuckyRecordREQ()
end

function UICollectCodeResult:_onBtnRecvRedpackClick(sender)
    self._service:sendCACCollectCodeQueryCodeREQ()
end

function UICollectCodeResult:_onBtnMyCodeClick(sender)
    self._service:sendCACCollectCodeQueryCodeREQ()
end

function UICollectCodeResult:playMoneyEffectAndAutoStop()
    self._particleSystem_Money:show()
    self._particleSystem_Money:resetSystem()
    scheduleOnce(function()
        self._particleSystem_Money:stopSystem()
        scheduleOnce(function()
            self._particleSystem_Money:hide()
        end, 1, self)
    end, 2, self)
end

function UICollectCodeResult:_onMachineStop()
    if not self:isVisible() then
        return
    end

    local myCodeInfo = self._service:getMyCodeInfo()
    local totalRedpackCount = 0
    local codeCount = #myCodeInfo.codes
    local itemId
    for _, item in ipairs(myCodeInfo.codes) do
        totalRedpackCount = tonumber(item.count) + totalRedpackCount
        itemId = item.itemId
    end

    self._layoutResultHasCode:setVisible(totalRedpackCount > 0)
    self._layoutResultNoCode:setVisible(totalRedpackCount == 0)
    for _, layout in ipairs({ self._layoutResultHasCode, self._layoutResultNoCode }) do
        local descStr = ""
        if totalRedpackCount > 0 then
            if itemId == 0x0F000004 then
                descStr = "¥:" .. totalRedpackCount .. "元"
            else
                descStr = PropReader.generatePropTxt({ { itemId = itemId, count = totalRedpackCount } })
            end
        else
            descStr = "本期收集的幸运码未中奖"
            if myCodeInfo.unluckyItemId and myCodeInfo.unluckyItemId ~= 0 then
                descStr = descStr .. "\n获得：" .. PropReader.generatePropTxt({ {
                    id = myCodeInfo.unluckyItemId,
                    count = myCodeInfo.unluckyItemCount,
                    time = myCodeInfo.unluckyItemTime
                } }, 'x', ' ') .. "\n新年好运不缺席"
            end
        end
        layout.txtDesc:setString(descStr)
        layout.txtStatus:setString("已获得" .. codeCount .. "组幸运码 状态：已开奖")

        local actionNode = layout.txtDesc
        local normalScale = actionNode:getScaleX()
        actionNode:setScale(0.1)
        local action = cc.Sequence:create(
        cc.ScaleTo:create(0.3, normalScale),
        cc.CallFunc:create(function()
            print("scale", actionNode:getScaleX())
        end)
        )
        actionNode:runAction(action)
    end

    if totalRedpackCount > 0 then
        self:playMoneyEffectAndAutoStop()
    end
    manager.AudioManager.getInstance():playEffect("sound/SFX/Activity/CollectCode/opencode.mp3")
end

function UICollectCodeResult:needBlackMask() return true end


return UICollectCodeResult