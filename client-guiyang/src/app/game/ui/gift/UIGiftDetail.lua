local csbPath = "ui/csb/Gift/UIGiftDetail.csb"
local super = require("app.game.ui.UIBase")
local MultiArea = require("app.gameMode.config.MultiArea")

local UIGiftDetail = class("UIGiftDetail", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGiftDetail:ctor()
	self._shareScreenShot = false;
	self._btnClose = nil
	self._shareUrl = nil
end

function UIGiftDetail:init()
    self.nameText  = seekNodeByName(self, "TextName",  "ccui.Text");
    self.telText  = seekNodeByName(self, "TextTelephone",  "ccui.Text");
    self.addressText  = seekNodeByName(self, "TextAddress",  "ccui.Text");
    self.logitisText  = seekNodeByName(self, "TextLogitis",  "ccui.Text");
    self.codeText = seekNodeByName(self, "TextCode",  "ccui.Text");
    self.logistics = seekNodeByName(self, "logistics",  "ccui.Text");
end

function UIGiftDetail:onShow(...)
	local args = {...};
    self.nameText:setString(args[1])
    self.telText:setString(args[2])
    self.addressText:setString(args[3])
    if args[4] == "" then
        self.logistics:setString("发货后即可查询")
    else
        self.logistics:setString(args[4])
    end
    if args[5] ==  "" then
        self.codeText:setString("发货后即可查询")
    else
        self.codeText:setString(args[5])
    end
end

function UIGiftDetail:needBlackMask()
	return true;
end

function UIGiftDetail:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGiftDetail:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIGiftDetail;
