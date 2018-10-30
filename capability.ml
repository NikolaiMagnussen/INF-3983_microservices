(* Auto-generated from "capability.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type capability = [ `None | `User of int | `Admin of int ]

let capability_tag = Bi_io.variant_tag
let write_untagged_capability = (
  fun ob x ->
    match x with
      | `None -> Bi_outbuf.add_char4 ob '3' '\227' '>' '\216'
      | `User x ->
        Bi_outbuf.add_char4 ob '\184' '\134' '\190' 'k';
        (
          Bi_io.write_svint
        ) ob x
      | `Admin x ->
        Bi_outbuf.add_char4 ob '\175' 'x' '\028' 'o';
        (
          Bi_io.write_svint
        ) ob x
)
let write_capability ob x =
  Bi_io.write_tag ob Bi_io.variant_tag;
  write_untagged_capability ob x
let string_of_capability ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_capability ob x;
  Bi_outbuf.contents ob
let get_capability_reader = (
  fun tag ->
    if tag <> 23 then Atdgen_runtime.Ob_run.read_error () else
      fun ib ->
        Bi_io.read_hashtag ib (fun ib h has_arg ->
          match h, has_arg with
            | 870530776, false -> `None
            | 948354667, true -> (`User (
                (
                  Atdgen_runtime.Ob_run.read_int
                ) ib
              ))
            | 796400751, true -> (`Admin (
                (
                  Atdgen_runtime.Ob_run.read_int
                ) ib
              ))
            | _ -> Atdgen_runtime.Ob_run.unsupported_variant h has_arg
        )
)
let read_capability = (
  fun ib ->
    if Bi_io.read_tag ib <> 23 then Atdgen_runtime.Ob_run.read_error_at ib;
    Bi_io.read_hashtag ib (fun ib h has_arg ->
      match h, has_arg with
        | 870530776, false -> `None
        | 948354667, true -> (`User (
            (
              Atdgen_runtime.Ob_run.read_int
            ) ib
          ))
        | 796400751, true -> (`Admin (
            (
              Atdgen_runtime.Ob_run.read_int
            ) ib
          ))
        | _ -> Atdgen_runtime.Ob_run.unsupported_variant h has_arg
    )
)
let capability_of_string ?pos s =
  read_capability (Bi_inbuf.from_string ?pos s)
