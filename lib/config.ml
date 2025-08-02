type t = {
  port : int;
  data_dir : string;
  max_clients : int;
  aof_enabled : bool;
}

let default = {
  port = 6380;
  data_dir = "/tmp/ocaml-kv";
  max_clients = 128;
  aof_enabled = true;
}

(* TODO: parse from a file or env vars *)
let from_env () =
  let port = try int_of_string (Sys.getenv "KV_PORT") with _ -> default.port in
  let data_dir = try Sys.getenv "KV_DATA" with _ -> default.data_dir in
  { default with port; data_dir }
