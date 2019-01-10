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

--user auth check function
function auth_user(username, password)
	local rds = connect_redis()
	if not rds then
		ngx.say("connect redis error.")
		ngx.exit(ngx.HTTP_BAD_REQUEST)
	end
	local ok, err = rds:hget('userinfo', username)
	if ok and ok ~= ngx.null then
		local pass = ok or ""
		if pass ~= "" and password == pass then
			--ngx.say("username: " .. username .. ", password: " .. pass)
			return true
		else
			ngx.log(ngx.STDERR, "password is not correct! ")
			return false
		end
	else
		ngx.log(ngx.STDERR, "username is not existed! ")
		return false
	end
	close_redis(rds)
end
--auth_user("user5","123456")

--save token to redis
function save_token(token, username)
	--ngx.say("I'm the save_token function!")
	local rds = connect_redis()
	if not rds then
		ngx.say("connect redis error.")
		return
	end
	local ok, err = rds:set(token, username)
	if not ok then
		ngx.log(ngx.STDERR, "failed to set token: " .. err)
	end
	--add expire time 600s
	rds:expire(token, "600")
	ngx.say("save token result: " .. ok)
	close_redis(rds)
end

--generate guid
function guid()
	local seed={'e','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
	local tb={}
	for i=1,32 do
		table.insert(tb,seed[math.random(1,16)])
	end
	local sid=table.concat(tb)
	return string.format('%s-%s-%s-%s-%s',
			string.sub(sid,1,8),
			string.sub(sid,9,12),
			string.sub(sid,13,16),
			string.sub(sid,17,20),
			string.sub(sid,21,32)
	)
end

--create token api
local cjson = require "cjson.safe"
if ngx.var.request_method == "GET" then
	ngx.exit(ngx.HTTP_FORBIDDEN);
end
if ngx.var.request_method == "POST" then
	ngx.req.read_body()
	local bodydata = cjson.decode(ngx.req.get_body_data())
	local username = bodydata["username"]
	local password = bodydata["password"]
	if username ~= ngx.null and password ~= ngx.null then
		--ngx.say("post param username:", username)
		--ngx.say("post param password:", password)
		local auth = auth_user(username, password)
		if not auth then
			ngx.say("用户名或密码错误！")
			ngx.exit(ngx.HTTP_BAD_REQUEST);
		else
			local timestamp = ngx.now()
			local token = guid() .. ngx.md5(timestamp)
			--ngx.say("generated token is : " .. token)
			ngx.header.AuthToken = token

			save_token(token, username)
			ngx.exit(ngx.HTTP_CREATED);
		end
	end
end

