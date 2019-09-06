--[[
    因为搜索路径是src+test，所以这么命名在src下的require也能找到
    所以尽情的为所欲为吧！
]]

local function _WO_SHI_CESHI_FENXIANG( data )
    return function ()
        tlog.info(data)
        tlog.info("为所欲为吧！")
    end
end

local function _I_AM_TEST_SHARE()
    return function ()
        tlog.info("为所欲为吧！")
        tlog.info("为所欲为吧！")
        tlog.info("为所欲为吧！")
        tlog.info("为所欲为吧！")
        tlog.info("为所欲为吧！")
    end
end

return {
    WO_SHI_CESHI_FENXIANG = _WO_SHI_CESHI_FENXIANG,
    I_AM_TEST_SHARE = _I_AM_TEST_SHARE
}