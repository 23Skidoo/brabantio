(** Alpha-beta pruning. *)

type successor_fun = (Game_state.player_color -> Game_state.t
                      -> (Game_state.pos * Game_state.t) list)

type eval_fun = Game_state.player_color -> Game_state.t -> int

type final_value_fun = Game_state.player_color -> Game_state.t -> int

val plus_inf : int
val minus_inf : int
val default_search_depth : int

val alphabeta : (successor_fun -> eval_fun -> final_value_fun
                 -> Game_state.t -> Game_state.player_color -> int
                 -> Game_state.pos)
