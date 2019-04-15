--- 查询进程状态，是否存在进程名
local shell = require "resty.shell"
local argsUtil = require('argsUtil')
local cmd
local param
-- 查询进程且不显示当前grep进程
--cmd = "ps -ef |grep -v grep |grep "
-- "-C"必须提供精确的进程名，并且它并不能通过部分名字或者通配符查找
cmd = "ps -C "

-- 读取get请求参数
local local_args = ngx.req.get_uri_args()

param = local_args["name"]

if nil == param then
	ngx.say("name参数不能为空！\n")
end

local args = {
	socket = "unix:/tmp/shell.sock",  --这是第一步的unxi socket
	data = param .. "\r\n",
}

local status, out, err = shell.execute(cmd, args)
ngx.header.content_type = "text/plain; charset=utf-8"
--ngx.say("process shell status:\n" .. status)

if nil == out then
	ngx.say("Result:\n" .. status)                    -- 命令输出结果
	if err then
		ngx.say("\n" .. "err:\n"  .. err)
	end
else
	if 256 == status then
		ngx.say("Result: 此进程不存在\n")
	end
	ngx.say("Result:\n" .. out)                    -- 命令输出结果
end
