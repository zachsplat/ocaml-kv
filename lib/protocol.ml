(* dead simple text protocol. one command per line.
   SET key value
   GET key
   DEL key
   PING
   QUIT
*)

type cmd =
  | Set of string * string
  | Get of string
  | Del of string
  | Ping
  | Quit
  | Unknown of string

let parse_line line =
  let parts = String.split_on_char ' ' (String.trim line) in
  match parts with
  | ["SET"; k; v] -> Set (k, v)
  | "SET" :: k :: rest ->
    (* value might have spaces *)
    Set (k, String.concat " " rest)
  | ["GET"; k] -> Get k
  | ["DEL"; k] -> Del k
  | ["PING"] | ["ping"] -> Ping
  | ["QUIT"] | ["quit"] -> Quit
  | _ -> Unknown line

let response_ok = "+OK\n"
let response_pong = "+PONG\n"
let response_nil = "$-1\n"
let response_err msg = "-ERR " ^ msg ^ "\n"

let response_val v =
  Printf.sprintf "$%d\n%s\n" (String.length v) v
