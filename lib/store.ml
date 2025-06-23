type entry = {
  value : string;
  mutable expires_at : float option;
}

type t = {
  mutable data : (string, entry) Hashtbl.t;
  mutable count : int;
}

let create () =
  { data = Hashtbl.create 256; count = 0 }

let now () = Unix.gettimeofday ()

let is_expired e =
  match e.expires_at with
  | None -> false
  | Some t -> now () > t

let get t key =
  match Hashtbl.find_opt t.data key with
  | Some e when not (is_expired e) -> Some e.value
  | Some _ ->
    (* lazy cleanup *)
    Hashtbl.remove t.data key;
    t.count <- t.count - 1;
    None
  | None -> None

let set ?ttl t key value =
  let expires_at = match ttl with
    | None -> None
    | Some secs -> Some (now () +. secs)
  in
  (match Hashtbl.find_opt t.data key with
   | None -> t.count <- t.count + 1
   | Some _ -> ());
  Hashtbl.replace t.data key { value; expires_at }

let del t key =
  if Hashtbl.mem t.data key then begin
    Hashtbl.remove t.data key;
    t.count <- t.count - 1;
    true
  end else
    false

let size t = t.count

(* remove all expired keys, called periodically maybe *)
let gc t =
  let to_remove = Hashtbl.fold (fun k e acc ->
    if is_expired e then k :: acc else acc
  ) t.data [] in
  List.iter (fun k ->
    Hashtbl.remove t.data k;
    t.count <- t.count - 1
  ) to_remove
