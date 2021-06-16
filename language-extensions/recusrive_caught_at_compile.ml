module rec M : sig
  val x : int
end = struct
  let x = N.y
end

and N : sig
  val x : int

  val y : int
end = struct
  let x = M.x

  let y = 0
end
