type cmd =
  | Set of string * string * float option  (* key, value, optional ttl *)
  | Get of string
  | Del of string
  | Ping
  | Quit
  | Keys
  | Unknown of string

let parse_line line =
  let parts = String.split_on_char ' ' (String.trim line) in
  match parts with
  | ["SET"; k; v] -> Set (k, v, None)
  | ["SET"; k; v; "EX"; ttl_s] ->
    (try Set (k, v, Some (float_of_string ttl_s))
     with _ -> Unknown line)
  | "SET" :: k :: rest ->
    Set (k, String.concat " " rest, None)
  | ["GET"; k] -> Get k
  | ["DEL"; k] -> Del k
  | ["PING"] | ["ping"] -> Ping
  | ["QUIT"] | ["quit"] -> Quit
  | ["KEYS"] | ["keys"] -> Keys
  | _ -> Unknown line

let response_ok = "+OK\n"
let response_pong = "+PONG\n"
let response_nil = "$-1\n"
let response_err msg = "-ERR " ^ msg ^ "\n"

let response_val v =
  Printf.sprintf "$%d\n%s\n" (String.length v) v
