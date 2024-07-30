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
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   ocaml
   dune
   (sqlite3 (= 5.1.0))
   (base (= v0.17.1))
   (yojson (= 2.2.2))
   (ppx_inline_test (= v0.17.0))
 )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
