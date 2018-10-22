open Lwt
open Cohttp
open Cohttp_lwt_unix

module Handlers = struct
  let index_get _ =
    Lwt.return (`OK, "alt er fint")

  let index_post body =
    Lwt.return (`OK, "Got a POST with body: " ^ body)


  let body =
    Client.get (Uri.of_string "https://www.reddit.com/") >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.string_of_status in
    body |> Cohttp_lwt.Body.to_string >>= fun body ->
    Lwt.return (code, body)

  let stuff _ =
    body >>= fun (c, b) ->
    Lwt.return (`OK, ("Requested something and got back with status: " ^ c ^ " and some body: " ^ b))
end
