(lang dune 3.16)

(name yosqlite)

(generate_opam_files true)

(source
 (github finalclass/yosqlite))

(authors "Szymon Wygnański")

(maintainers "Szymon Wygnański")

(license MIT)

(documentation https://github.com/finalclass/yosqlite)

(package
 (name yosqlite)
 (synopsis "Simple Sqlite3. Yojson+Sqlite3 amalgamation")
 (description "Convenience functions for working with Sqlite3 library")
 (depends
   ocaml
   dune
   (sqlite3 (= 5.1.0))
   (base (= v0.17.1))
   (yojson (= 2.2.2))
   (ppx_inline_test (= v0.17.0))
   (ppx_deriving_yojson (= 3.8.0))
 )
 (tags
  (sqlite3 sqlite database)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
