open Base

let db_open = Sqlite3.db_open

let db_close = Sqlite3.db_close

type binding =
  [ `Null
  | `Int of int
  | `Float of float
  | `String of string ]

type record = [`Assoc of (string * Yojson.Safe.t) list]

open struct
  let prepare_stmt ~(bind : binding list) ~sql db =
    let bindings = bind in
    let open Sqlite3 in
    let stmt = prepare db sql in
    bindings
    |> List.iteri ~f:(fun i (b : binding) ->
           ( match b with
           | `Null -> bind stmt (i + 1) Data.NULL
           | `Int int -> bind stmt (i + 1) (Data.INT (Int64.of_int int))
           | `Float float -> bind stmt (i + 1) (Data.FLOAT float)
           | `String str -> bind stmt (i + 1) (Data.TEXT str) )
           |> ignore ) ;
    stmt
end

let execute ?(bind : binding list option) ~(sql : string) (db : Sqlite3.db) :
    unit =
  let bindings = bind |> Option.value ~default:[] in
  let stmt = db |> prepare_stmt ~bind:bindings ~sql in
  let open Sqlite3 in
  match step stmt with
  | Rc.DONE -> finalize stmt |> ignore
  | err -> failwith ("Yosqlite execution failed with " ^ Rc.to_string err)

let fetch ?(bind : binding list option) ~(sql : string) (db : Sqlite3.db) :
    Yojson.Safe.t list =
  let bindings = bind |> Option.value ~default:[] in
  let stmt = db |> prepare_stmt ~bind:bindings ~sql in
  let open Sqlite3 in
  let process_row stmt : Yojson.Safe.t option =
    match step stmt with
    | Rc.ROW ->
        let data = row_data stmt in
        let names = row_names stmt in
        let assoc =
          Array.foldi
            names
            ~init:[]
            ~f:(fun i (acc : (string * Yojson.Safe.t) list) name ->
              let entry =
                match Array.get data i with
                | NONE -> (name, `Null)
                | NULL -> (name, `Null)
                | INT int -> (name, `Int (int |> Int.of_int64_exn))
                | FLOAT f -> (name, `Float f)
                | TEXT text -> (name, `String text)
                | BLOB text -> (name, `String text)
              in
              entry :: acc )
        in
        Some (`Assoc assoc)
    | _ -> None
  in
  let rec loop acc =
    match process_row stmt with
    | Some row -> loop (row :: acc)
    | None -> List.rev acc
  in
  loop []
