let listen_addr = Unix.inet_addr_loopback

let start ~port ?(aof=None) store =
  let sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  Unix.setsockopt sock Unix.SO_REUSEADDR true;
  Unix.bind sock (Unix.ADDR_INET (listen_addr, port));
  Unix.listen sock 128;
  Printf.printf "listening on :%d\n%!" port;
  while true do
    let client, _addr = Unix.accept sock in
    handle_client store aof client
  done

and handle_client store aof fd =
  let ic = Unix.in_channel_of_descr fd in
  let oc = Unix.out_channel_of_descr fd in
  let running = ref true in
  while !running do
    match input_line ic with
    | exception End_of_file ->
      running := false
    | line ->
      let resp = dispatch store aof (Protocol.parse_line line) in
      output_string oc resp;
      flush oc;
      if resp = "" then running := false
  done;
  (try Unix.close fd with Unix.Unix_error _ -> ())

and dispatch store aof = function
  | Protocol.Set (k, v, ttl) ->
    Store.set ?ttl store k v;
    (match aof with Some a -> Aof.log_set a k v ttl | None -> ());
    Protocol.response_ok
  | Protocol.Get k ->
    (match Store.get store k with
     | Some v -> Protocol.response_val v
     | None -> Protocol.response_nil)
  | Protocol.Del k ->
    let ok = Store.del store k in
    if ok then begin
      (match aof with Some a -> Aof.log_del a k | None -> ());
      "+1\n"
    end else "+0\n"
  | Protocol.Ping -> Protocol.response_pong
  | Protocol.Quit -> ""
  | Protocol.Keys ->
    let keys = Store.keys store in
    let buf = Buffer.create 128 in
    Buffer.add_string buf (Printf.sprintf "*%d\n" (List.length keys));
    List.iter (fun k ->
      Buffer.add_string buf (Printf.sprintf "$%d\n%s\n" (String.length k) k)
    ) keys;
    Buffer.contents buf
  | Protocol.Unknown _ -> Protocol.response_err "unknown command"
