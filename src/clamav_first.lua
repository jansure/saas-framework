-- 功能：如果请求体中不包含文件，则直接发送tcp数据流；
-- 如果请求体中包含文件，则先将文件发送到杀毒服务器，如果没有病毒，仅将文件流发送到tcp服务器

local vdata = {}
local cjson = require("cjson.safe")
cjson.encode_keep_buffer = 0
local unicode = require("unicode")
local utf8 = require('lua-utf8')
local stringext = require('stringext')
local http = require("resty.http")
local argsUtil = require('argsUtil')
local inspect = require ("inspect")
local curl = require("lcurl")

-- 读取form参数
local local_args = {}
local local_is_have_file_param
local local_file_args  = {}
local local_body_data
local_args, local_is_have_file_param, local_file_args, local_body_data = argsUtil.init_form_args()
for k, v in pairs(local_args) do
    ngx.log(ngx.ERR, "------local_args k:", k)
    ngx.log(ngx.ERR, "------local_args v:", v)
end
ngx.log(ngx.ERR, "------local_is_have_file_param:", local_is_have_file_param)
for k, v in pairs(local_file_args) do
    ngx.log(ngx.ERR, "------local_file_args k:", k)
    ngx.log(ngx.ERR, "------local_file_args v:", v)
end

-- 建立tcp连接
local tcpsock = ngx.socket.tcp()
local host = "49.4.8.123"
local port = 1688
local ok, err = tcpsock:connect(host, port)
if not ok then
    ngx.log(ngx.ERR, "failed to connect tcp server:", err)
    return
end
--- 3000 seconds timeout
tcpsock:settimeouts(30000, 30000, 30000)

local bytes
local reqdata
local reqdatalist = {}
local reqdatalistlen

-- 若不存在文件参数
if local_is_have_file_param == false then
    reqdata = "{"
    --local args_tab = ngx.req.get_uri_args()
    --- 拼接实际请求参数
    for k, v in pairs(local_args) do
        --ngx.log(ngx.ERR, "------k:", k)
        -- 使用utf8编码
        v = utf8.escape(v)
        --ngx.log(ngx.ERR, "------v:", v)
        reqdata = reqdata .. (string.format("\"%s\"", k)) .. ":" .. v .. ","
    end
    reqdata = string.sub(reqdata, 0, string.len(reqdata) - 1) .. "}"
    --ngx.log(ngx.ERR, "-----reqdata:", reqdata)
    -- 将带发送的字符串拆分成单个字符的数组
    reqdatalist, reqdatalistlen = stringext.stringToChars(reqdata)
    -- 遍历字符数组，将中文字符替换为其unicode编码值
    for i = 1, reqdatalistlen do
        if (stringext.isCJKCode(reqdatalist[i])) then
            reqdatalist[i] = unicode.encode(reqdatalist[i])
            --ngx.log(ngx.ERR, "-----reqdatalist----:", reqdatalist[i])
        end
    end
    -- 将字符数组转为字符串
    reqdata = table.concat(reqdatalist)
    --ngx.log(ngx.ERR, "-----reqdata table.concat(reqdatalist)----:", reqdata)

    -- 发送请求数据
    bytes, err = tcpsock:send(reqdata .. "\r\n\r\n")
    if err then
        ngx.log(ngx.ERR, "failed to send request data to tcp server:", err)
        return
    end
    ngx.log(ngx.ERR, "successfully send request data to tcp server:", bytes)
else
    -- 若存在文件参数，先转发到杀毒服务器
    local httpc = http:new()
    local inpath = "/scan/file?name=test"
    local host = "http://192.168.1.159:8866"
    local bodydata = local_body_data
    print(bodydata)
    local inheaders = ngx.req.get_headers()
    print(inspect(inheaders))
    local inmethod = "POST"
    local res, err = httpc:request_uri(
        host,
        {
            path = inpath,
            method = inmethod,
            headers = inheaders,
            body = bodydata
        }
    )
    print(inspect(res))
    -- 若有病毒，记录访问次数
    if res.status ~= ngx.HTTP_OK then
        local token = ngx.var.remote_addr .. ngx.var.uri
        local clamavlimit = ngx.shared.clamavlimit
        local req, _ = clamavlimit:get(token)
        if req then
            -- token存在，则计数+1
            clamavlimit:incr(token, 1)
        else
            -- 否则，新增记录，有效期为60s
            clamavlimit:set(token, 1, 60)
        end
        ngx.exit(res.status)
        ngx.say(res.body)
        return
    else
        -- 若无病毒，发送文件流到服务器
        bytes, err = tcpsock:send(bodydata)
        if err then
            ngx.log(ngx.ERR, "failed to send bodydata to tcp server:", err)
            return
        end
        ngx.log(ngx.ERR, "successfully send bodydata to tcp server:", bytes)
    end
end
