local csbPath = "ui/csb/Backpack/UIBagInfo.csb"
local super = require("app.game.ui.UIBase")

local UIBackpackDetail = class("UIBackpackDetail", super, function () return kod.LoadCSBNode(csbPath) end)

function UIBackpackDetail:ctor()
    self.propObj = nil
end

function UIBackpackDetail:init()
    self._textDetail  = seekNodeByName(self, "Text_content",  "ccui.Text");
    self._textTime = seekNodeByName(self, "Text_time", "ccui.Text")
    self._icon = seekNodeByName(self, "Image_1", "ccui.ImageView")
    self._textName = seekNodeByName(self, "Text_name", "ccui.Text")
end

function UIBackpackDetail:onShow(...)
    local data = {...};
    self.propObj = data[1]
    self.external = data[2]

    if self.propObj:getDestoryTime() ~= "" then
        self._textTime:setString("使用期限:将于".. self.propObj:getDestoryTime().. "到期")
    else
        self._textTime:setString("")
    end

    self._icon:loadTexture("art/function/img_none.png")
    PropReader.setIconForNode(self._icon,self.propObj:getId())
    local num = 1
    if self.external ~= nil then
        num = self.external.num or 1
    end
    self._textName:setString(self.propObj:getName() .. "*" .. num)
    self._textDetail:setString(self.propObj:getDesc())
end

function UIBackpackDetail:needBlackMask()
	return true;
end

function UIBackpackDetail:closeWhenClickMask()
	return true
end

return UIBackpackDetail;
