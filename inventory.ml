open Lwt
open Config
open Cohttp
open Cohttp_lwt_unix

module Inventory = struct

  module InventoryMap = Map.Make(String)
  let inventory_create =
    InventoryMap.empty |> InventoryMap.add "kake" (1, 100) |> InventoryMap.add "torsk" (2, 100) |> InventoryMap.add "hest" (3, 100)

  let _inventory = ref inventory_create

  let extract_session h =
    let key_cmp (k, _v) = String.equal Config.sess_cookie_key k in
    let opt_sess = h |> Cookie.Cookie_hdr.extract |> List.find_opt key_cmp in
    match opt_sess with
    | Some (_k, v) -> v
    | None -> ""

  let is_logged_in h =
    let uri = Config.authentication_uri "is_logged_in" in
    let sess = extract_session h in
    Client.post ~body: (Cohttp_lwt.Body.of_string sess) uri >>= fun (resp, _body) ->
    Lwt.return (Response.status resp == `OK)

  let add_new k v =
    _inventory := InventoryMap.add k v !_inventory

  let list_inventory _b h =
    is_logged_in h >>= fun logged_in ->
    if logged_in then
      Lwt.return (`OK, String.concat " " (List.map (fun (x, _y) -> x) (InventoryMap.bindings !_inventory)))
    else
      Lwt.return (`Not_found, "You are not logged in")

  let list_item key h =
    is_logged_in h >>= fun logged_in ->
    if logged_in then
      match InventoryMap.find_opt key !_inventory with
      | Some (id, quant) -> Lwt.return (`OK, Printf.sprintf "Item %s has id %d and %d remains in the inventory" key id quant)
      | None -> Lwt.return (`Not_found, key ^ " is not a item we keep in store")
    else
      Lwt.return (`Not_found, "You are not logged in")

  let inventory_add key quant =
    let (id, old_quant) = InventoryMap.find key !_inventory in
    _inventory := InventoryMap.add key (id, old_quant+quant) !_inventory;
    true

  let inventory_sub key quant =
    inventory_add key (-quant)

  let buy_item key h =
    is_logged_in h >>= fun logged_in ->
    if logged_in && InventoryMap.mem key !_inventory then
      if inventory_sub key 1 then
        Lwt.return (`OK, "You bought 1 " ^ key)
      else
        Lwt.return (`Not_found, "You can't buy 1 " ^ key)
    else
      Lwt.return (`Not_found, "You are not logged in")

  let sell_item key h =
    is_logged_in h >>= fun logged_in ->
    if logged_in && InventoryMap.mem key !_inventory then
      if inventory_add key 1 then
        Lwt.return (`OK, "You just sold 1 " ^ key)
      else
        Lwt.return (`Not_found, "You can't sell 1 " ^ key)
    else Lwt.return (`Not_found, "You are not logged in")
end
