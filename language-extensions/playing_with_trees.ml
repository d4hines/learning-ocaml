(*
 depth t = go 0 [(0,t)]
 where
  go depth  []    = depth
  go depth (t:ts) = case t of
    (d, Empty)        -> go (max depth d)  ts
    (d, Branch _ l r) -> go (max depth d) ((d+1,l):(d+1,r):ts)
*)

type tree = Empty | Branch of int * tree * tree

let depth t =
  let rec go depth l =
    match (depth, l) with
    | depth, [] -> depth
    | depth, t :: ts -> (
        match t with
        | d, Empty -> go (max depth d) ts
        | d, Branch (_, l, r) ->
            go (max depth d) ((d + 1, l) :: (d + 1, r) :: ts) )
  in
  go 0 [ (0, t) ]

let fold fn a t =
  let rec fold fn a l =
    match l with
    | [] -> a
    | t :: ts -> (
        match t with
        | Empty -> fold fn a ts
        | Branch (x, l, r) ->
            let a = fn x a in
            fold fn a (l :: r :: ts) )
  in
  fold fn a [ t ]

(* let rec my_tree = Branch (6, Empty, my_tree)

let () = print_endline @@ "Max : " ^ string_of_int @@ fold ( + ) 0 my_tree *)

(* let () = print_endline @@ "Normal Depth: "^ string_of_int @@ depth my_tree *)

(*
                     6             0 [(0, *6)]
                    / \            0 [(1, *4), (1, *2)]
                   /   \           1 [(2, *7), (2, *empty), (1, *4), (1, *2)]
                  /     \
                 4      2
                / \    / \
               7
              / \
*)

type node =
  | Int of int
  | String of string
  | Bytes of Bytes.t
  | Prim of string * node list

let foldl : ('a -> 'b list -> 'a) -> 'a -> 'b list -> 'a  = assert false
(* 
given an accumulator
AND all the things you haven't proccessed,
produce one new accumulator AND a new list to proccess
*)

(* given an accumulator and a  *)
let foldl' : ('a -> 'b -> 'a)     -> 'a -> 'b list -> 'a  = List.fold_left



let fold fn a node =
  let rec fold fn a l =
    match l with
    | [] -> a
    | hd :: tl -> (
        let a = fn a hd in
        match hd with
        | Prim (p, args) ->
            fold fn a (args @ tl)
        | node ->
          fold fn a tl)
  in
  fold fn a [ node ]

let cata fnInt fnString fnBytes fnPrim a node =
  let rec fold a node =
    match node with
    | Int x -> 
      fnInt x
    | String x ->
      fnString x 
    | Bytes x ->
      fnBytes x   
    | Prim (x, args) ->
      let folded = List.map (fold a) args in
      fnPrim x folded
  in
  fold a node
let my_micheline =
  Prim
    ( "foo",
      [
        Int 3;
        Prim ("bar", [ Int 2; Prim ("constant", [ String "somehash"; String "somehash2" ]) ]);
        Prim ("constant", [ String "some_other_hash"  ]);
        String "should not appear";
      ] )


(*let () = Printf.printf "%d" (List.length (cata (fun i a -> a) (fun i a -> i :: a) (fun i a -> a) (fun i a -> a) [] my_micheline)) *)
let l = cata
  (fun x -> [])
  (fun x -> [x])
  (fun x -> [])
  (fun x a -> if x = "concat" then (print_endline (String.concat "" (List.concat a)); List.concat a) else List.concat a)
  [] my_micheline

let () = Printf.printf "%d" (List.length l) 
let () = List.iter (fun x -> print_endline @@ "Found hash: " ^ x) l


let get_hash : string list -> node -> string list =
  fun l node -> 
    match node with
  | Prim ("constant", args) -> 
    print_endline "found a constant";
    (match args with
    | [String x] -> x :: l
    | _ -> raise @@ Failure "badly formed")
  | _ ->
    print_endline "Not a constant";
    l


(* foo 1 (bar 2 (constant "somehash")) (constant "someotherhash" "some") *)

(*
let get_all_hashes = fold get_hash [] 

let all_my_hashes = get_all_hashes my_micheline

let () = List.iter (fun x -> print_endline @@ "Found hash: " ^ x) all_my_hashes
*)