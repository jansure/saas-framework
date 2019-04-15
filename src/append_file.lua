local shell = require ("resty.shell")
local multipart = require ("multipart")
local guid = require ("guid")

local cmd
local param
--cmd = "python /root/appendFile/appendFile.py"

-- 读取form参数
local multipart_data = multipart()
local local_args = multipart_data:get()
for k, v in pairs(local_args) do
	ngx.log(ngx.ERR, "------local_args k:", k)
	ngx.log(ngx.ERR, "------local_args v:", v)
end

cmd = local_args["cmd_path"]
param = local_args["cmd_param"]

if nil == param then
	ngx.say("cmd_param参数不能为空！\n")
end

-- 生成一个随机标识，用于修改进程名称
local param_n = guid.generate()
--local param_c = " -c 12345"
--local param_n = " -n wwwww"
local args = {
	socket = "unix:/tmp/shell.sock",  --这是第一步的unxi socket
	--data = param .. param_c .. param_n .. " & " .. "\r\n",
	data = param .. " -n " .. param_n .. " & " .. "\r\n",
}

if nil ~= cmd then
	local status, out, err = shell.execute(cmd, args)
	ngx.header.content_type = "text/plain; charset=utf-8"
	if nil == out then
		ngx.say("Result:\n" .. status .. "\n" .. err)                    -- 命令输出结果
		if "timeout" == err then
			ngx.say("process name : appendFile" .. param_n)
		end
	else
		ngx.say("Result:\n" .. out)                    -- 命令输出结果
	end
else
	ngx.say("cmd_path参数不能为空！\n")
end
