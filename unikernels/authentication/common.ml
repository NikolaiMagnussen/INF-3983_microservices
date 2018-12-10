module Common = struct
  let protocol = "http"

  let front_port = 8000
  let front_domain = "front.local"
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol front_domain front_port endpoint)
  let sess_cookie_key = "x-session-id"

  let authentication_port = 8001
  let authentication_domain = "authentication.local"
  let authentication_default_users = [("dummy", "password123", "this_is_salt", `None);
                                      ("user", "password123", "even_more salty", `User 0);
                                      ("admin", "password123", "the salties of all", `Admin 0)]
  let authentication_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol authentication_domain authentication_port endpoint)

  let inventory_min = 0
  let inventory_max = 100
  let inventory_port = 8002
  let inventory_domain = "inventory.local"
  let inventory_uri endpoint = Uri.of_string (Printf.sprintf "%s://%s:%d/%s" protocol inventory_domain inventory_port endpoint)
end
