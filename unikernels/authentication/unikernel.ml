open Lwt
open Cohttp
open Cohttp_mirage
open Authentication
open Common

module Authentication_service (R: Mirage_types_lwt.RANDOM) (CON: Conduit_mirage.S) = struct
  module H = Cohttp_mirage.Server(Conduit_mirage.Flow)

  let generate_router routes key =
    List.assoc_opt key routes

  let routes = [
    (("/login", `POST), Authentication.login);
    (("/logout", `POST), Authentication.logout);
    (("/capabilities", `POST), Authentication.capabilities);
    (("/is_logged_in", `POST), Authentication.is_logged_in);
  ]

  let handle uri meth _ body =
    let router = generate_router routes in
    let endpoint_handler = router (uri, meth) in
    match endpoint_handler with
    | Some fn -> fn body >>= fun (s, b) -> H.respond_string ~status: s ~body: b ()
    | None -> H.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

  let start _r conduit _nc =
    let callback _conn req body =
      let uri = req |> Request.uri |> Uri.path in
      let meth = req |> Request.meth in
      let headers = req |> Request.headers |> Header.to_string in
      body |> Cohttp_lwt.Body.to_string >>= fun body ->
      handle uri meth headers body
    in
    let spec = H.make ~callback () in
    CON.listen conduit (`TCP Common.authentication_port) (H.listen spec)
end
