let () =
  let s = Kv.Store.create () in

  (* basic set/get *)
  Kv.Store.set s "hello" "world";
  assert (Kv.Store.get s "hello" = Some "world");
  assert (Kv.Store.get s "nope" = None);

  (* overwrite *)
  Kv.Store.set s "hello" "updated";
  assert (Kv.Store.get s "hello" = Some "updated");
  assert (Kv.Store.size s = 1);

  (* delete *)
  assert (Kv.Store.del s "hello" = true);
  assert (Kv.Store.get s "hello" = None);
  assert (Kv.Store.del s "hello" = false);
  assert (Kv.Store.size s = 0);

  (* ttl - kinda hard to test without sleeping *)
  Kv.Store.set ~ttl:0.001 s "tmp" "val";
  Unix.sleepf 0.01;
  assert (Kv.Store.get s "tmp" = None);

  Printf.printf "all tests passed\n"
