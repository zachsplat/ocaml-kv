let listen_addr = Unix.inet_addr_loopback

let start ~port store =
  let sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  Unix.setsockopt sock Unix.SO_REUSEADDR true;
  Unix.bind sock (Unix.ADDR_INET (listen_addr, port));
  Unix.listen sock 128;
  Printf.printf "listening on :%d\n%!" port;
  while true do
    let client, _addr = Unix.accept sock in
    (* just handle inline for now, no threading *)
    handle_client store client
  done

and handle_client store fd =
  let ic = Unix.in_channel_of_descr fd in
  let oc = Unix.out_channel_of_descr fd in
  let running = ref true in
  while !running do
    match input_line ic with
    | exception End_of_file ->
      running := false
    | line ->
      let resp = dispatch store (Protocol.parse_line line) in
      output_string oc resp;
      flush oc;
      if resp = "" then running := false
  done;
  Unix.close fd

and dispatch store = function
  | Protocol.Set (k, v) ->
    Store.set store k v;
    Protocol.response_ok
  | Protocol.Get k ->
    (match Store.get store k with
     | Some v -> Protocol.response_val v
     | None -> Protocol.response_nil)
  | Protocol.Del k ->
    if Store.del store k then "+1\n"
    else "+0\n"
  | Protocol.Ping -> Protocol.response_pong
  | Protocol.Quit -> ""
  | Protocol.Unknown _ -> Protocol.response_err "unknown command"
