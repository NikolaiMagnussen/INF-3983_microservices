open Mirage

let port =
  let doc = Key.Arg.info ~doc:"What port to listen on." ["port"] in
  Key.(create "port" Arg.(opt int 8000 doc))

let main =
  foreign
    ~deps:[abstract nocrypto]
    ~keys:[Key.abstract port]
    "Unikernel.Front_service" (random @-> conduit @-> job)

let () =
  let packages = [
    package "uri";
    package "mirage-entropy";
    package "cohttp-mirage";
    package ~ocamlfind:[] "mirage-solo5";
    package ~sublibs:["mirage"] "nocrypto";
  ] in
  register ~packages "front" [main $ default_random $ conduit_direct (generic_stackv4 default_network)]
