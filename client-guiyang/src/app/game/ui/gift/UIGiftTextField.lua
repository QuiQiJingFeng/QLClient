local csbPath = "ui/csb/Gift/UIGetGift.csb"
local super = require("app.game.ui.UIBase")

local UIGiftTextField = class("UIGiftTextField", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGiftTextField:ctor()
    self._btnClose = nil

    self._rewardInfo = nil
    self._nameTextFiled = nil
    self._telTextFiled = nil
    self._addressTextFiled = nil
    self._btnComfirm = nil

    self.name = ""
    self.telephone = ""
    self.address = ""
    self.campaignId = 0
end

function UIGiftTextField:init()
    -- body
    self._btnClose  = seekNodeByName(self, "Button_x_STP",  "ccui.Button");
    self._rewardInfo  = seekNodeByName(self, "rewardInfo",  "ccui.Text");
    self._nameTextFiled  = seekNodeByName(self, "name",  "ccui.TextField");
    self._telTextFiled  = seekNodeByName(self, "telephone",  "ccui.TextField");
    self._addressTextFiled  = seekNodeByName(self, "address",  "ccui.TextField");
    self._btnComfirm = seekNodeByName(self, "Button_Comfirm",  "ccui.Button");

    self._nameTextFiled:setTextColor(cc.c4b(151, 86, 31, 255))
    self._telTextFiled:setTextColor(cc.c4b(151, 86, 31, 255))
    self._addressTextFiled:setTextColor(cc.c4b(151, 86, 31, 255))

    self:_registerCallback()
end

function UIGiftTextField:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnComfirm, handler(self, self._onClickComfirm), ccui.TouchEventType.ended)
end

function UIGiftTextField:onShow( ... )
    local args = {...}
    self.rewardTxt = args[1]
    self.goodUID = args[2]

    self._rewardInfo:setString("恭喜您获得".. self.rewardTxt .."的奖励,请仔细填写以下收货信息以保证您顺利收到奖励！")
end

function UIGiftTextField:_onClose()
    UIManager:getInstance():destroy("UIGiftTextField")
end

function UIGiftTextField:needBlackMask()
	return true;
end

function UIGiftTextField:closeWhenClickMask()
	return false
end

-- 检测内容合法性
function UIGiftTextField:checkContentIllegal()
    local nameLegal = string.len(self.name) > 2 -- 名字需大于2个英文字符
    local phoneLegal = tonumber(self.telephone) and string.len(self.telephone)>= 11
    local addressLegal = string.len(self.address) > 2 

    if not nameLegal then
        return 1
    elseif not phoneLegal then
        return 2
    elseif not addressLegal then
        return 3
    else
        return 0
    end
end

-- 点击确定按钮
function UIGiftTextField:_onClickComfirm()
    -- 统计领取按钮的点击次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Receive);

    self.name = self._nameTextFiled:getString()
    self.telephone = self._telTextFiled:getString()
    self.address = self._addressTextFiled:getString()
    local result = self:checkContentIllegal()
    if result == 0 then
        game.ui.UIMessageBoxMgr.getInstance():show("确定后将以您的信息为准发放奖励\n是否继续确认。", {"确定","取消"},function()
            game.service.GiftService.getInstance():queryApplyGoods(game.service.LocalPlayerService.getInstance():getRoleId(), self.goodUID, self.name, self.telephone, self.address);
            game.service.GiftService:getInstance():queryGoods()
            end)
    else
        if result == 1 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的姓名")
        elseif result == 2 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的电话号码")
        elseif result ==3 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入完整的收货信息")
        end
    end
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGiftTextField:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIGiftTextField