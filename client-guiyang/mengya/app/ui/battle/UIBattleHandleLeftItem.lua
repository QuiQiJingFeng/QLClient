local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleLeftItem = class("UIBattleHandleLeftItem",UITableViewCell)
local UIManager = app.UIManager

function UIBattleHandleLeftItem:init()
    self._panelPengGangLeft = Util:seekNodeByName(self,"panelPengGangLeft","ccui.Layout")
    self._panelHandleCardLeft = Util:seekNodeByName(self,"panelHandleCardLeft","ccui.Layout")
    self._panelCard4 = Util:seekNodeByName(self,"panelCard4","ccui.Layout")
end

function UIBattleHandleLeftItem:updateData(data)
    if data.type == "peng" or data.type == "gang" then
        self._panelPengGangLeft:setVisible(true)
        self._panelHandleCardLeft:setVisible(false)
        self._panelCard4:setVisible(data.type == "peng")

        return self._panelPengGangLeft:getContentSize()
    elseif data.type == "handCard" then
        self._panelPengGangLeft:setVisible(false)
        self._panelHandleCardLeft:setVisible(true)
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
        return self._panelHandleCardLeft:getContentSize()
    end
end
 

return UIBattleHandleLeftItem