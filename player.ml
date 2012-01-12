(* Strategies for playing. *)

open Game_state
open Util

type player = t -> player_color -> pos

let human state color =   
  let rec go () =
    begin
      print_string <| (string_of_color color) ^ "> ";
      let inp = read_line () |> trim in
      if inp = "q" || inp = "quit"
      then raise Exit
      else
        let pos = pos_of_string inp in
        match pos with
        | Some pos when is_move_valid state color pos -> 
          pos
        | _ -> 
          print_string "Invalid move.\n";
          go ()
    end in
  begin
    Game_state.show state;
    go ();
  end

let random state color = 
  list_all_valid_moves state color |> random_elt

let successor color state = 
  let valid_moves = list_all_valid_moves state color in
  List.map (fun move -> (move, make_move state color move)) valid_moves

let final color state =
  let open Alphabeta in
  let score = current_score state in
  if List.hd score |> fst = color 
  then plus_inf else minus_inf

let alphabeta state color =
  let open Alphabeta in
  let eval color state = 
    let score = current_score state in
    (List.assoc color score) - (List.assoc (opponent color) score)
  in
  alphabeta successor eval final state color default_search_depth

let weights = 
  [|
  [| 120; -20; 20;  5;  5; 20; -20; 120 |];
  [| -20; -40; -5; -5; -5; -5; -40; -20 |];
  [|  20;  -5; 15;  3;  3; 15;  -5;  20 |];
  [|   5;  -5;  3;  3;  3;  3;  -5;   5 |];
  [|   5;  -5;  3;  3;  3;  3;  -5;   5 |];
  [|  20;  -5; 15;  3;  3; 15;  -5;  20 |];
  [| -20; -40; -5; -5; -5; -5; -40; -20 |];
  [| 120; -20; 20;  5;  5; 20; -20; 120 |];
  |]

let alphabeta_smart state color = 
  let open Alphabeta in
  let color_coerced = (color : player_color :> [`White | `Black | `Empty]) in
  let eval (color : player_color) state =
    let res = ref 0 in
    iteri state (fun i j contents ->
      let weight = weights.(i).(j) in
      let res' = match contents with
        | `Empty -> 0
        | colored when colored = color_coerced -> weight
        | _ -> -weight
      in res := !res + res');
    !res
  in
  alphabeta successor eval final state color default_search_depth
