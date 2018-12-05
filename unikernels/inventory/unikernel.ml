open Lwt
open Cohttp
open Cohttp_mirage
open Common
open Inventory

module Inventory_service (R: Mirage_types_lwt.RANDOM) (CON: Conduit_mirage.S) = struct
  module H = Cohttp_mirage.Server(Conduit_mirage.Flow)

  let generate_router routes key =
    List.assoc_opt key routes

  let routes = [
    (("/list", `GET), Inventory.list_inventory);
    (("/list", `POST), Inventory.list_item);
    (("/buy", `POST), Inventory.buy_item);
    (("/sell", `POST), Inventory.sell_item);
  ]

  let handle uri meth headers body =
    let router = generate_router routes in
    let endpoint_handler = router (uri, meth) in
    match endpoint_handler with
    | Some fn -> fn body headers >>= fun (s, b) -> H.respond_string ~status: s ~body: b ()
    | None -> H.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

  let start _r conduit _nc =
    let callback _conn req body =
      let uri = req |> Request.uri |> Uri.path in
      let meth = Request.meth req in
      let headers = Request.headers req in
      body |> Cohttp_lwt.Body.to_string >>= fun body ->
      handle uri meth headers body
    in
    let spec = H.make ~callback () in
    CON.listen conduit (`TCP Common.inventory_port) (H.listen spec)
end
