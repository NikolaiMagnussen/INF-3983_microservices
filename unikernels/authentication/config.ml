open Mirage

let main = foreign ~deps:[abstract nocrypto] "Unikernel.Authentication_service" (random @-> conduit @-> job)

let () =
  let packages = [
    package "biniou";
    package "uuidm";
    package "atdgen";
    package "base64";
    package "digestif.ocaml";
    package "yojson";
    package "uri";
    package "mirage-entropy";
    package "cohttp-mirage";
    package ~ocamlfind:[] "mirage-solo5";
    package ~sublibs:["mirage"] "nocrypto";
  ] in
  register ~packages "authentication" [main $ default_random $ conduit_direct (generic_stackv4 default_network)]
