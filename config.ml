module Config = struct
  let protocol = "http"
  let domain = "dev"

  let front_port = 8000
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain front_port endpoint)
  let sess_cookie_key = "x-session-id"

  let authentication_port = 8001
  let authentication_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain authentication_port endpoint)

  let inventory_port = 8002
  let inventory_min = 0
  let inventory_max = 100
  let inventory_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain inventory_port endpoint)
end
