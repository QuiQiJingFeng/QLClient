
local GB2260 = class("GB2260")
local CONTENT = ""
function GB2260:ctor()
    self._url = "http://www.mca.gov.cn/article/sj/xzqh/2019/2019/201911250933.html"
end
--（1）前1、2位数字表示：所在省份的代码；（2）第3、4位数字表示：所在城市的代码；（3）第5、6位数字表示：所在区县的代码；
--第7~14位数字表示：出生年、月、日；
--15,16，17 顺序码  《表示在同一地址码所标识的区域范围内，对同年、同月、同日出生的人编定的顺序号，顺序码的奇数分配给男性，偶数分配给女性》
--第17位数字表示性别：奇数表示男性，偶数表示女性
--
function GB2260:getData()
    kod.util.Http.sendRequest(self._url,{}, function(response, readyState, status)
        if status == 200 then
            local data = response
            self:parseData(data)
        else
            error("status = "..tostring(status))
        end
    end, "GET")
end

function GB2260:parseData(data)
    data = string.gmatch(data,"<body>(.*)</body>")()
    data = string.gmatch(data,"<table.-</table>","")()
    data = string.gsub(data,"<.->","")
    data = string.gsub(data," ","")
    for i = 1, 10 do
        data = string.gsub(data,"\n\n","\n")
    end
    data = string.gsub(data,"\n",",")
    local datas = string.split(data,",")
    local file
    for i, item in ipairs(datas) do
        if item ~= "" then
            if string.find(item,"注：") then
                file:write("\n}\n\nreturn _M")
                file:close()
                break
            end
            if i == 1 then
                file = io.open("GB2260.lua","wb+")
                file:write("local _M = {\n")
            else
                if i %2 == 0 then
                    local content = item
                    if i ~= 2 then
                        content = "\n[".. content .."] = '"
                    else
                        content = "--" .. content
                    end
                    file:write(content)
                else
                    file:write(item.."',")
                end
            end
        end
    end
end

return GB2260