open Util

type player_color  = [ `White | `Black ]
type cell_contents = [ `White | `Black | `Empty ]

type t     = cell_contents array array
type pos   = Pos of int * int
type score = (player_color * int) list
type dir   = int * int

let all_directions = [ (1,0); (1,1); (0,1); (-1,1);
                       (-1,0); (-1,-1); (0,-1); (1,-1) ]

(* Code assumes that board_size <= 10. With some effort, this restriction can be
   dropped.*)
let board_size = 8
let board_upper_bnd = board_size - 1

let pos_of_string s =
  if (String.length s != 2)
  then None
  else
    let (c0, c1) = (s.[0], s.[1]) in
    let (r0, r1) = (Char.code (Char.lowercase c0) - Char.code 'a',
                    Char.code c1 - Char.code '1') in
    if (0 <= r0) && (r0 < board_size) && (0 <= r1)  && (r1 < board_size)
    then Some (Pos (r1, r0))
    else None

let string_of_pos (Pos (p0, p1)) = Printf.sprintf "%c%c"
  (Char.code 'a' + p1 |> Char.chr)
  (Char.code '1' + p0 |> Char.chr)

let string_of_color = function
  | `Black -> "Black"
  | `White -> "White"

let opponent = function
  | `Black -> `White
  | `White -> `Black


(* Helpers for working with the game state. *)

(* Helper: does this pair of coordinates specify a valid position? *)
let pos_in_bounds (Pos (i,j)) =
  (0 <= i) && (i < board_size)
  && (0 <= j) && (j < board_size)

(* Helper: advance the position in the given direction. *)
let advance (Pos (x,y)) (dx, dy) = Pos (x + dx, y + dy)

(* Helper: return the contents of the cell with the given coordinates. *)
let get_cell_contents (state : t) ((Pos (i,j)) : pos) = state.(i).(j)

(* Helper: set the contents of the cell with the given coordinates. *)
let set_cell_contents (state : t) ((Pos (i,j)) : pos) (cont : cell_contents) =
  state.(i).(j) <- cont

(* Helper: run a side-effecting function on each pair of coordinates. *)
let iter_pos (f : pos -> unit) =
  for i = 0 to board_upper_bnd do
    for j = 0 to board_upper_bnd do
      f (Pos (i,j))
    done
  done

(* Helper: run a side-effecting function on each cell. *)
let iter (state : t) (f : cell_contents -> unit) =
  iter_pos (fun (Pos (i,j)) -> f state.(i).(j))

(* Helper: Go through all pairs of coordinates until a pair satisfying a given
   predicate is found. Had to use functional style because Ocaml has neither
   break nor return. *)
let walk_until (f : pos -> bool) =
  let rec go i j = match (i,j) with
    | (i, j) when f (Pos (i,j)) -> true
    | (i, j) when j = board_upper_bnd ->
      if i = board_upper_bnd
      then false
      else go (i+1) 0
    | (i, j) -> go i (j+1)
  in
  go 0 0

(* Helper: Go in a given direction until an interesting pair of coordinates is
   found or the predicate says us to stop. Returns true in the former case,
   false in the latter. The initial position is not visited. *)
let walk_in_dir_until (pos0 : pos) (walk_dir : dir)
    (f : pos -> [< `Stop | `Found | `Continue]) =
  let rec go p =
    if not (pos_in_bounds p)
    then false
    else
      let res = f p in
      if res = `Stop
      then false
      else
        if res = `Found
        then true
        else go (advance p walk_dir)
  in
  go (advance pos0 walk_dir)

