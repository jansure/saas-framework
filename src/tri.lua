local shell = require "resty.shell"
local argsUtil = require('argsUtil')
local args = {
	socket = "unix:/tmp/shell.sock",  --这是第一步的unxi socket
	data = "15 5\r\n",
}
local cmd = "/root/exetest/tri"

-- 读取form参数
--local local_args = {}
--local local_is_have_file_param
--local local_file_args  = {}
--local local_body_data
--local_args, local_is_have_file_param, local_file_args, local_body_data = argsUtil.init_form_args()
--for k, v in pairs(local_args) do
--	ngx.log(ngx.ERR, "------local_args k:", k)
--	ngx.log(ngx.ERR, "------local_args v:", v)
--end
--ngx.log(ngx.ERR, "------local_is_have_file_param:", local_is_have_file_param)
--for k, v in pairs(local_file_args) do
--	ngx.log(ngx.ERR, "------local_file_args k:", k)
--	ngx.log(ngx.ERR, "------local_file_args v:", v)
--end

local status, out, err = shell.execute(cmd, args)
--local status, out, err = shell.execute("/root/exetest/tri 30", args)
ngx.header.content_type = "text/plain"
ngx.say("Result:\n" .. out)                    -- 命令输出结果

