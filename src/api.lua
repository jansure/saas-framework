--connect redis
function connect_redis()
    local redis = require "resty.redis"
    local client, errmsg = redis:new()
    if not client then
        ngx.log(ngx.STDERR, "get redis failed: " .. (errmsg or "nil"))
        return
    end
    client:set_timeout(3000)

    local redis_info = {
        host = "49.4.8.123",
        port = 26379,
        db = 0,
        password = "kongbaoping@cabrtech"
    }
    local result, errmsg = client:connect(redis_info["host"], redis_info["port"])
    if not result then
        ngx.log(ngx.STDERR, "connect redis failed: " .. (errmsg or "nil"))
        return
    end
    local ok, errmsg = client:auth(redis_info["password"])
    if not ok then
        ngx.log(ngx.STDERR, "auth redis failed: " .. (errmsg or "nil"))
        return
    end

    return client
end

--close redis
function close_redis(rediscli)
    if rediscli then
        --connection poll timeout and pool size
        rediscli:set_keepalive(0, 10000)
    end
end

--check token
function check_token()
    local args = ngx.req.get_headers()
    local token_input = args["AuthToken"]
    if not token_input then
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("Only Authorized Request Will be Processed!")
        return false
    end
    local rds = connect_redis()
    if not rds then
        ngx.say("connect redis error.")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    local ok, err = rds:exists(token_input)
    if ok == 1 then
        --ngx.say("token exists! " .. ok)
        return true
    else
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("token not exists! ")
        return false
    end
    close_redis(rds)
end

local ok, err = check_token()
--print(ok)
if ok then
    --ngx.redirect("http://49.4.8.123:8083/product/productList")
    --ngx.req.set_uri("/", true)
    --local res = ngx.location.capture('/hello',{method = ngx.HTTP_GET, copy_all_vars = true})
    ngx.req.read_body()
    local bodydata = ngx.req.get_body_data()
    local inheaders = ngx.req.get_headers()
    local inmethod = ngx.var.request_method
    local inpath = ngx.var.request_uri
    local http = require("resty.http")
    local httpc = http:new()
    local res, err = httpc:request_uri("http://49.4.8.123:8083",
        {
            path = inpath,
            method = inmethod,
            headers = inheaders,
            body = bodydata
        })
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end
    ngx.say(res.body)
end