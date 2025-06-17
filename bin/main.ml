let () =
  let port = ref 6380 in
  let spec = [
    ("--port", Arg.Set_int port, "port to listen on (default 6380)");
  ] in
  Arg.parse spec (fun _ -> ()) "ocaml-kv [--port N]";
  let store = Kv.Store.create () in
  Kv.Server.start ~port:!port store
