module Config = struct
  let account_username = "admin"
  let account_password = "password"
  let account_port = 8001

  let front_port = 8000
  let protocol = "http"
  let domain = "dev"
  let account_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain account_port endpoint)
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain front_port endpoint)

  let sess_cookie_key = "x-session-id"
end
