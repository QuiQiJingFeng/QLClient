local PlayerSettingData = class("PlayerSettingData")

local _instance = nil
function PlayerSettingData:getInstance()
	if not _instance then
		_instance = PlayerSettingData.new()
	end
	return _instance
end

function PlayerSettingData:clear()
    self._setting = {
        effect = {
            playCardScale = true,   --出牌放大
            oneClickPlayCard = true,  --单击出牌
            moreShare = true,         --更多分享
            expression = true,        --互动表情
            ivitePush = true,         --接收离线推送
        },
        cardTable = {
            tableColorIdx = 1,       --牌桌选择[绿、蓝、紫]
            cardColorIdx = 1         --牌颜色选择[蓝、绿、橘]
        },
        sound = {
            sliderMusic = 30,        --音乐声音大小
            sliderAudioEffect = 30,  --音效声音大小
        }
    }
end

function PlayerSettingData:ctor()
    self:clear()
    app.LocalStorage:setRoleId("ABCIDE")
    local setting = app.LocalStorage:loadDataFromKey("PlayerSettingData")
    if setting then
        self._setting = setting
    end
end

function PlayerSettingData:getSetting()
    return self._setting
end

function PlayerSettingData:updateSettings(setting)
    app.LocalStorage:saveDataByKey("PlayerSettingData",setting)
    self._setting = setting
end

--出牌放大
function PlayerSettingData:getPlayCardScale()
    return self._setting.effect.playCardScale
end

--单击出牌
function PlayerSettingData:getOneClickPlayCard()
    return self._setting.effect.oneClickPlayCard
end

--更多分享
function PlayerSettingData:getPlayCardScale()
    return self._setting.effect.moreShare
end

--互动表情
function PlayerSettingData:getExpression()
    return self._setting.effect.expression
end

--离线推送
function PlayerSettingData:getIvitePush()
    return self._setting.effect.ivitePush
end

--桌布颜色
function PlayerSettingData:getTableColorIdx()
    return self._setting.cardTable.tableColorIdx
end

--牌颜色
function PlayerSettingData:getCardColorIdx()
    return self._setting.cardTable.cardColorIdx
end


return PlayerSettingData