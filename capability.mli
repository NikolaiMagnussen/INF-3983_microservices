(* Auto-generated from "capability.atd" *)
              [@@@ocaml.warning "-27-32-35-39"]

type capability = [ `None | `User of int | `Admin of int ]

(* Writers for type capability *)

val capability_tag : Bi_io.node_tag
  (** Tag used by the writers for type {!capability}.
      Readers may support more than just this tag. *)

val write_untagged_capability :
  Bi_outbuf.t -> capability -> unit
  (** Output an untagged biniou value of type {!capability}. *)

val write_capability :
  Bi_outbuf.t -> capability -> unit
  (** Output a biniou value of type {!capability}. *)

val string_of_capability :
  ?len:int -> capability -> string
  (** Serialize a value of type {!capability} into
      a biniou string. *)

(* Readers for type capability *)

val get_capability_reader :
  Bi_io.node_tag -> (Bi_inbuf.t -> capability)
  (** Return a function that reads an untagged
      biniou value of type {!capability}. *)

val read_capability :
  Bi_inbuf.t -> capability
  (** Input a tagged biniou value of type {!capability}. *)

val capability_of_string :
  ?pos:int -> string -> capability
  (** Deserialize a biniou value of type {!capability}.
      @param pos specifies the position where
                 reading starts. Default: 0. *)


