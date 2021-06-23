(* 
Note modules have same type name "t"
Ocaml doesn't know what to do.
"Illegal Shadowing"

*)
module type Printable = sig
  type t
  val print : Format.formatter -> t -> unit
end
module type Comparable = sig
  type t
  val compare : t -> t -> int
end

module type PrintableComparable_Doesnt_Work = sig
  include Printable
  include Comparable 
end
(* 
But if we use _destructive substitution_ it will work
*)
module type PrintableComparable_Doesnt_Work = sig
  include Printable
  include Comparable with type t := t
end

(* 

Substituting inside a signature

*)
module type S = sig
  type t
  module Sub : sig
    type outer = t
    type t
    val to_outer : t -> outer
  end
end
(* results in: 
module type S =
  sig
    type t
    module Sub : sig type outer = t type t val to_outer : t -> outer end
  end
*)
(* whereas if we do the destructive substitution: *)
module type S = sig
  type t
  module Sub : sig
    type outer := t
    type t
    val to_outer : t -> outer
  end
end

(* We get this:
module type S =
  sig
    type t
    module Sub : sig type t val to_outer : t/1 -> t/2 end
end
*)
