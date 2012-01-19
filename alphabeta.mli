(** Alpha-beta pruning. *)

(** A positive value that is larger than anything returned by the evaluation
    function. *)
val plus_inf : int

(** Zero minus plus_inf. *)
val minus_inf : int

(** Default search depth. *)
val default_search_depth : int

(** Functions that we need from a game state module. See Game_state for an
    example. *)
module type GameStateSig = sig
  type t
  type pos
  type player_color

  (** Return the opponent of this player. *)
  val opponent : player_color -> player_color

  (** Are there any valid moves for this player? *)
  val any_valid_moves : t -> player_color -> bool

  (** Successor function. *)
  val successor : player_color -> t -> (pos * t) list

  (** Evaluation function. *)
  val eval : player_color -> t -> int

  (** Final value function. *)
  val final : player_color -> t -> int

end

(** Given a game state module, produce a custom alpha-beta search function. *)
module Make : functor (T : GameStateSig) ->
sig
  val alphabeta : ?depth:int -> T.t -> T.player_color -> T.pos
end

