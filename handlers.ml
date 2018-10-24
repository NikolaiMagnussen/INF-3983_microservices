open Lwt
open Cohttp
open Cohttp_lwt_unix
open Config

module Handlers = struct
  let index_get _ =
    Lwt.return (`OK, "alt er fint")

  let index_post body =
    Lwt.return (`OK, "Got a POST with body: " ^ body)

  let login b =
    let uri = Config.account_uri "login" in
    Client.post ~body: (Cohttp_lwt.Body.of_string b) uri >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.string_of_status in
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    Lwt.return (`OK, ("Requested something and got back with status: " ^ code ^ " and some body: " ^ body))

  let logout b =
    let uri = Config.account_uri "logout" in
    Client.post ~body: (Cohttp_lwt.Body.of_string b) uri >>= fun (resp, _body) ->
    let code = Response.status resp in
    if code == `OK then
      Lwt.return (`OK, "You are now logged out and the session is invalidated")
    else
      Lwt.return (`Not_found, "That session is not valid or not logged in")

  let secret b =
    let uri = Config.account_uri "is_logged_in" in
    Client.post ~body: (Cohttp_lwt.Body.of_string b) uri >>= fun (resp, _body) ->
    let code = Response.status resp in
    if code == `OK then
      Lwt.return (`OK, "You are logged in, the secret is: 42")
    else
      Lwt.return (`Not_found, "You were not logged in, you can't get the secret")
end
