local csbPath = "ui/csb/Agent/UIRecruit.csb"
local super = require("app.game.ui.UIBase")
local UIClubElemRecommend = import("app.game.ui.club.create.UIClubElemRecommend")

local UIRecruit = class("UIRecruit", super, function () return kod.LoadCSBNode(csbPath) end)

--[[
    招募
]]

function UIRecruit:ctor()
    self._textWechat = nil -- 微信号
    self._btnCopy = nil -- 复制
    self._btnClose = nil -- 关闭
    self._btnMakeMoney = nil -- 立即赚钱

    self._wechat = "" -- 保存一下微信号

    self._timer = nil -- 计时器
end

function UIRecruit:init()
    self._textWechat = seekNodeByName(self, "Text_wechat", "ccui.Text")
    self._btnCopy = seekNodeByName(self, "Button_copy", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._btnMakeMoney = seekNodeByName(self, "Button_makeMoney", "ccui.Button")

    bindEventCallBack(self._btnCopy, handler(self, self._onBtnCopy), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnMakeMoney, handler(self, self._onBtnMakeMoney), ccui.TouchEventType.ended)
end

function UIRecruit:onShow(path, weChat)
    --self:playAnimation_Scale()
    self._wechat = weChat or "123456"
    self._textWechat:setString(self._wechat)

    self._elemRecruit = UIClubElemRecommend.extend(
        seekNodeByName(self, "pageview_Notice", "ccui.PageView"),
        nil,
        seekNodeByName(self, "listview_Indicator", "ccui.ListView")
	)

    local data = {}
    for k, v in ipairs(path) do
        table.insert(data, {tp = UIClubElemRecommend.NOTICE_CONFS.ELEM_TYPE.IMAGE, title = "", content = v, content_ext = nil})
    end

    if #data == 0 then
        return
    end

    self._elemRecruit:load(UIClubElemRecommend.NOTICE_CONFS.fromProtocol(data))
    
   
end

function UIRecruit:_onBtnCopy()
    -- 统计点击复制微信
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.zhaomu_copy_click);

    if self._wechat ~= "" and game.plugin.Runtime.setClipboard(self._wechat) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end

    --self:playAnimation_Scale()
end

function UIRecruit:_onBtnMakeMoney()
    -- 统计立刻赚钱按钮
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.zhaomu_zhuanqian_click);

    --game.service.AgentService.getInstance():openWebView(config.AGTSTYLE.main)
    if not UIManager:getInstance():getIsShowing("UIAgentApply") then 
        UIManager:getInstance():show("UIAgentApply", self._wechat)
    end 
end

function UIRecruit:_onBtnClose()
    UIManager:getInstance():destroy("UIRecruit")
end

function UIRecruit:onHide()
    game.service.AgentService.getInstance():removeEventListenersByTag(self)
end

function UIRecruit:needBlackMask()
	return true;
end

function UIRecruit:closeWhenClickMask()
	return false
end

function UIRecruit:getUIRecordLevel()
	return config.UIRecordLevel.MainLayer
end

return UIRecruit