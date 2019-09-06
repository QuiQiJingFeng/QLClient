local Version = class("Version")

--[[
 * 版本号封装，支持x.x.x.x类型版本号
 * 第一部分：表示具有换代意义的版本升级
 * 第二部分：表示局部功能改变
 * 第三部分：表示bug修复
 * 第四部分：表示svn版本号
 * 其中第一第二第三部分用于审核版本显示
 *]]

function Version:ctor(versionString)
    -- 数字类型，版本数组
    self._versions = {}	
	self:_parseVersion(versionString or "")
end

function Version:_parseVersion(versionString)
	local v = string.split(versionString, ".")	
	local has_vailid = false
	local versions = {}
	for i = 4, 1, -1 do
		local part = tonumber(v[i])
		if part or i == 1 or has_vailid then -- 版本号至少有1位
			versions[i] = part or 0
			has_vailid = true			
		end		
	end
	self._versions = versions
end

function Version:getVersions()
    return self._versions
end

function Version:compare(other)
	if iskindof(other, "Version") then
		return self:_compare(other:getVersions())
	elseif type(other) == "string" then
		return self:_compare(Version.new(other):getVersions())
	elseif type(other) == "table" then
		return self:_compare(other)		
	end
	assert(false, "error version object")
end

function Version:_compare(versiontbl)
	local _versions = self._versions
	for i = 1, 4 do
		local part1 = _versions[i] or 0
		local part2 = versiontbl[i] or 0
		if part1 > part2 then return 1 end
		if part1 < part2 then return -1 end		
	end
	return 0
end

function Version:toString()
	local version = ""
	for _, part in ipairs(self._versions) do
		if version ~= "" then version = version .. "." end
		version = version .. part
	end
	return version
end

return Version