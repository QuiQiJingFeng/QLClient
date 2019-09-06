local csbPath = "ui/csb/UIAward.csb"
local UIAward = class("UIAward",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

function UIAward:getGradeLayerId( )
    return config.UIConstants.UI_LAYER_ID.Top
end

function UIAward:onHideUI()
    UIManager.getInstance():hide("UIAward")
end

function UIAward:init()
    self.text = seekNodeByName(self, "Text_Award_Notice", "ccui.Text")
    self.img = seekNodeByName(self, "Image_Award", "ccui.ImageView");
    seekNodeByName(self, "Button_Close_1", "ccui.Button"):setVisible(false)
    self.buttonshare = seekNodeByName(self, "Button_Share_1", "ccui.Button")
    bindEventCallBack(self.buttonshare, handler(self,self.onHideUI), ccui.TouchEventType.ended)
    seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont");
    seekNodeByName(self, "Panel_Encourage", "ccui.Layout"):setVisible(false)
end

function UIAward:onShow(num)
    self.text:setString('恭喜您获得大赢家称号，获得'..num..'礼券奖励')
    local path = "shop/icon_lq.png"
    self.img:loadTexture(path)
    self.img:getChildByName('BitmapFontLabel_1'):setString('X'..num)
    self.buttonshare:getChildByName("BitmapFontLabel_1_A_Tree2"):setString('确定')
end

function UIAward:needBlackMask()
    return true
end

return UIAward