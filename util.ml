
let (<|) f x = f x

let (|>) x f = f x

let is_whitespace c = c = ' ' || c = '\n' || c = '\t' || c = '\r'

(* No String.map in the standard library :-( *)
let str_map f s = 
  let len = String.length s in
  begin
    for i = 0 to (len-1) do
      let c = s.[i] in
      f c
    done;
  end

let trim s =
  let buf = Buffer.create (String.length s) in
  let f c = if not (is_whitespace c) then Buffer.add_char buf c in
  begin
    str_map f s; 
    Buffer.contents buf;
  end

let random_elt l = 
  let len = List.length l in
  let idx = Random.int len in
  List.nth l idx

let any p l =
  let rec go = function
    | [] -> false
    | (x::xs) -> p x || go xs
  in go l

let ascending p x y = compare (p x) (p y)
let descending p x y = compare (p y) (p x)

let null = function
  | [] -> true
  | _ -> false

let map_fst f (a, b) = (f a, b)
let map_snd f (a, b) = (a, f b)

let copy_matrix m =
  let l = Array.length m in
  if l = 0 then m else
    let result = Array.make l m.(0) in
    for i = 0 to l - 1 do
      result.(i) <- Array.copy m.(i) 
    done;
    result
