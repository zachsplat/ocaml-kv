# ocaml-kv

embedded key-value store in OCaml. TCP interface, simple get/set/del.

not meant for production use, just wanted to see how far I could get
with a straightforward design before needing anything fancy.

## build

```
opam install dune
dune build
```

## run

```
dune exec ocaml_kv -- --port 6380
```

then `nc localhost 6380` and type commands:
```
SET foo bar
GET foo
DEL foo
```

## benchmarks

on my machine (nothing scientific):
- SET: ~500k ops/sec
- GET: ~800k ops/sec

the bottleneck is probably the hashtable resizing, haven't profiled yet.
