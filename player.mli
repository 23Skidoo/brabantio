(** Strategies for playing. *)

(** A player (AI or human) is represented as a function from a game state to a
    board position. *)
type player = Game_state.t -> Game_state.player_color -> Game_state.pos

(** Let the human player decide. *)
val human : player

(** Choose a random valid position. *)
val random : player

(** Use alpha-beta search. *)
val alphabeta : player

(** Use alpha-beta search with a smarter heuristic. *)
val alphabeta_smart : player

(** Smart alpha-beta search that allows to set search depth. *)
val alphabeta_smart_depth : ?depth:int -> Game_state.t
  -> Game_state.player_color -> Game_state.pos
