open Ocamlbuild_plugin;;

dispatch begin function
  | After_options ->
      Options.ocamldoc := S[A"ocamldoc"; A"-keep-code"; A"-colorize-code"]
  | _ -> ()
end
