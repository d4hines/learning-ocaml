print_endline "hello world"

let rec x = 1 :: y and y = 2 :: x

let rec foo x = match x with
| [] -> assert false
| 1 :: rest -> print_endline "hello 1"; foo rest
| 2 :: rest -> print_endline "hello 2"; foo rest
| _ -> assert false

(* Loops forever *)
let _ = foo x
