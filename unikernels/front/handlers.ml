open Lwt
open Cohttp
open Cohttp_lwt
open Common

module Handlers = struct
  let index_get _body _h =
    Lwt.return (`OK, "alt er fint", [])

  let index_post body _h =
    Cohttp_lwt.Body.to_string body >>= fun body ->
    Lwt.return (`OK, "Got a POST with body: " ^ body, [])

  let create_session id =
    (Common.sess_cookie_key, id) |> Cookie.Set_cookie_hdr.make ~path: "/" ~domain: Common.domain ~http_only: true |> Cookie.Set_cookie_hdr.serialize

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

  let login body h =
    is_logged_in h >>= fun logged_in ->
    if not logged_in then
      let uri = Common.authentication_uri "login" in
      Client.post ~body uri >>= fun (resp, body) ->
      let code = Response.status resp in
      body |> Cohttp_lwt.Body.to_string >>= fun body ->
      let cookie = create_session body in
      if code == `OK then
        Lwt.return (`OK, "You have successfully logged in", [cookie])
      else
        Lwt.return (`OK, "Wrong credentials", [])
    else
      Lwt.return (`OK, "You are already logged in", [])

  let logout _b h =
    let uri = Common.authentication_uri "logout" in
    let sess = extract_session h in
    Client.post ~body: (Cohttp_lwt.Body.of_string sess) uri >>= fun (resp, _body) ->
    let code = Response.status resp in
    let cookie = create_session "invalid" in
    if code == `OK then
      Lwt.return (`OK, "You are now logged out and the session is invalidated", [cookie])
    else
      Lwt.return (`Not_found, "That session is not valid or not logged in", [cookie])

  let secret _b h =
    is_logged_in h >>= fun logged_in ->
    if logged_in then
      Lwt.return (`OK, "You are logged in, the secret is: 42", [])
    else
      Lwt.return (`Not_found, "You were not logged in, you can't get the secret", [])

  let inventory_list _body headers =
    let uri = Common.inventory_uri "list" in
    Client.get ~headers uri >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    match Response.status resp with
    | `OK -> Lwt.return (`OK, body, [])
    | _ -> Lwt.return (`Not_found, body, [])

  let inventory_list_item body headers =
    let uri = Common.inventory_uri "list" in
    Client.post ~body ~headers uri >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    match Response.status resp with
    | `OK -> Lwt.return (`OK, body, [])
    | _ -> Lwt.return (`Not_found, body, [])

  let inventory_sell body headers =
    let uri = Common.inventory_uri "sell" in
    Client.post ~body ~headers uri >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    match Response.status resp with
    | `OK -> Lwt.return (`OK, body, [])
    | _ -> Lwt.return (`Not_found, body, [])

  let inventory_buy body headers =
    let uri = Common.inventory_uri "buy" in
    Client.post ~body ~headers uri >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    match Response.status resp with
    | `OK -> Lwt.return (`OK, body, [])
    | _ -> Lwt.return (`Not_found, body, [])
end
