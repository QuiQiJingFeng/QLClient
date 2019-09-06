--[[
    麻将馆赛事创建模板列表页面
--]]

local CurrencyHelper = require("app.game.util.CurrencyHelper")
local csbPath = "ui/csb/Campaign/selfbuild/UIClubBattleCreate.csb"
local super = require("app.game.ui.UIBase")
local UICampaignCreate_Club = class("UICampaignCreate_Club", super, function() return kod.LoadCSBNode(csbPath) end)

local UICellModel = class( "UICellModel" ) 

function UICellModel:ctor( uiroot , data)
    self._BtnTextFont = seekNodeByName(uiroot , "BitmapFontLabel_4", "ccui.TextBMFont")  -- 按钮上问题
    self._BtnCreate   = seekNodeByName(uiroot , "Button_creat_FangKa" , "ccui.Button")  -- 右下角按钮，有【比赛中，比赛结束，报名几种状态】
    self._gameName = seekNodeByName(uiroot , "Text_3" , "ccui.Text" )      -- 赛事名称
    self._numLimit = seekNodeByName(uiroot , "Text_7" , "ccui.Text" )      -- 人数限制
    self._signFee  = seekNodeByName(uiroot , "Text_6" , "ccui.Text" )      -- 报名费用
    self._gameCost = seekNodeByName(uiroot , "Text_5" , "ccui.Text")       -- 创建赛事总花费
    self._btnGameInfo = seekNodeByName(uiroot , "Button_xq", "ccui.Button")    -- 详情按钮
    self.uiroot = uiroot
    self._data = data
    self.delayTime = 10*60
    self:insertData(data)
    
    bindEventCallBack(self._BtnCreate, handler(self, self._onBtnCreateClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnGameInfo, handler(self, self._onBtnGameInfoClick), ccui.TouchEventType.ended)
end

function UICellModel:insertData(data)
    -- 数据填充

    self._gameName:setString(data.name)
    self._numLimit:setString( "最低" .. data.leastCount .. "人开赛")
    self._gameCost:setString(self:_generateCost({data.createCost}) .. config.STRING.UICAMPAIGNCREATE_CLUB_STRING_100)
    self._signFee:setString(self:_generateFee(data.cost) .. "/人")    
end

-- 生成消耗房卡数
function UICellModel:_generateCost(items)
    local result = ""

    -- 取出所有道具信息
    local costInfo = {}
    table.foreach(items, function (k,v)
        table.insert(costInfo, v)
    end)

    result = PropReader.generatePropTxt(costInfo)
    return result
end

-- 生成报名费显示
function UICellModel:_generateFee(items)
    local result = ""

    -- 取出优先级最高的
    table.sort(items, function (a,b)
        return a > b
    end)

    if #items == 0 then return config.STRING.UICAMPAIGNCREATE_CLUB_STRING_101 end
    result = PropReader.generatePropTxt({items[1].item})
    return result
end

-- 创建按钮回调
function UICellModel:_onBtnCreateClick()
    self._data.isShow = true
    local startTime = math.floor(kod.util.Time.now()) + self.delayTime
	local endTime = startTime + 6 * 24 * 60 * 60
    local x = self.uiroot:getParent()._timePicker
    self._data.parent._timePicker:setTime(startTime, endTime, startTime)
	self._data.parent._timePicker:setVisible(true)
end

function UICellModel:_onBtnGameInfoClick()
    UIManager:getInstance():show("UICampaignDetailPage_Club", self._data)
end


function UICampaignCreate_Club:ctor()
    self._allGameinfo = {}
end

function UICampaignCreate_Club:init( )
    self._btnBack = seekNodeByName(self, "Button_2_FangKa" , "ccui.Button")
    self._titleText = seekNodeByName(self, "BitmapFontLabel_hf", "ccui.TextBMFont")
    self._btnHelp = seekNodeByName(self, "Button_hlep_FangKa", "ccui.Button")
    self._gameList = seekNodeByName(self, "ListView_Nr_FangKa", "ccui.ListView")
    self._panelModel = seekNodeByName(self, "Panel_Db_FangKa", "ccui.Layout")
    
    self._panelModel:retain()
    self._gameList:removeAllItems()
    -- self._gameList:setScrollBarOpacity(0)
    
    local callback = function(time)
        
        for i,v in ipairs(self._allGameinfo) do
            if v.isShow then
                local date = kod.util.Time.dateWithFormat(nil, os.time(time))
                v.time = date
                v.timeStamp = os.time(time)
                UIManager:getInstance():show("UICampaignCreateConfirm_Club", v)
                v.isShow = false
                self._timePicker:setVisible(false)
            end
        end
        
	end
	self._timePicker = require("app.game.ui.campaign.selfbuild.UITimePickRoller").new(callback)
	self:addChild(self._timePicker:getWidget(), 100)
    self._timePicker:setVisible(false)
    UIManager:getInstance():createMaskLayer(self._timePicker)
    self:_registerCallBack()
end

function UICampaignCreate_Club:_registerCallBack()
    bindEventCallBack(self._btnBack, handler(self, self._onBtnBackClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHelp, handler(self, self._onBtnHelpClick), ccui.TouchEventType.ended)
end

function UICampaignCreate_Club:onShow( data )
    self._allGameinfo = data
    self:insertData(self._allGameinfo)
    self._bindKey = CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.CARD, seekNodeByName(self, "ImageView_Card_Bundle", "ccui.ImageView"))
end

function UICampaignCreate_Club:onHide()
    if self._bindKey then
        CurrencyHelper.getInstance():getBinder():unbind(self._bindKey)
    end
    self._bindKey = nil
end

function UICampaignCreate_Club:_onBtnHelpClick()
    UIManager:getInstance():show("UICampaignCreateDesc_Club")
end

function UICampaignCreate_Club:insertData(data)

    self._gameList:removeAllItems()
    for i=1,#data do
        local item = self._panelModel:clone()
        data[i].parent = self
        data[i].isShow = false
        local cell = UICellModel.new(item , data[i])
        self._gameList:addChild(item)
    end    

end

function UICampaignCreate_Club:_onBtnBackClick()
    self:_onClose()
end

function UICampaignCreate_Club:hide()
    self:setVisible(false)
end

function UICampaignCreate_Club:_onClose()
    UIManager:getInstance():destroy("UICampaignCreate_Club")
end

function UICampaignCreate_Club:dispose()
    self._panelModel:release()
    self._panelModel = nil
end

function UICampaignCreate_Club:needBlackMask()
	return true;
end

function UICampaignCreate_Club:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICampaignCreate_Club:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UICampaignCreate_Club