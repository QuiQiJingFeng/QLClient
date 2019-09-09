local csbPath = app.UISettingCsb
local super = app.UIBase
local Util = app.Util
local UICheckBoxGroup = app.UICheckBoxGroup
local StorageKey = "info:setting"

local UISetting = class("UISetting", super, function() return app.Util:loadCSBNode(csbPath) end)
 
function UISetting:ctor()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))

    local cbxEffect = Util:seekNodeByName(self,"cbxEffect","ccui.CheckBox")
    local cbxDesk = Util:seekNodeByName(self,"cbxDesk","ccui.CheckBox")
    local cbxSound = Util:seekNodeByName(self,"cbxSound","ccui.CheckBox")
    local cbxUpdate = Util:seekNodeByName(self,"cbxUpdate","ccui.CheckBox")
    self._cbxTabTop =  UICheckBoxGroup.new({cbxEffect,cbxDesk,cbxSound,cbxUpdate},handler(self,self._onCheckBoxClick))
    self._pageContent = Util:seekNodeByName(self,"pageContent","ccui.PageView")


    --[[===功能設置===]]
    --出牌停留
    self._cbxPlayCardScale = Util:seekNodeByName(self,"cbxPlayCardScale","ccui.CheckBox")
    --单击出牌
    self._cbxOneClickPlayCard = Util:seekNodeByName(self,"cbxOneClickPlayCard","ccui.CheckBox")
    --更多分享
    self._cbxMoreShare = Util:seekNodeByName(self,"cbxMoreShare","ccui.CheckBox")
    --互动表情
    self._cbxExpression = Util:seekNodeByName(self,"cbxExpression","ccui.CheckBox")
    --离线邀请
    self._cbxIvitePush = Util:seekNodeByName(self,"cbxIvitePush","ccui.CheckBox")

    --[[=====牌桌设置=====]]
    --牌桌颜色设置
    local cbxDesktopGreed = Util:seekNodeByName(self,"cbxDesktopGreed","ccui.CheckBox")
    local cbxDesktopBlue = Util:seekNodeByName(self,"cbxDesktopBlue","ccui.CheckBox")
    local cbxDesktopPurple = Util:seekNodeByName(self,"cbxDesktopPurple","ccui.CheckBox")
    self._cbxTabDeskColor =  UICheckBoxGroup.new({cbxDesktopGreed,cbxDesktopBlue,cbxDesktopPurple})
    --牌颜色设置
    local cbxCardBlue = Util:seekNodeByName(self,"cbxCardBlue","ccui.CheckBox")
    local cbxCardGreen = Util:seekNodeByName(self,"cbxCardGreen","ccui.CheckBox")
    local cbxCardOringe = Util:seekNodeByName(self,"cbxCardOringe","ccui.CheckBox")
    self._cbxTabCardColor =  UICheckBoxGroup.new({cbxCardBlue,cbxCardGreen,cbxCardOringe})


    --[[========声音=========]]
    --音乐
    self._sliderMusic = Util:seekNodeByName(self,"sliderMusic","ccui.Slider")
    --音效
    self._sliderAudioEffect = Util:seekNodeByName(self,"sliderAudioEffect","ccui.Slider")
    self._sliderMusic:addEventListener(handler(self, self._onSliderMusicChange))
	self._sliderAudioEffect:addEventListener(handler(self, self._onSliderAudioEffectChange))

    --[[=========更新=========]]
    --新版本更新
    self._btnUpdate = Util:seekNodeByName(self,"btnUpdate","ccui.Button")
    Util:bindTouchEvent(self._btnUpdate,handler(self,self._onBtnUpdateClick))
    --问题上报
    self._btnFixGame = Util:seekNodeByName(self,"btnFixGame","ccui.Button")
    Util:bindTouchEvent(self._btnFixGame,handler(self,self._onBtnFixGameClick))
end

function UISetting:_onBtnUpdateClick()
    app.UITipManager:getInstance():show("敬请期待")
end

function UISetting:_onBtnFixGameClick()
	app.UITipManager:getInstance():show("敬请期待")
end



function UISetting:_onSliderMusicChange(sender)
    local volume = sender:getPercent() * 0.01
	app.AudioManager.getInstance():getMusicVolume(volume)	
end

function UISetting:_onSliderAudioEffectChange(sender)
    local volume = sender:getPercent() * 0.01
	app.AudioManager.getInstance():setSoundsVolume(volume)	
end

function UISetting:_onCheckBoxClick(cbx,index)
    self._pageContent:setCurrentPageIndex(index-1)
end

function UISetting:_onBtnCloseClick()
    app.UIManager:getInstance():hide("UISetting")
end

function UISetting:onShow()
    self._cbxTabTop:setSelectIdx(1)

    local setting = app.PlayerSettingData:getInstance():getSetting()
    self._cbxTabDeskColor:setSelectIdx(setting.cardTable.tableColorIdx)
    self._cbxTabCardColor:setSelectIdx(setting.cardTable.cardColorIdx)
    self._cbxPlayCardScale:setSelected(setting.effect.playCardScale)
    self._cbxOneClickPlayCard:setSelected(setting.effect.oneClickPlayCard)
    self._cbxMoreShare:setSelected(setting.effect.moreShare)
    self._cbxExpression:setSelected(setting.effect.expression)
    self._cbxIvitePush:setSelected(setting.effect.ivitePush)
    self._sliderMusic:setPercent(setting.sound.sliderMusic)
    self._sliderAudioEffect:setPercent(setting.sound.sliderAudioEffect)
end

function UISetting:onHide()
    local setting = {
        effect = {
            playCardScale = self._cbxPlayCardScale:isSelected(),
            oneClickPlayCard = self._cbxOneClickPlayCard:isSelected(),
            moreShare = self._cbxMoreShare:isSelected(),
            expression = self._cbxExpression:isSelected(),
            ivitePush = self._cbxIvitePush:isSelected(),
        },
        cardTable = {
            tableColorIdx = self._cbxTabDeskColor:getSelectIdx(),
            cardColorIdx = self._cbxTabCardColor:getSelectIdx()
        },
        sound = {
            sliderMusic = self._sliderMusic:getPercent(),
            sliderAudioEffect = self._sliderAudioEffect:getPercent(),
        }
    }
    app.PlayerSettingData:updateSettings(setting)
end

function UISetting:needBlackMask()
    return true
end

 
return UISetting