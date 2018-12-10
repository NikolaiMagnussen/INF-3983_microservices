open Lwt
open Cohttp
open Cohttp_mirage
open Common
open Handlers

module Front_service (R : Mirage_types_lwt.RANDOM) (CON : Conduit_mirage.S) = struct
  module S = Cohttp_mirage.Server(Conduit_mirage.Flow)

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

  let handle uri meth headers body conduit =
    let router = generate_router routes in
    let endpoint_handler = router (uri, meth) in
    let h = Header.init () in
    match endpoint_handler with
    | Some fn -> fn body headers conduit >>= fun (s, b, c) ->
      let headers = Header.add_list h c in
      S.respond_string ~headers ~status: s ~body: b ()
    | None -> Cohttp_lwt.Body.to_string body >>= fun body ->
      S.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

  let start _r conduit _nc =
    let callback _conn req body =
      let uri = req |> Request.uri |> Uri.path in
      let meth = Request.meth req in
      let headers = Request.headers req in
      handle uri meth headers body conduit
    in
    let spec = S.make ~callback () in
    CON.listen conduit (`TCP (Key_gen.port())) (S.listen spec)
end
