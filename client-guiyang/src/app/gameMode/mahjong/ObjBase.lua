local ObjBase = class("ObjBase")

function ObjBase:ctor()
	self._objId = createObjID();
	self._belongPool = nil;
end

function ObjBase:bindPool(pool)
	self._belongPool = pool;
end

function ObjBase:_reset() end
function ObjBase:stop() end
function ObjBase:destroy()
	self._objId = nil;
	self._belongPool = nil;
end
function ObjBase:_release() end
function ObjBase:getId()
	return self._objId;
end

function ObjBase:delete()
	self._belongPool:backObject(self._objId);
end

return ObjBase;