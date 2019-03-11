--
-- Created by IntelliJ IDEA.
-- User: pkpm
-- Date: 2019/3/11
-- Time: 14:30
-- To change this template use File | Settings | File Templates.
--

ngx.header["Access-Control-Allow-Origin"] = "*"
ngx.header["Access-Control-Allow-Headers"] = "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range,AuthToken"
ngx.header["Access-Control-Allow-Credentials"] = "true"
if ngx.var.request_method == "OPTIONS" then
    ngx.header["Access-Control-Max-Age"] = "1728000000000"
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, DELETE"
    ngx.header["Content-Length"] = "0"
    ngx.header["Content-Type"] = "application/json, charset=utf-8"
end