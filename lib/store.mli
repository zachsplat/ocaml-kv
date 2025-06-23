type t
val create : unit -> t
val get : t -> string -> string option
val set : ?ttl:float -> t -> string -> string -> unit
val del : t -> string -> bool
val size : t -> int
val gc : t -> unit
