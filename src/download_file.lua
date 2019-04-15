local multipart = require ("multipart")
local file_name

-- 读取form参数
local multipart_data = multipart()
local local_args = multipart_data:get()
for k, v in pairs(local_args) do
    ngx.log(ngx.ERR, "------local_args k:", k)
    ngx.log(ngx.ERR, "------local_args v:", v)
end
file_name = local_args["filename"]
if nil == file_name then
    ngx.say("filename参数不能为空！\n")
end

ngx.header.content_type = "text/plain; charset=utf-8"
--- 以只读方式打开文件
--local f = assert(io.open(file_name, 'r'), "该文件不存在！")
local f = io.open(file_name, 'r')
if nil == f then
    ngx.print("该文件不存在！")
else
    --- 从当前位置读取整个文件
    local file_data = f:read("*a")
    --- 关闭打开的文件
    f:close()
    ngx.print(file_data)
end