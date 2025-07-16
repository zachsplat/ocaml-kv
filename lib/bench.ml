(* quick and dirty benchmarking *)

let time_it label n f =
  let t0 = Unix.gettimeofday () in
  for _ = 1 to n do
    f ()
  done;
  let elapsed = Unix.gettimeofday () -. t0 in
  Printf.printf "%s: %d ops in %.3fs (%.0f ops/sec)\n%!"
    label n elapsed (float_of_int n /. elapsed)
