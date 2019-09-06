local ns = namespace("kod.util")
local daySeconds = 24 * 3600
ns.Time = {}

function ns.Time.now()
    return require("socket").gettime();
end

--当前时间戳秒
function ns.Time.nowSeconds()
    return ns.Time.now()
end

--当前时间戳毫秒
function ns.Time.nowMilliseconds()
    return ns.Time.now() * 1000
end

-- 获取格式化后的时间
function ns.Time.time2Date(time)
	local date = os.date("*t", time)
    return date;
end

--获取年月日，时分秒
function ns.Time.getTime()
	local t =  ns.Time.now()
	local date= os.date("*t",t)
	return os.date("*t",t)
end
--获取下一天
function ns.Time.getNextDay()
	local t = ns.Time.now() + daySeconds
	return os.date("*t",t)
end
--获取下个月1号
function ns.Time.getNextMonth()
	local t = ns.Time.getTime()
	t.day = 1
	t.month = t.month == 12 and 1 or (t.month+1)
	t.year = t.month==1 and (t.year+1) or t.year
	return t
end

--返回日期
function ns.Time.date(time)
    time = time or kod.util.Time.now()
	local date = os.date("*t", time)
	date.wday = date.wday - 1 -- os。date返回的weekday以周日为计算基点，需修正
    return date
end

--按特定结构返回日期
function ns.Time.dateWithFormat(format, time)
	format = format or "%Y-%m-%d %H: %M"
	time = time or ns.Time.now()
	return os.date(format, time)
end

--是否是闰年
function ns.Time.isLeapYear(year)
  return year%4==0 and (year%100~=0 or year%400==0)
end

--获取月份有多少天
function ns.Time.getMonthDayNum(year, month)
	return month == 2 and (ns.Time.isLeapYear(year) and 29 or 28) or ((month == 4 or month == 6 or month == 9 or month == 11) and 30 or 31)
end

--判断是否是今天
function ns.Time.isAnotherDay(time)
	local t1 = ns.Time.date(time)
	local t2 = ns.Time.getTime()
	if t1.year == t2.year and t1.month == t2.month and t1.day == t2.day then
		return false
	end
	return true
end

function ns.Time.convertToDate(timeMS)
    local ret = {
        hour = 0,
        minute = 0,
        second = 0,
        milisec = 0,
    }
    if timeMS > 0 then
        ret.hour = math.floor(timeMS / 3600000)
        ret.minute = math.floor(timeMS / 60000) % 60
        ret.second = math.floor(timeMS / 1000) - ret.hour * 3600 - 60 * ret.minute
        ret.milisec = math.floor((timeMS % 1000) / 10)
    end
    return ret
end