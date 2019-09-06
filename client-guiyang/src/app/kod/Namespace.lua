-- 用于声明namespace
-- @param spaceName string
function cc.exports.namespace(spaceName)
	local parts = string.split(spaceName, '.')
	if #parts == 0 then
		return nil
	end

	local parentNS = cc.exports[parts[1]]
	if parentNS == nil then
		cc.exports[parts[1]] = {}
		parentNS = cc.exports[parts[1]]
	end

	for i = 2,#parts do
		if parentNS[parts[i]] == nil then
			parentNS[parts[i]] = {}
		end
		parentNS = parentNS[parts[i]]
	end
	return parentNS
end

-- 包裹一层，便捷的声明
function cc.exports.wrap_class_namespace(spaceName, classObject)
    if classObject ~= nil and classObject.__cname ~= nil then
        local space = namespace(spaceName)
        space[classObject.__cname] = classObject
		return classObject
	end
end