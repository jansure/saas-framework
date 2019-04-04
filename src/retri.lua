local shell = require "resty.shell"
   local args = {
            socket = "unix:/tmp/shell.sock",  --这是第一步的unxi socket
   }
local status, out, err = shell.execute("/root/exetest/retri", args)  --ls 是想调用的命令,
ngx.header.content_type = "text/plain"
if nil == out then
    ngx.say("Result:\n" .. status .. "\n" .. err)                    -- 命令输出结果
else
    ngx.say("Result:\n" .. out)                    -- 命令输出结果
end
