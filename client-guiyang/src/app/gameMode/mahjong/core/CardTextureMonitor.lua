--[[
    检测每个texture，如果某个值得数量超过4(>)
]]

local function Monitor(reporter)
    local _reference = {}

    local _report = function(type, texture)
        reporter(type, texture)
    end

    local _add = function(texture)
        local count = _reference[texture] == nil and 0 or _reference[texture]
        _reference[texture] = count + 1 
        if count == 4 then
            -- _report("TEXTURE ADD ERROR", texture)
        end
    end

    local _remove = function(texture)
        local count = _reference[texture] == nil and 0 or _reference[texture]
        if count == 0 then
            _report("TEXTURE REMOVE ERROR", texture)
            return
        end
        _reference[texture] = count - 1
    end

    return {
        ['add'] = function ( texture )
            _add(texture)
        end,
        ['rm'] = function ( texture )
            _remove(texture)
        end
    }
end

return Monitor