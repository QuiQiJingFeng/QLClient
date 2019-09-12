local Util = app.Util
local UITableViewCell = app.UITableViewCell
local UIBattleHandleTopItem = class("UIBattleHandleTopItem",UITableViewCell)
local UIManager = app.UIManager

function UIBattleHandleTopItem:init()
    self._panelPengGangTop = Util:seekNodeByName(self,"panelPengGangTop","ccui.Layout")
    self._panelHandleCardTop = Util:seekNodeByName(self,"panelHandleCardTop","ccui.Layout")
    self._panelCard4 = Util:seekNodeByName(self,"btnCard4","ccui.Button")
end

function UIBattleHandleTopItem:updateData(data)
    if data.type == "peng" or data.type == "gang" then
        self._panelPengGangTop:setVisible(true)
        self._panelHandleCardTop:setVisible(false)
        self._panelCard4:setVisible(data.type == "peng")

        return self._panelPengGangTop:getContentSize()
    elseif data.type == "handCard" then
        self._panelPengGangTop:setVisible(false)
        self._panelHandleCardTop:setVisible(true)
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
        return self._panelHandleCardTop:getContentSize()
    end
end
 

return UIBattleHandleTopItem