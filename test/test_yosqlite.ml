open Base
open Yosqlite

let wrap f =
  let db = db_open "test.sqlite" in
  let ret = f db in
  db_close db |> ignore ;
  Stdlib.Sys.remove "test.sqlite" ;
  ret

let fetch_one_animal db =
  let open Sqlite3 in
  let result = ref None in
  let callback row _headers =
    match row with
    | [|Some id; Some name|] ->
        result := Some (id, name) ;
        ()
    | _ -> ()
  in
  let sql = "SELECT * FROM animals LIMIT 1" in
  ignore (exec db sql ~cb:callback) ;
  !result

let create_animals_table db =
  db
  |> execute
       ~sql:
         {| CREATE TABLE animals (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
             ); |}

let insert_cat db =
  db |> execute ~sql:"INSERT INTO animals (name) VALUES ('cat');"

let%test "execute" =
  wrap @@ fun db ->
  db |> create_animals_table ;
  db |> insert_cat ;
  match fetch_one_animal db with
  | Some (_, name) -> String.equal name "cat"
  | None -> false

let%test "fetch" =
  wrap @@ fun db ->
  db |> create_animals_table ;
  db |> insert_cat ;
  let rows = db |> fetch ~sql:"SELECT * FROM animals" in
  let open Yojson.Safe.Util in
  let name = rows |> List.hd_exn |> member "name" |> to_string in
  String.equal name "cat"

let%test "bindings" =
  wrap @@ fun db ->
  db |> create_animals_table ;
  db |> insert_cat ;
  db |> execute ~sql:"INSERT INTO animals(name) VALUES(?)" ~bind:[`String "dog"] ;
  let row = db |> fetch ~sql:"SELECT * FROM animals WHERE name = ?" ~bind:[`String "dog"] |> List.hd_exn in
  let open Yojson.Safe.Util in
  let name = row |> member "name" |> to_string in
  String.equal name "dog"
