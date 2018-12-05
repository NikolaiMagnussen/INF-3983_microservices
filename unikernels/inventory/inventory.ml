open Lwt
open Common
open Cohttp
open Cohttp_mirage

module Inventory = struct

  module InventoryMap = Map.Make(String)
  let inventory_create =
    InventoryMap.empty |> InventoryMap.add "kake" (1, 100) |> InventoryMap.add "torsk" (2, 100) |> InventoryMap.add "hest" (3, 100)

  let _inventory = ref inventory_create

  let inventory_add key quant =
    let (id, old_quant) = InventoryMap.find key !_inventory in
    let new_quant = old_quant + quant in
    if new_quant < Common.inventory_min || new_quant > Common.inventory_max then
      false
    else
      let new_inventory = InventoryMap.add key (id, new_quant) !_inventory in
      _inventory := new_inventory;
      true

  let inventory_sub key quant =
    inventory_add key (-quant)

  let extract_session h =
    let key_cmp (k, _v) = String.equal Common.sess_cookie_key k in
    let opt_sess = h |> Cookie.Cookie_hdr.extract |> List.find_opt key_cmp in
    match opt_sess with
    | Some (_k, v) -> v
    | None -> ""

  let is_logged_in h =
    let uri = Common.authentication_uri "is_logged_in" in
    let sess = extract_session h in
    Client.post ~body: (Cohttp_lwt.Body.of_string sess) uri >>= fun (resp, _body) ->
    Lwt.return (Response.status resp == `OK)

  let capabilities h =
    let uri = Common.authentication_uri "capabilities" in
    let sess = h |> extract_session |> Cohttp_lwt.Body.of_string in
    Client.post ~body: sess uri >>= fun (resp, body) ->
    match Response.status resp with
    | `OK ->
      Cohttp_lwt.Body.to_string body >>= fun body ->
      Lwt.return (Some (Capability_j.capability_of_string body))
    | _ -> Lwt.return None

  let list_inventory _b h =
    capabilities h >>= fun capabilities ->
    match capabilities with
    | None -> Lwt.return (`Not_found, "You are not logged in")
    | Some _ -> Lwt.return (`OK, String.concat "\n" (List.map (fun (x, _y) -> x) (InventoryMap.bindings !_inventory)))

  let list_item key h =
    capabilities h >>= fun capabilities ->
    match capabilities with
    | None -> Lwt.return (`Not_found, "You are not logged in")
    | Some _ ->
      match InventoryMap.find_opt key !_inventory with
      | Some (id, quant) -> Lwt.return (`OK, Printf.sprintf "Item %s has id %d and %d remains in the inventory" key id quant)
      | None -> Lwt.return (`Not_found, key ^ " is not an item we keep in store")

  let buy_item key h =
    capabilities h >>= fun capabilities ->
    match capabilities with
    | None -> Lwt.return (`Not_found, "You are not logged in")
    | Some `None -> Lwt.return (`Not_found, "You do not have permission to buy")
    | Some c ->
      if InventoryMap.mem key !_inventory then
        if inventory_sub key 1 then
          Lwt.return (`OK, (Capability_j.string_of_capability c) ^ " bought 1 " ^ key)
        else
          Lwt.return (`Not_found, (Capability_j.string_of_capability c) ^ " can't buy 1 " ^ key ^ " - not enough in stock")
      else
        Lwt.return (`Not_found, key ^ " is not an itme we keep in store")

  let sell_item key h =
    capabilities h >>= fun capabilities ->
    match capabilities with
    | None -> Lwt.return (`Not_found, "You are not logged in")
    | Some `None | Some `User _ -> Lwt.return (`Not_found, "You do not have permission to sell")
    | Some (`Admin _ as c) ->
      if InventoryMap.mem key !_inventory then
        if inventory_add key 1 then
          Lwt.return (`OK, (Capability_j.string_of_capability c) ^ " sold 1 " ^ key)
        else
          Lwt.return (`Not_found, (Capability_j.string_of_capability c) ^ " can't sell 1 " ^ key ^ " - too many in stock")
      else
        Lwt.return (`Not_found, key ^ " is not an itme we keep in store")
end
