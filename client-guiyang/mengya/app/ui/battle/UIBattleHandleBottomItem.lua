local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleBottomItem = class("UIBattleHandleBottomItem",UITableViewCell)
local UIManager = app.UIManager

function UIBattleHandleBottomItem:init()
    self._panelPengGangBottom = Util:seekNodeByName(self,"panelPengGangBottom","ccui.Layout")
    self._panelHandleCardBottom = Util:seekNodeByName(self,"panelHandleCardBottom","ccui.Button")
    self._btnCard4 = Util:seekNodeByName(self,"btnCard4","ccui.Button")
end

function UIBattleHandleBottomItem:updateData(data)
    if data.type == "peng" or data.type == "gang" then
        self._panelPengGangBottom:setVisible(true)
        self._panelHandleCardBottom:setVisible(false)
        self._btnCard4:setVisible(data.type == "peng")

        return self._panelPengGangBottom:getContentSize()
    elseif data.type == "handCard" then
        self._panelPengGangBottom:setVisible(false)
        self._panelHandleCardBottom:setVisible(true)

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

        return self._panelHandleCardBottom:getContentSize()
    end
end
 

return UIBattleHandleBottomItem