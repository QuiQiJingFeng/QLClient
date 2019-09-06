local KEY_MING_GANG, KEY_AN_GANG = 'mingGang', 'anGang'
local CARD_GROUP_COUNT = 5
local GROUP_SURFACE_MAX_COUNT = 4
local Constants = require("app.gameMode.mahjong.core.Constants")
local PlayType = Constants.PlayType
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Gold/UIGoldShareRoundResult_ShareNode.csb'
local M = class("UIGoldShareRoundResult_ShareNode", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    super.ctor(self)
end

function M:init()
    -- self._textSlogan = seekNodeByName(self, "Text_Slogan", "ccui.Text")
    self._textHuType = seekNodeByName(self, "BMFont_Hu_Type", "ccui.TextBMFont")
    -- 双喜临门
    self._imgSomeWords_1_SXLM = seekNodeByName(self, "Image_Some_Word_1", "ccui.ImageView")
    -- 财源滚滚
    self._imgSomeWords_2_CYGG = seekNodeByName(self, "Image_Some_Word_2", "ccui.ImageView")

    self._textPlayerName = seekNodeByName(self, "Text_Player_Name", "ccui.Text")
    self._imagePlayerIcon = seekNodeByName(self, "Image_Player_Icon", "ccui.ImageView")

    self._layoutShare = seekNodeByName(self, "Layout_Share", "ccui.Layout")
    self._mahjongCardsLayout = seekNodeByName(self._layoutShare, "Layout_Mahjong_Cards", "ccui.Layout")
    self._mahjongCardGroups = self:_initMahjongGroups(self._mahjongCardsLayout)
end

function M:getShareLayout()
    return self._layoutShare
end

function M:onShow()
    local shareData = game.service.GoldService.getInstance():getShareData()
    self:_loadGroupSurfaces(shareData.cardGroupDatas)
    self:_setPlayerInfo(shareData.playerInfo)
    self:_setHuTypeAndSomeWords(shareData)
    self:_shareSelf()
    game.service.GoldService.getInstance():setShareData({})
end

function M:_setPlayerInfo(info)
    if Macro.assertFalse(info, 'There has no player info') then
        local strName = kod.util.String.getMaxLenString(info.name, 8)
        self._textPlayerName:setString(strName)
        game.util.PlayerHeadIconUtil.setIcon(self._imagePlayerIcon, info.faceUrl)
    end
end

function M:_setHuTypeAndSomeWords(shareData) 
    self._textHuType:setString(Constants.SpecialEvents.getName(shareData.huType))

    local cyggVisiable = shareData.huType == PlayType.HU_QING_YI_SE
    or shareData.huType == PlayType.HU_QING_DAN_DIAO
    or shareData.huType == PlayType.HU_QING_DA_DUI
    or shareData.huType == PlayType.HU_DAN_DIAO
    or shareData.huType == PlayType.HU_RUAN_BAO
    or shareData.huType == PlayType.HU_YING_BAO
    -- 以下是潮汕的
    or shareData.huType == PlayType.HU_TIAN_HU
    or shareData.huType == PlayType.HU_SI_GANG

    self._imgSomeWords_2_CYGG:setVisible(cyggVisiable)
    self._imgSomeWords_1_SXLM:setVisible(not cyggVisiable)
end

--[[1
    这个方法是从 UIGoldShareRoundResult.lua 直接复制过来的（方法名相同）
    使用必须保证这两个ui的csd文件在 Layout_mahjong_cards 下的结构是一模一样的
]]
function M:_initMahjongGroups(container)
    local mahjongCardGroups = {}
    for groupIndex = 1, CARD_GROUP_COUNT, 1 do
        local group = {}
        local imgGroup = seekNodeByName(container, "ImageView_Group_" .. groupIndex, "ccui.ImageView")
        for surfaceIndex = 1, GROUP_SURFACE_MAX_COUNT, 1 do
            -- 可能找不到，不过不影响后续的赋值逻辑
            group['surface' .. surfaceIndex] = seekNodeByName(imgGroup, "ImageView_Surface_" .. surfaceIndex, "ccui.ImageView")
        end
        -- 加入gang的资源，如果有杠的话只需要做显隐处理即可，真正的牌面都加入到了surface中
        -- 可能找不到，不过不影响后续的赋值逻辑
        local imgMingGang = seekNodeByName(imgGroup, "ImageView_Ming_Gang", "ccui.ImageView")
        local imgAnGang = seekNodeByName(imgGroup, "ImageView_An_Gang", "ccui.ImageView")
        group[KEY_MING_GANG] = imgMingGang
        group[KEY_AN_GANG] = imgAnGang

        table.insert(mahjongCardGroups, group)
    end
    return mahjongCardGroups
end

--[[1
    这个方法是从 UIGoldShareRoundResult.lua 直接复制过来的（方法名相同）
    使用必须保证这两个ui的csd文件在 Layout_mahjong_cards 下的结构是一模一样的
]]
function M:_loadGroupSurfaces(cardGroupDatas)
    for groupIndex, cards in ipairs(cardGroupDatas) do
        local mahjongGroup = self._mahjongCardGroups[groupIndex]
        -- 牌面赋值
        for cardIndex, value in ipairs(cards) do
            if value ~= 255 then
                local skinPath = CardFactory:getInstance():getSurfaceSkin(value)
                if Macro.assertFalse(skinPath, 'get skin path failed, value = ' .. tostring(value)) then
                    local imgSurface = mahjongGroup["surface" .. cardIndex]
                    imgSurface:loadTexture(skinPath, ccui.TextureResType.plistType)
                end
            end
        end
        -- 杠的显示，只有index[1,4]的group有杠牌
        if groupIndex <= 4 then
            local mingGangVisiable = #cards == 4 and cards[4] ~= 255
            local anGangVisibale = #cards == 4 and cards[4] == 255
            mahjongGroup[KEY_MING_GANG]:setVisible(mingGangVisiable)
            mahjongGroup[KEY_AN_GANG]:setVisible(anGangVisibale)
        end
    end
end

function M:_shareSelf()
    local shareEnter = share.constants.ENTER.SYSTEM_SCREEN_SHOT
    local shareData = {}
    local shareDatas = { shareData, shareData, shareData }
    share.ShareWTF.getInstance():share(shareEnter, shareDatas, function()
    end)

    scheduleOnce(function()
        if self then
            self:hideSelf()
        end
    end, 3, self)
end

return M