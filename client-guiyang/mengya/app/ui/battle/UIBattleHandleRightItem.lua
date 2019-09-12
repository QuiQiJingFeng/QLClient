local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleRightItem = class("UIBattleHandleRightItem",UITableViewCell)
local UIManager = app.UIManager

function UIBattleHandleRightItem:init()
    self._panelPengGangRight = Util:seekNodeByName(self,"panelPengGangRight","ccui.Layout")
    self._panelHandleCardRight = Util:seekNodeByName(self,"panelHandleCardRight","ccui.Layout")
    self._panelCard4 = Util:seekNodeByName(self,"panelCard4","ccui.Layout")
end

function UIBattleHandleRightItem:updateData(data)
    self:setLocalZOrder(100 - self:getIdx())
    if data.type == "peng" or data.type == "gang" then
        self._panelPengGangRight:setVisible(true)
        self._panelHandleCardRight:setVisible(false)
        self._panelCard4:setVisible(data.type == "peng")

        local size =  self._panelPengGangRight:getContentSize()
        return cc.size(size.height,size.width)
    elseif data.type == "handCard" then
        self._panelPengGangRight:setVisible(false)
        self._panelHandleCardRight:setVisible(true)
        local datas = self:getTableView():getDatas()
        if self:getIdx() == #datas then
            local num = 0
            for i, info in ipairs(datas) do
                if info.type == "handCard" then
                    num = num + 1
                end
            end
            if num % 3 == 2 then
                self:setDiffDelt(cc.p(20,0))
            end
        end

        return self._panelHandleCardRight:getContentSize()
    end
end
 

return UIBattleHandleRightItem