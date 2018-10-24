open Lwt
open Cohttp
open Cohttp_lwt_unix
open Account
open Config


let generate_router routes key =
  List.assoc_opt key routes

let routes = [
  (("/login", `POST), Account.login);
  (("/logout", `POST), Account.logout);
  (("/is_logged_in", `POST), Account.is_logged_in);
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
  Server.create ~mode:(`TCP (`Port Config.account_port)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)

