module Config = struct
  let protocol = "http"
  let domain = "dev"

  let front_port = 8000
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain front_port endpoint)
  let sess_cookie_key = "x-session-id"

  let authentication_port = 8001
  let authentication_default_users = [("dummy", "password123", "this_is_salt", `None);
                                      ("user", "password123", "even_more salty", `User 0);
                                      ("admin", "password123", "the salties of all", `Admin 0)]
  let authentication_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain authentication_port endpoint)

  let inventory_port = 8002
  let inventory_min = 0
  let inventory_max = 100
  let inventory_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol domain inventory_port endpoint)
end
