local _M = {}

function _M.split(self, s, delim)

    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return nil
    end

    local start = 1
    local t = {}

    while true do
        local pos = string.find(s, delim, start, true) -- plain find

        if not pos then
            break
        end

        table.insert(t, string.sub(s, start, pos - 1))
        start = pos + string.len(delim)
    end

    table.insert(t, string.sub(s, start))

    return t
end

function _M.get_post_form_data(self, form, err)

    if not form then
        ngx.log(ngx.ERR, "failed to new upload: ", err)
        return {}
    end

    form:set_timeout(1000) -- 1 sec
    local paramTable = { ["s"] = 1 }
    local tempkey = ""
    while true do
        local typ, res, err = form:read()
        if not typ then
            ngx.log(ngx.ERR, "failed to read: ", err)
            return {}
        end
        local key = ""
        local value = ""
        if typ == "header" then
            local key_res = _M.split(res[2], ";")
            key_res = key_res[2]
            key_res = _M.split(key_res, "=")
            key = (string.gsub(key_res[2], "\"", ""))
            paramTable[key] = ""
            tempkey = key
        end
        if typ == "body" then
            value = res
            if paramTable.s ~= nil then
                paramTable.s = nil
            end
            paramTable[tempkey] = value
        end
        if typ == "eof" then
            break
        end
    end
    return paramTable
end

return _M