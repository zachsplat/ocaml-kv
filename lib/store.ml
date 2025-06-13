type t = {
  mutable data : (string, string) Hashtbl.t;
  mutable count : int;
}

let create () =
  { data = Hashtbl.create 256; count = 0 }

let get t key =
  Hashtbl.find_opt t.data key

let set t key value =
  (match Hashtbl.find_opt t.data key with
   | None -> t.count <- t.count + 1
   | Some _ -> ());
  Hashtbl.replace t.data key value

let del t key =
  if Hashtbl.mem t.data key then begin
    Hashtbl.remove t.data key;
    t.count <- t.count - 1;
    true
  end else
    false

let size t = t.count
