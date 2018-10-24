module Config = struct
  let account_username = "admin"
  let account_password = "password"
  let account_port = 8001

  let front_port = 8000
  let domain = "http://localhost"
  let account_uri endpoint = Uri.of_string (Printf.sprintf "%s:%d/%s" domain account_port endpoint)
  let front_uri endpoint = Uri.of_string (Printf.sprintf "%s:%d/%s" domain front_port endpoint)
end
