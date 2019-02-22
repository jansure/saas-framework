ngx.req.read_body()
local bodydata = ngx.req.get_body_data()
local inheaders = ngx.req.get_headers()
local inmethod = ngx.var.request_method
local inpath =string.gsub(ngx.var.request_uri, "data/", "",1)
local host = "http://192.168.1.77:8088"

--local match_res = string.match(inpath, ".htm", 1)
--ngx.log(ngx.ERR, "---match_res---", match_res)
-- 若匹配到html路径
--if match_res then
--    local target = host .. inpath
    --return ngx.redirect(target, ngx.HTTP_MOVED_TEMPORARILY)
--    return ngx.redirect(target, 301)
--else
    local http = require("resty.http")
    local httpc = http:new()
    local res, err = httpc:request_uri(
            host,
            {
                path = inpath,
                method = inmethod,
                headers = inheaders,
                body = bodydata
            }
    )
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end
    ngx.print(res.body)
--end
