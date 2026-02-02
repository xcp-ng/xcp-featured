val apply_edition :
  string -> string -> (string * string) list -> V6_interface.edition_info
(** [apply_edition dbg title xapi_params] returns the edition granted to xapi *)

val get_editions : string -> V6_interface.edition list
(** [get_editions dbg] returns the list of editions available *)

val get_version : 'a -> (string * string) list
(** [get_version dbg] returns a list of version-related string for XCP-ng *)
