--[[    @desc: PropObject 道具实例
    author:{贺逸}
    time:2018-04-26
    --@id: 需要截图的node
    --@name: 名称
	--@type: 类型
    --@desc: 来源
    --@source: 来源
	--@purpose: 用途
    --@destoryTime: 有效期
    --@icon: 图片地址
	--@storageFlag: 是否进入背包
]]
local PropObject = class("PropObject")

function PropObject:ctor()
end

function PropObject:clone(obj)
	self._id = obj.id
	self._area = obj._area
	self._name = obj._name	
	self._type = obj._type
	self._desc = obj._desc
	self._source = obj._source
	self._purpose = obj._purpose
	self._destoryTime = obj._destoryTime
	self._icon = obj._iconicon
	self._storageFlag = obj._storageFlag
	self._duration = obj._duration
	self._extension = obj._extension
end

function PropObject:reset(obj, itemInfo)
	self._id = obj.id
	self._area = obj.area
	self._name = obj.name	
	self._type = obj.type
	self._desc = obj.desc
	self._source = obj.source
	self._purpose = obj.purpose
	self._destoryTime = obj.destroyTime
	self._icon = obj.icon
	self._storageFlag = obj.storageFlag
	self._duration = obj.duration
	self._external = itemInfo
end

function PropObject:getId()						return self._id; end
function PropObject:getArea()						return self._area; end
function PropObject:getName()						return self._name; end
function PropObject:getDesc()						return self._desc; end
function PropObject:getSource()					return self._source; end
function PropObject:getPurpose()					return self._purpose; end
function PropObject:getDestoryTime()				return self._destoryTime; end
function PropObject:getIcon()						return self._icon; end
function PropObject:getStorageFlag()				return self._storageFlag; end
function PropObject:getDuration()				return self._duration end

-- 物品附加信息
function PropObject:getExternal()				return self._external end
function PropObject:setExternal(value)			self._external = value; end

-- 获取物品type
function PropObject:getType()						return self._type; end

-- 使用物品 成功返回true 失败返回false
function PropObject:excute(external)
	UIManager:getInstance():show("UIBackpackDetail", self, external)
	return true
end

return PropObject 