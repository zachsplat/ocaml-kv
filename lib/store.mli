type t
val create : unit -> t
val get : t -> string -> string option
val set : ?ttl:float -> t -> string -> string -> unit
val del : t -> string -> bool
val keys : t -> string list
val size : t -> int
val gc : t -> unit
