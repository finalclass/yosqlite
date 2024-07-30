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
  db |> db_close |> ignore ;
  Stdlib.Sys.remove "animals.sqlite"
