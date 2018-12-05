(* Auto-generated from "capability.atd" *)
[@@@ocaml.warning "-27-32-35-39"]

type capability = Capability_t.capability

val write_capability :
  Bi_outbuf.t -> capability -> unit
  (** Output a JSON value of type {!capability}. *)

val string_of_capability :
  ?len:int -> capability -> string
  (** Serialize a value of type {!capability}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_capability :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> capability
  (** Input JSON data of type {!capability}. *)

val capability_of_string :
  string -> capability
  (** Deserialize JSON data of type {!capability}. *)