(* Helper: Would this move result in a flip in the given direction? *)
let would_flip (state : t) (color : player_color) (move : pos) (dir : dir) =
  let r = ref 0 in
  (* The funny :> operator is called 'coercion'. Without them, the module
     interface would be more complicated because of type-theoretic reasons. *)
  let color_coerced = (color : player_color :> cell_contents) in
  let f (Pos (i,j)) =
    r := !r + 1;
    match state.(i).(j) with
    | `Empty -> `Stop
    | colored when colored = color_coerced ->
      if !r = 1
      then `Stop
      else `Found
    | _ -> `Continue
  in
  walk_in_dir_until move dir f

(* Helper: Perform a flip in the given position & direction. *)
let do_flip (state : t) (color : player_color) (move : pos) (dir : dir) =
  let color_coerced = (color : player_color :> cell_contents) in
  let f (Pos (i,j)) =
    match state.(i).(j) with
    | `Empty -> `Stop
    | colored when colored = color_coerced -> `Stop
    | _ ->
      state.(i).(j) <- color_coerced;
      `Continue
  in
  let _ = walk_in_dir_until move dir f
  (* Ignore the result. *)
  in ()

(* Helper: Perform all flips in the given position. *)
let flip (state : t) (color : player_color) (move : pos) =
  let dirs = List.filter (would_flip state color move) all_directions in
  assert (not (null dirs));
  set_cell_contents state move (color : player_color :> cell_contents);
  List.iter (do_flip state color move) dirs

(* Externally visible functions for working with game state. *)

let create () =
  let s = Array.make_matrix board_size board_size `Empty in
  (* Here we assume that the board is 8x8. *)
  s.(3).(3) <- `White; s.(4).(4) <- `White;
  s.(3).(4) <- `Black; s.(4).(3) <- `Black; s

let parse s =
  if String.length s != 64
  then None else
    let all_valid = ref true in
    let check_valid = function
      | 'E' | 'X' | 'O' -> ()
      | _ -> all_valid := false
    in
    String.iter check_valid s;
    if not !all_valid then None else
      let state = create () in
      let cell_of_char = function
        | 'E' -> `Empty
        | 'X' -> `Black
        | 'O' -> `White
        | _   -> invalid_arg "parse: invalid char"
      in
      iter_pos (fun (Pos (i,j) as pos) ->
        set_cell_contents state pos (cell_of_char s.[i*8 + j]));
      Some state

let show s =
  let string_of_cell c = match c with
    | `Black -> "X"
    | `White -> "0"
    | `Empty -> " " in
  let print_horizontal_line () =
    print_string "|---";
    for i = 0 to board_upper_bnd do
      print_string "|---";
    done;
    print_endline "|"; in
  begin
    print_horizontal_line ();
    print_string "|---";
    for i = 0 to board_upper_bnd do
      Printf.printf "| %c " ((Char.code 'a') + i |> Char.chr)
    done;
    print_endline "|";
    for i = 0 to board_upper_bnd do
      print_horizontal_line ();
      print_string ("| " ^ (string_of_int (i + 1)) ^ " |");
      for j = 0 to board_upper_bnd do
        print_string (" " ^ string_of_cell s.(i).(j) ^ " |");
      done;
      print_newline ();
    done;
    print_horizontal_line ();
  end

let iteri (state : t) (f : int -> int -> cell_contents -> unit) =
  for i = 0 to board_upper_bnd do
    for j = 0 to board_upper_bnd do
      f i j state.(i).(j)
    done
  done

let current_score state =
  let num_black = ref 0 in
  let num_white = ref 0 in
  let f = function
    | `Black -> num_black := !num_black + 1
    | `White -> num_white := !num_white + 1
    | _ -> ()
  in
  iter state f;
  let res = [(`Black, !num_black); (`White, !num_white)] in
  List.sort (descending snd) res

let is_move_valid state color move =
  get_cell_contents state move = `Empty
  && any (would_flip state color move) all_directions

let list_all_valid_moves state color =
  let r = ref [] in
  let f move =
    if is_move_valid state color move
    then r := move :: !r
    else ()
  in
  iter_pos f;
  !r

let any_valid_moves state color =
  walk_until (fun move -> is_move_valid state color move)

let next_to_play state color =
  if any_valid_moves state color
  then Some color
  else
    let color' = (opponent color) in
    if any_valid_moves state color'
    then Some color'
    else None

let update state (color : player_color) (move : pos) = flip state color move

let make_move state (color : player_color) (move : pos) =
  let state' = copy_matrix state in
  flip state' color move;
  state';
