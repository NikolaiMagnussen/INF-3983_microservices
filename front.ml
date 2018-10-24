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
  (("/secret", `POST), Handlers.secret);
]

let handle uri meth _ body =
  let router = generate_router routes in
  let endpoint_handler = router (uri, meth) in
  match endpoint_handler with
  | Some fn -> fn body >>= fun (s, b) -> Server.respond_string ~status: s ~body: b ()
  | None -> Server.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

let server =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.path in
    let meth = req |> Request.meth in
    let headers = req |> Request.headers |> Header.to_string in
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    handle uri meth headers body
  in
  Server.create ~mode:(`TCP (`Port Config.front_port)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)
