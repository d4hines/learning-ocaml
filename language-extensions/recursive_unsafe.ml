module rec M : sig
  val f : unit -> int
end = struct
  let f () = N.x
end

and N : sig
  val x : int
end = struct
  let x = M.f ()
end

(* 

From Craige:
here are all the normal kinds of issues around value recursion: *)
module rec M1 : sig val f : unit -> unit end = struct let f   = M1.f  
 end  (* Not well-founded ⇒ boom. *)
module rec M2 : sig val f : unit -> unit end = struct let f x = M2.f x  end  (* OK. Just a non-terminating function *)
(**
This is the kind of thing that's caught by let rec checking, which is already far from being a simple syntactic check: https://github.com/ocaml/ocaml/blob/trunk/typing/rec_check.ml. Life becomes even more complicated when considering non-pure modules (with top-level side-effects), that may generate fresh types, and may abstract those types from each other -- and AFAIK in practice these features force the implementation to be in terms of backpatching, which opens the door to runtime failures in invalid definitions. (edited) 


*)