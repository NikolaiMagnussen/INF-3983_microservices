module Inventory = struct

  module InventoryMap = Map.Make(String)
  let inventory_create =
    InventoryMap.empty |> InventoryMap.add "kake" (1, 100) |> InventoryMap.add "torsk" (2, 100) |> InventoryMap.add "hest" (3, 100)

  let _inventory = ref inventory_create

  let add_new k v =
    _inventory := InventoryMap.add k v !_inventory

  let list_inventory _b =
    Lwt.return (`OK, String.concat " " (List.map (fun (x, _y) -> x) (InventoryMap.bindings !_inventory)))

  let list_item key =
    match InventoryMap.find_opt key !_inventory with
    | Some (id, quant) -> Lwt.return (`OK, Printf.sprintf "Item %s has id %d and %d remains in the inventory" key id quant)
    | None -> Lwt.return (`Not_found, key ^ " is not a item we keep in store")

  let buy_item key =
    _inventory := (match InventoryMap.find_opt key !_inventory with
        | Some (id, quant) -> InventoryMap.add key (id, quant-1) !_inventory
        | None -> !_inventory);
    Lwt.return (`OK, "You bought 1 " ^ key)

  let sell_item key =
    _inventory := (match InventoryMap.find_opt key !_inventory with
        | Some (id, quant) -> InventoryMap.add key (id, quant+1) !_inventory
        | None -> !_inventory);
    Lwt.return (`OK, "You just sold 1 " ^ key)
end
