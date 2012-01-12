open Game_state
open Util

type successor_fun = player_color -> t -> (pos * t) list

type eval_fun = player_color -> t -> int

type final_value_fun = player_color -> t -> int

let plus_inf  = 32768
let minus_inf = -plus_inf
let default_search_depth = 4

let alphabeta successor eval final state max_player depth =
  let rec go state color depth alpha beta =
    let opp = opponent color in
    match depth with
    | 0 -> (None, eval color state)
    | _ -> 
      let successors = successor color state in
      if null successors
      then 
        if any_valid_moves state opp
        then map_snd (~-) (go state opp (depth-1) (-beta) (-alpha))
        else
        (None, final color state)
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
