--公共对象池

--对象ID
local OBJECT_ID = 0;
cc.exports.createObjID = function ()
	OBJECT_ID = OBJECT_ID + 1;
	return OBJECT_ID;
end
--默认最小对象数量
local DEFINE_MIN_COUNT  = 5;
--默认最大对象数量
local DEFINE_MAX_COUNT  = 50;

cc.exports.ObjectPool = class("ObjectPool")
--构造函数
function ObjectPool:ctor(...)
	local args = {...};
	--对象table
	self._objects = {};
	--活动对象table
	self._actives = {};
	--沉默对象table
	self._silents = {};
	--对象总数
	self._objectCount = 0;
	--对象类型
	self._objClass = nil;
	--最小数量（初始化及每次增长时的数量）
	self._minCount = DEFINE_MIN_COUNT;
	--最大数量
	self._maxCount = DEFINE_MAX_COUNT;
	
	local objClass,minCount,maxCount
	if 2 > #args then
		error("objClass is nil!ObjectPool can not take in a nil classType!");
		return;
	else
		objClass = args[2];
		--print("ObjectPool objClass is "..objClass.class.__cname);
	end
	if 3 > #args then
		print("ObjectPool minCount is Define:"..tostring(DEFINE_MIN_COUNT));
		minCount = DEFINE_MIN_COUNT;
	else
		print("ObjectPool minCount is Custom:"..tostring(args[3]));
		minCount = args[3];
	end
	if 4 > #args then
		print("ObjectPool maxCount is Define:"..tostring(DEFINE_MAX_COUNT));
		maxCount = DEFINE_MAX_COUNT;
	else
		maxCount = args[4];
		print("ObjectPool maxCount is Custom:"..tostring(args[4]));
	end
	if maxCount < minCount then
		error("ERROR: maxCount not less than minCount!");
		return;
	end
	self:_init(objClass,minCount,maxCount);
end
--创建对象池
function ObjectPool:create(...)
	local _instance = ObjectPool:new(...);
	return _instance;
end
--销毁对象池
function ObjectPool:destroy()
	for i = #self._objects, 1, -1 do
		if nil ~= self._objects[i].destroy and "function" == type(self._objects[i].destroy) then
			self._objects[i]:destroy();
		else
			error("ERROR: if you want to use ObjectPool, Object must inherit in ObjBase!");
		end
		
		table.remove(self._objects,i);
	end
	self._objects  = {};
	self._silents = {};
	self._actives = {};
	self._objectCount = 0;
end
--初始化对象池
function ObjectPool:_init(objClass,minCount,maxCount)
	self._objClass = objClass;
	self._minCount = minCount;
	self._maxCount = maxCount;
	self:addObj(minCount);
end
--增长池
--@param 增加数量（非必须，默认为minCount）
function ObjectPool:addObj(count)
	if self._objectCount >= self._maxCount then
		print("WARNING: this ObjectPool is full!");
		return false;
	end
	local _count = count;
	if nil == _count then
		_count = self._minCount;
	end
	local _begin = self._objectCount + 1;
	local _end = _begin + _count - 1;
	if _end > self._maxCount then
		_end = self._maxCount;
	end
	for i = _begin, _end do
		local obj = self._objClass:new()
		
		if nil ~= obj.bindPool and "function" == type(obj.bindPool) then
			obj:bindPool(self);
		else
			error("ERROR: if you want to use ObjectPool, Object must inherit in ObjBase!");
		end
		
		if nil ~= obj.reset and "function" == type(obj.reset) then
			obj:_reset()
		else
			error("ERROR: if you want to use ObjectPool, Object must inherit in ObjBase!");
		end
		
		table.insert(self._objects,obj);
		table.insert(self._silents,i);
	end
	self._objectCount = #self._objects;
	return true;
end
--从池中捞取对象
--@param 对象id(非必须，不传的话返回一个可用的silent对象)
function ObjectPool:getObject(id)
	local _result = nil;
	if nil == id then
		if 0 >= #self._silents then
			if not self:addObj() then
				return _result;
			end
		end
		local _index = self._silents[#self._silents];
		if nil == _index then
			error("ERROR: _index is invalid!");
			return _result;
		end
		_result = self._objects[_index];
		self._actives[_result:getId()] = _index;
		table.remove(self._silents);
	else
		local _index = self._actives[id];
		if nil == _index then
			error("ERROR: id is invalid!");
			return _result;
		end
		_result = self._objects[_index];
	end
	return _result;
end
--将对象还给池
--@param 对象id
function ObjectPool:backObject(id)
	if nil == id then
		error("ERROR: if you want to back an object, must have a id!");
		return;
	end
	local _index = self._actives[id];
	if nil == _index then
		error("ERROR: id is invalid!");
		return;
	end
	local obj = self._objects[_index];
	if nil ~= obj and nil ~= obj.stop and "function" == type(obj.stop) then
		obj:stop()
	else
		error("ERROR: if you want to use ObjectPool, Object must inherit in ObjBase!");
	end
	table.insert(self._silents,_index);
	self._actives[id] = nil;
end