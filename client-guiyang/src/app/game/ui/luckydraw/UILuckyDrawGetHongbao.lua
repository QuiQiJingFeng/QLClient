local csbPath = "ui/csb/Choujiang/UIYaojiang7.csb"

local UILuckyDrawGetHongbao= class("UILuckyDrawGetHongbao",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UILuckyDrawGetHongbao:ctor()
end


function UILuckyDrawGetHongbao:init()

	self._btnCopy = seekNodeByName(self, "Button_x_NoticeTips_0", "ccui.Button")
	self._btnCopy:addClickEventListener(handler(self, self._onClickCopy))

	self._textWx = seekNodeByName(self, "Text_1_0", "ccui.Text")
end

function UILuckyDrawGetHongbao:needBlackMask()
    return true
end

function UILuckyDrawGetHongbao:closeWhenClickMask()
	return true
end

function UILuckyDrawGetHongbao:onShow()
	-- self._textWx:setString()
	-- self._textWx:setString("官方微信:"..MultiArea.getWeChat(game.service.LocalPlayerService:getInstance():getArea()))
	self._textWx:setString("官方微信:".."myqhd2017")
end


--关闭
function UILuckyDrawGetHongbao:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawGetHongbao")
end

--拷贝
function UILuckyDrawGetHongbao:_onClickCopy()
	if game.plugin.Runtime.setClipboard("myqhd2017") == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end	
end



return UILuckyDrawGetHongbao
