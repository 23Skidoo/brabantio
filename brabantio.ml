(* Main file. *)

open Util

(* Option parsing. *)

type player_type = Human of Player.player | AI of Player.player
type mode = Interactive | Batch of int
let usage =
"Usage: brabantio [OPTION]...
An implementation of the game Othello (reversi).\n"

(* Global variables are evil, but these are set only in parse_options, and so
   can be regarded as const. *)
let player_1 = ref (Human Player.human)
let player_2 = ref (AI Player.alphabeta_smart)
let mode = ref Interactive

let player_type_names = ["human"; "random"; "alphabeta"; "alphabeta-smart"]

let player_type_of_string (s : string) = match s with
  | "human" -> Human Player.human
  | "random" -> AI Player.random
  | "alphabeta" -> AI Player.alphabeta
  | "alphabeta-smart" -> AI Player.alphabeta_smart
  | _ -> let player_type_names_string =
           "{ " ^ (String.concat ", " player_type_names) ^ " }"
         in invalid_arg ("Argument must be one of" ^ player_type_names_string)

let player_of_player_type = function
  | Human p -> p
  | AI p -> p

let set_player (which : [< `First | `Second]) (s : string) =
  let p = player_type_of_string s in
  match which with
  | `First -> (player_1 := p)
  | `Second -> (player_2 := p)

let set_mode (i : int) =
  if i > 1 then mode := (Batch i) else ()

let parse_options () =
  let speclist =
    [("-batch", Arg.Int set_mode, "N - Run N games in batch mode");
     ("-player1", Arg.Symbol (player_type_names, set_player `First)
       , " - Player 1 (black; default: human)");
     ("-player2", Arg.Symbol (player_type_names, set_player `Second)
       , " - Player 2 (white; default: random)")]
  in Arg.parse speclist (fun _ -> ()) usage

let sanity_check () =
  let is_human = function
    | Human _ -> true
    | _ -> false
  in
  let is_batch = function
    | Batch _ -> true
    | _ -> false
  in
  if (any is_human [!player_1; !player_2]) && (is_batch !mode)
  then invalid_arg "Batch mode only works when both players are AI!"
  else ()


(* Statistics for the batch mode. *)

module type StatsSig =
sig
  (** A data structure for tracking game stats across several matches. *)
  type t

  (** Create a new stats-tracking data structure. *)
  val create : unit -> t
  (** Update with the result of a game. *)
  val update : t -> Game_state.score -> t
  (** Print the stats out. *)
  val show : t -> int -> unit
end

module Stats : StatsSig = struct
  open Game_state

  (* Player color, (Wins, Total score) *)
  type t = (player_color * (int * int)) list

  let create () = [(`Black, (0, 0)); (`White, (0, 0))]

  let update (stats : t) score =
    let merge_scores (color, score) (wins, total_score) result =
      (color, (wins + result, total_score + score))
    in
    let (winner_color, _) as winner = List.nth score 0 in
    let (loser_color, _) as loser = List.nth score 1 in
    let res = [merge_scores winner (List.assoc winner_color stats) 1;
               merge_scores loser (List.assoc loser_color stats) 0] in
    List.sort (descending snd) res

  let show (stats : t) n =
    let print_player_result (player, (wins, score)) =
      Printf.printf "%s won %d times, total score %d.\n"
        (string_of_color player) wins score
    in
    Printf.printf "Played %d games.\n" n;
    print_player_result (List.nth stats 0);
    print_player_result (List.nth stats 1)

end


(* Welcome message *)

let print_banner () =
  begin
    print_string "brabantio 0.1\n";
    print_string ("Make your move by entering target cell coordinates " ^
                     "(e.g. 'a6').\n");
    print_string "To exit, type 'quit', 'q', or press Ctrl-D(EOF).\n\n";
  end

(* Game loop. *)

let print_result (score : (Game_state.player_color * int) list) =
  let open Game_state in
  print_endline ((List.hd score |> fst |> string_of_color) ^ " won!");
  print_endline "Final score:";
  let f (color, points) =
    let msg = (string_of_color color) ^ " : " ^ (string_of_int points) in
    print_endline ("    " ^ msg)
  in
  List.iter f score

let game_loop (player_1 : Player.player) (player_2 : Player.player)
    (verbosity : [< `Silent | `Verbose]) =
  let open Game_state in
  let is_verbose = verbosity = `Verbose in
  let players = [(`Black, player_1); (`White, player_2)] in
  let state = create () in
  let rec go color =
    let color' = next_to_play state color in
    match color' with
    | None ->
      let score = current_score state in
      if is_verbose then
        begin show state; print_result score end;
      score
    | Some c ->
      let player = List.assoc c players in
      let move = player state c in
      update state c move;
      if is_verbose then
        print_endline (string_of_color c ^ ": " ^ string_of_pos move);
      go (opponent c)
  in go `Black

(** Run the game loop either interactively, or in a batch mode. *)
let run_game () =
  let p1 = player_of_player_type !player_1 in
  let p2 = player_of_player_type !player_2 in
  match !mode with
  | Interactive ->
    print_banner ();
    let _ = game_loop p1 p2 `Verbose in ()
  | Batch n ->
    let stats = ref (Stats.create ()) in
    for i = 1 to n do
      let score = game_loop p1 p2 `Silent in
      stats := Stats.update !stats score
    done;
    Stats.show !stats n

(* Program entry point. *)

let () =
  try
    Random.self_init ();
    parse_options ();
    sanity_check ();
    run_game ()
  with
  | Exit | End_of_file -> exit 0
  | (Invalid_argument s) | (Failure s) -> prerr_endline ("Error: " ^ s)
