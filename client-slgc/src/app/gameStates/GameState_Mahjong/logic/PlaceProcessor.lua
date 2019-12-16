local PlaceBase = class("PlaceBase")

function PlaceBase:ctor()
    self._roleId = nil
    self._name = nil
    self._headUrl = nil
    self._score = 0
    game.EventCenter:on("PlaceStepSYN",handler(self,self.handlePlaceStepSYN),self)
end

function PlaceBase:dispose()
    game.EventCenter:off(self)
end

--[[
    {
        required int type = 1;
        required int sourceId = 2;
        required int targetId = 3;
        optional Msg1 msg1 = 4;
        optional Msg2 msg2 = 5;
    }
]]
function PlaceBase:handlePlaceStepSYN(step)
end

--玩家ID
function PlaceBase:setRoleId(roleId) self._roleId = roleId end
function PlaceBase:getRoleId() return self._roleId end
--玩家名称
function PlaceBase:setRoleName(name) self._name = name end
function PlaceBase:getRoleId() return self._name end
--头像
function PlaceBase:setHeadUrl(url) self._headUrl = url end
function PlaceBase:getHeadUrl() return self._headUrl end
--积分
function PlaceBase:setScore(score) self._score = score end
function PlaceBase:getScore() return self._score end

--手牌区列表
function PlaceBase:setHandList(handList) self._handList = handList end
function PlaceBase:getHandList() return self._handList end

--出牌区列表
function PlaceBase:setDiscardList(discardList) self._discardList = discardList end
function PlaceBase:getDiscardList() return self._discardList end

--玩家对象
function PlaceBase:setPlayer(player) self._player = player end
function PlaceBase:getPlayer() return self._player end

return PlaceBase