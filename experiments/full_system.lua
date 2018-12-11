path = "/login"
req_body = "dXNlcjpwYXNzd29yZDEyMwo="
token = nil

request = function()
        return wrk.format("POST", path, wrk.headers, req_body)
end

response = function(status, headers, body)
        if not token and status == 200 then
                token = headers["set-cookie"]
                path = "/inventory/list"
                req_body = "hest"
                wrk.headers["cookie"] = token
        end
end
