(* append-only file for persistence. write every mutation as a line.
   on startup we replay the whole thing. obviously this gets huge
   but whatever, compaction is a TODO *)

type t = {
  mutable oc : out_channel option;
  path : string;
}

let create path =
  { oc = None; path }

let open_log t =
  let oc = open_out_gen [Open_creat; Open_append; Open_wronly] 0o644 t.path in
  t.oc <- Some oc

let append t line =
  match t.oc with
  | Some oc ->
    output_string oc (line ^ "\n");
    flush oc
  | None -> () (* silently drop if not open, not great *)

let log_set t key value ttl =
  let ttl_part = match ttl with
    | None -> ""
    | Some s -> Printf.sprintf " EX %f" s
  in
  append t (Printf.sprintf "SET %s %s%s" key value ttl_part)

let log_del t key =
  append t (Printf.sprintf "DEL %s" key)

let replay t store =
  if Sys.file_exists t.path then begin
    let ic = open_in t.path in
    let n = ref 0 in
    (try while true do
      let line = input_line ic in
      let parts = String.split_on_char ' ' line in
      (match parts with
       | ["SET"; k; v] -> Store.set store k v
       | ["SET"; k; v; "EX"; _ttl] ->
         (* don't restore TTL from old logs, too messy *)
         Store.set store k v
       | ["DEL"; k] -> ignore (Store.del store k)
       | _ -> ());
      incr n
    done with End_of_file -> ());
    close_in ic;
    Printf.printf "replayed %d entries from %s\n%!" !n t.path
  end

let close t =
  match t.oc with
  | Some oc -> close_out oc; t.oc <- None
  | None -> ()
