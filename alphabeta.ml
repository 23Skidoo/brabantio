open Util

let plus_inf  = 32768
let minus_inf = -plus_inf
let default_search_depth = 4

module type GameStateSig = sig
  type t
  type pos
  type player_color

  val opponent : player_color -> player_color
  val any_valid_moves : t -> player_color -> bool
  val successor : player_color -> t -> (pos * t) list
  val eval : player_color -> t -> int
  val final : player_color -> t -> int
end

module Make (T : GameStateSig) =
struct
  let alphabeta (depth : int) (state : T.t) (max_player : T.player_color) =
    let rec go (state : T.t) (color : T.player_color) 
        (depth : int) (alpha : int) (beta : int) =
      let opp = T.opponent color in
      match depth with
      | 0 -> (None, T.eval color state)
      | _ -> 
        let successors = T.successor color state in
        if null successors
        then
          (* NB: Instead of a termination test, we use. *)
          if T.any_valid_moves state opp
          then map_snd (~-) (go state opp (depth-1) (-beta) (-alpha))
          else
            (None, T.final color state)
        else
          let first_succ = List.hd successors in
          let first_move = fst first_succ in
          let (_, first_value) = map_snd (~-) (go (snd first_succ) opp 
                                                 (depth-1) (-beta) (-alpha))
          in
          let go' ((m, v, a) as seed) (move, state) =
            if v >= beta
            then seed
            else let newAlpha = if v > alpha then v else alpha in
                 let (_, bv) = map_snd (~-) (go state opp (depth-1) 
                                               (-beta) (-newAlpha)) 
                 in
                 if bv > v
                 then (Some move, bv, newAlpha)
                 else (m,v,newAlpha)
          in
          let (best_move, best_value, _) = List.fold_left go' 
            (Some first_move, first_value, alpha) (List.tl successors)
          in (best_move, best_value)
    in
    let (move, _) = go state max_player depth minus_inf plus_inf in
    match move with
    | Some m -> m
    | None -> failwith "alphabeta: returned an empty move!"    
end
