-- 处理玩家数据相关逻辑
local LocalPlayerService = class("LocalPlayerService")

local _instance = nil
function LocalPlayerService:getInstance()
	if not _instance then
		_instance = LocalPlayerService.new()
	end
	return _instance
end

-- 清理类里的数据
function LocalPlayerService:clear()
end

function LocalPlayerService:ctor()
	self:clear()
end

--------------------------
-- Data Accessor
function LocalPlayerService:getIconUrl()				return self._iconUrl end
function LocalPlayerService:setIconUrl(value)			self._iconUrl = value end

function LocalPlayerService:getName()					return self._name end
function LocalPlayerService:setName(value)				self._name = value end

function LocalPlayerService:getRoleId()				return self._roleId end
function LocalPlayerService:setRoleId(value)			self._roleId = value end

function LocalPlayerService:getIp()					return self._ip end
function LocalPlayerService:setIp(value)				self._ip = value end

function LocalPlayerService:getCardCount()				return self._cardCount end
function LocalPlayerService:setCardCount(value)       self._cardCount = value end

function LocalPlayerService:getGoldAmount()			return self._goldAmount end
function LocalPlayerService:setGoldAmount(value)   self._goldAmount = value end

function LocalPlayerService:getBeanAmount()			return self._beanAmount end
function LocalPlayerService:setBeanAmount(value)  self._beanAmount = value end
 
function LocalPlayerService:setBindPhone(phone)			self.phone = phone end
-- 这里的手机号是已经加密过的，例如  138****1234 不要对他进行额外的处理了
function LocalPlayerService:getBindPhone()			return self.phone end
function LocalPlayerService:getUnionId()			return self._unionId end

function LocalPlayerService:getLastLoginTime() return self._lastLoginTime end
 
 
function LocalPlayerService:initGameData(protocol, unionId)
end

return LocalPlayerService