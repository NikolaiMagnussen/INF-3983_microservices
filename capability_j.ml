(* Auto-generated from "capability.atd" *)
[@@@ocaml.warning "-27-32-35-39"]

type capability = Capability_t.capability

let write_capability = (
  fun ob x ->
    match x with
      | `None -> Bi_outbuf.add_string ob "<\"None\">"
      | `User x ->
        Bi_outbuf.add_string ob "<\"User\":";
        (
          Yojson.Safe.write_int
        ) ob x;
        Bi_outbuf.add_char ob '>'
      | `Admin x ->
        Bi_outbuf.add_string ob "<\"Admin\":";
        (
          Yojson.Safe.write_int
        ) ob x;
        Bi_outbuf.add_char ob '>'
)
let string_of_capability ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_capability ob x;
  Bi_outbuf.contents ob
let read_capability = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          match Yojson.Safe.read_ident p lb with
            | "None" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              `None
            | "User" ->
              Atdgen_runtime.Oj_run.read_until_field_value p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_int
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              `User x
            | "Admin" ->
              Atdgen_runtime.Oj_run.read_until_field_value p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_int
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              `Admin x
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Double_quote -> (
          match Yojson.Safe.finish_string p lb with
            | "None" ->
              `None
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Square_bracket -> (
          match Atdgen_runtime.Oj_run.read_string p lb with
            | "User" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_int
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              `User x
            | "Admin" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_int
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              `Admin x
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
)
let capability_of_string s =
  read_capability (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
