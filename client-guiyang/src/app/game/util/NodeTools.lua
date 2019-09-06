local NodeTools = class("NodeTools")

function NodeTools.extendItem(node, templateClass)
	local t = tolua.getpeer(node)
	if not t then
		t = {}
		tolua.setpeer(node, t)
	end
	setmetatable(t, templateClass)

	return node
end

return NodeTools 