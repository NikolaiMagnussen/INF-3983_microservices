module Config = struct
  let authentication_username = "admin"
  let authentication_password = "password"
  let authentication_port = 8001

  let front_port = 8000
  let protocol = "http"
  let domain = "dev"
  let authentication_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain authentication_port endpoint)
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain front_port endpoint)

  let sess_cookie_key = "x-session-id"
end
