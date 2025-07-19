let () =
  let s = Kv.Store.create () in
  let n = 100_000 in

  Kv.Bench.time_it "set" n (fun () ->
    let k = "key" ^ string_of_int (Random.int n) in
    Kv.Store.set s k "value"
  );

  Kv.Bench.time_it "get" n (fun () ->
    let k = "key" ^ string_of_int (Random.int n) in
    ignore (Kv.Store.get s k)
  );

  Printf.printf "store size: %d\n" (Kv.Store.size s)
