local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeMessageBox.csb'
local UICollectCodeMessageBox = super.buildUIClass("UICollectCodeMessageBox", csbPath)

function UICollectCodeMessageBox:init()
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnCopy = seekButton(self, "Button_Copy", handler(self, self._onBtnCopyClick))

    local cbox = seekNodeByName(self, "CheckBox", "ccui.CheckBox")
    bindCheckEventCallBack(cbox, handler(self, self._onCheckBoxClicked), ccui.TouchEventType.ended)
    cbox:setSelected(false)

    self._textContent = seekNodeByName(self, "Text_Content", "ccui.Text")
    self._wechatId = MultiArea.getConfigByKey("activityRedpackWechat")

    local text = '红包已领取，关注微信公众号提现，详情咨询客服'
    if self._wechatId then
        text = "红包已领取，关注微信公众号“" .. self._wechatId .. "”提现"
    end
    self._textContent:setString(text)
end

function UICollectCodeMessageBox:onShow()
end

function UICollectCodeMessageBox:_onCheckBoxClicked(cbox)
    local v = cbox:isSelected()

    local key = "TipMessage_UICollectCodeMessageBox"
    local service = game.service.ActivityService.getInstance()
    local data = service.activeCache
    if data and data[key] ~= v then
        data[key] = v
        service:saveData()
    end
end

function UICollectCodeMessageBox:_onBtnCloseClick(sender)
    self:hideSelf()
end

function UICollectCodeMessageBox:_onBtnCopyClick(sender)
    if self._wechatId then
        if game.plugin.Runtime.setClipboard(self._wechatId) then
            game.service.WeChatService:getInstance():openWXApp()
            self:hideSelf()
        end
    end
end

function UICollectCodeMessageBox:needBlackMask() return true end

return UICollectCodeMessageBox