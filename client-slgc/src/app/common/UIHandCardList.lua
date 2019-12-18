local UIHandCardList = class("UIHandCardList")

function UIHandCardList.extend(self,direction,clickFunc)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIHandCardList)
    self:init(direction,clickFunc)
    assert(self:getDescription() == "ListView","must be ListView")

    return self
end

function UIHandCardList:init(direction,clickFunc)
    self._direction = direction
    self._clickFunc = clickFunc
end
--[[
    local CART_TYPE = game.CardFactory:getInstance():getCardType()
    {optype = CART_TYPE.GROUPCARD,opdata = {type = GROUP_TYPE.PENGGANG,cardValue = 5,from = 4,pos = 1}},
]]
function UIHandCardList:updateDatas(datas)
    self:removeAllItems()
    for i, data in ipairs(datas) do
        local card = game.CardFactory:getInstance():createCardWithOptions(self._direction,data.optype,data.opdata)
        self:pushBackCustomItem(card)
    end
end


return UIHandCardList