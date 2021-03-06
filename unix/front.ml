open Lwt
open Cohttp
open Cohttp_lwt_unix
open Handlers
open Config


let generate_router routes key =
  List.assoc_opt key routes

let routes = [
  (("/", `POST), Handlers.index_post);
  (("/", `GET), Handlers.index_get);
  (("/login", `POST), Handlers.login);
  (("/logout", `GET), Handlers.logout);
  (("/secret", `GET), Handlers.secret);
  (("/inventory/list", `GET), Handlers.inventory_list);
  (("/inventory/list", `POST), Handlers.inventory_list_item);
  (("/inventory/sell", `POST), Handlers.inventory_sell);
  (("/inventory/buy", `POST), Handlers.inventory_buy);
]

let handle uri meth headers body =
  let router = generate_router routes in
  let endpoint_handler = router (uri, meth) in
  let h = Header.init () in
  match endpoint_handler with
  | Some fn -> fn body headers >>= fun (s, b, c) ->
    let headers = Header.add_list h c in
    Server.respond_string ~headers ~status: s ~body: b ()
  | None -> Cohttp_lwt.Body.to_string body >>= fun body ->
    Server.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

let get_port =
  try int_of_string Sys.argv.(1)
  with Invalid_argument _ -> Config.front_port

let server =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.path in
    let meth = Request.meth req in
    let headers = Request.headers req in
    handle uri meth headers body
  in
  Server.create ~mode:(`TCP (`Port get_port)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)

