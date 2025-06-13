type t
val create : unit -> t
val get : t -> string -> string option
val set : t -> string -> string -> unit
val del : t -> string -> bool
val size : t -> int
