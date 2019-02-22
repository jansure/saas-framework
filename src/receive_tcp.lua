local tcpsock = ngx.socket.tcp()

--- connect;send;read timeout
tcpsock:settimeouts(6000, 6000000, 6000000)

---建立tcp连接
local host = "192.168.0.5"
local port = 1688
local ok, err = tcpsock:connect(host, port)
if not ok then
    ngx.log(ngx.ERR, "failed to connect tcp server:", err)
    return
end

while not ngx.worker.exiting() do
    repeat
        --接收数据
        local line, err, partial = tcpsock:receive(8192)
        line = line or partial

        --timeout则继续接收数据
        if (not line) and (err ~= 'timeout') then
            ngx.log(ngx.ERR, 'receive error:', err)
            return
        end
        if not line then
            ngx.log(ngx.ERR, 'line is nil.')
            break
        end

        ngx.print(line)
        ngx.flush(true)

    until true

end