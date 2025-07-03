let () =
  let port = ref 6380 in
  let data_dir = ref "/tmp/ocaml-kv" in
  let spec = [
    ("--port", Arg.Set_int port, "port to listen on (default 6380)");
    ("--data", Arg.Set_string data_dir, "data directory");
  ] in
  Arg.parse spec (fun _ -> ()) "ocaml-kv [--port N] [--data DIR]";
  (try Unix.mkdir !data_dir 0o755 with Unix.Unix_error (Unix.EEXIST, _, _) -> ());
  let aof_path = Filename.concat !data_dir "appendonly.log" in
  let store = Kv.Store.create () in
  let aof = Kv.Aof.create aof_path in
  Kv.Aof.replay aof store;
  Kv.Aof.open_log aof;
  Printf.printf "data dir: %s\n%!" !data_dir;
  Kv.Server.start ~port:!port ~aof:(Some aof) store
