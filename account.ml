open Config

module Account = struct
  let sessions = ref []

  let add_new_session =
    let sess = Uuidm.v `V4 in
    sessions := sess :: !sessions;
    Uuidm.to_string sess

  let correct_password =
    String.equal Config.account_password

  let correct_username =
    String.equal Config.account_username

  let check username password =
    correct_username username && correct_password password

  let session_is_logged_in sess =
    List.exists (Uuidm.equal sess) !sessions

  let is_logged_in body =
    Lwt.return (match Uuidm.of_string body with
        | Some stuff -> if session_is_logged_in stuff then (`OK, "You are logged in") else (`Not_found, "WRONG UUID")
        | None -> (`Not_found, "NOT LOGGED IN, FOK OFF"))

  let login body =
    let login_data_list_nth = String.split_on_char ';' body |> List.nth in
    let username = login_data_list_nth 0 in
    let password = login_data_list_nth 1 in
    if check username password then
      Lwt.return (`OK, Printf.sprintf "Du har nå logget inn med id %s" add_new_session)
    else
      Lwt.return (`OK, "Wrong login_info")
end
