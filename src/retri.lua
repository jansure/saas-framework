local shell = require "resty.shell"

-- 生成一个随机标识，用于修改进程名称
--local param_c = " -c 12345"
local param_n = " -n wwwww"

local args = {
        socket = "unix:/tmp/shell.sock",  --这是第一步的unxi socket
        data = param_n .. " & \r\n",
}

local status, out, err = shell.execute("/root/exetest/retri", args)  --ls 是想调用的命令,
ngx.header.content_type = "text/plain; charset=utf-8"
if nil == out then
    ngx.say("Result:\n" .. status .. "\n" .. err)                    -- 命令输出结果
    if "timeout" == err then
        ngx.say("process name :\n" .. param_n)
    end
else
    ngx.say("Result:\n" .. out)                    -- 命令输出结果
end
