open Capability_t
open Common

module Authentication = struct
  module SessionMap = Map.Make(Uuidm)
  module AccountMap = Map.Make(String)

  type account = { username : string; hash : Digestif.BLAKE2B.t; salt : string; capabilities : capability }

  let blake_digest str salt =
    let to_digest = str ^ ":" ^ salt in
    Digestif.BLAKE2B.digest_string to_digest

  let check_password password salt hash =
    let digest = blake_digest password salt in
    Digestif.BLAKE2B.eq digest  hash

  let account_create username password salt capabilities =
    let digest = blake_digest password salt in
    {username=username; hash=digest; salt=salt; capabilities=capabilities}

  let _sessions_create = SessionMap.empty
  let _accounts_create =
    let accounts = List.map (fun (u, p, s, c) -> (u, account_create u p s c)) Common.authentication_default_users in
    let add_to_accounts map data =
      let name, user = data in
      AccountMap.add name user map in
    List.fold_left add_to_accounts AccountMap.empty accounts

  let _sessions = ref _sessions_create
  let _accounts = ref _accounts_create

  let check username password =
    let password = String.trim password in
    match AccountMap.find_opt username !_accounts with
    | Some account -> check_password password account.salt account.hash
    | None -> false

  let account_capabilities username =
    match AccountMap.find_opt username !_accounts with
    | Some acc -> acc.capabilities
    | None -> `None

  let add_session sess username =
    _sessions := SessionMap.add sess username !_sessions

  let add_new_session username =
    let sess = Uuidm.v `V4 in
    add_session sess username;
    Uuidm.to_string sess

  let session_is_logged_in sess =
    SessionMap.mem sess !_sessions

  let session_remove sess =
    let old_size = SessionMap.cardinal !_sessions in
    _sessions := SessionMap.remove sess !_sessions;
    old_size <> SessionMap.cardinal !_sessions

  let get_capabilities sess =
    match SessionMap.find_opt sess !_sessions with
    | Some username -> account_capabilities username
    | None -> `None

  let safe_B64_decode s =
    try Some (B64.decode s)
    with Not_found -> None

  (* XXX: This is simply for debugging purposes, and should be disabled in production - currently NOT ENABLED as an endpoint *)
  let get_sessions _body =
    Lwt.return (`OK, String.concat "\n" (List.map (fun (uuid, user) -> "uuid: " ^ Uuidm.to_string uuid ^ " -> " ^ user) (SessionMap.bindings !_sessions)))

  (* XXX: This is simply for debugging purposes, and should be disabled in production - currently NOT ENABLED as an endpoint *)
  let get_accounts _body =
    Lwt.return (`OK, String.concat "\n" (List.map (fun (x, y) -> "username: " ^ x ^ " hash: " ^ (Digestif.BLAKE2B.to_hex y.hash) ^ " salt: " ^ y.salt) (AccountMap.bindings !_accounts)))

  let is_logged_in body =
    Lwt.return (match Uuidm.of_string body with
        | Some sess -> if session_is_logged_in sess then (`OK, "You are logged in") else (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT A VALID UUID"))

  let logout body =
    Lwt.return (match Uuidm.of_string body with
        | Some sess -> if session_remove sess then (`OK, "You are successfully logged out") else (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT A VALID UUID"))

  let login body =
    match safe_B64_decode body with
    | Some decoded ->
      let cred_list = String.split_on_char ':' decoded in
      if List.length cred_list = 2 then
        let username = List.nth cred_list 0 in
        let password = List.nth cred_list 1 in
        if check username password then
          Lwt.return (`OK, add_new_session username)
        else
          Lwt.return (`Not_found, "Wrong login info")
      else
        Lwt.return (`Not_found, "Not enough info")
    | None -> Lwt.return (`Not_found, "Could not B64 decode")

  let capabilities body =
    Lwt.return (match Uuidm.of_string body with
        | Some sess -> if session_is_logged_in sess then
            (`OK, (Capability_j.string_of_capability (get_capabilities sess)))
          else
            (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT A VALID UUID"))
end
