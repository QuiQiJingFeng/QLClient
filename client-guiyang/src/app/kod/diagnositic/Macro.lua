----------------------------
-- 日志监听器接口, 如果要获取日志输出, 实现本接口, 并注册到LoggerManager中
----------------------------
cc.exports.Macro = class("Macro")

-- 不应该是true, 如果是true就报错
function Macro.assetTrue(tf, ...)
	Logger.assert(not tf, ...);
	return tf;
end

-- 不应该是false，如果是false报错
function Macro.assetFalse(tf, ...)
	Logger.assert(tf, ...);
	return tf;
end

-- 上面的函数写错了防止大范围修改, 先不移除

-- 不应该是true, 如果是true就报错
function Macro.assertTrue(tf, ...)
	Logger.assert(not tf, ...);
	return tf;
end

-- 不应该是false，如果是false报错
function Macro.assertFalse(tf, ...)
	Logger.assert(tf, ...);
	return tf;
end