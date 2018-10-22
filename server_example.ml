open Lwt
open Cohttp
open Cohttp_lwt_unix

let index_get body =
    (`OK, "alt er fint")

let index_post body =
    (`OK, "jeg fikk en kropp" ^ body)

let router uri meth =
    match uri, meth with
    | "/", `POST -> Some index_post
    | "/", `GET -> Some index_get
    | _ -> None

let handle uri meth headers body =
    let endpoint_handler = router uri meth in
    match endpoint_handler with
    | Some fn -> let (s, b) = fn body in Server.respond_string ~status: s ~body: b ()
    | None -> Server.respond_string ~status: `Not_found ~body: ("404 NOT FOUND: " ^ (Code.string_of_method meth) ^ " to " ^ uri ^ ": " ^ body) ()

let server =
    let callback _conn req body =
        let uri = req |> Request.uri |> Uri.path in
        let meth = req |> Request.meth in
        let headers = req |> Request.headers |> Header.to_string in
        body |> Cohttp_lwt.Body.to_string >>= fun body ->
        handle uri meth headers body
    in
    Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)

