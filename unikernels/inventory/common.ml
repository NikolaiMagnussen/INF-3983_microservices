open Conduit

module Common = struct
  let entry (host:string) ip_str =
    let ip = Ipaddr.of_string_exn ip_str in
    host, (fun ~(port:int) -> (`TCP (ip, port) : Conduit.endp))

  let add_entry (host:string) ip_str table =
    let ip = Ipaddr.of_string_exn ip_str in
    Hashtbl.add table host (fun ~(port:int) -> (`TCP (ip, port) : Conduit.endp))

  let route_table =
    let tbl = Hashtbl.create 3 in
    add_entry "front.local" "10.0.0.2" tbl;
    add_entry "authentication.local" "10.0.1.2" tbl;
    add_entry "inventory.local" "10.0.2.2" tbl;
    tbl

  let static_resolver = Resolver_mirage.static route_table
  let ctx conduit = Cohttp_mirage.Client.ctx static_resolver conduit

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
