(** Miscellaneous utility functions *)

(** Function composition: [ f <| g x == f (g x) ] *)
val ( <| ) : ('a -> 'b) -> 'a -> 'b

(** Function composition: [f x |> g == g (f x) ] *)
val ( |> ) : 'a -> ('a -> 'b) -> 'b

(** Is this a whitespace character? *)
val is_whitespace : char -> bool

(** Remove all whitespace characters from a string *)
val trim : string -> string

(** Choose a random element from a list. Assumes that the global random
    generator has been already initialised. *)
val random_elt : 'a list -> 'a

(** True if there is a list element satisfying a given predicate. *)
val any : ('a -> bool) -> 'a list -> bool

(** Useful combinators for use in conjunction with e.g. [sort]: {[List.sort
    (ascending snd) [('A', 2); ('B', 4)]]}*)
val ascending : ('a -> 'b) -> 'a -> 'a -> int
val descending : ('a -> 'b) -> 'a -> 'a -> int

(** Is this list empty? *)
val null : 'a list -> bool

(** Apply the function to the first element of a tuple. *)
val map_fst : ('a -> 'b) -> ('a * 'c) -> ('b * 'c)

(** Apply the function to the second element of a tuple. *)
val map_snd : ('a -> 'b) -> ('c * 'a) -> ('c * 'b)

(** Deep-copy a 2-dimensional array. *)
val copy_matrix : 'a array array -> 'a array array
