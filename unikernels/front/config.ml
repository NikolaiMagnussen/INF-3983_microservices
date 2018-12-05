open Mirage

let main = foreign ~deps:[abstract nocrypto] "Unikernel.Front_service" (random @-> conduit @-> job)

let () =
  let packages = [
    package "uri";
    package "mirage-entropy";
    package "cohttp-mirage";
    package ~ocamlfind:[] "mirage-solo5";
    package ~sublibs:["mirage"] "nocrypto";
  ] in
  register ~packages "front" [main $ default_random $ conduit_direct (generic_stackv4 default_network)]
