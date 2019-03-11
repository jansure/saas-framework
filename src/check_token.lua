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
        host = "192.168.0.5",
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

--check token api
--if ngx.var.request_method ~= "GET" then
--    ngx.exit(ngx.HTTP_FORBIDDEN)
--end
local args = ngx.req.get_headers()
local token_input = args["AuthToken"]
ngx.log(ngx.STDERR, "AuthToken: " .. (token_input or "nil"))
if not token_input then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("{\"response\":\"Only Authorized Request Will be Processed!\"}")
    ngx.exit(ngx.HTTP_FORBIDDEN)
end
local rds = connect_redis()
if not rds then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("{\"response\":\"connect redis error.\"}")
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
local ok, err = rds:exists(token_input)
if ok == 1 then
    ngx.status = ngx.HTTP_OK
    ngx.say("{\"response\":\"token exists!\"}")
    ngx.exit(ngx.HTTP_OK)
else
    ngx.status = ngx.HTTP_OK
    ngx.say("{\"response\":\"token not exists!\"}")
    ngx.exit(ngx.HTTP_OK)
end
close_redis(rds)