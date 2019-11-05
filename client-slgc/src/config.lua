
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
local screen = {
    _width = nil,
    _height = nil,
    _realSize = nil,
    _size = nil,
    _center = nil,
    _offset = nil,
    _scale = nil,
    _widthFixed = nil,
    _safeAreaOffset_x = 0,
}

-- 初始化
function screen.init(width, height)
    screen._width = width
    screen._height = height
    screen._realSize = cc.Director:getInstance():getWinSize()
    return screen
end

-- 是否是横向适配
function screen.isWidthFixed()
    if screen._widthFixed == nil then
        screen._widthFixed = screen._realSize.width / screen._realSize.height > screen._width / screen._height
    end
    return screen._widthFixed
end

-- 屏幕的基础缩放
function screen.scale()
    if screen._scale == nil then
        if screen.isWidthFixed() then
            screen._scale = screen._realSize.width/screen._width
        else
            screen._scale = screen._realSize.height/screen._height
        end
    end
end

-- iphonex 适配
function screen.safeAreaRectCheck()
    local director = cc.Director:getInstance()
    if director.getSafeAreaRect then
        local visibleRect = director:getOpenGLView():getVisibleRect()
        local safeAreaRect = director:getSafeAreaRect()
        if safeAreaRect.width < visibleRect.width then
            screen._safeAreaOffset_x = (visibleRect.width - safeAreaRect.width) / 2
        end

        -- 这里的是绝对的坐标，需要进行等比例的缩放
        -- screen._safeAreaOffset_x = screen._safeAreaOffset_x / screen._scale
    end
end

-- 屏幕坐标转换到960-640后的坐标，ui上使用
function screen.size()
    if screen._size == nil then
        screen.scale()
        screen.safeAreaRectCheck()
        local size = cc.pFromSize(screen._realSize)
        if screen.isWidthFixed() then
            size = cc.pMul(size, 640/screen._realSize.height)
        else
            size = cc.pMul(size, 1136/screen._realSize.width)
        end
        screen._size = cc.size(size.x - screen._safeAreaOffset_x * 2, size.y)
    end
    return screen._size
end

-- 中心坐标（是以960-640坐标系下的坐标）
function screen.centerPoint()
    if screen._center == nil then
        screen._center = cc.pMul(cc.pFromSize(screen.size()), 0.5)
    end
    return screen._center
end

-- 屏幕的偏移
function screen.offsetPoint()
    if screen._offset == nil then
        screen._offset = cc.p(-(screen.size().width + screen._safeAreaOffset_x * 2 -screen._width)/2, -(screen.size().height-screen._height)/2)
        screen._offset.x = screen._offset.x + screen._safeAreaOffset_x
    end
    return screen._offset
end

-- 将一个960-640的原始 坐标转换到 当前屏幕转换到960-640后的分辨率下的 坐标
-- 以下几个函数只是转换方式不同

-- 中间x方向锚点的距离
function screen.toCenterX(x)
    return screen.centerPoint().x - (screen._width/2 - x) + screen.offsetPoint().x
end

-- 中间y方向锚点的距离
function screen.toCenterY(y)
    return screen.centerPoint().y - (screen._height/2 - y) + screen.offsetPoint().y
end

-- 右锚点的距离不变
function screen.toRight(x)
    return screen.size().width - (screen._width - x) + screen.offsetPoint().x
end

-- 右锚点的距离不变
function screen.toLeft(x)
    return x + screen.offsetPoint().x
end

-- 上锚点的距离不变
function screen.toTop(y)
    return screen.size().height - (screen._height - y) + screen.offsetPoint().y
end

-- 下锚点的距离不变
function screen.toButtom(y)
    return y + screen.offsetPoint().y
end

function screen.toPercentX(x)
    return screen.size().width * x / screen._width + screen.offsetPoint().x
end

function screen.toPercentY(y)
    return screen.size().height * y / screen._height + screen.offsetPoint().y
end

CC_DESIGN_RESOLUTION = {
    width = 1136,
    height = 640,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio < 1136 / 640  then
            return { autoscale = "FIXED_WIDTH" }
        end
    end,
}
CC_DESIGN_RESOLUTION.screen = screen.init(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
