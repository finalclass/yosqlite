# Sqlite for OCaml with types from Yojson

There are four functions in the library:

- db_open
- db_close
- execute
- fetch

`db_open` and `db_close` are taken straight from [Sqlite3](https://mmottl.github.io/sqlite3-ocaml/api/sqlite3/Sqlite3/) package. You could even use your own Sqlite3 db handle, these are just added for convenience.

`fetch` is like `execute` but returns list of Yojson **`Assoc**

This is how you would tipically use the package:

``` ocaml
open Base
open Yosqlite

type t =
  { id: int
  ; name: string }
[@@deriving yojson]

let init db =
  db
  |> execute
       ~sql:
         {|
    CREATE TABLE animals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  |}

let insert_animal ~name db =
  db |> execute ~sql:"INSERT INTO animals(name) VALUES(?)" ~bind:[`String name]

let find_animal ~name db =
  db
  |> fetch ~sql:"SELECT * FROM animals WHERE name = ?" ~bind:[`String name]
  |> List.hd_exn
  |> of_yojson
  |> Result.ok_or_failwith

let main =
  let db = db_open "animals.sqlite" in
  db |> init ;
  db |> insert_animal ~name:"cat" ;
  let animal = db |> find_animal ~name:"cat" in
  assert (String.equal animal.name "cat") ;
  db |> db_close |> ignore
```

You can also find couple of examples in the `test` directory.

## API Reference


 ```ocaml
val db_open : ?mode:[ `NO_CREATE | `READONLY ] -> ?uri:bool/2 -> ?memory:bool/2 -> ?mutex:[ `FULL | `NO ] -> ?cache:[ `PRIVATE | `SHARED ] -> ?vfs:string -> string -> Sqlite3.db

val db_close : Sqlite3.db -> bool/2

type binding =
  [ `Null
  | `Int of int
  | `Float of float
  | `String of string ]

val execute: ?bind:(binding list) -> sql:string -> Sqlite3.db -> unit

val fetch : ?bind:(binding list option) -> ~sql:string Sqlite3.db -> Yojson.Safe.t list
 ```
 
 
