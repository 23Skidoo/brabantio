(** Game state and associated operations. *)

type player_color = [`White | `Black]

(** The game state type *)
type t

(** Position on a board. *)
type pos

(** Game score. Element 0 is always the winner. *)
type score = (player_color * int) list

(** Parse a position. *)
val pos_of_string : string -> pos option
(** Format a position for printing. *)
val string_of_pos : pos -> string

(** Format the player color. *)
val string_of_color : player_color -> string

(** Color of the opponent of this player. *)
val opponent : player_color -> player_color

(** Initialise a new game state. *)
val create : unit -> t

(** Print out the game state. *)
val show : t -> unit

(** Run a side-effecting function on each cell *)
val iteri : t -> (int -> int -> [`White | `Black | `Empty] -> unit) -> unit

(** What is the current score? *)
val current_score : t -> score

(** Is this move valid? *)
val is_move_valid : t -> player_color -> pos -> bool

(** List all valid moves for this player in a given position. *)
val list_all_valid_moves : t -> player_color -> pos list

(** Are there any valid moves for this player in a given position? *)
val any_valid_moves : t -> player_color -> bool

(** Whose move is next? *)
val next_to_play : t -> player_color -> player_color option

(** Make a move. Updates in-place. Throws an exception when the move is
    invalid. *)
val update : t -> player_color -> pos -> unit

(** An applicative version of [update]. Throws an exception when the move is
    invalid. *)
val make_move : t -> player_color -> pos -> t
