open Config

module Authentication = struct
  let __sessions = ref (ref [])

  let get_sessions =
    !__sessions

  let set_sessions vals =
    get_sessions := vals

  let put_session sess =
    get_sessions := sess :: !get_sessions

  let add_new_session () =
    let sess = Uuidm.v `V4 in
    put_session sess;
    Uuidm.to_string sess

  let correct_password =
    String.equal Config.authentication_password

  let correct_username =
    String.equal Config.authentication_username

  let check username password =
    correct_username username && correct_password password

  let session_is_logged_in sess =
    List.exists (Uuidm.equal sess) !get_sessions

  let session_remove sess =
    let new_sessions = List.filter (fun s -> s |> Uuidm.equal sess |> not) !get_sessions in
    let old_sessions = !get_sessions in
    set_sessions new_sessions;
    List.length new_sessions != List.length old_sessions

  (* XXX: This is simply for debugging purposes, and should be disabled in production - currently NOT ENABLED as an endpoint *)
  let get_sessions _body =
    Lwt.return (`OK, String.concat " " (List.map Uuidm.to_string !get_sessions))

  let is_logged_in body =
    Lwt.return (match Uuidm.of_string body with
        | Some sess -> if session_is_logged_in sess then (`OK, "You are logged in") else (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT A VALID UUID"))

  let logout body =
    Lwt.return (match Uuidm.of_string body with
        | Some sess -> if session_remove sess then (`OK, "You are successfully logged out") else (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT A VALID UUID"))

  let login body =
    let login_data_list_nth = String.split_on_char ';' body |> List.nth in
    let username = login_data_list_nth 0 in
    let password = login_data_list_nth 1 in
    if check username password then
      Lwt.return (`OK, add_new_session ())
    else
      Lwt.return (`Not_found, "Wrong login_info")
end
